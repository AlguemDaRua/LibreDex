import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/network/api_client.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_repository.g.dart';

@riverpod
class SyncProgress extends _$SyncProgress {
  @override
  double build() => 0.0;

  void setProgress(double value) {
    state = value;
  }
}

@riverpod
SyncRepository syncRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final progress = ref.watch(syncProgressProvider.notifier);
  return SyncRepository(db: db, progressNotifier: progress);
}

class SyncRepository {
  final AppDatabase db;
  final SyncProgress progressNotifier;

  SyncRepository({required this.db, required this.progressNotifier});

  int _extractIdFromUrl(String url) {
    try {
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final parts = cleanUrl.split('/');
      return int.parse(parts.last);
    } catch (_) {
      return url.hashCode;
    }
  }

  /// Perform a mass 100% Offline-First synchronization of Generation 1 (151 Pokémon).
  /// Batches insertions, caches all Moves, Abilities and relationships inside Drift.
  Future<void> performFullInitialSync() async {
    try {
      progressNotifier.setProgress(0.01);

      // 1. Fetch 151 Kanto Pokémon base index
      final indexResponse = await ApiClient.get('pokemon?limit=151');
      final results = indexResponse.data['results'] as List<dynamic>;

      final List<Map<String, dynamic>> pokemonBaseList = results.map((r) {
        return {
          'name': r['name'] as String,
          'url': r['url'] as String,
        };
      }).toList();

      progressNotifier.setProgress(0.05);

      final List<Pokemon> pokemonsToInsert = [];
      final List<Map<String, dynamic>> allAbilitiesToFetch = [];
      final List<Map<String, dynamic>> allMovesToFetch = [];

      // 2. Fetch Pokémon details in chunk size of 20
      const int pokemonChunkSize = 20;
      int completedPokemons = 0;

      for (int i = 0; i < pokemonBaseList.length; i += pokemonChunkSize) {
        final chunk = pokemonBaseList.sublist(
          i,
          i + pokemonChunkSize > pokemonBaseList.length ? pokemonBaseList.length : i + pokemonChunkSize,
        );

        await Future.wait(chunk.map((p) async {
          try {
            final name = p['name'];
            final res = await ApiClient.get('pokemon/$name');
            final data = res.data;

            final int id = data['id'];
            final String pokeName = data['name'];
            final List<dynamic> types = data['types'];
            final String type1 = types[0]['type']['name'];
            final String? type2 = types.length > 1 ? types[1]['type']['name'] : null;

            final List<dynamic> stats = data['stats'];
            final int baseHp = stats[0]['base_stat'];
            final int baseAtk = stats[1]['base_stat'];
            final int baseDef = stats[2]['base_stat'];
            final int baseSpAtk = stats[3]['base_stat'];
            final int baseSpDef = stats[4]['base_stat'];
            final int baseSpd = stats[5]['base_stat'];

            final String spriteUrl = data['sprites']['other']['official-artwork']['front_default'] 
                ?? data['sprites']['front_default'] 
                ?? '';
            final String shinySpriteUrl = data['sprites']['other']['official-artwork']['front_shiny'] 
                ?? data['sprites']['front_shiny'] 
                ?? '';

            pokemonsToInsert.add(Pokemon(
              id: id,
              name: pokeName[0].toUpperCase() + pokeName.substring(1),
              form: 'normal',
              type1: type1,
              type2: type2,
              baseHp: baseHp,
              baseAtk: baseAtk,
              baseDef: baseDef,
              baseSpAtk: baseSpAtk,
              baseSpDef: baseSpDef,
              baseSpd: baseSpd,
              isLegendary: false,
              isMythical: false,
              isParadox: false,
              isUltraBeast: false,
              spriteUrl: spriteUrl,
              shinySpriteUrl: shinySpriteUrl,
            ));

            // Abilities
            final List<dynamic> abilities = data['abilities'] ?? [];
            for (final item in abilities) {
              final abilityData = item['ability'];
              final String abName = abilityData['name'];
              final String abUrl = abilityData['url'];
              final int abId = _extractIdFromUrl(abUrl);
              final bool isHidden = item['is_hidden'] ?? false;

              allAbilitiesToFetch.add({
                'pokemonId': id,
                'abilityId': abId,
                'name': abName,
                'isHidden': isHidden,
              });
            }

            // Moves
            final List<dynamic> moves = data['moves'] ?? [];
            for (final item in moves) {
              final moveData = item['move'];
              final String mvName = moveData['name'];
              final String mvUrl = moveData['url'];
              final int mvId = _extractIdFromUrl(mvUrl);

              final List<dynamic> versionDetails = item['version_group_details'] ?? [];
              if (versionDetails.isEmpty) continue;

              final detail = versionDetails.first;
              final int levelLearned = detail['level_learned_at'] ?? 0;
              final String rawMethod = detail['move_learn_method']['name'] ?? 'level-up';

              String method = 'level';
              if (rawMethod == 'machine') {
                method = 'tm';
              } else if (rawMethod == 'egg') {
                method = 'egg';
              } else if (rawMethod == 'tutor') {
                method = 'tutor';
              }

              allMovesToFetch.add({
                'pokemonId': id,
                'moveId': mvId,
                'name': mvName,
                'learnMethod': method,
                'levelLearned': levelLearned,
              });
            }
          } catch (_) {}
          completedPokemons++;
          // Progress: 0.05 to 0.40
          progressNotifier.setProgress(0.05 + (completedPokemons / pokemonBaseList.length) * 0.35);
        }));
      }

      // Write basic Pokémons to database atomically
      await db.transaction(() async {
        for (final p in pokemonsToInsert) {
          await db.into(db.pokemonTable).insertOnConflictUpdate(p);
        }
      });

      progressNotifier.setProgress(0.40);

      // 3. Sync Unique Abilities (0.40 to 0.60)
      final Set<int> uniqueAbilityIds = allAbilitiesToFetch.map((a) => a['abilityId'] as int).toSet();
      final List<Ability> abilitiesToInsert = [];
      int completedAbilities = 0;

      const int abilityChunkSize = 25;
      final List<int> uniqueAbilityList = uniqueAbilityIds.toList();

      for (int i = 0; i < uniqueAbilityList.length; i += abilityChunkSize) {
        final chunk = uniqueAbilityList.sublist(
          i,
          i + abilityChunkSize > uniqueAbilityList.length ? uniqueAbilityList.length : i + abilityChunkSize,
        );

        await Future.wait(chunk.map((abId) async {
          try {
            final res = await ApiClient.get('ability/$abId');
            final data = res.data;
            final String rawName = data['name'];

            final effectEntries = data['effect_entries'] as List<dynamic>? ?? [];
            String description = 'No description available.';
            for (final entry in effectEntries) {
              if (entry['language']['name'] == 'en') {
                description = entry['short_effect'] ?? entry['effect'] ?? description;
                break;
              }
            }
            if (description == 'No description available.') {
              final flavorTexts = data['flavor_text_entries'] as List<dynamic>? ?? [];
              for (final entry in flavorTexts) {
                if (entry['language']['name'] == 'en') {
                  description = entry['flavor_text'] ?? description;
                  break;
                }
              }
            }

            final cleanName = rawName.replaceAll('-', ' ').split(' ').map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1);
            }).join(' ');

            abilitiesToInsert.add(Ability(
              id: abId,
              name: cleanName,
              description: description,
            ));
          } catch (_) {}
          completedAbilities++;
          // Progress: 0.40 to 0.60
          progressNotifier.setProgress(0.40 + (completedAbilities / uniqueAbilityList.length) * 0.20);
        }));
      }

      // Write Abilities and their PokemonAbility relations
      await db.transaction(() async {
        for (final a in abilitiesToInsert) {
          await db.into(db.abilityTable).insertOnConflictUpdate(a);
        }
        for (final item in allAbilitiesToFetch) {
          await db.into(db.pokemonAbilitiesTable).insertOnConflictUpdate(PokemonAbility(
            pokemonId: item['pokemonId'],
            abilityId: item['abilityId'],
            isHidden: item['isHidden'],
          ));
        }
      });

      progressNotifier.setProgress(0.60);

      // 4. Sync Unique Moves (0.60 to 1.0)
      final Set<int> uniqueMoveIds = allMovesToFetch.map((m) => m['moveId'] as int).toSet();
      final List<Move> movesToInsert = [];
      int completedMoves = 0;

      const int moveChunkSize = 25;
      final List<int> uniqueMoveList = uniqueMoveIds.toList();

      for (int i = 0; i < uniqueMoveList.length; i += moveChunkSize) {
        final chunk = uniqueMoveList.sublist(
          i,
          i + moveChunkSize > uniqueMoveList.length ? uniqueMoveList.length : i + moveChunkSize,
        );

        await Future.wait(chunk.map((mvId) async {
          try {
            final res = await ApiClient.get('move/$mvId');
            final data = res.data;
            final String rawName = data['name'];

            final int pp = data['pp'] ?? 15;
            final int? power = data['power'];
            final int? accuracy = data['accuracy'];
            final String type = data['type']['name'] ?? 'normal';
            final String damageClass = data['damage_class']['name'] ?? 'physical';

            final effectEntries = data['effect_entries'] as List<dynamic>? ?? [];
            String description = 'No description available.';
            for (final entry in effectEntries) {
              if (entry['language']['name'] == 'en') {
                description = entry['short_effect'] ?? entry['effect'] ?? description;
                break;
              }
            }
            if (description == 'No description available.') {
              final flavorTexts = data['flavor_text_entries'] as List<dynamic>? ?? [];
              for (final entry in flavorTexts) {
                if (entry['language']['name'] == 'en') {
                  description = entry['flavor_text'] ?? description;
                  break;
                }
              }
            }

            final cleanName = rawName.replaceAll('-', ' ').split(' ').map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1);
            }).join(' ');

            movesToInsert.add(Move(
              id: mvId,
              name: cleanName,
              type: type,
              power: power,
              accuracy: accuracy,
              pp: pp,
              damageClass: damageClass,
              description: description,
            ));
          } catch (_) {}
          completedMoves++;
          // Progress: 0.60 to 0.95
          progressNotifier.setProgress(0.60 + (completedMoves / uniqueMoveList.length) * 0.35);
        }));
      }

      // Write Moves and relations inside SQLite Transaction
      await db.transaction(() async {
        for (final m in movesToInsert) {
          await db.into(db.moveTable).insertOnConflictUpdate(m);
        }
        for (final item in allMovesToFetch) {
          await db.into(db.pokemonMovesTable).insertOnConflictUpdate(PokemonMove(
            pokemonId: item['pokemonId'],
            moveId: item['moveId'],
            learnMethod: item['learnMethod'],
            levelLearned: item['levelLearned'],
          ));
        }
      });

      progressNotifier.setProgress(1.0);
    } catch (_) {
      progressNotifier.setProgress(1.0);
    }
  }
}

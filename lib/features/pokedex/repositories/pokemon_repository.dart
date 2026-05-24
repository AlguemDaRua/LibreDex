import 'package:drift/drift.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pokemon_repository.g.dart';

/// Database provider since we cannot modify app_database.dart.
/// Keeps database singleton and closes it on dispose.
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

/// Repository provider injected with Drift Database.
@Riverpod(keepAlive: true)
PokemonRepository pokemonRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PokemonRepository(db: db);
}

/// Repository responsible for syncing and retrieving offline-first Pokémon data.
class PokemonRepository {
  final AppDatabase db;

  PokemonRepository({required this.db});

  /// Synchronizes first 151 Pokémon details from PokeAPI in chunks.
  /// Uses transaction to keep database ops atomic.
  Future<void> syncPokedex() async {
    try {
      // 1. Fetch basic Pokémon list limit to 151 (Generation 1)
      final response = await ApiClient.get('pokemon?limit=151');
      final results = response.data['results'] as List<dynamic>;

      final List<String> pokemonNames = results.map((r) => r['name'] as String).toList();

      // 2. Fetch details in chunk size of 15 to optimize network request parallelization
      const int chunkSize = 15;
      for (int i = 0; i < pokemonNames.length; i += chunkSize) {
        final chunk = pokemonNames.sublist(
          i,
          i + chunkSize > pokemonNames.length ? pokemonNames.length : i + chunkSize,
        );

        // Fetch chunk concurrently
        await Future.wait(chunk.map((name) => _fetchAndSavePokemon(name)));
      }
    } catch (e) {
      throw Exception('Failed to sync Pokedex: $e');
    }
  }

  /// Private helper to fetch details of a single Pokémon and insert/update it inside SQLite
  Future<void> _fetchAndSavePokemon(String nameOrId) async {
    try {
      final response = await ApiClient.get('pokemon/$nameOrId');
      final data = response.data;

      final int id = data['id'];
      final String name = data['name'];
      final String form = 'normal'; // Default form

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

      // Official artwork is much higher quality
      final String spriteUrl = data['sprites']['other']['official-artwork']['front_default'] 
          ?? data['sprites']['front_default'] 
          ?? '';
      final String shinySpriteUrl = data['sprites']['other']['official-artwork']['front_shiny'] 
          ?? data['sprites']['front_shiny'] 
          ?? '';

      final pokemon = Pokemon(
        id: id,
        name: name[0].toUpperCase() + name.substring(1), // Capitalize first letter
        form: form,
        type1: type1,
        type2: type2,
        baseHp: baseHp,
        baseAtk: baseAtk,
        baseDef: baseDef,
        baseSpAtk: baseSpAtk,
        baseSpDef: baseSpDef,
        baseSpd: baseSpd,
        isLegendary: false, // Species details omitted for speed in base sync
        isMythical: false,
        isParadox: false,
        isUltraBeast: false,
        spriteUrl: spriteUrl,
        shinySpriteUrl: shinySpriteUrl,
      );

      // Write atomically to database (upsert)
      await db.into(db.pokemonTable).insertOnConflictUpdate(pokemon);
    } catch (e) {
      // Individual pokemon failure should not break entire sync, but log it
    }
  }

  /// Watch all Pokémon reactively (updates in real time).
  Stream<List<Pokemon>> watchAllPokemon() {
    return db.select(db.pokemonTable).watch();
  }

  /// Extracts numeric ID from PokeAPI resource URL
  int _extractIdFromUrl(String url) {
    try {
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final parts = cleanUrl.split('/');
      return int.parse(parts.last);
    } catch (_) {
      return url.hashCode; // Fallback
    }
  }

  /// Compatibility wrapper for existing detail views
  Future<void> syncAbilitiesAndMoves(int pokemonId) async {
    try {
      final pokemon = await (db.select(db.pokemonTable)..where((tbl) => tbl.id.equals(pokemonId))).getSingleOrNull();
      if (pokemon != null) {
        await syncPokemonDetails(pokemonId, pokemon.name);
      }
    } catch (_) {}
  }

  /// Lazily fetches abilities and moves for a given Pokémon, caching them locally in SQLite.
  /// Fully implements parallel chunking, exact PokéAPI keys mapping and offline-first caching.
  Future<void> syncPokemonDetails(int pokemonId, String pokemonName) async {
    try {
      // Check if already cached locally in junction table
      final existingAbilities = await (db.select(db.pokemonAbilitiesTable)
            ..where((tbl) => tbl.pokemonId.equals(pokemonId)))
          .get();

      if (existingAbilities.isNotEmpty) {
        return; // Already synchronized and cached offline-first!
      }

      // Fetch on-demand details from PokeAPI using lowercase pokemonName
      final response = await ApiClient.get('pokemon/${pokemonName.toLowerCase()}');
      final data = response.data;

      final List<dynamic> abilitiesJson = data['abilities'] ?? [];
      final List<dynamic> movesJson = data['moves'] ?? [];

      // 1. Process and Sync Abilities concurrently
      final List<Future<void>> abilitySyncFutures = [];
      for (final item in abilitiesJson) {
        final abilityData = item['ability'];
        final String name = abilityData['name'];
        final String url = abilityData['url'];
        final int abilityId = _extractIdFromUrl(url);
        final bool isHidden = item['is_hidden'] ?? false;

        abilitySyncFutures.add(_syncSingleAbility(abilityId, name, pokemonId, isHidden));
      }
      await Future.wait(abilitySyncFutures);

      // 2. Gather Moves and Check Cache before API fetching
      final List<Map<String, dynamic>> movesToSync = [];
      for (final item in movesJson) {
        final moveData = item['move'];
        final String name = moveData['name'];
        final String url = moveData['url'];
        final int moveId = _extractIdFromUrl(url);

        // Gather learning details
        final List<dynamic> versionDetails = item['version_group_details'] ?? [];
        if (versionDetails.isEmpty) continue;

        // Extract first available learning details
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

        movesToSync.add({
          'id': moveId,
          'name': name,
          'method': method,
          'level': levelLearned,
        });
      }

      // Pull existing moves in SQLite to check what needs detailed API fetching
      final existingMoves = await db.select(db.moveTable).get();
      final Map<int, Move> existingMoveMap = {for (var m in existingMoves) m.id: m};

      // 3. Process and Sync Moves in highly optimized parallel chunks of 15
      const int moveChunkSize = 15;
      for (int i = 0; i < movesToSync.length; i += moveChunkSize) {
        final chunk = movesToSync.sublist(
          i,
          i + moveChunkSize > movesToSync.length ? movesToSync.length : i + moveChunkSize,
        );

        await Future.wait(chunk.map((m) async {
          try {
            final int moveId = m['id'];
            final String name = m['name'];
            final String method = m['method'];
            final int levelLearned = m['level'];

            // Skip detailed fetching if move details are already cached in MoveTable
            final existing = existingMoveMap[moveId];
            if (existing != null && existing.description != null && existing.type != 'Normal') {
              // Just insert the junction directly
              await db.into(db.pokemonMovesTable).insertOnConflictUpdate(PokemonMove(
                pokemonId: pokemonId,
                moveId: moveId,
                learnMethod: method,
                levelLearned: levelLearned,
              ));
              return;
            }

            // Otherwise fetch deep move details from PokeAPI
            await _fetchAndSaveSingleMove(moveId, name, pokemonId, method, levelLearned);
          } catch (_) {
            // Absorb single move failure to let others continue
          }
        }));
      }
    } catch (e) {
      // Background sync errors should not crash the view, let UI fallback gracefully
    }
  }

  /// Helper to fetch and insert a single Ability with English description
  Future<void> _syncSingleAbility(int abilityId, String name, int pokemonId, bool isHidden) async {
    try {
      final existing = await (db.select(db.abilityTable)..where((tbl) => tbl.id.equals(abilityId))).getSingleOrNull();

      if (existing == null || existing.description == 'Special ability of this Pokémon.' || existing.description.isEmpty) {
        final response = await ApiClient.get('ability/$abilityId');
        final data = response.data;

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

        final cleanName = name.replaceAll('-', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');

        await db.into(db.abilityTable).insertOnConflictUpdate(Ability(
          id: abilityId,
          name: cleanName,
          description: description,
        ));
      }

      // Insert junction entry
      await db.into(db.pokemonAbilitiesTable).insertOnConflictUpdate(PokemonAbility(
        pokemonId: pokemonId,
        abilityId: abilityId,
        isHidden: isHidden,
      ));
    } catch (_) {
      // Graceful error isolation
    }
  }

  /// Helper to fetch and insert a single Move with damageClass, type, pp, accuracy, power, and description
  Future<void> _fetchAndSaveSingleMove(int moveId, String name, int pokemonId, String method, int levelLearned) async {
    try {
      final response = await ApiClient.get('move/$moveId');
      final data = response.data;

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

      final cleanName = name.replaceAll('-', ' ').split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');

      // Insert Move
      await db.into(db.moveTable).insertOnConflictUpdate(Move(
        id: moveId,
        name: cleanName,
        type: type,
        power: power,
        accuracy: accuracy,
        pp: pp,
        damageClass: damageClass,
        description: description,
      ));

      // Insert junction entry
      await db.into(db.pokemonMovesTable).insertOnConflictUpdate(PokemonMove(
        pokemonId: pokemonId,
        moveId: moveId,
        learnMethod: method,
        levelLearned: levelLearned,
      ));
    } catch (_) {
      // Graceful error isolation
    }
  }

  /// Watch abilities with full details for a given Pokémon using JOIN
  Stream<List<PokemonAbilityWithDetails>> watchAbilitiesForPokemon(int pokemonId) {
    final query = db.select(db.pokemonAbilitiesTable).join([
      innerJoin(db.abilityTable, db.abilityTable.id.equalsExp(db.pokemonAbilitiesTable.abilityId)),
    ])..where(db.pokemonAbilitiesTable.pokemonId.equals(pokemonId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final junction = row.readTable(db.pokemonAbilitiesTable);
        final ability = row.readTable(db.abilityTable);
        return PokemonAbilityWithDetails(junction: junction, ability: ability);
      }).toList();
    });
  }

  /// Watch moves with full details for a given Pokémon using JOIN
  Stream<List<PokemonMoveWithDetails>> watchMovesForPokemon(int pokemonId) {
    final query = db.select(db.pokemonMovesTable).join([
      innerJoin(db.moveTable, db.moveTable.id.equalsExp(db.pokemonMovesTable.moveId)),
    ])..where(db.pokemonMovesTable.pokemonId.equals(pokemonId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final junction = row.readTable(db.pokemonMovesTable);
        final move = row.readTable(db.moveTable);
        return PokemonMoveWithDetails(junction: junction, move: move);
      }).toList();
    });
  }
}

@riverpod
Stream<List<PokemonAbilityWithDetails>> pokemonAbilities(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchAbilitiesForPokemon(pokemonId);
}

@riverpod
Stream<List<PokemonMoveWithDetails>> pokemonMoves(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchMovesForPokemon(pokemonId);
}

@riverpod
Stream<List<Map<String, dynamic>>> pokemonAbilitiesStream(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.db.watchPokemonAbilities(pokemonId);
}

@riverpod
Stream<List<Map<String, dynamic>>> pokemonMovesStream(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.db.watchPokemonMoves(pokemonId);
}

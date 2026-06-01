import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/network/api_client.dart';
import 'package:drift/drift.dart';
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

  // Offline high-performance static lookups for Legendary IDs
  static const Set<int> _legendaryIds = {
    144, 145, 146, 150,
    243, 244, 245, 249, 250,
    377, 378, 379, 380, 381, 382, 383, 384,
    480, 481, 482, 483, 484, 485, 486, 487, 488,
    638, 639, 640, 641, 642, 643, 644, 645, 646,
    716, 717, 718,
    772, 773, 785, 786, 787, 788, 789, 790, 791, 792, 800,
    888, 889, 890, 891, 892, 894, 895, 896, 897, 898, 905,
    1001, 1002, 1003, 1004, 1007, 1008, 1009, 1010, 1017, 1020, 1021, 1022, 1023, 1024
  };

  // Offline high-performance static lookups for Mythical IDs
  static const Set<int> _mythicalIds = {
    151,
    251,
    385, 386,
    489, 490, 491, 492, 493,
    494, 647, 648, 649,
    719, 720, 721,
    801, 802, 807, 808, 809,
    893,
    1014, 1015, 1016, 1025
  };

  /// Perform a mass, lightning-fast 100% Offline-First initial synchronization
  /// for all 1025 Pokémon (Generations 1-9+) using optimized Drift batches.
  /// Moves and abilities are loaded lazily when details are opened.
  Future<void> performFullInitialSync() async {
    try {
      progressNotifier.setProgress(0.01);

      // 1. Generate exact list of IDs 1 to 1025 to fetch all 9 Generations
      final List<int> pokemonIds = List.generate(1025, (index) => index + 1);

      progressNotifier.setProgress(0.05);

      final List<Pokemon> pokemonsToInsert = [];
      int completedPokemons = 0;

      // 2. Fetch Pokémon details in optimized concurrent batches of 40
      const int pokemonChunkSize = 40;

      for (int i = 0; i < pokemonIds.length; i += pokemonChunkSize) {
        final chunk = pokemonIds.sublist(
          i,
          i + pokemonChunkSize > pokemonIds.length ? pokemonIds.length : i + pokemonChunkSize,
        );

        await Future.wait(chunk.map((id) async {
          try {
            final res = await ApiClient.get('pokemon/$id');
            final data = res.data;

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

            // Choose the best artwork set that contains both default and shiny to ensure 100% perfect alignment in the slider
            String spriteUrl = '';
            String shinySpriteUrl = '';

            final officialDefault = data['sprites']?['other']?['official-artwork']?['front_default'];
            final officialShiny = data['sprites']?['other']?['official-artwork']?['front_shiny'];

            final homeDefault = data['sprites']?['other']?['home']?['front_default'];
            final homeShiny = data['sprites']?['other']?['home']?['front_shiny'];

            final pixelDefault = data['sprites']?['front_default'];
            final pixelShiny = data['sprites']?['front_shiny'];

            if (officialDefault != null && officialShiny != null) {
              spriteUrl = officialDefault;
              shinySpriteUrl = officialShiny;
            } else if (homeDefault != null && homeShiny != null) {
              spriteUrl = homeDefault;
              shinySpriteUrl = homeShiny;
            } else if (pixelDefault != null && pixelShiny != null) {
              spriteUrl = pixelDefault;
              shinySpriteUrl = pixelShiny;
            } else {
              // Strict fallback: use official artwork if available, then home, then pixel
              spriteUrl = officialDefault ?? homeDefault ?? pixelDefault ?? '';
              shinySpriteUrl = officialShiny ?? homeShiny ?? pixelShiny ?? spriteUrl;
            }

            // Ultra Beasts (UB): IDs 793 to 799, 803 to 806.
            final bool isUltraBeast = (id >= 793 && id <= 799) || (id >= 803 && id <= 806);

            // Paradox Pokémon: IDs 984 to 995, 1007 to 1010.
            final bool isParadox = (id >= 984 && id <= 995) || (id >= 1007 && id <= 1010);

            // Check legendary and mythical status instantly offline-first using ID Sets
            final bool isLegendary = _legendaryIds.contains(id);
            final bool isMythical = _mythicalIds.contains(id);

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
              isLegendary: isLegendary,
              isMythical: isMythical,
              isParadox: isParadox,
              isUltraBeast: isUltraBeast,
              spriteUrl: spriteUrl,
              shinySpriteUrl: shinySpriteUrl,
            ));
          } catch (_) {
            // Absorb single Pokémon network exceptions to make synchronization resilient
          } finally {
            completedPokemons++;
            // Smooth progress update (0.05 to 0.95)
            progressNotifier.setProgress(0.05 + (completedPokemons / pokemonIds.length) * 0.90);
          }
        }));
      }

      // 3. Atomically write all compact Pokémon to SQLite in a single optimized Drift batch!
      if (pokemonsToInsert.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAll(
            db.pokemonTable,
            pokemonsToInsert,
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      progressNotifier.setProgress(1.0);
    } catch (_) {
      progressNotifier.setProgress(1.0);
    }
  }
}

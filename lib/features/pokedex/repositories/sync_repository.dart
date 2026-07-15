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

  /// All known alternate form slugs with their human-readable form labels.
  static const List<Map<String, String>> _alternateForms = [
    // Alolan Forms
    {'slug': 'rattata-alola', 'form': 'Alolan'},
    {'slug': 'raticate-alola', 'form': 'Alolan'},
    {'slug': 'raichu-alola', 'form': 'Alolan'},
    {'slug': 'sandshrew-alola', 'form': 'Alolan'},
    {'slug': 'sandslash-alola', 'form': 'Alolan'},
    {'slug': 'vulpix-alola', 'form': 'Alolan'},
    {'slug': 'ninetales-alola', 'form': 'Alolan'},
    {'slug': 'diglett-alola', 'form': 'Alolan'},
    {'slug': 'dugtrio-alola', 'form': 'Alolan'},
    {'slug': 'meowth-alola', 'form': 'Alolan'},
    {'slug': 'persian-alola', 'form': 'Alolan'},
    {'slug': 'geodude-alola', 'form': 'Alolan'},
    {'slug': 'graveler-alola', 'form': 'Alolan'},
    {'slug': 'golem-alola', 'form': 'Alolan'},
    {'slug': 'ponyta-alola', 'form': 'Alolan'},
    {'slug': 'rapidash-alola', 'form': 'Alolan'},
    {'slug': 'slowpoke-alola', 'form': 'Alolan'},
    {'slug': 'slowbro-alola', 'form': 'Alolan'},
    {'slug': 'farfetchd-alola', 'form': 'Alolan'},
    {'slug': 'grimer-alola', 'form': 'Alolan'},
    {'slug': 'muk-alola', 'form': 'Alolan'},
    {'slug': 'exeggutor-alola', 'form': 'Alolan'},
    {'slug': 'marowak-alola', 'form': 'Alolan'},
    // Galarian Forms
    {'slug': 'meowth-galar', 'form': 'Galarian'},
    {'slug': 'ponyta-galar', 'form': 'Galarian'},
    {'slug': 'rapidash-galar', 'form': 'Galarian'},
    {'slug': 'slowpoke-galar', 'form': 'Galarian'},
    {'slug': 'slowbro-galar', 'form': 'Galarian'},
    {'slug': 'farfetchd-galar', 'form': 'Galarian'},
    {'slug': 'weezing-galar', 'form': 'Galarian'},
    {'slug': 'mr-mime-galar', 'form': 'Galarian'},
    {'slug': 'articuno-galar', 'form': 'Galarian'},
    {'slug': 'zapdos-galar', 'form': 'Galarian'},
    {'slug': 'moltres-galar', 'form': 'Galarian'},
    {'slug': 'slowking-galar', 'form': 'Galarian'},
    {'slug': 'corsola-galar', 'form': 'Galarian'},
    {'slug': 'zigzagoon-galar', 'form': 'Galarian'},
    {'slug': 'linoone-galar', 'form': 'Galarian'},
    {'slug': 'darumaka-galar', 'form': 'Galarian'},
    {'slug': 'darmanitan-galar', 'form': 'Galarian'},
    {'slug': 'yamask-galar', 'form': 'Galarian'},
    {'slug': 'stunfisk-galar', 'form': 'Galarian'},
    // Hisuian Forms
    {'slug': 'growlithe-hisui', 'form': 'Hisuian'},
    {'slug': 'arcanine-hisui', 'form': 'Hisuian'},
    {'slug': 'voltorb-hisui', 'form': 'Hisuian'},
    {'slug': 'electrode-hisui', 'form': 'Hisuian'},
    {'slug': 'typhlosion-hisui', 'form': 'Hisuian'},
    {'slug': 'qwilfish-hisui', 'form': 'Hisuian'},
    {'slug': 'sneasel-hisui', 'form': 'Hisuian'},
    {'slug': 'samurott-hisui', 'form': 'Hisuian'},
    {'slug': 'lilligant-hisui', 'form': 'Hisuian'},
    {'slug': 'zorua-hisui', 'form': 'Hisuian'},
    {'slug': 'zoroark-hisui', 'form': 'Hisuian'},
    {'slug': 'braviary-hisui', 'form': 'Hisuian'},
    {'slug': 'sliggoo-hisui', 'form': 'Hisuian'},
    {'slug': 'goodra-hisui', 'form': 'Hisuian'},
    {'slug': 'avalugg-hisui', 'form': 'Hisuian'},
    {'slug': 'decidueye-hisui', 'form': 'Hisuian'},
    // Paldean Forms
    {'slug': 'wooper-paldea', 'form': 'Paldean'},
    {'slug': 'tauros-paldea-combat', 'form': 'Paldean Combat'},
    {'slug': 'tauros-paldea-blaze', 'form': 'Paldean Blaze'},
    {'slug': 'tauros-paldea-aqua', 'form': 'Paldean Aqua'},
    // Mega Evolutions — Gen 6
    {'slug': 'venusaur-mega', 'form': 'Mega'},
    {'slug': 'charizard-mega-x', 'form': 'Mega X'},
    {'slug': 'charizard-mega-y', 'form': 'Mega Y'},
    {'slug': 'blastoise-mega', 'form': 'Mega'},
    {'slug': 'alakazam-mega', 'form': 'Mega'},
    {'slug': 'gengar-mega', 'form': 'Mega'},
    {'slug': 'kangaskhan-mega', 'form': 'Mega'},
    {'slug': 'pinsir-mega', 'form': 'Mega'},
    {'slug': 'gyarados-mega', 'form': 'Mega'},
    {'slug': 'aerodactyl-mega', 'form': 'Mega'},
    {'slug': 'mewtwo-mega-x', 'form': 'Mega X'},
    {'slug': 'mewtwo-mega-y', 'form': 'Mega Y'},
    {'slug': 'ampharos-mega', 'form': 'Mega'},
    {'slug': 'scizor-mega', 'form': 'Mega'},
    {'slug': 'heracross-mega', 'form': 'Mega'},
    {'slug': 'houndoom-mega', 'form': 'Mega'},
    {'slug': 'tyranitar-mega', 'form': 'Mega'},
    {'slug': 'blaziken-mega', 'form': 'Mega'},
    {'slug': 'gardevoir-mega', 'form': 'Mega'},
    {'slug': 'mawile-mega', 'form': 'Mega'},
    {'slug': 'aggron-mega', 'form': 'Mega'},
    {'slug': 'medicham-mega', 'form': 'Mega'},
    {'slug': 'manectric-mega', 'form': 'Mega'},
    {'slug': 'banette-mega', 'form': 'Mega'},
    {'slug': 'absol-mega', 'form': 'Mega'},
    {'slug': 'garchomp-mega', 'form': 'Mega'},
    {'slug': 'lucario-mega', 'form': 'Mega'},
    {'slug': 'abomasnow-mega', 'form': 'Mega'},
    {'slug': 'beedrill-mega', 'form': 'Mega'},
    {'slug': 'pidgeot-mega', 'form': 'Mega'},
    {'slug': 'slowbro-mega', 'form': 'Mega'},
    {'slug': 'steelix-mega', 'form': 'Mega'},
    {'slug': 'sceptile-mega', 'form': 'Mega'},
    {'slug': 'swampert-mega', 'form': 'Mega'},
    {'slug': 'sableye-mega', 'form': 'Mega'},
    {'slug': 'sharpedo-mega', 'form': 'Mega'},
    {'slug': 'camerupt-mega', 'form': 'Mega'},
    {'slug': 'altaria-mega', 'form': 'Mega'},
    {'slug': 'glalie-mega', 'form': 'Mega'},
    {'slug': 'salamence-mega', 'form': 'Mega'},
    {'slug': 'metagross-mega', 'form': 'Mega'},
    {'slug': 'latias-mega', 'form': 'Mega'},
    {'slug': 'latios-mega', 'form': 'Mega'},
    {'slug': 'rayquaza-mega', 'form': 'Mega'},
    {'slug': 'lopunny-mega', 'form': 'Mega'},
    {'slug': 'gallade-mega', 'form': 'Mega'},
    {'slug': 'audino-mega', 'form': 'Mega'},
    {'slug': 'diancie-mega', 'form': 'Mega'},
  ];

  /// Picks the best sprite URLs — HOME sprites first (full shiny coverage for ALL gens),
  /// then official-artwork, then pixel sprites.
  static ({String normal, String shiny}) _pickSprites(Map<String, dynamic> data) {
    final homeDefault = data['sprites']?['other']?['home']?['front_default'];
    final homeShiny = data['sprites']?['other']?['home']?['front_shiny'];

    final officialDefault = data['sprites']?['other']?['official-artwork']?['front_default'];
    final officialShiny = data['sprites']?['other']?['official-artwork']?['front_shiny'];

    final pixelDefault = data['sprites']?['front_default'];
    final pixelShiny = data['sprites']?['front_shiny'];

    // HOME has complete shiny coverage for Gen 1–9. Prefer it.
    if (homeDefault != null && homeShiny != null) {
      return (normal: homeDefault as String, shiny: homeShiny as String);
    }
    // Official artwork — Gen 9 often missing shiny here
    if (officialDefault != null && officialShiny != null) {
      return (normal: officialDefault as String, shiny: officialShiny as String);
    }
    // Pixel sprites — oldest fallback
    if (pixelDefault != null && pixelShiny != null) {
      return (normal: pixelDefault as String, shiny: pixelShiny as String);
    }
    // Last resort: mix best available for each
    final n = homeDefault ?? officialDefault ?? pixelDefault ?? '';
    final s = homeShiny ?? officialShiny ?? pixelShiny ?? n;
    return (normal: n as String, shiny: s as String);
  }

  /// Perform a mass, lightning-fast 100% Offline-First initial synchronization
  /// for all 1025 Pokémon (Generations 1-9+) using optimized Drift batches.
  /// Then fetches all known alternate forms (Alolan, Galarian, Hisuian, Paldean, Mega).
  /// Moves and abilities are loaded lazily when details are opened.
  Future<void> performFullInitialSync() async {
    try {
      progressNotifier.setProgress(0.01);

      // 1. Generate exact list of IDs 1 to 1025 to fetch all 9 Generations
      final List<int> pokemonIds = List.generate(1025, (index) => index + 1);

      progressNotifier.setProgress(0.05);

      final List<Pokemon> pokemonsToInsert = [];
      int completedPokemons = 0;
      final int totalWork = pokemonIds.length + _alternateForms.length;

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

            final String pokeName = data['name'] as String;
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

            final sprites = _pickSprites(data);

            // Ultra Beasts (UB): IDs 793 to 799, 803 to 806.
            final bool isUltraBeast = (id >= 793 && id <= 799) || (id >= 803 && id <= 806);

            // Paradox Pokémon: IDs 984 to 995, 1007 to 1010.
            final bool isParadox = (id >= 984 && id <= 995) || (id >= 1007 && id <= 1010);

            final bool isLegendary = _legendaryIds.contains(id);
            final bool isMythical = _mythicalIds.contains(id);

            // Capitalize name properly (handle hyphens like "mr-mime")
            final String displayName = pokeName
                .split('-')
                .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
                .join('-');

            pokemonsToInsert.add(Pokemon(
              id: id,
              name: displayName,
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
              spriteUrl: sprites.normal,
              shinySpriteUrl: sprites.shiny,
            ));
          } catch (_) {
            // Absorb single Pokémon network exceptions to make synchronization resilient
          } finally {
            completedPokemons++;
            progressNotifier.setProgress(0.05 + (completedPokemons / totalWork) * 0.90);
          }
        }));
      }

      // 3. Atomically write base Pokémon to SQLite
      if (pokemonsToInsert.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAll(
            db.pokemonTable,
            pokemonsToInsert,
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      // 4. Fetch alternate forms in batches of 20
      const int formChunkSize = 20;
      final List<Pokemon> formsToInsert = [];

      for (int i = 0; i < _alternateForms.length; i += formChunkSize) {
        final chunk = _alternateForms.sublist(
          i,
          i + formChunkSize > _alternateForms.length ? _alternateForms.length : i + formChunkSize,
        );

        await Future.wait(chunk.map((formInfo) async {
          try {
            final String slug = formInfo['slug']!;
            final String formLabel = formInfo['form']!;

            final res = await ApiClient.get('pokemon/$slug');
            final data = res.data;

            final int formId = data['id'];
            final String pokeName = data['name'] as String;

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

            final sprites = _pickSprites(data);

            // Build display name: extract base species name and prepend form
            // e.g. "vulpix-alola" → base "Vulpix" + form "Alolan" → "Vulpix (Alolan)"
            final String baseName = pokeName
                .replaceAll('-alola', '')
                .replaceAll('-galar', '')
                .replaceAll('-hisui', '')
                .replaceAll('-paldea', '')
                .replaceAll('-mega', '')
                .replaceAll('-combat', '')
                .replaceAll('-blaze', '')
                .replaceAll('-aqua', '')
                .replaceAll('-x', '')
                .replaceAll('-y', '')
                .split('-')
                .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
                .join(' ');

            final String displayName = '$baseName ($formLabel)';

            formsToInsert.add(Pokemon(
              id: formId,
              name: displayName,
              form: formLabel,
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
              spriteUrl: sprites.normal,
              shinySpriteUrl: sprites.shiny,
            ));
          } catch (_) {
            // Absorb individual form failures
          } finally {
            completedPokemons++;
            progressNotifier.setProgress(0.05 + (completedPokemons / totalWork) * 0.90);
          }
        }));
      }

      // 5. Write all forms atomically
      if (formsToInsert.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAll(
            db.pokemonTable,
            formsToInsert,
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

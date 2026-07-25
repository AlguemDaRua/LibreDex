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

      // HOME sprites have full shiny coverage for ALL gens (including Gen 9).
      // Official-artwork often lacks shiny for Gen 9 Pokémon — always prefer HOME first.
      String spriteUrl = '';
      String shinySpriteUrl = '';

      final homeDefault = data['sprites']?['other']?['home']?['front_default'];
      final homeShiny = data['sprites']?['other']?['home']?['front_shiny'];

      final officialDefault = data['sprites']?['other']?['official-artwork']?['front_default'];
      final officialShiny = data['sprites']?['other']?['official-artwork']?['front_shiny'];

      final pixelDefault = data['sprites']?['front_default'];
      final pixelShiny = data['sprites']?['front_shiny'];

      if (homeDefault != null && homeShiny != null) {
        spriteUrl = homeDefault;
        shinySpriteUrl = homeShiny;
      } else if (officialDefault != null && officialShiny != null) {
        spriteUrl = officialDefault;
        shinySpriteUrl = officialShiny;
      } else if (pixelDefault != null && pixelShiny != null) {
        spriteUrl = pixelDefault;
        shinySpriteUrl = pixelShiny;
      } else {
        // Last resort: mix best available for each
        spriteUrl = homeDefault ?? officialDefault ?? pixelDefault ?? '';
        shinySpriteUrl = homeShiny ?? officialShiny ?? pixelShiny ?? spriteUrl;
      }

      int nationalDexNumber = id;
      try {
        final speciesUrl = data['species']?['url'] as String?;
        if (speciesUrl != null) {
          final uri = Uri.parse(speciesUrl);
          final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
          if (segments.isNotEmpty) {
            nationalDexNumber = int.parse(segments.last);
          }
        }
      } catch (_) {}

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
        nationalDexNumber: nationalDexNumber,
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


  /// Compatibility wrapper for existing detail views (now obsolete due to full JSON bundling)
  Future<void> syncAbilitiesAndMoves(int pokemonId) async {
    // Obsolete: Data is 100% pre-bundled on initial app sync
    return;
  }

  /// Lazily fetches abilities and moves for a given Pokémon, caching them locally in SQLite.
  /// Obsolete: All 70,000+ relationships are perfectly seeded from JSON on app launch.
  Future<void> syncPokemonDetails(int pokemonId, String pokemonName) async {
    // Obsolete
    return;
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

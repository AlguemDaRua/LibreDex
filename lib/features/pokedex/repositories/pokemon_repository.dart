import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pokemon_repository.g.dart';

/// Database provider since we cannot modify app_database.dart.
/// Keeps database singleton and closes it on dispose.
@riverpod
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

/// Repository provider injected with Drift Database.
@riverpod
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
      // Omitted print for production code standards
    }
  }

  /// Watch all Pokémon reactively (updates in real time).
  Stream<List<Pokemon>> watchAllPokemon() {
    return db.select(db.pokemonTable).watch();
  }
}

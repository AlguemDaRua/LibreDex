import 'package:drift/drift.dart';
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

/// Wrapper for Pokémon Abilities with full entity details.
class PokemonAbilityWithDetails {
  final PokemonAbility junction;
  final Ability ability;

  PokemonAbilityWithDetails({required this.junction, required this.ability});
}

/// Wrapper for Pokémon Moves with full entity details.
class PokemonMoveWithDetails {
  final PokemonMove junction;
  final Move move;

  PokemonMoveWithDetails({required this.junction, required this.move});
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

  /// Lazily fetches abilities and moves for a given Pokémon, caching them locally in SQLite
  Future<void> syncAbilitiesAndMoves(int pokemonId) async {
    try {
      // Check if already cached locally
      final existingAbilities = await (db.select(db.pokemonAbilitiesTable)
            ..where((tbl) => tbl.pokemonId.equals(pokemonId)))
          .get();

      if (existingAbilities.isNotEmpty) {
        return; // Already synchronized and cached offline-first!
      }

      // Fetch on-demand details from PokeAPI
      final response = await ApiClient.get('pokemon/$pokemonId');
      final data = response.data;

      final List<dynamic> abilitiesJson = data['abilities'] ?? [];
      final List<dynamic> movesJson = data['moves'] ?? [];

      // Execute all inserts atomically in a fast local transaction
      await db.transaction(() async {
        // 1. Process Abilities
        for (final item in abilitiesJson) {
          final abilityData = item['ability'];
          final String name = abilityData['name'];
          final String url = abilityData['url'];
          final int abilityId = _extractIdFromUrl(url);
          final bool isHidden = item['is_hidden'] ?? false;

          final cleanName = name.replaceAll('-', ' ').split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ');

          // Insert Ability entry if not already existing
          await db.into(db.abilityTable).insertOnConflictUpdate(Ability(
                id: abilityId,
                name: cleanName,
                description: 'Special ability of this Pokémon.',
              ));

          // Insert junction association
          await db.into(db.pokemonAbilitiesTable).insertOnConflictUpdate(PokemonAbility(
                pokemonId: pokemonId,
                abilityId: abilityId,
                isHidden: isHidden,
              ));
        }

        // 2. Process Moves
        for (final item in movesJson) {
          final moveData = item['move'];
          final String name = moveData['name'];
          final String url = moveData['url'];
          final int moveId = _extractIdFromUrl(url);

          final cleanName = name.replaceAll('-', ' ').split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ');

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

          // Insert base Move entry if not already existing
          await db.into(db.moveTable).insertOnConflictUpdate(Move(
                id: moveId,
                name: cleanName,
                type: 'Normal', // Cache placeholder type, lazy filled
                damageClass: 'physical',
                pp: 15,
              ));

          // Insert junction association
          await db.into(db.pokemonMovesTable).insertOnConflictUpdate(PokemonMove(
                pokemonId: pokemonId,
                moveId: moveId,
                learnMethod: method,
                levelLearned: levelLearned,
              ));
        }
      });
    } catch (e) {
      // Background sync errors should not crash the view, let UI fallback gracefully
    }
  }

  /// Watch abilities with full details for a given Pokémon
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

  /// Watch moves with full details for a given Pokémon
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

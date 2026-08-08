import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

/// Database Table for Pokémons.
@DataClassName('Pokemon')
class PokemonTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get form => text()();
  TextColumn get type1 => text()();
  TextColumn get type2 => text().nullable()();
  IntColumn get baseHp => integer()();
  IntColumn get baseAtk => integer()();
  IntColumn get baseDef => integer()();
  IntColumn get baseSpAtk => integer()();
  IntColumn get baseSpDef => integer()();
  IntColumn get baseSpd => integer()();
  BoolColumn get isLegendary => boolean()();
  BoolColumn get isMythical => boolean()();
  BoolColumn get isParadox => boolean()();
  BoolColumn get isUltraBeast => boolean()();
  TextColumn get spriteUrl => text()();
  TextColumn get shinySpriteUrl => text()();
  IntColumn get nationalDexNumber => integer().withDefault(Constant(0))();
  IntColumn get generation => integer().withDefault(Constant(1))();
  IntColumn get evolutionStage => integer().withDefault(Constant(0))();
  TextColumn get eggGroups => text().nullable()();
  TextColumn get formSource => text().nullable()();
  TextColumn get dlcSource => text().nullable()();
  BoolColumn get isChampions => boolean().withDefault(Constant(false))();
  BoolColumn get isLegendsZA => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Database Table for Moves.
@DataClassName('Move')
class MoveTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get power => integer().nullable()();
  IntColumn get accuracy => integer().nullable()();
  IntColumn get pp => integer()();
  TextColumn get damageClass => text()(); // physical, special, status
  TextColumn get description => text().nullable()();
  IntColumn get priority => integer().withDefault(Constant(0))();
  BoolColumn get isContact => boolean().withDefault(Constant(false))();
  BoolColumn get isHealing => boolean().withDefault(Constant(false))();
  BoolColumn get isSound => boolean().withDefault(Constant(false))();
  BoolColumn get isPunching => boolean().withDefault(Constant(false))();
  BoolColumn get isBiting => boolean().withDefault(Constant(false))();
  BoolColumn get isPowder => boolean().withDefault(Constant(false))();
  BoolColumn get isPulse => boolean().withDefault(Constant(false))();
  BoolColumn get isBallistic => boolean().withDefault(Constant(false))();
  BoolColumn get isSlicing => boolean().withDefault(Constant(false))();
  BoolColumn get isWind => boolean().withDefault(Constant(false))();
  BoolColumn get isDance => boolean().withDefault(Constant(false))();
  BoolColumn get isBite => boolean().withDefault(Constant(false))();
  BoolColumn get isMultiHit => boolean().withDefault(Constant(false))();
  BoolColumn get isProtective => boolean().withDefault(Constant(false))();
  BoolColumn get isSwitching => boolean().withDefault(Constant(false))();
  BoolColumn get isRecharge => boolean().withDefault(Constant(false))();
  BoolColumn get isRecoil => boolean().withDefault(Constant(false))();
  BoolColumn get isDraining => boolean().withDefault(Constant(false))();
  BoolColumn get isStatusMove => boolean().withDefault(Constant(false))();
  BoolColumn get isDamagingMove => boolean().withDefault(Constant(false))();
  BoolColumn get isSignatureMove => boolean().withDefault(Constant(false))();
  BoolColumn get isDLCMove => boolean().withDefault(Constant(false))();
  BoolColumn get isChampionsMove => boolean().withDefault(Constant(false))();
  BoolColumn get isLegendsZAMove => boolean().withDefault(Constant(false))();
  IntColumn get generation => integer().withDefault(Constant(1))();
  TextColumn get introducedIn => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Database Table for Abilities.
@DataClassName('Ability')
class AbilityTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get generation => integer().withDefault(Constant(1))();
  BoolColumn get isHiddenAbility => boolean().withDefault(Constant(false))();
  BoolColumn get isChampionsAbility => boolean().withDefault(Constant(false))();
  BoolColumn get isLegendsZAAbility => boolean().withDefault(Constant(false))();
  TextColumn get introducedIn => text().nullable()();
  TextColumn get sourceGames => text().nullable()();
  TextColumn get effectTags => text().nullable()();
  TextColumn get battleEffectTags => text().nullable()();
  TextColumn get pokemonTypes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction Table for Pokémon <-> Moves Many-to-Many Relationship.
@DataClassName('PokemonMove')
class PokemonMovesTable extends Table {
  IntColumn get pokemonId => integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get moveId => integer().references(MoveTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get learnMethod => text()(); // PokéAPI ids, e.g. level-up, machine, egg, tutor
  IntColumn get levelLearned => integer().nullable()();

  @override
  Set<Column> get primaryKey => {pokemonId, moveId, learnMethod};
}

/// Junction Table for Pokémon <-> Abilities Many-to-Many Relationship.
@DataClassName('PokemonAbility')
class PokemonAbilitiesTable extends Table {
  IntColumn get pokemonId => integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get abilityId => integer().references(AbilityTable, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isHidden => boolean()();

  @override
  Set<Column> get primaryKey => {pokemonId, abilityId};
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

/// The local Drift SQLite database setup.
/// Handles asynchronous connections, automated migrations and foreign key constraints.
@DriftDatabase(tables: [
  PokemonTable,
  MoveTable,
  AbilityTable,
  PokemonMovesTable,
  PokemonAbilitiesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Enable Foreign Key support and reverse-lookup indexes used by the
        // MoveDex and AbilityDex detail pages.
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_moves_move_id '
          'ON pokemon_moves_table (move_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_ability_id '
          'ON pokemon_abilities_table (ability_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_name ON pokemon_table (name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_move_name ON move_table (name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_ability_name ON ability_table (name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_form ON pokemon_table (form)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_type1 ON pokemon_table (type1)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_type2 ON pokemon_table (type2)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_generation ON pokemon_table (generation)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_nationalDexNumber ON pokemon_table (national_dex_number)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_move_type ON move_table (type)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_move_damageClass ON move_table (damage_class)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_move_power ON move_table (power)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_move_priority ON move_table (priority)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_moves_pokemon_id ON pokemon_moves_table (pokemon_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_moves_learn_method ON pokemon_moves_table (learn_method)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_pokemon_id ON pokemon_abilities_table (pokemon_id)',
        );
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(moveTable, moveTable.description);
        }
        if (from < 3) {
          await m.addColumn(pokemonTable, pokemonTable.nationalDexNumber);
        }
        if (from < 4) {
          // pokemonTable columns
          await m.addColumn(pokemonTable, pokemonTable.generation);
          await m.addColumn(pokemonTable, pokemonTable.evolutionStage);
          await m.addColumn(pokemonTable, pokemonTable.eggGroups);
          await m.addColumn(pokemonTable, pokemonTable.formSource);
          await m.addColumn(pokemonTable, pokemonTable.dlcSource);
          await m.addColumn(pokemonTable, pokemonTable.isChampions);
          await m.addColumn(pokemonTable, pokemonTable.isLegendsZA);

          // moveTable columns
          await m.addColumn(moveTable, moveTable.priority);
          await m.addColumn(moveTable, moveTable.isContact);
          await m.addColumn(moveTable, moveTable.isHealing);
          await m.addColumn(moveTable, moveTable.isSound);
          await m.addColumn(moveTable, moveTable.isPunching);
          await m.addColumn(moveTable, moveTable.isBiting);
          await m.addColumn(moveTable, moveTable.isPowder);
          await m.addColumn(moveTable, moveTable.isPulse);
          await m.addColumn(moveTable, moveTable.isBallistic);
          await m.addColumn(moveTable, moveTable.isSlicing);
          await m.addColumn(moveTable, moveTable.isWind);
          await m.addColumn(moveTable, moveTable.isDance);
          await m.addColumn(moveTable, moveTable.isBite);
          await m.addColumn(moveTable, moveTable.isMultiHit);
          await m.addColumn(moveTable, moveTable.isProtective);
          await m.addColumn(moveTable, moveTable.isSwitching);
          await m.addColumn(moveTable, moveTable.isRecharge);
          await m.addColumn(moveTable, moveTable.isRecoil);
          await m.addColumn(moveTable, moveTable.isDraining);
          await m.addColumn(moveTable, moveTable.isStatusMove);
          await m.addColumn(moveTable, moveTable.isDamagingMove);
          await m.addColumn(moveTable, moveTable.isSignatureMove);
          await m.addColumn(moveTable, moveTable.isDLCMove);
          await m.addColumn(moveTable, moveTable.isChampionsMove);
          await m.addColumn(moveTable, moveTable.isLegendsZAMove);
          await m.addColumn(moveTable, moveTable.generation);
          await m.addColumn(moveTable, moveTable.introducedIn);

          // abilityTable columns
          await m.addColumn(abilityTable, abilityTable.generation);
          await m.addColumn(abilityTable, abilityTable.isHiddenAbility);
          await m.addColumn(abilityTable, abilityTable.isChampionsAbility);
          await m.addColumn(abilityTable, abilityTable.isLegendsZAAbility);
          await m.addColumn(abilityTable, abilityTable.introducedIn);
          await m.addColumn(abilityTable, abilityTable.sourceGames);
          await m.addColumn(abilityTable, abilityTable.effectTags);
          await m.addColumn(abilityTable, abilityTable.battleEffectTags);
          await m.addColumn(abilityTable, abilityTable.pokemonTypes);
        }
      },
    );
  }

  /// Watch relational Abilities of a specific Pokémon using JOIN returning Map objects.
  Stream<List<Map<String, dynamic>>> watchPokemonAbilities(int pokemonId) {
    final query = select(pokemonAbilitiesTable).join([
      innerJoin(abilityTable, abilityTable.id.equalsExp(pokemonAbilitiesTable.abilityId)),
    ])..where(pokemonAbilitiesTable.pokemonId.equals(pokemonId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final junction = row.readTable(pokemonAbilitiesTable);
        final ability = row.readTable(abilityTable);
        return {
          'id': ability.id,
          'name': ability.name,
          'effect': ability.description,
          'isHidden': junction.isHidden,
        };
      }).toList();
    });
  }

  /// Watch relational Moves of a specific Pokémon using JOIN returning Map objects.
  Stream<List<Map<String, dynamic>>> watchPokemonMoves(int pokemonId) {
    final query = select(pokemonMovesTable).join([
      innerJoin(moveTable, moveTable.id.equalsExp(pokemonMovesTable.moveId)),
    ])..where(pokemonMovesTable.pokemonId.equals(pokemonId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final junction = row.readTable(pokemonMovesTable);
        final move = row.readTable(moveTable);
        return {
          'id': move.id,
          'name': move.name,
          'type': move.type,
          'power': move.power,
          'pp': move.pp,
          'accuracy': move.accuracy,
          'damageClass': move.damageClass,
          'description': move.description,
          'learnMethod': junction.learnMethod,
          'levelLearned': junction.levelLearned,
        };
      }).toList();
    });
  }

  /// Fetch relational Abilities of a specific Pokémon using JOIN.
  Future<List<PokemonAbilityWithDetails>> getPokemonAbilities(int pokemonId) async {
    final query = select(pokemonAbilitiesTable).join([
      innerJoin(abilityTable, abilityTable.id.equalsExp(pokemonAbilitiesTable.abilityId)),
    ])..where(pokemonAbilitiesTable.pokemonId.equals(pokemonId));

    final rows = await query.get();
    return rows.map((row) {
      final junction = row.readTable(pokemonAbilitiesTable);
      final ability = row.readTable(abilityTable);
      return PokemonAbilityWithDetails(junction: junction, ability: ability);
    }).toList();
  }

  /// Fetch relational Moves of a specific Pokémon using JOIN.
  Future<List<PokemonMoveWithDetails>> getPokemonMoves(int pokemonId) async {
    final query = select(pokemonMovesTable).join([
      innerJoin(moveTable, moveTable.id.equalsExp(pokemonMovesTable.moveId)),
    ])..where(pokemonMovesTable.pokemonId.equals(pokemonId));

    final rows = await query.get();
    return rows.map((row) {
      final junction = row.readTable(pokemonMovesTable);
      final move = row.readTable(moveTable);
      return PokemonMoveWithDetails(junction: junction, move: move);
    }).toList();
  }

  /// Fetch all Pokémons that can learn a specific Move, along with how they learn it.
  Future<List<Map<String, dynamic>>> getPokemonsForMove(int moveId) async {
    final query = select(pokemonMovesTable).join([
      innerJoin(pokemonTable, pokemonTable.id.equalsExp(pokemonMovesTable.pokemonId)),
    ])..where(pokemonMovesTable.moveId.equals(moveId));

    final rows = await query.get();
    return rows.map((row) {
      final junction = row.readTable(pokemonMovesTable);
      final pokemon = row.readTable(pokemonTable);
      return {
        'pokemon': pokemon,
        'learnMethod': junction.learnMethod,
        'levelLearned': junction.levelLearned,
      };
    }).toList();
  }

  /// Fetch all Pokémons that can have a specific Ability.
  Future<List<Map<String, dynamic>>> getPokemonsForAbility(int abilityId) async {
    final query = select(pokemonAbilitiesTable).join([
      innerJoin(pokemonTable, pokemonTable.id.equalsExp(pokemonAbilitiesTable.pokemonId)),
    ])..where(pokemonAbilitiesTable.abilityId.equals(abilityId));

    final rows = await query.get();
    return rows.map((row) {
      final junction = row.readTable(pokemonAbilitiesTable);
      final pokemon = row.readTable(pokemonTable);
      return {
        'pokemon': pokemon,
        'isHidden': junction.isHidden,
      };
    }).toList();
  }
}

/// Helper method to open connection on modern/background thread.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'libredex.db'));

    // SQLite workaround for older Android devices (minSdkVersion 29 and below)
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}

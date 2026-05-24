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

  @override
  Set<Column> get primaryKey => {id};
}

/// Database Table for Abilities.
@DataClassName('Ability')
class AbilityTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction Table for Pokémon <-> Moves Many-to-Many Relationship.
@DataClassName('PokemonMove')
class PokemonMovesTable extends Table {
  IntColumn get pokemonId => integer().references(PokemonTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get moveId => integer().references(MoveTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get learnMethod => text()(); // level, tm, egg, tutor
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Enable Foreign Key support in SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(moveTable, moveTable.description);
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
          'name': move.name,
          'type': move.type,
          'power': move.power,
          'pp': move.pp,
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

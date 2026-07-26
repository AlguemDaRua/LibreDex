import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';

/// Seeds the local database from the JSON assets bundled inside the app.
///
/// LibreDex ships every Pokémon, move, ability and learnset, so this never
/// touches the network — a fresh install is fully usable while offline.
class SyncRepository {
  /// SQLite has a variable limit per statement, so rows are inserted in chunks.
  static const int _chunkSize = 500;

  final AppDatabase db;

  const SyncRepository({required this.db});

  /// Returns true when the Pokémon table already has rows.
  Future<bool> get isSeeded async {
    final count = countAll();
    final query = db.selectOnly(db.pokemonTable)..addColumns([count]);
    final row = await query.getSingle();
    return (row.read(count) ?? 0) > 0;
  }

  /// Loads a bundled JSON array, decoding it off the UI isolate.
  static Future<List<dynamic>> _loadJsonList(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return await compute(_decodeList, raw);
  }

  static List<dynamic> _decodeList(String raw) => jsonDecode(raw) as List<dynamic>;

  Future<void> _insertAll<T extends Table, D extends Insertable<D>>(
    TableInfo<T, D> table,
    List<D> rows,
  ) async {
    for (var i = 0; i < rows.length; i += _chunkSize) {
      final end = i + _chunkSize < rows.length ? i + _chunkSize : rows.length;
      final slice = rows.sublist(i, end);
      await db.batch((batch) {
        batch.insertAll(table, slice, mode: InsertMode.insertOrReplace);
      });
    }
  }

  /// Seeds Pokémon, moves, abilities and both junction tables from the bundled
  /// assets. Safe to run repeatedly — every row is inserted as an upsert.
  Future<void> seedBundledData() async {
    final pokemon = (await _loadJsonList('assets/data/pokemon.json'))
        .map((p) => Pokemon(
              id: p['id'] as int,
              name: p['name'] as String,
              form: (p['form'] as String?) ?? 'normal',
              type1: p['type1'] as String,
              type2: p['type2'] as String?,
              baseHp: p['baseHp'] as int,
              baseAtk: p['baseAtk'] as int,
              baseDef: p['baseDef'] as int,
              baseSpAtk: p['baseSpAtk'] as int,
              baseSpDef: p['baseSpDef'] as int,
              baseSpd: p['baseSpd'] as int,
              isLegendary: (p['isLegendary'] as bool?) ?? false,
              isMythical: (p['isMythical'] as bool?) ?? false,
              isParadox: (p['isParadox'] as bool?) ?? false,
              isUltraBeast: (p['isUltraBeast'] as bool?) ?? false,
              spriteUrl: (p['spriteUrl'] as String?) ?? '',
              shinySpriteUrl: (p['shinySpriteUrl'] as String?) ?? '',
              nationalDexNumber: (p['nationalDexNumber'] as int?) ?? p['id'] as int,
            ))
        .toList();

    final moves = (await _loadJsonList('assets/data/moves.json'))
        .map((m) => Move(
              id: m['id'] as int,
              name: m['name'] as String,
              type: m['type'] as String,
              power: m['power'] as int?,
              accuracy: m['accuracy'] as int?,
              pp: m['pp'] as int,
              damageClass: m['damageClass'] as String,
              description: m['description'] as String?,
            ))
        .toList();

    final abilities = (await _loadJsonList('assets/data/abilities.json'))
        .map((a) => Ability(
              id: a['id'] as int,
              name: a['name'] as String,
              description: a['description'] as String,
            ))
        .toList();

    final pokemonAbilities = (await _loadJsonList('assets/data/pokemon_abilities.json'))
        .map((a) => PokemonAbility(
              pokemonId: a['pokemonId'] as int,
              abilityId: a['abilityId'] as int,
              isHidden: a['isHidden'] as bool,
            ))
        .toList();

    final pokemonMoves = (await _loadJsonList('assets/data/pokemon_moves.json'))
        .map((m) {
          // The generator writes moves as compact arrays to keep the largest
          // bundled asset small. The map branch keeps old assets reseedable.
          if (m is List) {
            return PokemonMove(
              pokemonId: m[0] as int,
              moveId: m[1] as int,
              learnMethod: m[2] as String,
              levelLearned: m.length > 3 ? m[3] as int? : null,
            );
          }
          final map = m as Map<String, dynamic>;
          return PokemonMove(
            pokemonId: map['pokemonId'] as int,
            moveId: map['moveId'] as int,
            learnMethod: map['learnMethod'] as String,
            levelLearned: map['levelLearned'] as int?,
          );
        })
        .toList();

    // Parents before children so the foreign keys always resolve.
    await _insertAll(db.pokemonTable, pokemon);
    await _insertAll(db.moveTable, moves);
    await _insertAll(db.abilityTable, abilities);
    await _insertAll(db.pokemonAbilitiesTable, pokemonAbilities);
    await _insertAll(db.pokemonMovesTable, pokemonMoves);
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(db: ref.watch(databaseProvider));
});

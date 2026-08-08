import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds the local database from the JSON assets bundled inside the app.
///
/// LibreDex ships every Pokémon, move, ability and learnset, so this never
/// touches the network — a fresh install has its reference data without a connection.
class SyncRepository {
  /// SQLite has a variable limit per statement, so rows are inserted in chunks.
  static const int _chunkSize = 500;

  /// Bump whenever the bundled assets change contents (new forms, fixed
  /// learnsets, real item/lore data replacing placeholders, audited sprite
  /// URLs, ...). Existing installs re-seed once at startup instead of
  /// keeping stale tables.
  ///
  /// History: v1 initial bundle; v2 Champions/Z-A forms overlay + Champions
  /// train learnsets; v3 fixes form sprite URLs that 404 upstream
  /// (transportation/cosplay forms now reuse the base species render).
  static const int bundledDataVersion = 3;

  static const String _bundledDataVersionKey = 'bundled_data_version';

  final AppDatabase db;

  const SyncRepository({required this.db});

  /// Returns true when the Pokémon table already has rows.
  Future<bool> get isSeeded async {
    final count = countAll();
    final query = db.selectOnly(db.pokemonTable)..addColumns([count]);
    final row = await query.getSingle();
    return (row.read(count) ?? 0) > 0;
  }

  /// Seeds on first launch and re-seeds whenever [bundledDataVersion] moved
  /// past what this install has stored. Called once by the startup gate.
  Future<void> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seededVersion = prefs.getInt(_bundledDataVersionKey) ?? 0;
    if (seededVersion < bundledDataVersion) {
      await reseedBundledData();
    } else if (!await isSeeded) {
      await seedBundledData();
    }
    await prefs.setInt(_bundledDataVersionKey, bundledDataVersion);
  }

  /// Clears every seeded table and re-inserts the bundled dataset, so stale
  /// junction rows from older bundles cannot linger. Favorites and team
  /// slots live in SharedPreferences and survive the rebuild.
  Future<void> reseedBundledData() async {
    // Keep the existing database usable until every bundled row is ready.
    // If unpacking fails or the process is interrupted, Drift rolls the whole
    // transaction back instead of leaving a partially rebuilt Pokédex.
    await db.transaction(() async {
      await db.delete(db.pokemonMovesTable).go();
      await db.delete(db.pokemonAbilitiesTable).go();
      await db.delete(db.pokemonTable).go();
      await db.delete(db.moveTable).go();
      await db.delete(db.abilityTable).go();
      await _seedBundledData();
    });
  }

  /// Loads a bundled JSON array, decoding it off the UI isolate.
  static Future<List<dynamic>> _loadJsonList(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return await compute(_decodeList, raw);
  }

  static List<dynamic> _decodeList(String raw) => jsonDecode(raw) as List<dynamic>;

  /// Loads a bundled JSON object, decoding it off the UI isolate.
  static Future<Map<String, dynamic>> _loadJsonMap(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return await compute(_decodeMap, raw);
  }

  static Map<String, dynamic> _decodeMap(String raw) => jsonDecode(raw) as Map<String, dynamic>;

  /// Decodes one Pokémon JSON row. Shared by the base bundle and the
  /// Champions / Legends Z-A forms overlay, which uses the same shape.
  static Pokemon _pokemonFromJson(Map<dynamic, dynamic> p) {
    return Pokemon(
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
      generation: (p['generation'] as int?) ?? 1,
      evolutionStage: (p['evolutionStage'] as int?) ?? 0,
      eggGroups: p['eggGroups'] as String?,
      formSource: p['formSource'] as String?,
      dlcSource: p['dlcSource'] as String?,
      isChampions: (p['isChampions'] as bool?) ?? false,
      isLegendsZA: (p['isLegendsZA'] as bool?) ?? false,
    );
  }

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
  Future<void> seedBundledData() {
    return db.transaction(_seedBundledData);
  }

  Future<void> _seedBundledData() async {
    final pokemonRows = (await _loadJsonList('assets/data/pokemon.json'))
        .map((p) => Map<dynamic, dynamic>.from(p as Map<dynamic, dynamic>))
        .toList();

    // Champions / Legends Z-A forms overlay. It is additive: any failure to
    // read it simply leaves the app with the classic dataset, and the
    // curated overrides (readable Eternal Flower Floette name, intentionally
    // blanked broken shiny) are applied to the base rows before insert.
    Map<String, dynamic> overlay;
    try {
      overlay = await _loadJsonMap('assets/data/forms_extra.json');
    } catch (_) {
      overlay = const {};
    }
    final overridesById = <int, Map<dynamic, dynamic>>{
      for (final raw in (overlay['pokemonOverrides'] as List<dynamic>? ?? const []))
        (raw as Map<dynamic, dynamic>)['id'] as int: Map<dynamic, dynamic>.from(raw),
    };
    for (final row in pokemonRows) {
      final patch = overridesById[row['id'] as int];
      if (patch == null) continue;
      for (final entry in patch.entries) {
        if (entry.key == 'id' || entry.key == 'note') continue;
        row[entry.key] = entry.value;
      }
    }

    final pokemon = pokemonRows.map(_pokemonFromJson).toList()
      ..addAll(
        (overlay['pokemon'] as List<dynamic>? ?? const [])
            .map((p) => _pokemonFromJson(p as Map<dynamic, dynamic>)),
      );

    final moves = (await _loadJsonList('assets/data/moves.json'))
        .cast<Map<String, dynamic>>()
        .map((m) => Move(
              id: m['id'] as int,
              name: m['name'] as String,
              type: m['type'] as String,
              power: m['power'] as int?,
              accuracy: m['accuracy'] as int?,
              pp: m['pp'] as int,
              damageClass: m['damageClass'] as String,
              description: m['description'] as String?,
              priority: (m['priority'] as int?) ?? 0,
              isContact: (m['isContact'] as bool?) ?? false,
              isHealing: (m['isHealing'] as bool?) ?? false,
              isSound: (m['isSound'] as bool?) ?? false,
              isPunching: (m['isPunching'] as bool?) ?? false,
              isBiting: (m['isBiting'] as bool?) ?? false,
              isPowder: (m['isPowder'] as bool?) ?? false,
              isPulse: (m['isPulse'] as bool?) ?? false,
              isBallistic: (m['isBallistic'] as bool?) ?? false,
              isSlicing: (m['isSlicing'] as bool?) ?? false,
              isWind: (m['isWind'] as bool?) ?? false,
              isDance: (m['isDance'] as bool?) ?? false,
              isBite: (m['isBite'] as bool?) ?? false,
              isMultiHit: (m['isMultiHit'] as bool?) ?? false,
              isProtective: (m['isProtective'] as bool?) ?? false,
              isSwitching: (m['isSwitching'] as bool?) ?? false,
              isRecharge: (m['isRecharge'] as bool?) ?? false,
              isRecoil: (m['isRecoil'] as bool?) ?? false,
              isDraining: (m['isDraining'] as bool?) ?? false,
              isStatusMove: (m['isStatusMove'] as bool?) ?? (m['damageClass'] == 'status'),
              isDamagingMove: (m['isDamagingMove'] as bool?) ?? (m['damageClass'] != 'status'),
              isSignatureMove: (m['isSignatureMove'] as bool?) ?? false,
              isDLCMove: (m['isDLCMove'] as bool?) ?? false,
              isChampionsMove: (m['isChampionsMove'] as bool?) ?? false,
              isLegendsZAMove: (m['isLegendsZAMove'] as bool?) ?? false,
              generation: (m['generation'] as int?) ?? 1,
              introducedIn: m['introducedIn'] as String?,
            ))
        .toList();

    final abilities = (await _loadJsonList('assets/data/abilities.json'))
        .cast<Map<String, dynamic>>()
        .map((a) => Ability(
              id: a['id'] as int,
              name: a['name'] as String,
              description: a['description'] as String,
              generation: (a['generation'] as int?) ?? 1,
              isHiddenAbility: (a['isHiddenAbility'] as bool?) ?? false,
              isChampionsAbility: (a['isChampionsAbility'] as bool?) ?? false,
              isLegendsZAAbility: (a['isLegendsZAAbility'] as bool?) ?? false,
              introducedIn: a['introducedIn'] as String?,
              sourceGames: a['sourceGames'] as String?,
              effectTags: a['effectTags'] as String?,
              battleEffectTags: a['battleEffectTags'] as String?,
              pokemonTypes: a['pokemonTypes'] as String?,
            ))
        .toList()
      // Champions-only abilities (Mega Sol, Dragonize, ...) ship with the
      // overlay because the base snapshot predates them.
      ..addAll(
        (overlay['extraAbilities'] as List<dynamic>? ?? const []).map(
          (a) => Ability(
            id: a['id'] as int,
            name: a['name'] as String,
            description: a['description'] as String,
            generation: (a['generation'] as int?) ?? 9,
            isHiddenAbility: (a['isHiddenAbility'] as bool?) ?? false,
            isChampionsAbility: (a['isChampionsAbility'] as bool?) ?? true,
            isLegendsZAAbility: (a['isLegendsZAAbility'] as bool?) ?? false,
          ),
        ),
      );

    final pokemonAbilities = (await _loadJsonList('assets/data/pokemon_abilities.json'))
        .map((a) => PokemonAbility(
              pokemonId: a['pokemonId'] as int,
              abilityId: a['abilityId'] as int,
              isHidden: a['isHidden'] as bool,
            ))
        .toList()
      // Champions-specific ability overrides for the overlay Mega forms.
      ..addAll([
        for (final form in (overlay['pokemon'] as List<dynamic>? ?? const []))
          for (final a in (form['abilities'] as List<dynamic>? ?? const []))
            PokemonAbility(
              pokemonId: form['id'] as int,
              abilityId: a['abilityId'] as int,
              isHidden: a['isHidden'] as bool,
            ),
      ]);

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

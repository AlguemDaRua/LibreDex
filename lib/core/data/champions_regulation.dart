import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bundled availability and patch data for the active Pokémon Champions set.
///
/// Regulation membership is deliberately separate from legacy `isChampions*`
/// flags: an entry can be available in M-C without being Champions-exclusive,
/// and an existing item can become regulation-eligible without being new to
/// the series.
final championsRegulationProvider =
    FutureProvider<ChampionsRegulationCatalog>((ref) async {
  try {
    final raw = await rootBundle.loadString(
      'assets/data/champions_regulation_mc.json',
    );
    return compute(_decodeRegulationCatalog, raw);
  } catch (_) {
    return ChampionsRegulationCatalog.empty();
  }
});

ChampionsRegulationCatalog _decodeRegulationCatalog(String raw) {
  return ChampionsRegulationCatalog.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
  );
}

class ChampionsMoveChange {
  final int pokemonId;
  final int moveId;
  final String moveName;

  const ChampionsMoveChange({
    required this.pokemonId,
    required this.moveId,
    this.moveName = '',
  });

  factory ChampionsMoveChange.fromJson(Map<String, dynamic> json) {
    return ChampionsMoveChange(
      pokemonId: json['pokemonId'] as int,
      moveId: json['moveId'] as int,
      moveName: json['moveName'] as String? ?? '',
    );
  }
}

/// One immutable, ID-based view of Pokémon Champions Regulation M-C.
class ChampionsRegulationCatalog {
  final String regulationName;
  final String gameVersion;
  final String asOf;
  final String activeStartUtc;
  final String activeEndUtc;
  final String officialAnnouncementPeriod;
  final String patchSummary;
  final int officialNewPokemonCount;

  final List<int> pokemonIds;
  final List<int> newPokemonIds;
  final List<int> newMegaFormIds;
  final List<int> newRosterPokemonIds;
  final List<int> moveIds;
  final List<int> newMoveIds;
  final List<int> abilityIds;
  final List<int> newAbilityIds;
  final List<int> itemIds;
  final List<int> newItemIds;

  final Map<String, int> sourcePokemonIds;
  final Map<int, String> abilityDescriptions;
  final Map<int, String> newAbilityDescriptions;
  final Map<int, String> moveDescriptions;
  final Map<int, String> newMoveDescriptions;
  final Map<int, int> movePpAdjustments;
  final Map<int, int> previousMovePp;
  final List<ChampionsMoveChange> removedMoves;
  final List<int> newlyUsableMoveIds;

  late final Set<int> _pokemonIdSet = pokemonIds.toSet();
  late final Set<int> _newPokemonIdSet = newRosterPokemonIds.toSet();
  late final Set<int> _moveIdSet = moveIds.toSet();
  late final Set<int> _newMoveIdSet = newMoveIds.toSet();
  late final Set<int> _abilityIdSet = abilityIds.toSet();
  late final Set<int> _newAbilityIdSet = newAbilityIds.toSet();
  late final Set<int> _itemIdSet = itemIds.toSet();
  late final Set<int> _newItemIdSet = newItemIds.toSet();

  ChampionsRegulationCatalog({
    required this.regulationName,
    required this.gameVersion,
    required this.asOf,
    required this.activeStartUtc,
    required this.activeEndUtc,
    required this.officialAnnouncementPeriod,
    required this.patchSummary,
    required this.officialNewPokemonCount,
    required this.pokemonIds,
    required this.newPokemonIds,
    required this.newMegaFormIds,
    required this.newRosterPokemonIds,
    required this.moveIds,
    required this.newMoveIds,
    required this.abilityIds,
    required this.newAbilityIds,
    required this.itemIds,
    required this.newItemIds,
    required this.sourcePokemonIds,
    required this.abilityDescriptions,
    required this.newAbilityDescriptions,
    required this.moveDescriptions,
    required this.newMoveDescriptions,
    required this.movePpAdjustments,
    required this.previousMovePp,
    required this.removedMoves,
    required this.newlyUsableMoveIds,
  });

  factory ChampionsRegulationCatalog.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final ppChanges = (json['movePpAdjustments'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final removed = (json['removedMoves'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return ChampionsRegulationCatalog(
      regulationName: meta['title'] as String? ?? 'Pokémon Champions',
      gameVersion: meta['gameVersion'] as String? ?? '',
      asOf: meta['asOf'] as String? ?? '',
      activeStartUtc: (meta['activePeriodUtc'] as Map<String, dynamic>?)
              ?['startDate'] as String? ??
          '',
      activeEndUtc: (meta['activePeriodUtc'] as Map<String, dynamic>?)
              ?['endDate'] as String? ??
          '',
      officialAnnouncementPeriod:
          meta['officialAnnouncementPeriod'] as String? ?? '',
      patchSummary: meta['patchSummary'] as String? ?? '',
      officialNewPokemonCount: meta['officialNewPokemonCount'] as int? ?? 0,
      pokemonIds: _readIntList(json, 'pokemonIds'),
      newPokemonIds: _readIntList(json, 'newPokemonIds'),
      newMegaFormIds: _readIntList(json, 'newMegaFormIds'),
      newRosterPokemonIds: _readIntList(json, 'newRosterPokemonIds'),
      moveIds: _readIntList(json, 'moveIds'),
      newMoveIds: _readIntList(json, 'newMoveIds'),
      abilityIds: _readIntList(json, 'abilityIds'),
      newAbilityIds: _readIntList(json, 'newAbilityIds'),
      itemIds: _readIntList(json, 'itemIds'),
      newItemIds: _readIntList(json, 'newItemIds'),
      sourcePokemonIds: {
        for (final entry in (json['sourcePokemonIds'] as Map<String, dynamic>? ?? const {}).entries)
          entry.key: entry.value as int,
      },
      abilityDescriptions: _readStringMap(json, 'abilityDescriptions'),
      newAbilityDescriptions: _readStringMap(json, 'newAbilityDescriptions'),
      moveDescriptions: _readStringMap(json, 'moveDescriptions'),
      newMoveDescriptions: _readStringMap(json, 'newMoveDescriptions'),
      movePpAdjustments: {
        for (final change in ppChanges) change['moveId'] as int: change['pp'] as int,
      },
      previousMovePp: {
        for (final change in ppChanges)
          change['moveId'] as int: change['previousPp'] as int,
      },
      removedMoves: [for (final change in removed) ChampionsMoveChange.fromJson(change)],
      newlyUsableMoveIds: _readIntList(json, 'newlyUsableMoveIds'),
    );
  }

  factory ChampionsRegulationCatalog.empty() => ChampionsRegulationCatalog(
        regulationName: 'Pokémon Champions',
        gameVersion: '',
        asOf: '',
        activeStartUtc: '',
        activeEndUtc: '',
        officialAnnouncementPeriod: '',
        patchSummary: '',
        officialNewPokemonCount: 0,
        pokemonIds: const [],
        newPokemonIds: const [],
        newMegaFormIds: const [],
        newRosterPokemonIds: const [],
        moveIds: const [],
        newMoveIds: const [],
        abilityIds: const [],
        newAbilityIds: const [],
        itemIds: const [],
        newItemIds: const [],
        sourcePokemonIds: const {},
        abilityDescriptions: const {},
        newAbilityDescriptions: const {},
        moveDescriptions: const {},
        newMoveDescriptions: const {},
        movePpAdjustments: const {},
        previousMovePp: const {},
        removedMoves: const [],
        newlyUsableMoveIds: const [],
      );

  static List<int> _readIntList(Map<String, dynamic> json, String key) =>
      (json[key] as List<dynamic>? ?? const []).cast<int>();

  static Map<int, String> _readStringMap(Map<String, dynamic> json, String key) {
    final map = json[key] as Map<String, dynamic>? ?? const {};
    return {for (final entry in map.entries) int.parse(entry.key): entry.value as String};
  }

  String get regulationCode => 'M-C';
  int get rosterEntryCount => pokemonIds.length;
  int get newRosterEntryCount => newRosterPokemonIds.length;

  bool isPokemonEligible(int id) => _pokemonIdSet.contains(id);
  bool isNewPokemon(int id) => _newPokemonIdSet.contains(id);
  bool isMoveAvailable(int id) => _moveIdSet.contains(id);
  bool isNewMove(int id) => _newMoveIdSet.contains(id);
  bool isAbilityAvailable(int id) => _abilityIdSet.contains(id);
  bool isNewAbility(int id) => _newAbilityIdSet.contains(id);
  bool isItemAvailable(int id) => _itemIdSet.contains(id);
  bool isNewItem(int id) => _newItemIdSet.contains(id);

  String? abilityDescriptionFor(int id) => abilityDescriptions[id];
  String? newAbilityDescriptionFor(int id) => newAbilityDescriptions[id];
  String? moveDescriptionFor(int id) => moveDescriptions[id];
  String? newMoveDescriptionFor(int id) => newMoveDescriptions[id];
  int? movePpFor(int id) => movePpAdjustments[id];
  int? previousMovePpFor(int id) => previousMovePp[id];
  List<ChampionsMoveChange> removedMovesForPokemon(int id) =>
      removedMoves.where((change) => change.pokemonId == id).toList(growable: false);

  /// Adds M-C aliases to Pokémon names for roster-aware search.
  ///
  /// Queries such as "M-C", "new Champions" and "M-C Pikachu" resolve only
  /// to eligible IDs; ordinary names continue to be searched by the Pokédex.
  bool matchesPokemonSearch(int id, String query, {String aliases = ''}) {
    if (!isPokemonEligible(id)) return false;
    final markers = isNewPokemon(id)
        ? 'pokemon champions m-c regulation available eligible new newly added'
        : 'pokemon champions m-c regulation available eligible';
    final haystack = '$markers $aliases'.toLowerCase();
    final tokens = query.toLowerCase().trim().split(RegExp(r'\s+'))
      ..removeWhere((token) => token.isEmpty);
    return tokens.isNotEmpty && tokens.every(haystack.contains);
  }
}

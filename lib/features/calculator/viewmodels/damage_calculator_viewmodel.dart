import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/battle_engine/battle_engine.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';

part 'damage_calculator_viewmodel.g.dart';

class DamageCalculatorState {
  final Pokemon? attacker;
  final Pokemon? defender;

  /// Which game's stat system drives the duel math. Mainline by default —
  /// Pokémon Champions is an additional mode, never a replacement.
  final BattleRuleset ruleset;

  // Attacker Stats Settings
  final int attackerLevel;
  final String attackerNature;
  final Map<String, int> attackerIvs;
  final Map<String, int> attackerEvs;
  final Map<String, int> attackerStages;
  final String attackerHeldItem;
  final String? attackerAbility;
  final bool attackerTeraActive;
  final String? attackerTeraType;
  final String attackerStatus;
  final int attackerFriendship;
  final double attackerHpPercent;

  // Active Move Settings
  final String? selectedMoveName;
  final String moveType;
  final String moveCategory;
  final double movePower;
  final int moveHits;
  final int rageFistHits;

  /// Completed turns since the attacker entered battle (0–5). Slow Start
  /// halves Attack and Speed until five turns have completed.
  final int attackerTurnsOnField;

  // Defender Stats Settings
  final int defenderLevel;
  final String defenderNature;
  final Map<String, int> defenderIvs;
  final Map<String, int> defenderEvs;
  final Map<String, int> defenderStages;
  final String defenderHeldItem;
  final String? defenderAbility;
  final bool defenderTeraActive;
  final String? defenderTeraType;
  final String defenderStatus;
  final double defenderHpPercent;

  // Global Battlefield Tweaks & Battle Flags
  final bool isCriticalHit;
  final String weather;
  final String terrain;
  final bool reflectActive;
  final bool lightScreenActive;
  final bool helpingHandActive;
  final bool trickRoomActive;
  final bool defenderProtected;
  final bool isDoubleBattle;

  // Simple Tab Sandbox Fields
  final double simpleAttackerStat;
  final double simpleDefenderStat;
  final double simpleStab;
  final double simpleEffectiveness;

  // Pokémon Champions Stat Points (66 total, max 32 per stat). Kept
  // alongside — never merged into — the EV/IV maps, so toggling the ruleset
  // back and forth preserves each mode's setup.
  final Map<String, int> attackerSps;
  final Map<String, int> defenderSps;

  DamageCalculatorState({
    this.attacker,
    this.defender,
    this.ruleset = BattleRuleset.mainline,
    this.attackerLevel = 50,
    this.attackerNature = 'adamant',
    required this.attackerIvs,
    required this.attackerEvs,
    required this.attackerStages,
    this.attackerHeldItem = 'None',
    this.attackerAbility,
    this.attackerTeraActive = false,
    this.attackerTeraType,
    this.attackerStatus = 'none',
    this.attackerFriendship = 255,
    this.attackerHpPercent = 100.0,
    this.selectedMoveName,
    this.moveType = 'fire',
    this.moveCategory = 'physical',
    this.movePower = 90.0,
    this.moveHits = 3,
    this.rageFistHits = 0,
    this.attackerTurnsOnField = 0,
    this.defenderLevel = 50,
    this.defenderNature = 'bold',
    required this.defenderIvs,
    required this.defenderEvs,
    required this.defenderStages,
    this.defenderHeldItem = 'None',
    this.defenderAbility,
    this.defenderTeraActive = false,
    this.defenderTeraType,
    this.defenderStatus = 'none',
    this.defenderHpPercent = 100.0,
    this.isCriticalHit = false,
    this.weather = 'none',
    this.terrain = 'none',
    this.reflectActive = false,
    this.lightScreenActive = false,
    this.helpingHandActive = false,
    this.trickRoomActive = false,
    this.defenderProtected = false,
    this.isDoubleBattle = false,
    this.simpleAttackerStat = 200.0,
    this.simpleDefenderStat = 150.0,
    this.simpleStab = 1.5,
    this.simpleEffectiveness = 1.0,
    required this.attackerSps,
    required this.defenderSps,
  });

  DamageCalculatorState copyWith({
    Pokemon? attacker,
    Pokemon? defender,
    BattleRuleset? ruleset,
    int? attackerLevel,
    String? attackerNature,
    Map<String, int>? attackerIvs,
    Map<String, int>? attackerEvs,
    Map<String, int>? attackerStages,
    String? attackerHeldItem,
    Object? attackerAbility = const _Sentinel(),
    bool? attackerTeraActive,
    Object? attackerTeraType = const _Sentinel(),
    String? attackerStatus,
    int? attackerFriendship,
    double? attackerHpPercent,
    String? selectedMoveName,
    String? moveType,
    String? moveCategory,
    double? movePower,
    int? moveHits,
    int? rageFistHits,
    int? attackerTurnsOnField,
    int? defenderLevel,
    String? defenderNature,
    Map<String, int>? defenderIvs,
    Map<String, int>? defenderEvs,
    Map<String, int>? defenderStages,
    String? defenderHeldItem,
    Object? defenderAbility = const _Sentinel(),
    bool? defenderTeraActive,
    Object? defenderTeraType = const _Sentinel(),
    String? defenderStatus,
    double? defenderHpPercent,
    bool? isCriticalHit,
    String? weather,
    String? terrain,
    bool? reflectActive,
    bool? lightScreenActive,
    bool? helpingHandActive,
    bool? trickRoomActive,
    bool? defenderProtected,
    bool? isDoubleBattle,
    double? simpleAttackerStat,
    double? simpleDefenderStat,
    double? simpleStab,
    double? simpleEffectiveness,
    Map<String, int>? attackerSps,
    Map<String, int>? defenderSps,
  }) {
    return DamageCalculatorState(
      attacker: attacker ?? this.attacker,
      defender: defender ?? this.defender,
      ruleset: ruleset ?? this.ruleset,
      attackerLevel: attackerLevel ?? this.attackerLevel,
      attackerNature: attackerNature ?? this.attackerNature,
      attackerIvs: attackerIvs ?? Map<String, int>.from(this.attackerIvs),
      attackerEvs: attackerEvs ?? Map<String, int>.from(this.attackerEvs),
      attackerStages: attackerStages ?? Map<String, int>.from(this.attackerStages),
      attackerHeldItem: attackerHeldItem ?? this.attackerHeldItem,
      attackerAbility: attackerAbility is _Sentinel ? this.attackerAbility : attackerAbility as String?,
      attackerTeraActive: attackerTeraActive ?? this.attackerTeraActive,
      attackerTeraType: attackerTeraType is _Sentinel ? this.attackerTeraType : attackerTeraType as String?,
      attackerStatus: attackerStatus ?? this.attackerStatus,
      attackerFriendship: attackerFriendship ?? this.attackerFriendship,
      attackerHpPercent: attackerHpPercent ?? this.attackerHpPercent,
      selectedMoveName: selectedMoveName ?? this.selectedMoveName,
      moveType: moveType ?? this.moveType,
      moveCategory: moveCategory ?? this.moveCategory,
      movePower: movePower ?? this.movePower,
      rageFistHits: rageFistHits ?? this.rageFistHits,
      attackerTurnsOnField: attackerTurnsOnField ?? this.attackerTurnsOnField,
      defenderLevel: defenderLevel ?? this.defenderLevel,
      defenderNature: defenderNature ?? this.defenderNature,
      defenderIvs: defenderIvs ?? Map<String, int>.from(this.defenderIvs),
      defenderEvs: defenderEvs ?? Map<String, int>.from(this.defenderEvs),
      defenderStages: defenderStages ?? Map<String, int>.from(this.defenderStages),
      defenderHeldItem: defenderHeldItem ?? this.defenderHeldItem,
      defenderAbility: defenderAbility is _Sentinel ? this.defenderAbility : defenderAbility as String?,
      defenderTeraActive: defenderTeraActive ?? this.defenderTeraActive,
      defenderTeraType: defenderTeraType is _Sentinel ? this.defenderTeraType : defenderTeraType as String?,
      defenderStatus: defenderStatus ?? this.defenderStatus,
      defenderHpPercent: defenderHpPercent ?? this.defenderHpPercent,
      isCriticalHit: isCriticalHit ?? this.isCriticalHit,
      weather: weather ?? this.weather,
      terrain: terrain ?? this.terrain,
      reflectActive: reflectActive ?? this.reflectActive,
      lightScreenActive: lightScreenActive ?? this.lightScreenActive,
      helpingHandActive: helpingHandActive ?? this.helpingHandActive,
      trickRoomActive: trickRoomActive ?? this.trickRoomActive,
      defenderProtected: defenderProtected ?? this.defenderProtected,
      isDoubleBattle: isDoubleBattle ?? this.isDoubleBattle,
      simpleAttackerStat: simpleAttackerStat ?? this.simpleAttackerStat,
      simpleDefenderStat: simpleDefenderStat ?? this.simpleDefenderStat,
      simpleStab: simpleStab ?? this.simpleStab,
      simpleEffectiveness: simpleEffectiveness ?? this.simpleEffectiveness,
      attackerSps: attackerSps ?? Map<String, int>.from(this.attackerSps),
      defenderSps: defenderSps ?? Map<String, int>.from(this.defenderSps),
    );
  }

  /// Convert calculator state to pure-Dart [BattleState].
  BattleState? toBattleState() {
    if (attacker == null || defender == null) return null;

    final atkState = PokemonState.fromDatabase(
      attacker!,
      level: attackerLevel,
      nature: attackerNature,
      ivs: attackerIvs,
      evs: attackerEvs,
      sps: attackerSps,
      stages: attackerStages,
      heldItem: attackerHeldItem,
      ability: attackerAbility,
      status: attackerStatus,
      teraActive: attackerTeraActive,
      teraType: attackerTeraType,
      hpPercent: attackerHpPercent,
      turnsOnField: attackerTurnsOnField,
      friendship: attackerFriendship,
    );

    final defState = PokemonState.fromDatabase(
      defender!,
      level: defenderLevel,
      nature: defenderNature,
      ivs: defenderIvs,
      evs: defenderEvs,
      sps: defenderSps,
      stages: defenderStages,
      heldItem: defenderHeldItem,
      ability: defenderAbility,
      status: defenderStatus,
      teraActive: defenderTeraActive,
      teraType: defenderTeraType,
      hpPercent: defenderHpPercent,
    );

    final moveState = MoveState(
      name: selectedMoveName ?? 'Custom Move',
      type: moveType,
      basePower: movePower.round(),
      damageClass: moveCategory,
      isCritical: isCriticalHit,
      hits: moveHits,
      rageFistHits: rageFistHits,
    );

    final fieldState = FieldState(
      weather: weather,
      terrain: terrain,
      reflectActive: reflectActive,
      lightScreenActive: lightScreenActive,
      helpingHandActive: helpingHandActive,
      trickRoomActive: trickRoomActive,
      defenderProtected: defenderProtected,
      isDoubleBattle: isDoubleBattle,
    );

    return BattleState(
      attacker: atkState,
      defender: defState,
      move: moveState,
      field: fieldState,
      ruleset: ruleset,
    );
  }

  /// Calculate damage using the pure-Dart [BattleEngine].
  DamageResult? calculateDamage() {
    final bState = toBattleState();
    if (bState == null) return null;
    return BattleEngine.calculate(bState);
  }
}

class _Sentinel {
  const _Sentinel();
}

@riverpod
class DamageCalculatorViewModel extends _$DamageCalculatorViewModel {
  static const _rulesetPrefsKey = 'damage_calculator_ruleset';

  /// Completes once the persisted ruleset has been applied, so in-flight
  /// launch intents (e.g. "open in calculator" from a Champions team) are
  /// never clobbered by the preferences load.
  final Completer<void> _rulesetReady = Completer<void>();
  Future<void> get rulesetReady => _rulesetReady.future;

  @override
  DamageCalculatorState build() {
    _loadRuleset();
    return DamageCalculatorState(
      attackerIvs: {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
      attackerEvs: {'hp': 252, 'atk': 252, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 4},
      attackerStages: {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      defenderIvs: {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
      defenderEvs: {'hp': 252, 'atk': 0, 'def': 252, 'spa': 0, 'spd': 4, 'spe': 0},
      defenderStages: {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      // Champions defaults mirror the competitive mainline spreads on the
      // left: a fast physical attacker vs. a bulky physical defender.
      attackerSps: Map<String, int>.from(ChampionsStatPreset.presets.first.spread),
      defenderSps: Map<String, int>.from(ChampionsStatPreset.presets[2].spread),
    );
  }

  Future<void> _loadRuleset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_rulesetPrefsKey);
      if (saved == BattleRuleset.champions.name) {
        _applyRuleset(BattleRuleset.champions);
      }
    } finally {
      if (!_rulesetReady.isCompleted) _rulesetReady.complete();
    }
  }

  /// Applies a ruleset change in-memory only; Champions natures that do not
  /// exist as Stat Alignments (Hardy/Docile/Bashful/Quirky) normalize to
  /// Serious, the single neutral alignment.
  void _applyRuleset(BattleRuleset next) {
    String normalize(String nature) =>
        next.isChampions && !ChampionsRules.isValidAlignment(nature) ? 'serious' : nature;
    final attacker = normalize(state.attackerNature);
    final defender = normalize(state.defenderNature);
    state = state.copyWith(
      ruleset: next,
      attackerNature: attacker,
      defenderNature: defender,
    );
  }

  Future<void> setRuleset(BattleRuleset next) async {
    if (state.ruleset == next) return;
    _applyRuleset(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rulesetPrefsKey, next.name);
  }

  void updateAttackerSp(String key, int val) {
    final map = Map<String, int>.from(state.attackerSps);
    map[key] = ChampionsRules.clampStatPoint(map, key, val);
    state = state.copyWith(attackerSps: map);
  }

  void updateDefenderSp(String key, int val) {
    final map = Map<String, int>.from(state.defenderSps);
    map[key] = ChampionsRules.clampStatPoint(map, key, val);
    state = state.copyWith(defenderSps: map);
  }

  void applyChampionsPreset({required bool isAttacker, required ChampionsStatPreset preset}) {
    if (isAttacker) {
      state = state.copyWith(attackerSps: Map<String, int>.from(preset.spread));
    } else {
      state = state.copyWith(defenderSps: Map<String, int>.from(preset.spread));
    }
  }

  void setAttacker(Pokemon p, {String? defaultAbility}) {
    state = state.copyWith(
      attacker: p,
      selectedMoveName: null,
      attackerAbility: defaultAbility ?? state.attackerAbility,
      attackerTeraType: p.type1,
    );
  }

  void setDefender(Pokemon p, {String? defaultAbility}) {
    state = state.copyWith(
      defender: p,
      defenderAbility: defaultAbility ?? state.defenderAbility,
      defenderTeraType: p.type1,
    );
  }

  void setAttackerAbility(String? ability) => state = state.copyWith(attackerAbility: ability);
  void setDefenderAbility(String? ability) => state = state.copyWith(defenderAbility: ability);
  void toggleAttackerTera(bool active) => state = state.copyWith(attackerTeraActive: active);
  void setAttackerTeraType(String type) => state = state.copyWith(attackerTeraType: type);
  void toggleDefenderTera(bool active) => state = state.copyWith(defenderTeraActive: active);
  void setDefenderTeraType(String type) => state = state.copyWith(defenderTeraType: type);

  void setAttackerStatus(String status) => state = state.copyWith(attackerStatus: status);
  void setDefenderStatus(String status) => state = state.copyWith(defenderStatus: status);
  void setAttackerFriendship(int val) => state = state.copyWith(attackerFriendship: val.clamp(0, 255));
  void setAttackerHpPercent(double val) => state = state.copyWith(attackerHpPercent: val.clamp(1.0, 100.0));
  void setDefenderHpPercent(double val) => state = state.copyWith(defenderHpPercent: val.clamp(1.0, 100.0));
  void toggleCriticalHit(bool val) => state = state.copyWith(isCriticalHit: val);
  void setAttackerTurnsOnField(int turns) =>
      state = state.copyWith(attackerTurnsOnField: turns.clamp(0, 5));

  void setRageFistHits(int hits) {
    final clamped = hits.clamp(0, 6);
    final basePower = 50.0 + (clamped * 50.0);
    state = state.copyWith(rageFistHits: clamped, movePower: basePower);
  }

  void setAttackerHeldItem(String item) => state = state.copyWith(attackerHeldItem: item);
  void setDefenderHeldItem(String item) => state = state.copyWith(defenderHeldItem: item);

  void updateAttackerLevel(int lvl) => state = state.copyWith(attackerLevel: lvl);
  void updateDefenderLevel(int lvl) => state = state.copyWith(defenderLevel: lvl);
  void updateAttackerNature(String nature) => state = state.copyWith(attackerNature: nature);
  void updateDefenderNature(String nature) => state = state.copyWith(defenderNature: nature);

  void updateAttackerIv(String key, int val) {
    final map = Map<String, int>.from(state.attackerIvs);
    map[key] = val;
    state = state.copyWith(attackerIvs: map);
  }

  void updateAttackerEv(String key, int val) {
    final map = Map<String, int>.from(state.attackerEvs);
    map[key] = val;
    state = state.copyWith(attackerEvs: map);
  }

  void updateDefenderIv(String key, int val) {
    final map = Map<String, int>.from(state.defenderIvs);
    map[key] = val;
    state = state.copyWith(defenderIvs: map);
  }

  void updateDefenderEv(String key, int val) {
    final map = Map<String, int>.from(state.defenderEvs);
    map[key] = val;
    state = state.copyWith(defenderEvs: map);
  }

  void updateAttackerStage(String key, int val) {
    final map = Map<String, int>.from(state.attackerStages);
    map[key] = val.clamp(-6, 6);
    state = state.copyWith(attackerStages: map);
  }

  void updateDefenderStage(String key, int val) {
    final map = Map<String, int>.from(state.defenderStages);
    map[key] = val.clamp(-6, 6);
    state = state.copyWith(defenderStages: map);
  }

  void selectMove(String name, String type, String category, double power) {
    int hits = state.rageFistHits;
    double actualPower = power;
    if (name.toLowerCase() == 'rage fist') {
      actualPower = 50.0 + (hits * 50.0);
    }
    final isVariableMulti = CombatUtils.isVariableMultiHitMove(name);
    state = state.copyWith(
      selectedMoveName: name,
      moveType: type,
      moveCategory: category,
      movePower: actualPower,
      moveHits: isVariableMulti ? 3 : 1,
    );
  }

  void updateMoveType(String type) => state = state.copyWith(moveType: type);
  void updateMoveCategory(String category) => state = state.copyWith(moveCategory: category);
  void updateMovePower(double power) => state = state.copyWith(movePower: power);
  void updateMoveHits(int hits) => state = state.copyWith(moveHits: hits.clamp(1, 10));
  void setSimpleAttackerStat(double stat) => state = state.copyWith(simpleAttackerStat: stat);
  void setSimpleDefenderStat(double stat) => state = state.copyWith(simpleDefenderStat: stat);
  void setSimpleStab(double stab) => state = state.copyWith(simpleStab: stab);
  void setSimpleEffectiveness(double eff) => state = state.copyWith(simpleEffectiveness: eff);

  void setWeather(String w) => state = state.copyWith(weather: w);
  void setTerrain(String t) => state = state.copyWith(terrain: t);
  void toggleReflect(bool val) => state = state.copyWith(reflectActive: val);
  void toggleLightScreen(bool val) => state = state.copyWith(lightScreenActive: val);
  void toggleHelpingHand(bool val) => state = state.copyWith(helpingHandActive: val);
  void toggleDefenderProtected(bool val) => state = state.copyWith(defenderProtected: val);
  void toggleTrickRoom(bool val) => state = state.copyWith(trickRoomActive: val);
  void toggleDoubleBattle(bool val) => state = state.copyWith(isDoubleBattle: val);

  /// Swaps Attacker and Defender Pokémon and all their associated battle stats.
  void swapAttackerAndDefender() {
    final s = state;
    state = s.copyWith(
      attacker: s.defender,
      defender: s.attacker,
      attackerLevel: s.defenderLevel,
      defenderLevel: s.attackerLevel,
      attackerNature: s.defenderNature,
      defenderNature: s.attackerNature,
      attackerIvs: Map.of(s.defenderIvs),
      defenderIvs: Map.of(s.attackerIvs),
      attackerEvs: Map.of(s.defenderEvs),
      defenderEvs: Map.of(s.attackerEvs),
      attackerSps: Map.of(s.defenderSps),
      defenderSps: Map.of(s.attackerSps),
      attackerStages: Map.of(s.defenderStages),
      defenderStages: Map.of(s.attackerStages),
      attackerHeldItem: s.defenderHeldItem,
      defenderHeldItem: s.attackerHeldItem,
      attackerAbility: s.defenderAbility,
      defenderAbility: s.attackerAbility,
      attackerTeraActive: s.defenderTeraActive,
      defenderTeraActive: s.attackerTeraActive,
      attackerTeraType: s.defenderTeraType,
      defenderTeraType: s.attackerTeraType,
      attackerStatus: s.defenderStatus,
      defenderStatus: s.attackerStatus,
      attackerHpPercent: s.defenderHpPercent,
      defenderHpPercent: s.attackerHpPercent,
    );
  }
}

/// A one-shot request for the damage calculator to open in a specific
/// configuration — e.g. the Team Builder's "analyze in calculator" action,
/// which switches straight to the team's ruleset with the member loaded as
/// attacker. Cross-section navigation cannot pass arguments through the
/// home IndexedStack, so the intent is parked here and consumed once by the
/// calculator screen after the first frame.
class CalculatorLaunchIntent {
  final int? attackerPokemonId;
  final BattleRuleset? ruleset;

  const CalculatorLaunchIntent({this.attackerPokemonId, this.ruleset});
}

final calculatorLaunchIntentProvider =
    NotifierProvider<CalculatorLaunchIntentNotifier, CalculatorLaunchIntent?>(
  CalculatorLaunchIntentNotifier.new,
);

class CalculatorLaunchIntentNotifier extends Notifier<CalculatorLaunchIntent?> {
  @override
  CalculatorLaunchIntent? build() => null;

  void request(CalculatorLaunchIntent intent) => state = intent;

  /// Returns the pending intent, if any, and clears it.
  CalculatorLaunchIntent? consume() {
    final pending = state;
    state = null;
    return pending;
  }
}

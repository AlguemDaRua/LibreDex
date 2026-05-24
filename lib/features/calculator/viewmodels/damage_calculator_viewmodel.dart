import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:libredex/core/database/app_database.dart';

part 'damage_calculator_viewmodel.g.dart';

class DamageCalculatorState {
  final Pokemon? attacker;
  final Pokemon? defender;

  // Attacker Stats Settings
  final int attackerLevel;
  final String attackerNature;
  final Map<String, int> attackerIvs;
  final Map<String, int> attackerEvs;
  final Map<String, int> attackerStages;

  // Active Move Settings
  final String? selectedMoveName;
  final String moveType;
  final String moveCategory;
  final double movePower;

  // Defender Stats Settings
  final int defenderLevel;
  final String defenderNature;
  final Map<String, int> defenderIvs;
  final Map<String, int> defenderEvs;
  final Map<String, int> defenderStages;

  // Direct Simple Tab Overrides
  final double simpleDefenderStat;

  // Global Battlefield Tweaks
  final String weather;
  final String terrain;
  final bool reflectActive;
  final bool lightScreenActive;
  final bool helpingHandActive;
  final bool trickRoomActive;

  DamageCalculatorState({
    this.attacker,
    this.defender,
    this.attackerLevel = 50,
    this.attackerNature = 'adamant',
    required this.attackerIvs,
    required this.attackerEvs,
    required this.attackerStages,
    this.selectedMoveName,
    this.moveType = 'fire',
    this.moveCategory = 'physical',
    this.movePower = 90.0,
    this.defenderLevel = 50,
    this.defenderNature = 'bold',
    required this.defenderIvs,
    required this.defenderEvs,
    required this.defenderStages,
    this.simpleDefenderStat = 120.0,
    this.weather = 'none',
    this.terrain = 'none',
    this.reflectActive = false,
    this.lightScreenActive = false,
    this.helpingHandActive = false,
    this.trickRoomActive = false,
  });

  DamageCalculatorState copyWith({
    Pokemon? attacker,
    Pokemon? defender,
    int? attackerLevel,
    String? attackerNature,
    Map<String, int>? attackerIvs,
    Map<String, int>? attackerEvs,
    Map<String, int>? attackerStages,
    String? selectedMoveName,
    String? moveType,
    String? moveCategory,
    double? movePower,
    int? defenderLevel,
    String? defenderNature,
    Map<String, int>? defenderIvs,
    Map<String, int>? defenderEvs,
    Map<String, int>? defenderStages,
    double? simpleDefenderStat,
    String? weather,
    String? terrain,
    bool? reflectActive,
    bool? lightScreenActive,
    bool? helpingHandActive,
    bool? trickRoomActive,
  }) {
    return DamageCalculatorState(
      attacker: attacker ?? this.attacker,
      defender: defender ?? this.defender,
      attackerLevel: attackerLevel ?? this.attackerLevel,
      attackerNature: attackerNature ?? this.attackerNature,
      attackerIvs: attackerIvs ?? Map<String, int>.from(this.attackerIvs),
      attackerEvs: attackerEvs ?? Map<String, int>.from(this.attackerEvs),
      attackerStages: attackerStages ?? Map<String, int>.from(this.attackerStages),
      selectedMoveName: selectedMoveName ?? this.selectedMoveName,
      moveType: moveType ?? this.moveType,
      moveCategory: moveCategory ?? this.moveCategory,
      movePower: movePower ?? this.movePower,
      defenderLevel: defenderLevel ?? this.defenderLevel,
      defenderNature: defenderNature ?? this.defenderNature,
      defenderIvs: defenderIvs ?? Map<String, int>.from(this.defenderIvs),
      defenderEvs: defenderEvs ?? Map<String, int>.from(this.defenderEvs),
      defenderStages: defenderStages ?? Map<String, int>.from(this.defenderStages),
      simpleDefenderStat: simpleDefenderStat ?? this.simpleDefenderStat,
      weather: weather ?? this.weather,
      terrain: terrain ?? this.terrain,
      reflectActive: reflectActive ?? this.reflectActive,
      lightScreenActive: lightScreenActive ?? this.lightScreenActive,
      helpingHandActive: helpingHandActive ?? this.helpingHandActive,
      trickRoomActive: trickRoomActive ?? this.trickRoomActive,
    );
  }
}

@riverpod
class DamageCalculatorViewModel extends _$DamageCalculatorViewModel {
  @override
  DamageCalculatorState build() {
    return DamageCalculatorState(
      attackerIvs: {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
      attackerEvs: {'hp': 252, 'atk': 252, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 4},
      attackerStages: {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      defenderIvs: {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
      defenderEvs: {'hp': 252, 'atk': 0, 'def': 252, 'spa': 0, 'spd': 4, 'spe': 0},
      defenderStages: {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
    );
  }

  void setAttacker(Pokemon p) {
    state = state.copyWith(attacker: p, selectedMoveName: null);
  }

  void setDefender(Pokemon p) {
    state = state.copyWith(defender: p);
  }

  void updateAttackerLevel(int lvl) {
    state = state.copyWith(attackerLevel: lvl);
  }

  void updateDefenderLevel(int lvl) {
    state = state.copyWith(defenderLevel: lvl);
  }

  void updateAttackerNature(String nature) {
    state = state.copyWith(attackerNature: nature);
  }

  void updateDefenderNature(String nature) {
    state = state.copyWith(defenderNature: nature);
  }

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
    state = state.copyWith(
      selectedMoveName: name,
      moveType: type,
      moveCategory: category,
      movePower: power,
    );
  }

  void updateMoveType(String type) {
    state = state.copyWith(moveType: type);
  }

  void updateMoveCategory(String category) {
    state = state.copyWith(moveCategory: category);
  }

  void updateMovePower(double power) {
    state = state.copyWith(movePower: power);
  }

  void setSimpleDefenderStat(double stat) {
    state = state.copyWith(simpleDefenderStat: stat);
  }

  void setWeather(String w) {
    state = state.copyWith(weather: w);
  }

  void setTerrain(String t) {
    state = state.copyWith(terrain: t);
  }

  void toggleReflect(bool val) {
    state = state.copyWith(reflectActive: val);
  }

  void toggleLightScreen(bool val) {
    state = state.copyWith(lightScreenActive: val);
  }

  void toggleHelpingHand(bool val) {
    state = state.copyWith(helpingHandActive: val);
  }

  void toggleTrickRoom(bool val) {
    state = state.copyWith(trickRoomActive: val);
  }
}

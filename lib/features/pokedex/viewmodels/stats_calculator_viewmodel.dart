import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_calculator_viewmodel.g.dart';

/// Mapping of all 25 natures and their 10% beneficial (+10%) and hindering (-10%) stat modifiers.
const Map<String, Map<String, double>> natureModifiers = {
  'Hardy': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
  'Lonely': {'Atk': 1.1, 'Def': 0.9, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
  'Brave': {'Atk': 1.1, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 0.9},
  'Adamant': {'Atk': 1.1, 'Def': 1.0, 'SpA': 0.9, 'SpD': 1.0, 'Spe': 1.0},
  'Naughty': {'Atk': 1.1, 'Def': 1.0, 'SpA': 1.0, 'SpD': 0.9, 'Spe': 1.0},
  'Bold': {'Atk': 0.9, 'Def': 1.1, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
  'Docile': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
  'Relaxed': {'Atk': 1.0, 'Def': 1.1, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 0.9},
  'Impish': {'Atk': 1.0, 'Def': 1.1, 'SpA': 0.9, 'SpD': 1.0, 'Spe': 1.0},
  'Lax': {'Atk': 1.0, 'Def': 1.1, 'SpA': 1.0, 'SpD': 0.9, 'Spe': 1.0},
  'Modest': {'Atk': 0.9, 'Def': 1.0, 'SpA': 1.1, 'SpD': 1.0, 'Spe': 1.0},
  'Mild': {'Atk': 1.0, 'Def': 0.9, 'SpA': 1.1, 'SpD': 1.0, 'Spe': 1.0},
  'Quiet': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.1, 'SpD': 1.0, 'Spe': 0.9},
  'Bashful': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
  'Rash': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.1, 'SpD': 0.9, 'Spe': 1.0},
  'Calm': {'Atk': 0.9, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.1, 'Spe': 1.0},
  'Gentle': {'Atk': 1.0, 'Def': 0.9, 'SpA': 1.0, 'SpD': 1.1, 'Spe': 1.0},
  'Sassy': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.1, 'Spe': 0.9},
  'Careful': {'Atk': 1.0, 'Def': 1.0, 'SpA': 0.9, 'SpD': 1.1, 'Spe': 1.0},
  'Quirky': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
  'Timid': {'Atk': 0.9, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.1},
  'Hasty': {'Atk': 1.0, 'Def': 0.9, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.1},
  'Jolly': {'Atk': 1.0, 'Def': 1.0, 'SpA': 0.9, 'SpD': 1.0, 'Spe': 1.1},
  'Naive': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 0.9, 'Spe': 1.1},
  'Serious': {'Atk': 1.0, 'Def': 1.0, 'SpA': 1.0, 'SpD': 1.0, 'Spe': 1.0},
};

/// Immutable state containing IVs, EVs, Level, and Active Nature for competitive calculations.
class StatsCalculatorState {
  final int level;
  final Map<String, int> ivs;
  final Map<String, int> evs;
  final String nature;

  StatsCalculatorState({
    required this.level,
    required this.ivs,
    required this.evs,
    required this.nature,
  });

  StatsCalculatorState.initial()
      : level = 100,
        ivs = {
          'HP': 31,
          'Atk': 31,
          'Def': 31,
          'SpA': 31,
          'SpD': 31,
          'Spe': 31,
        },
        evs = {
          'HP': 0,
          'Atk': 0,
          'Def': 0,
          'SpA': 0,
          'SpD': 0,
          'Spe': 0,
        },
        nature = 'Serious';

  StatsCalculatorState copyWith({
    int? level,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    String? nature,
  }) {
    return StatsCalculatorState(
      level: level ?? this.level,
      ivs: ivs ?? this.ivs,
      evs: evs ?? this.evs,
      nature: nature ?? this.nature,
    );
  }

  /// Calculates total Effort Values sum (max 508).
  int get totalEvs => evs.values.fold(0, (sum, val) => sum + val);
}

/// State notifier utilizing Riverpod codegen to manage individual competitive custom statistics.
@riverpod
class StatsCalculator extends _$StatsCalculator {
  @override
  StatsCalculatorState build() {
    return StatsCalculatorState.initial();
  }

  /// Updates Level (1 to 100).
  void updateLevel(int newLevel) {
    state = state.copyWith(level: newLevel.clamp(1, 100));
  }

  /// Updates Individual Value (0 to 31).
  void updateIv(String statName, int newValue) {
    final newIvs = Map<String, int>.from(state.ivs);
    newIvs[statName] = newValue.clamp(0, 31);
    state = state.copyWith(ivs: newIvs);
  }

  /// Updates Effort Value (0 to 252, total EV sum limited strictly to 508).
  void updateEv(String statName, int newValue) {
    final currentEvs = Map<String, int>.from(state.evs);
    currentEvs[statName] = 0; // Temporarily subtract current value to assess max cap
    final currentSum = currentEvs.values.fold(0, (sum, val) => sum + val);

    final maxAllowedValue = (508 - currentSum).clamp(0, 252);
    final finalValue = newValue.clamp(0, maxAllowedValue);

    final newEvs = Map<String, int>.from(state.evs);
    newEvs[statName] = finalValue;
    state = state.copyWith(evs: newEvs);
  }

  /// Updates nature.
  void updateNature(String natureName) {
    if (natureModifiers.containsKey(natureName)) {
      state = state.copyWith(nature: natureName);
    }
  }

  /// Resets state.
  void reset() {
    state = StatsCalculatorState.initial();
  }

  /// Returns final calculated stats based on current state values and standard Pokémon formulas.
  Map<String, int> getCalculatedStats(Pokemon pokemon) {
    final hp = StatCalculator.calculateHp(
      base: pokemon.baseHp,
      iv: state.ivs['HP'] ?? 31,
      ev: state.evs['HP'] ?? 0,
      level: state.level,
      isShedinja: pokemon.name.toLowerCase() == 'shedinja',
    );

    final modifiers = natureModifiers[state.nature] ?? {};

    final atk = StatCalculator.calculateOtherStat(
      base: pokemon.baseAtk,
      iv: state.ivs['Atk'] ?? 31,
      ev: state.evs['Atk'] ?? 0,
      level: state.level,
      natureModifier: modifiers['Atk'] ?? 1.0,
    );

    final def = StatCalculator.calculateOtherStat(
      base: pokemon.baseDef,
      iv: state.ivs['Def'] ?? 31,
      ev: state.evs['Def'] ?? 0,
      level: state.level,
      natureModifier: modifiers['Def'] ?? 1.0,
    );

    final spa = StatCalculator.calculateOtherStat(
      base: pokemon.baseSpAtk,
      iv: state.ivs['SpA'] ?? 31,
      ev: state.evs['SpA'] ?? 0,
      level: state.level,
      natureModifier: modifiers['SpA'] ?? 1.0,
    );

    final spd = StatCalculator.calculateOtherStat(
      base: pokemon.baseSpDef,
      iv: state.ivs['SpD'] ?? 31,
      ev: state.evs['SpD'] ?? 0,
      level: state.level,
      natureModifier: modifiers['SpD'] ?? 1.0,
    );

    final spe = StatCalculator.calculateOtherStat(
      base: pokemon.baseSpd,
      iv: state.ivs['Spe'] ?? 31,
      ev: state.evs['Spe'] ?? 0,
      level: state.level,
      natureModifier: modifiers['Spe'] ?? 1.0,
    );

    return {
      'HP': hp,
      'Atk': atk,
      'Def': def,
      'SpA': spa,
      'SpD': spd,
      'Spe': spe,
    };
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/core/database/app_database.dart';

part 'stats_calculator_viewmodel.g.dart';

/// Estado imutável para a calculadora reativa do Pokémon Showdown.
class StatsCalculatorState {
  final int level;
  final Map<String, int> ivs;
  final Map<String, int> evs;
  final String nature;
  final String heldItem;

  StatsCalculatorState({
    required this.level,
    required this.ivs,
    required this.evs,
    required this.nature,
    this.heldItem = 'None',
  });

  int get totalEvs => evs.values.fold(0, (sum, val) => sum + val);

  StatsCalculatorState copyWith({
    int? level,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    String? nature,
    String? heldItem,
  }) {
    return StatsCalculatorState(
      level: level ?? this.level,
      ivs: ivs ?? this.ivs,
      evs: evs ?? this.evs,
      nature: nature ?? this.nature,
      heldItem: heldItem ?? this.heldItem,
    );
  }
}

@riverpod
class StatsCalculator extends _$StatsCalculator {
  @override
  StatsCalculatorState build() {
    return StatsCalculatorState(
      level: 100, // Nível padrão Showdown
      ivs: {
        'hp': 31,
        'atk': 31,
        'def': 31,
        'spa': 31,
        'spd': 31,
        'spe': 31,
      },
      evs: {
        'hp': 0,
        'atk': 0,
        'def': 0,
        'spa': 0,
        'spd': 0,
        'spe': 0,
      },
      nature: 'serious', // Natureza neutra inicial
    );
  }

  void updateLevel(int level) {
    state = state.copyWith(level: level);
  }

  void updateIv(String statKey, int value) {
    final updatedIvs = Map<String, int>.from(state.ivs);
    updatedIvs[statKey] = value.clamp(0, 31);
    state = state.copyWith(ivs: updatedIvs);
  }

  void updateEv(String statKey, int value) {
    final updatedEvs = Map<String, int>.from(state.evs);
    final int otherEvsSum = updatedEvs.entries
        .where((entry) => entry.key != statKey)
        .fold(0, (sum, entry) => sum + entry.value);

    int allowedValue = value.clamp(0, 252);
    if (otherEvsSum + allowedValue > 508) {
      allowedValue = 508 - otherEvsSum;
    }

    updatedEvs[statKey] = allowedValue;
    state = state.copyWith(evs: updatedEvs);
  }

  void updateNature(String natureId) {
    state = state.copyWith(nature: natureId);
  }

  void updateHeldItem(String item) {
    state = state.copyWith(heldItem: item);
  }

  void reset() {
    state = build();
  }

  /// Returns item-based multiplier for a given stat key.
  double _getItemStatMultiplier(String statKey) {
    final item = state.heldItem;
    switch (item) {
      case 'Choice Band':   return statKey == 'atk' ? 1.5 : 1.0;
      case 'Choice Specs':  return statKey == 'spa' ? 1.5 : 1.0;
      case 'Choice Scarf':  return statKey == 'spe' ? 1.5 : 1.0;
      case 'Assault Vest':  return statKey == 'spd' ? 1.5 : 1.0;
      case 'Eviolite':      return (statKey == 'def' || statKey == 'spd') ? 1.5 : 1.0;
      case 'Thick Club':    return statKey == 'atk' ? 2.0 : 1.0;
      case 'Deep Sea Tooth': return statKey == 'spa' ? 2.0 : 1.0;
      case 'Iron Ball':     return statKey == 'spe' ? 0.5 : 1.0;
      case 'Lagging Tail':  return statKey == 'spe' ? 0.5 : 1.0;
      case 'Quick Powder':  return statKey == 'spe' ? 2.0 : 1.0;
      default:              return 1.0;
    }
  }

  /// Retorna o multiplicador da Natureza oficial do Pokémon para cada atributo.
  double getNatureMultiplier(String nature, String stat) {
    if (stat == 'HP') return 1.0;
    final String n = nature.toLowerCase();
    
    if (n == 'adamant') {
      if (stat == 'Attack') return 1.1;
      if (stat == 'Sp. Atk') return 0.9;
    }
    if (n == 'bold') {
      if (stat == 'Defense') return 1.1;
      if (stat == 'Attack') return 0.9;
    }
    if (n == 'brave') {
      if (stat == 'Attack') return 1.1;
      if (stat == 'Speed') return 0.9;
    }
    if (n == 'calm') {
      if (stat == 'Sp. Def') return 1.1;
      if (stat == 'Attack') return 0.9;
    }
    if (n == 'careful') {
      if (stat == 'Sp. Def') return 1.1;
      if (stat == 'Sp. Atk') return 0.9;
    }
    if (n == 'gentle') {
      if (stat == 'Sp. Def') return 1.1;
      if (stat == 'Defense') return 0.9;
    }
    if (n == 'hasty') {
      if (stat == 'Speed') return 1.1;
      if (stat == 'Defense') return 0.9;
    }
    if (n == 'impish') {
      if (stat == 'Defense') return 1.1;
      if (stat == 'Sp. Atk') return 0.9;
    }
    if (n == 'jolly') {
      if (stat == 'Speed') return 1.1;
      if (stat == 'Sp. Atk') return 0.9;
    }
    if (n == 'lax') {
      if (stat == 'Defense') return 1.1;
      if (stat == 'Sp. Def') return 0.9;
    }
    if (n == 'lonely') {
      if (stat == 'Attack') return 1.1;
      if (stat == 'Defense') return 0.9;
    }
    if (n == 'mild') {
      if (stat == 'Sp. Atk') return 1.1;
      if (stat == 'Defense') return 0.9;
    }
    if (n == 'modest') {
      if (stat == 'Sp. Atk') return 1.1;
      if (stat == 'Attack') return 0.9;
    }
    if (n == 'naive') {
      if (stat == 'Speed') return 1.1;
      if (stat == 'Sp. Def') return 0.9;
    }
    if (n == 'naughty') {
      if (stat == 'Attack') return 1.1;
      if (stat == 'Sp. Def') return 0.9;
    }
    if (n == 'quiet') {
      if (stat == 'Sp. Atk') return 1.1;
      if (stat == 'Speed') return 0.9;
    }
    if (n == 'rash') {
      if (stat == 'Sp. Atk') return 1.1;
      if (stat == 'Sp. Def') return 0.9;
    }
    if (n == 'relaxed') {
      if (stat == 'Defense') return 1.1;
      if (stat == 'Speed') return 0.9;
    }
    if (n == 'sassy') {
      if (stat == 'Sp. Def') return 1.1;
      if (stat == 'Speed') return 0.9;
    }
    if (n == 'timid') {
      if (stat == 'Speed') return 1.1;
      if (stat == 'Attack') return 0.9;
    }
    return 1.0; // Neutro
  }

  /// Calculates all stats applying nature + held item multipliers.
  Map<String, int> getCalculatedStats(Pokemon pokemon) {
    int applyItem(int base, String key) =>
        (base * _getItemStatMultiplier(key)).floor();
    return {
      'hp': StatCalculator.calculateHp(
        base: pokemon.baseHp,
        iv: state.ivs['hp'] ?? 31,
        ev: state.evs['hp'] ?? 0,
        level: state.level,
      ),
      'atk': applyItem(StatCalculator.calculateOtherStat(
        base: pokemon.baseAtk,
        iv: state.ivs['atk'] ?? 31,
        ev: state.evs['atk'] ?? 0,
        level: state.level,
        natureModifier: getNatureMultiplier(state.nature, 'Attack'),
      ), 'atk'),
      'def': applyItem(StatCalculator.calculateOtherStat(
        base: pokemon.baseDef,
        iv: state.ivs['def'] ?? 31,
        ev: state.evs['def'] ?? 0,
        level: state.level,
        natureModifier: getNatureMultiplier(state.nature, 'Defense'),
      ), 'def'),
      'spa': applyItem(StatCalculator.calculateOtherStat(
        base: pokemon.baseSpAtk,
        iv: state.ivs['spa'] ?? 31,
        ev: state.evs['spa'] ?? 0,
        level: state.level,
        natureModifier: getNatureMultiplier(state.nature, 'Sp. Atk'),
      ), 'spa'),
      'spd': applyItem(StatCalculator.calculateOtherStat(
        base: pokemon.baseSpDef,
        iv: state.ivs['spd'] ?? 31,
        ev: state.evs['spd'] ?? 0,
        level: state.level,
        natureModifier: getNatureMultiplier(state.nature, 'Sp. Def'),
      ), 'spd'),
      'spe': applyItem(StatCalculator.calculateOtherStat(
        base: pokemon.baseSpd,
        iv: state.ivs['spe'] ?? 31,
        ev: state.evs['spe'] ?? 0,
        level: state.level,
        natureModifier: getNatureMultiplier(state.nature, 'Speed'),
      ), 'spe'),
    };
  }
}
/// Stat calculation engine for battle participants.
library;

import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';
import 'package:libredex/features/stat_comparison/models/stat_modifier.dart';
import 'package:libredex/features/battle_engine/models/pokemon_state.dart';

class StatEngine {
  StatEngine._();

  /// Converts a [PokemonState] into a [ComparisonEntry] so it can leverage
  /// the verified [StatModifier] engine.
  static ComparisonEntry _toComparisonEntry(
    PokemonState state, {
    String weather = 'none',
    String terrain = 'none',
  }) {
    // Construct dummy database Pokemon object for StatModifier
    final p = Pokemon(
      id: state.id,
      name: state.name,
      form: state.form,
      type1: state.types.first,
      type2: state.types.length > 1 ? state.types[1] : null,
      baseHp: state.baseStats['hp'] ?? 50,
      baseAtk: state.baseStats['atk'] ?? 50,
      baseDef: state.baseStats['def'] ?? 50,
      baseSpAtk: state.baseStats['spa'] ?? 50,
      baseSpDef: state.baseStats['spd'] ?? 50,
      baseSpd: state.baseStats['spe'] ?? 50,
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: state.id,
      generation: 1,
      evolutionStage: 0,
      hasEvolution: state.hasEvolution,
      isChampions: false,
      isLegendsZA: false,
    );

    return ComparisonEntry(
      pokemon: p,
      level: state.level,
      nature: state.nature,
      ivs: state.ivs,
      evs: state.evs,
      sps: state.sps,
      ability: state.ability,
      heldItem: state.heldItem,
      status: state.status,
      stages: state.stages,
      turnsOnField: state.turnsOnField,
      hpPercent: state.hpPercent,
      weather: weather,
      terrain: terrain,
    );
  }

  /// Compute max HP for a Pokémon state under a specific ruleset.
  static int calculateMaxHp(PokemonState state, BattleRuleset ruleset) {
    final baseHp = state.baseStats['hp'] ?? 50;
    final isShedinja = state.name.toLowerCase() == 'shedinja';

    if (ruleset.isChampions) {
      return StatCalculator.calculateChampionsHp(
        base: baseHp,
        sp: state.sps['hp'] ?? 0,
        isShedinja: isShedinja,
      );
    }

    return StatCalculator.calculateHp(
      base: baseHp,
      iv: state.ivs['hp'] ?? 31,
      ev: state.evs['hp'] ?? 0,
      level: state.level,
      isShedinja: isShedinja,
    );
  }

  /// Compute full raw build stats for a Pokémon state.
  static ComparisonStats computeRawStats(
    PokemonState state,
    BattleRuleset ruleset,
  ) {
    final entry = _toComparisonEntry(state);
    return StatModifier.computeRawStats(entry, ruleset);
  }

  /// Compute full effective battle stats for a Pokémon state.
  ///
  /// A critical hit ignores negative Attack / Special Attack stages on the
  /// attacker and positive Defense / Special Defense stages on the defender.
  /// Those stage adjustments happen before the shared stat modifier pipeline
  /// so the same rule applies to both mainline and Champions calculations.
  static ComparisonStats computeEffectiveStats(
    PokemonState state,
    BattleRuleset ruleset, {
    bool isCriticalAttacker = false,
    bool isCriticalDefender = false,
    Set<String> additionallyIgnoreNegativeStages = const {},
    Set<String> additionallyIgnorePositiveStages = const {},
    String weather = 'none',
    String terrain = 'none',
  }) {
    if (isCriticalAttacker ||
        isCriticalDefender ||
        additionallyIgnoreNegativeStages.isNotEmpty ||
        additionallyIgnorePositiveStages.isNotEmpty) {
      final stages = Map<String, int>.from(state.stages);
      final negativeKeys = {
        if (isCriticalAttacker) 'atk',
        if (isCriticalAttacker) 'spa',
        ...additionallyIgnoreNegativeStages,
      };
      final positiveKeys = {
        if (isCriticalDefender) 'def',
        if (isCriticalDefender) 'spd',
        ...additionallyIgnorePositiveStages,
      };
      for (final key in negativeKeys) {
        if ((stages[key] ?? 0) < 0) stages[key] = 0;
      }
      for (final key in positiveKeys) {
        if ((stages[key] ?? 0) > 0) stages[key] = 0;
      }
      state = state.copyWith(stages: stages);
    }

    final entry = _toComparisonEntry(state, weather: weather, terrain: terrain);
    return StatModifier.computeEffectiveStats(entry, ruleset);
  }
}

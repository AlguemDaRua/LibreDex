/// Damage engine for the calculator's raw sandbox mode.
///
/// The sandbox lets a user type the attacking stat, defending stat, STAB and
/// type effectiveness by hand instead of picking two Pokémon. It previously
/// re-implemented the damage formula inside a `build()` method, which silently
/// diverged from [MainlineDamageEngine]: no Aurora Veil, no Multiscale, no
/// Filter/Solid Rock, no Expert Belt, no Tinted Lens, and a Helping Hand folded
/// into base power instead of applied as a final modifier.
///
/// This engine deletes that second implementation. It runs the *same*
/// [ModifierPipeline] and the *same* [DamageMath]; the only difference is which
/// four values are supplied by the user instead of derived.
library;

import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/utils/damage_math.dart';
import 'package:libredex/features/battle_engine/models/battle_state.dart';
import 'package:libredex/features/battle_engine/models/damage_result.dart';
import 'package:libredex/features/battle_engine/models/sandbox_overrides.dart';
import 'package:libredex/features/battle_engine/services/modifier_pipeline.dart';
import 'package:libredex/features/battle_engine/services/stat_engine.dart';

class SandboxDamageEngine {
  SandboxDamageEngine._();

  /// Calculate a single-strike damage result for a hand-fed sandbox state.
  ///
  /// The result carries no HP context: with no Pokémon selected there is no
  /// defender HP to divide by, so [DamageResult.defenderMaxHp],
  /// [DamageResult.minPercentage] and [DamageResult.maxPercentage] are zero and
  /// [DamageResult.koChance] is empty. The sandbox UI reports absolute damage
  /// plus its own fixed 100/200/300 HP benchmarks.
  static DamageResult calculate(BattleState state, SandboxOverrides sandbox) {
    final moveName = state.move.name.toLowerCase().replaceAll('-', ' ').trim();

    // Body Press draws its stage from Defense and Foul Play from the target's
    // Attack; the critical-hit stage rules already live in the stat engine.
    final attackerStats = StatEngine.computeEffectiveStats(
      state.attacker,
      state.ruleset,
      isCriticalAttacker: state.move.isCritical,
      additionallyIgnoreNegativeStages:
          state.move.isCritical && moveName == 'body press'
          ? const {'def'}
          : const {},
      weather: state.field.weather,
      terrain: state.field.terrain,
    );
    final defenderStats = StatEngine.computeEffectiveStats(
      state.defender,
      state.ruleset,
      isCriticalDefender: state.move.isCritical,
      additionallyIgnoreNegativeStages:
          state.move.isCritical && moveName == 'foul play'
          ? const {'atk'}
          : const {},
      weather: state.field.weather,
      terrain: state.field.terrain,
    );

    // The only branch point: the pipeline is told which values are user-typed.
    final pipe = ModifierPipeline.process(
      state,
      attackerStats,
      defenderStats,
      sandbox: sandbox,
    );

    final range = DamageMath.calculate(
      level: state.ruleset.isChampions
          ? ChampionsRules.level
          : state.attacker.level,
      basePower: pipe.effectiveBasePower,
      attack: pipe.effectiveAttack,
      defense: pipe.effectiveDefense,
      stab: pipe.stabMultiplier,
      effectiveness: pipe.typeEffectiveness,
      critical: state.move.isCritical,
      weather: pipe.weatherMultiplier,
      burned: pipe.isBurnApplied,
      finalModifiers: pipe.finalModifiers,
      // The sandbox exposes no hit-count control, so it always reports a
      // single strike. Multi-hit resolution stays a duel-view concern.
      hits: 1,
    );

    return DamageResult(
      rolls: range.rolls,
      minDamage: range.min,
      maxDamage: range.max,
      defenderMaxHp: 0,
      minPercentage: 0.0,
      maxPercentage: 0.0,
      koChance: '',
      modifiers: pipe.appliedModifiers,
      warnings: pipe.warnings,
      effectiveBasePower: pipe.effectiveBasePower,
      effectiveAttack: pipe.effectiveAttack,
      effectiveDefense: pipe.effectiveDefense,
      typeEffectiveness: pipe.typeEffectiveness,
      priorityBlockReason: pipe.priorityBlockReason,
    );
  }
}

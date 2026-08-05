/// Damage engine for Pokémon Champions ruleset.
library;

import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/utils/damage_math.dart';
import 'package:libredex/features/battle_engine/models/battle_state.dart';
import 'package:libredex/features/battle_engine/models/damage_result.dart';
import 'package:libredex/features/battle_engine/services/stat_engine.dart';
import 'package:libredex/features/battle_engine/services/modifier_pipeline.dart';

class ChampionsDamageEngine {
  ChampionsDamageEngine._();

  /// Calculate damage result for Pokémon Champions ruleset.
  static DamageResult calculate(BattleState state) {
    // Ensure state uses Champions ruleset
    final championsState = state.copyWith(ruleset: BattleRuleset.champions);

    final attackerStats = StatEngine.computeEffectiveStats(championsState.attacker, BattleRuleset.champions);
    final defenderStats = StatEngine.computeEffectiveStats(championsState.defender, BattleRuleset.champions);

    final maxHp = defenderStats.hp.effectiveStat;

    // Process pipeline modifiers
    final pipe = ModifierPipeline.process(championsState, attackerStats, defenderStats);

    // Champions forces Level 50
    final hitBasePowers = CombatUtils.getHitBasePowers(
      championsState.move.name,
      championsState.move.basePower,
      pipe.effectiveBasePower,
      hitCount: championsState.move.hits,
    );
    final hasParentalBond = championsState.attacker.ability?.toLowerCase() == 'parental bond' && hitBasePowers.length == 1;

    final DamageRange range;
    if (hitBasePowers.length > 1 || hasParentalBond) {
      final multiHit = DamageMath.calculateMultiHit(
        basePowers: hitBasePowers,
        level: 50,
        attack: pipe.effectiveAttack,
        defense: pipe.effectiveDefense,
        stab: pipe.stabMultiplier,
        effectiveness: pipe.typeEffectiveness,
        critical: championsState.move.isCritical,
        weather: pipe.weatherMultiplier,
        burned: pipe.isBurnApplied,
        finalModifiers: pipe.finalModifiers,
        parentalBond: hasParentalBond,
      );
      range = multiHit.total;
    } else {
      range = DamageMath.calculate(
        level: 50,
        basePower: pipe.effectiveBasePower,
        attack: pipe.effectiveAttack,
        defense: pipe.effectiveDefense,
        stab: pipe.stabMultiplier,
        effectiveness: pipe.typeEffectiveness,
        critical: championsState.move.isCritical,
        weather: pipe.weatherMultiplier,
        burned: pipe.isBurnApplied,
        finalModifiers: pipe.finalModifiers,
        hits: championsState.move.hits,
      );
    }

    final minDmg = range.min;
    final maxDmg = range.max;
    final minPct = maxHp > 0 ? (minDmg / maxHp) * 100.0 : 0.0;
    final maxPct = maxHp > 0 ? (maxDmg / maxHp) * 100.0 : 0.0;

    final koChance = _calculateKoChance(range.rolls, maxHp);

    return DamageResult(
      rolls: range.rolls,
      minDamage: minDmg,
      maxDamage: maxDmg,
      defenderMaxHp: maxHp,
      minPercentage: minPct,
      maxPercentage: maxPct,
      koChance: koChance,
      modifiers: pipe.appliedModifiers,
      warnings: pipe.warnings,
      effectiveBasePower: pipe.effectiveBasePower,
      effectiveAttack: pipe.effectiveAttack,
      effectiveDefense: pipe.effectiveDefense,
      typeEffectiveness: pipe.typeEffectiveness,
    );
  }

  static String _calculateKoChance(List<int> rolls, int maxHp) {
    if (maxHp <= 0 || rolls.isEmpty || rolls.last <= 0) return '0% chance';
    if (rolls.first >= maxHp) return 'guaranteed OHKO';

    int koCount = 0;
    for (final roll in rolls) {
      if (roll >= maxHp) koCount++;
    }

    if (koCount > 0) {
      final pct = (koCount / rolls.length) * 100.0;
      return '${pct.toStringAsFixed(1)}% chance to OHKO';
    }

    int twoHkoCount = 0;
    for (final r1 in rolls) {
      for (final r2 in rolls) {
        if (r1 + r2 >= maxHp) twoHkoCount++;
      }
    }
    final totalPairs = rolls.length * rolls.length;
    if (twoHkoCount == totalPairs) return 'guaranteed 2HKO';
    if (twoHkoCount > 0) {
      final pct = (twoHkoCount / totalPairs) * 100.0;
      return '${pct.toStringAsFixed(1)}% chance to 2HKO';
    }

    return 'guaranteed ${((maxHp / rolls.last).ceil())}HKO';
  }
}

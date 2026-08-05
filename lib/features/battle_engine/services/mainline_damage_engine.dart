/// Core Mainline Gen IX damage engine using verified integer math.
library;

import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/utils/damage_math.dart';
import 'package:libredex/features/battle_engine/models/battle_state.dart';
import 'package:libredex/features/battle_engine/models/damage_result.dart';
import 'package:libredex/features/battle_engine/services/stat_engine.dart';
import 'package:libredex/features/battle_engine/services/modifier_pipeline.dart';

class MainlineDamageEngine {
  MainlineDamageEngine._();

  /// Calculate precise 16-roll damage result for a Mainline battle state.
  static DamageResult calculate(BattleState state) {
    // 1. Compute effective battle stats
    final attackerStats = StatEngine.computeEffectiveStats(state.attacker, state.ruleset);
    final defenderStats = StatEngine.computeEffectiveStats(state.defender, state.ruleset);

    final maxHp = defenderStats.hp.effectiveStat;

    // 2. Process pipeline modifiers
    final pipe = ModifierPipeline.process(state, attackerStats, defenderStats);

    // 3. Execute integer damage math (with full support for multi-strike moves like Triple Axel)
    final hitBasePowers = CombatUtils.getHitBasePowers(
      state.move.name,
      state.move.basePower,
      pipe.effectiveBasePower,
      hitCount: state.move.hits,
    );
    final hasParentalBond = state.attacker.ability?.toLowerCase() == 'parental bond' && hitBasePowers.length == 1;

    final DamageRange range;
    if (hitBasePowers.length > 1 || hasParentalBond) {
      final multiHit = DamageMath.calculateMultiHit(
        basePowers: hitBasePowers,
        level: state.attacker.level,
        attack: pipe.effectiveAttack,
        defense: pipe.effectiveDefense,
        stab: pipe.stabMultiplier,
        effectiveness: pipe.typeEffectiveness,
        critical: state.move.isCritical,
        weather: pipe.weatherMultiplier,
        burned: pipe.isBurnApplied,
        finalModifiers: pipe.finalModifiers,
        parentalBond: hasParentalBond,
      );
      range = multiHit.total;
    } else {
      range = DamageMath.calculate(
        level: state.attacker.level,
        basePower: pipe.effectiveBasePower,
        attack: pipe.effectiveAttack,
        defense: pipe.effectiveDefense,
        stab: pipe.stabMultiplier,
        effectiveness: pipe.typeEffectiveness,
        critical: state.move.isCritical,
        weather: pipe.weatherMultiplier,
        burned: pipe.isBurnApplied,
        finalModifiers: pipe.finalModifiers,
        hits: state.move.hits,
      );
    }

    final minDmg = range.min;
    final maxDmg = range.max;
    final minPct = maxHp > 0 ? (minDmg / maxHp) * 100.0 : 0.0;
    final maxPct = maxHp > 0 ? (maxDmg / maxHp) * 100.0 : 0.0;

    // 4. Estimate KO chance
    final koChance = _calculateKoChance(range.rolls, maxHp, state.move.hits);

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

  static String _calculateKoChance(List<int> rolls, int maxHp, int hits) {
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

    // 2HKO check
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

    // 3HKO check
    if (rolls.last * 3 >= maxHp) return 'possible 3HKO';

    return 'guaranteed ${((maxHp / rolls.last).ceil())}HKO';
  }
}

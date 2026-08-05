/// Complete output from a battle damage calculation.
library;

import 'package:libredex/features/battle_engine/models/applied_modifier.dart';

class DamageResult {
  /// Exact 16 damage rolls (from 85% to 100% random variance).
  final List<int> rolls;

  /// Minimum damage dealt (rolls[0]).
  final int minDamage;

  /// Maximum damage dealt (rolls[15]).
  final int maxDamage;

  /// Defender's total HP.
  final int defenderMaxHp;

  /// Minimum damage as percentage of defender's max HP (0–100+).
  final double minPercentage;

  /// Maximum damage as percentage of defender's max HP (0–100+).
  final double maxPercentage;

  /// Descriptive KO chance label (e.g. "guaranteed OHKO", "87.5% chance to 2HKO").
  final String koChance;

  /// Ordered list of modifiers applied during calculation.
  final List<AppliedModifier> modifiers;

  /// Clear warnings if an unsupported mechanic or uncertain calculation was encountered.
  final List<String> warnings;

  /// Computed effective base power of the move.
  final int effectiveBasePower;

  /// Computed effective stat value of attacker.
  final int effectiveAttack;

  /// Computed effective stat value of defender.
  final int effectiveDefense;

  /// Final type effectiveness multiplier (0, 0.25, 0.5, 1, 2, 4).
  final double typeEffectiveness;

  const DamageResult({
    required this.rolls,
    required this.minDamage,
    required this.maxDamage,
    required this.defenderMaxHp,
    required this.minPercentage,
    required this.maxPercentage,
    required this.koChance,
    required this.modifiers,
    this.warnings = const [],
    required this.effectiveBasePower,
    required this.effectiveAttack,
    required this.effectiveDefense,
    required this.typeEffectiveness,
  });

  /// True if the calculation has warnings about unverified or missing mechanics.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Formatted roll range summary string e.g. "45 - 53 (28.4% - 33.5%)".
  String get rangeSummary =>
      '$minDamage - $maxDamage (${minPercentage.toStringAsFixed(1)}% - ${maxPercentage.toStringAsFixed(1)}%)';
}

/// Modifier information applied during battle damage calculations.
library;

enum ModifierCategory {
  basePower,
  attack,
  defense,
  weather,
  terrain,
  critical,
  stab,
  typeEffectiveness,
  status,
  screen,
  item,
  ability,
  finalModifier,
  statStage,
  rule,
}

/// Description of a modifier applied to damage calculations.
class AppliedModifier {
  final String name;
  final double multiplier;
  final ModifierCategory category;
  final String? description;

  const AppliedModifier({
    required this.name,
    required this.multiplier,
    required this.category,
    this.description,
  });

  @override
  String toString() => '$name (×${multiplier.toStringAsFixed(2)})';
}

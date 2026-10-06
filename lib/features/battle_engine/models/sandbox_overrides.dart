/// Values the calculator's raw sandbox supplies by hand instead of deriving
/// them from two selected Pokémon.
library;

/// The four inputs the raw-sandbox panel lets a user type directly.
///
/// Everything a damage calculation needs beyond these — held items, abilities,
/// weather, terrain, screens, burn, spread, criticals — is derived by the
/// shared [ModifierPipeline], so the sandbox resolves through the same code
/// path as the duel view and cannot drift from it.
///
/// [attack] and [defense] are the *final* effective stats: stat stages and
/// stat-modifying held items have already been folded in by the caller, which
/// is the point at which the duel view's stat engine hands its numbers to the
/// pipeline.
class SandboxOverrides {
  /// Effective attacking stat, after stages and stat-modifying held items.
  final int attack;

  /// Effective defending stat, after stages and stat-modifying held items.
  final int defense;

  /// Same-type attack bonus multiplier (1.0 / 1.5 / 2.0 / 2.25 / 1.2).
  final double stab;

  /// Type effectiveness multiplier (0 / 0.25 / 0.5 / 1 / 2 / 4).
  final double effectiveness;

  const SandboxOverrides({
    required this.attack,
    required this.defense,
    required this.stab,
    required this.effectiveness,
  });
}

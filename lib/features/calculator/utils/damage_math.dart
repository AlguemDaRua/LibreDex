/// Integer Gen IX damage arithmetic shared by the calculator UI and tests.
///
/// Damage is not floating point math: the games truncate/round at prescribed
/// points.  Using one large `double` expression moves those truncations and is
/// enough to produce damage ranges that do not agree with Pokémon Showdown.
library;

class DamageRange {
  const DamageRange(this.rolls);

  /// The 16 possible random rolls (85 through 100).
  final List<int> rolls;
  int get min => rolls.reduce((a, b) => a < b ? a : b);
  int get max => rolls.reduce((a, b) => a > b ? a : b);
}

/// A multi-strike result. [perHit] is ordered and [total] is the sum of
/// corresponding rolls, allowing the UI to show both the total and each hit.
class MultiHitDamage {
  const MultiHitDamage({required this.perHit, required this.total});

  final List<DamageRange> perHit;
  final DamageRange total;
}

class DamageMath {
  DamageMath._();

  /// Pokémon's `pokeRound`: ties are rounded down, rather than Dart's normal
  /// floating behaviour. Values passed here are fixed-point modifier results.
  static int _pokeRound(int numerator, int denominator) {
    final quotient = numerator ~/ denominator;
    final remainder = numerator % denominator;
    return remainder * 2 > denominator ? quotient + 1 : quotient;
  }

  static int _fixedModifier(int value, int modifier) =>
      _pokeRound(value * modifier, 4096);

  static int _modifierFromDouble(double value) => (value * 4096).round();

  /// Produces the exact 16-roll damage range for the subset of battle state
  /// represented by LibreDex's current UI.
  ///
  /// [finalModifiers] are applied in order after burn (screens, berries,
  /// Filter/Solid Rock, Life Orb, etc.) using the game's 12-bit fixed-point
  /// rounding. A move with [hits] returns total damage for its guaranteed
  /// repeated hits (e.g. Surging Strikes), as Showdown does.
  static DamageRange calculate({
    required int level,
    required int basePower,
    required int attack,
    required int defense,
    required double stab,
    required double effectiveness,
    bool critical = false,
    double weather = 1.0,
    bool burned = false,
    List<double> finalModifiers = const [],
    int hits = 1,
    bool parentalBondChild = false,
  }) {
    if (basePower <= 0 || attack <= 0 || defense <= 0 || effectiveness == 0) {
      return DamageRange(List<int>.filled(16, 0));
    }

    // getBaseDamage() from the Pokémon Showdown calculator / Gen IX engine.
    var base = (((((2 * level) ~/ 5) + 2) * basePower * attack) ~/ defense) ~/ 50 + 2;
    base = _fixedModifier(base, _modifierFromDouble(weather));
    // Gen IX Parental Bond's second strike is 25% of the base damage,
    // before random/STAB/type/final modifiers are applied.
    if (parentalBondChild) base = _fixedModifier(base, 1024);
    if (critical) base = (base * 3) ~/ 2;

    final stabMod = _modifierFromDouble(stab);
    final effectiveHits = hits < 1 ? 1 : hits;
    final rolls = <int>[];
    for (var random = 85; random <= 100; random++) {
      var damage = (base * random) ~/ 100;
      if (stabMod != 4096) damage = _pokeRound(damage * stabMod, 4096);
      // Type effectiveness is an ordinary multiplier after STAB.
      damage = (damage * effectiveness).floor();
      if (burned) damage ~/= 2;
      for (final modifier in finalModifiers) {
        damage = _fixedModifier(damage, _modifierFromDouble(modifier));
      }
      // A damaging hit always does at least 1 after modifiers.
      damage = damage < 1 ? 1 : damage;
      rolls.add(damage * effectiveHits);
    }
    return DamageRange(rolls);
  }

  /// Calculates each guaranteed strike independently. This matters for moves
  /// such as Triple Axel (20 → 40 → 60 BP), where multiplying a single-hit
  /// result is wrong because the base-damage truncation happens per hit.
  static MultiHitDamage calculateMultiHit({
    required List<int> basePowers,
    required int level,
    required int attack,
    required int defense,
    required double stab,
    required double effectiveness,
    bool critical = false,
    double weather = 1.0,
    bool burned = false,
    List<double> finalModifiers = const [],
    bool parentalBond = false,
  }) {
    final powers = basePowers.isEmpty ? const [0] : basePowers;
    final perHit = <DamageRange>[
      for (final bp in powers)
        calculate(
          level: level, basePower: bp, attack: attack, defense: defense,
          stab: stab, effectiveness: effectiveness, critical: critical,
          weather: weather, burned: burned, finalModifiers: finalModifiers,
        ),
    ];
    if (parentalBond) {
      // Parental Bond adds one child strike for a normally single-hit move.
      perHit.add(calculate(
        level: level, basePower: powers.first, attack: attack, defense: defense,
        stab: stab, effectiveness: effectiveness, critical: critical,
        weather: weather, burned: burned, finalModifiers: finalModifiers,
        parentalBondChild: true,
      ));
    }
    final total = List<int>.generate(16, (i) =>
        perHit.fold(0, (sum, hit) => sum + hit.rolls[i]));
    return MultiHitDamage(perHit: perHit, total: DamageRange(total));
  }
}

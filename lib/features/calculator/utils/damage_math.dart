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

  /// Exact 4096-based numerators for the multipliers the games hardcode.
  ///
  /// Pokémon never multiplies by 1.1. It multiplies by 4505 and divides by
  /// 4096, which is 1.09985 - close enough to matter on some base powers but
  /// not identical to it, and the two disagree by a point on some rolls.
  /// Reaching for the decimal instead of the fraction is what drifts.
  static const int boost11 = 4505; // 1.1x
  static const int boost12 = 4915; // 1.2x
  static const int boost13 = 5324; // 1.3x
  static const int boost15 = 6144; // 1.5x
  static const int boostHalve = 2048; // 0.5x

  /// Terrain boosts are 5325, not the 5324 the other 1.3x effects use.
  static const int boostTerrain = 5325;

  /// Punching Glove is 4506, one more than the 4505 that every other 1.1x
  /// item uses. Showdown carries the same quirk, so we match it.
  static const int boostPunchingGlove = 4506;

  /// Combines modifiers the way the games do: chain them into one value,
  /// then round once.
  ///
  /// Rounding after each modifier instead compounds the error. 7 damage
  /// through Filter (3072) then a halving (2048) rounds 7 -> 5 -> 2, but the
  /// game chains those to 1536/4096 and gets round(2.625) = 3. Every stage
  /// that can stack more than one modifier has to go through here.
  static int chainMods(
    List<int> mods, {
    int lowerBound = 41,
    int upperBound = 2097152,
  }) {
    var m = 4096;
    for (final mod in mods) {
      if (mod != 4096) {
        m = (m * mod + 2048) >> 12;
      }
    }
    return m.clamp(lowerBound, upperBound);
  }

  /// Pokémon's `pokeRound`: ties are rounded down, rather than Dart's normal
  /// floating behaviour. Values passed here are fixed-point modifier results.
  static int pokeRound(int numerator, int denominator) {
    final quotient = numerator ~/ denominator;
    final remainder = numerator % denominator;
    return remainder * 2 > denominator ? quotient + 1 : quotient;
  }

  /// Applies a 4096-based [modifier] to [value] with the game's rounding.
  static int fixedModifier(int value, int modifier) =>
      pokeRound(value * modifier, 4096);

  /// Converts a decimal modifier to the exact n/4096 numerator.
  ///
  /// Rounding the decimal directly is off by one on the common cases: 1.3
  /// becomes 5325 rather than the 5324 the games apply, and 1.1 becomes 4506
  /// rather than 4505. Small, but it is a real difference on some rolls.
  static int _modifierFromDouble(double value) =>
      switch ((value * 10).round()) {
        11 => boost11,
        12 => boost12,
        13 => boost13,
        15 => boost15,
        _ => (value * 4096).round(),
      };

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
    var base =
        (((((2 * level) ~/ 5) + 2) * basePower * attack) ~/ defense) ~/ 50 + 2;
    base = fixedModifier(base, _modifierFromDouble(weather));
    // Gen IX Parental Bond's second strike is 25% of the base damage,
    // before random/STAB/type/final modifiers are applied.
    if (parentalBondChild) base = fixedModifier(base, 1024);
    if (critical) base = (base * 3) ~/ 2;

    final stabMod = _modifierFromDouble(stab);
    // Final modifiers are chained into one and applied once - see chainMods.
    final finalMod = chainMods(
      finalModifiers.map(_modifierFromDouble).toList(),
      lowerBound: 1,
      upperBound: 0x7fffffff,
    );
    final effectiveHits = hits < 1 ? 1 : hits;
    final rolls = <int>[];
    for (var random = 85; random <= 100; random++) {
      var damage = (base * random) ~/ 100;
      if (stabMod != 4096) damage = pokeRound(damage * stabMod, 4096);
      // Type effectiveness is an ordinary multiplier after STAB.
      damage = (damage * effectiveness).floor();
      if (burned) damage ~/= 2;
      if (finalMod != 4096) damage = pokeRound(damage * finalMod, 4096);
      // A damaging hit always does at least 1 after modifiers.
      damage = damage < 1 ? 1 : damage;
      // 16-bit overflow: damage past 65535 wraps, as it does in the games.
      // Reachable with a huge Attack against a tiny Defense.
      if (damage > 65535) damage = damage % 65536;
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
          level: level,
          basePower: bp,
          attack: attack,
          defense: defense,
          stab: stab,
          effectiveness: effectiveness,
          critical: critical,
          weather: weather,
          burned: burned,
          finalModifiers: finalModifiers,
        ),
    ];
    if (parentalBond) {
      // Parental Bond adds one child strike for a normally single-hit move.
      perHit.add(
        calculate(
          level: level,
          basePower: powers.first,
          attack: attack,
          defense: defense,
          stab: stab,
          effectiveness: effectiveness,
          critical: critical,
          weather: weather,
          burned: burned,
          finalModifiers: finalModifiers,
          parentalBondChild: true,
        ),
      );
    }
    final total = List<int>.generate(
      16,
      (i) => perHit.fold(0, (sum, hit) => sum + hit.rolls[i]),
    );
    return MultiHitDamage(perHit: perHit, total: DamageRange(total));
  }
}

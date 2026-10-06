import 'package:flutter_test/flutter_test.dart';

import 'package:libredex/features/calculator/utils/damage_math.dart';

/// Damage ranges verified against Pokémon Showdown's own calculator source
/// (calc/src/mechanics/util.ts, calc/src/mechanics/gen789.ts).
///
/// Real Gen 9 matchups, level 50, 252 EVs in the relevant stats. The expected
/// values come from reimplementing Showdown's getBaseDamage / getFinalDamage /
/// chainMods / pokeRound straight from that source, so a failure here means we
/// have drifted from Showdown - not just that an internal assumption moved.
///
/// basePower is the value AFTER the pipeline applies base-power modifiers,
/// because Showdown chains those into basePower before it reaches
/// getBaseDamage. That ordering matters: chaining afterwards rounds at a
/// different point and gives a different answer.
///
/// The scenarios target the stages that were wrong before: item base-power
/// boosts (4505 / 4506 / 4915), terrain (5325), Technician (6144), and stacked
/// final modifiers, which must be chained rather than rounded one at a time.
void main() {
  group('damage matches Showdown', () {

    test('Garchomp Earthquake vs Tyranitar, Life Orb, super-effective', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 130,
        attack: 182,
        defense: 162,
        stab: 1.5,
        effectiveness: 2,
        finalModifiers: const [1.3],
      );
      expect(range.min, 218);
      expect(range.max, 257);
    });

    test('Charizard Flare Blitz vs Ferrothorn, Muscle Band + Charcoal', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 158,
        attack: 136,
        defense: 183,
        stab: 1.5,
        effectiveness: 2,
        finalModifiers: const [],
      );
      expect(range.min, 134);
      expect(range.max, 158);
    });

    test('Gholdengo Make It Rain vs Tyranitar, Wise Glasses + Expert Belt', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 88,
        attack: 185,
        defense: 152,
        stab: 1.5,
        effectiveness: 2,
        finalModifiers: const [1.2],
      );
      expect(range.min, 146);
      expect(range.max, 175);
    });

    test('Iron Hands Drain Punch vs Blissey, Punching Glove', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 83,
        attack: 192,
        defense: 62,
        stab: 1.5,
        effectiveness: 1,
        finalModifiers: const [],
      );
      expect(range.min, 145);
      expect(range.max, 172);
    });

    test('Scizor Bullet Punch vs Greninja, Technician + STAB', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 60,
        attack: 182,
        defense: 119,
        stab: 1.5,
        effectiveness: 1,
        finalModifiers: const [],
      );
      expect(range.min, 52);
      expect(range.max, 63);
    });

    test('Kingambit Sucker Punch vs Landorus-T, Reflect + Life Orb', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 70,
        attack: 187,
        defense: 142,
        stab: 1.5,
        effectiveness: 1,
        finalModifiers: const [0.5, 1.3],
      );
      expect(range.min, 34);
      expect(range.max, 41);
    });

    test('Rotom-W Thunderbolt vs Greninja, Electric Terrain', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 117,
        attack: 157,
        defense: 123,
        stab: 1.5,
        effectiveness: 1,
        finalModifiers: const [],
      );
      expect(range.min, 84);
      expect(range.max, 100);
    });

    test('Greninja Surf vs Amoonguss, resist berry + Light Screen', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 90,
        attack: 155,
        defense: 132,
        stab: 1.5,
        effectiveness: 1,
        finalModifiers: const [0.5, 0.5],
      );
      expect(range.min, 15);
      expect(range.max, 18);
    });

    test('Garchomp Dragon Claw vs Rotom-W, no item no STAB', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 80,
        attack: 182,
        defense: 159,
        stab: 1.0,
        effectiveness: 1,
        finalModifiers: const [],
      );
      expect(range.min, 35);
      expect(range.max, 42);
    });

    test('Landorus-T Earthquake vs Scizor, 4x with Life Orb and Expert Belt', () {
      final range = DamageMath.calculate(
        level: 50,
        basePower: 100,
        attack: 197,
        defense: 152,
        stab: 1.5,
        effectiveness: 4,
        finalModifiers: const [1.2],
      );
      expect(range.min, 360);
      expect(range.max, 422);
    });
  });
}

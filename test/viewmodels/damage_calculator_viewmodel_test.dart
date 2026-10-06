import 'package:flutter_test/flutter_test.dart';

import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';

/// A minimal state for exercising [DamageCalculatorState.sandboxOverrides].
///
/// The sandbox panel feeds raw Attack/Defense numbers into the shared battle
/// engine, so the overrides are the seam where an item that belongs in the
/// final-damage chain can leak into the Attack stat instead and be counted
/// twice. That happened with Life Orb and the type-boosting items, so these
/// tests pin which items belong where.
DamageCalculatorState sandboxState({
  String attackerItem = 'None',
  String defenderItem = 'None',
  String category = 'physical',
  Map<String, int>? attackerStages,
  Map<String, int>? defenderStages,
  bool isCriticalHit = false,
  String moveName = '',
  double attack = 100,
  double defense = 100,
}) {
  return DamageCalculatorState(
    attackerIvs: const {
      'hp': 31,
      'atk': 31,
      'def': 31,
      'spa': 31,
      'spd': 31,
      'spe': 31,
    },
    attackerEvs: const {
      'hp': 0,
      'atk': 0,
      'def': 0,
      'spa': 0,
      'spd': 0,
      'spe': 0,
    },
    attackerStages:
        attackerStages ??
        const {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
    attackerHeldItem: attackerItem,
    defenderIvs: const {
      'hp': 31,
      'atk': 31,
      'def': 31,
      'spa': 31,
      'spd': 31,
      'spe': 31,
    },
    defenderEvs: const {
      'hp': 0,
      'atk': 0,
      'def': 0,
      'spa': 0,
      'spd': 0,
      'spe': 0,
    },
    defenderStages:
        defenderStages ??
        const {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
    defenderHeldItem: defenderItem,
    attackerSps: const {
      'hp': 0,
      'atk': 0,
      'def': 0,
      'spa': 0,
      'spd': 0,
      'spe': 0,
    },
    defenderSps: const {
      'hp': 0,
      'atk': 0,
      'def': 0,
      'spa': 0,
      'spd': 0,
      'spe': 0,
    },
    selectedMoveName: moveName,
    moveCategory: category,
    isCriticalHit: isCriticalHit,
    simpleAttackerStat: attack,
    simpleDefenderStat: defense,
    simpleStab: 1.0,
    simpleEffectiveness: 1.0,
  );
}

void main() {
  group('sandboxOverrides keeps stages apart', () {
    test('final-damage items stay out of the Attack stat', () {
      // Regression: Life Orb, Expert Belt and the type-boosting items were
      // folded into the Attack override here AND applied again by
      // ModifierPipeline, so they counted twice on the sandbox path.
      for (final item in ['Life Orb', 'Expert Belt', 'Charcoal']) {
        final o = sandboxState(attackerItem: item).sandboxOverrides();
        expect(o.attack, 100, reason: '$item must not touch the Attack stat');
      }
    });

    test('base-power items stay out of the Attack stat too', () {
      for (final item in ['Muscle Band', 'Wise Glasses', 'Punching Glove']) {
        final o = sandboxState(attackerItem: item).sandboxOverrides();
        expect(o.attack, 100, reason: '$item boosts base power, not Attack');
      }
    });

    test('stat items do reach the Attack stat, on the correct side', () {
      expect(
        sandboxState(attackerItem: 'Choice Band').sandboxOverrides().attack,
        150,
      );
      // Choice Band does nothing for a special move.
      expect(
        sandboxState(
          attackerItem: 'Choice Band',
          category: 'special',
        ).sandboxOverrides().attack,
        100,
      );
      expect(
        sandboxState(
          attackerItem: 'Choice Specs',
          category: 'special',
        ).sandboxOverrides().attack,
        150,
      );
    });

    test('defensive items reach the Defense stat', () {
      expect(
        sandboxState(
          defenderItem: 'Assault Vest',
          category: 'special',
        ).sandboxOverrides().defense,
        150,
      );
      // Assault Vest is special-only.
      expect(
        sandboxState(defenderItem: 'Assault Vest').sandboxOverrides().defense,
        100,
      );
    });

    test('an item that does nothing leaves the stats untouched', () {
      final o = sandboxState(attackerItem: 'None').sandboxOverrides();
      expect(o.attack, 100);
      expect(o.defense, 100);
    });
  });

  group('sandboxOverrides applies stat stages', () {
    test('a negative attack stage halves the stat', () {
      final o = sandboxState(
        attackerStages: const {
          'atk': -2,
          'def': 0,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
      ).sandboxOverrides();
      expect(o.attack, 50);
    });

    test('a positive attack stage doubles the stat', () {
      final o = sandboxState(
        attackerStages: const {
          'atk': 2,
          'def': 0,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
      ).sandboxOverrides();
      expect(o.attack, 200);
    });

    test('a critical hit ignores the attacker’s negative stages', () {
      final o = sandboxState(
        attackerStages: const {
          'atk': -2,
          'def': 0,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
        isCriticalHit: true,
      ).sandboxOverrides();
      expect(o.attack, 100);
    });

    test('a critical hit ignores the defender’s positive stages', () {
      final o = sandboxState(
        defenderStages: const {
          'atk': 0,
          'def': 2,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
        isCriticalHit: true,
      ).sandboxOverrides();
      expect(o.defense, 100);
    });

    test('a critical hit still respects a negative defensive stage', () {
      final o = sandboxState(
        defenderStages: const {
          'atk': 0,
          'def': -2,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
        isCriticalHit: true,
      ).sandboxOverrides();
      expect(o.defense, 50);
    });
  });

  group('sandboxOverrides picks the right stat pair', () {
    test('a physical move uses Attack against Defense', () {
      final o = sandboxState(
        attackerStages: const {
          'atk': 2,
          'def': 0,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
        defenderStages: const {
          'atk': 0,
          'def': 2,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
      ).sandboxOverrides();
      expect(o.attack, 200);
      expect(o.defense, 200);
    });

    test('a special move uses Sp. Atk against Sp. Def', () {
      final o = sandboxState(
        category: 'special',
        attackerStages: const {
          'atk': 0,
          'def': 0,
          'spa': 2,
          'spd': 0,
          'spe': 0,
        },
        defenderStages: const {
          'atk': 0,
          'def': 0,
          'spa': 0,
          'spd': 2,
          'spe': 0,
        },
      ).sandboxOverrides();
      expect(o.attack, 200);
      expect(o.defense, 200);
    });

    test('Psyshock targets Defense despite being special', () {
      final o = sandboxState(
        category: 'special',
        moveName: 'Psyshock',
        defenderStages: const {
          'atk': 0,
          'def': 2,
          'spa': 0,
          'spd': 2,
          'spe': 0,
        },
      ).sandboxOverrides();
      // Defense is doubled, Sp. Def is also doubled, but Psyshock reads Def.
      expect(o.defense, 200);
    });

    test('Body Press uses the Defense stage for the attack stat', () {
      final o = sandboxState(
        moveName: 'Body Press',
        attackerStages: const {
          'atk': 2,
          'def': -2,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
      ).sandboxOverrides();
      // Attack is +2 but Body Press reads Defense, which is -2.
      expect(o.attack, 50);
    });
  });

  group('sandboxOverrides clamps', () {
    test('a stat never falls below 1', () {
      final o = sandboxState(
        attackerStages: const {
          'atk': -6,
          'def': 0,
          'spa': 0,
          'spd': 0,
          'spe': 0,
        },
        attack: 1,
      ).sandboxOverrides();
      expect(o.attack, greaterThanOrEqualTo(1));
    });

    test('very low input still produces a usable stat', () {
      final o = sandboxState(attack: 0.2, defense: 0.2).sandboxOverrides();
      expect(o.attack, greaterThanOrEqualTo(1));
      expect(o.defense, greaterThanOrEqualTo(1));
    });
  });
}

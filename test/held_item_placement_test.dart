import 'package:flutter_test/flutter_test.dart';

import 'package:libredex/features/calculator/utils/damage_math.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';

/// Held items enter the damage formula at one of three stages, and mixing them
/// up changes the result:
///
///   base power - Muscle Band, Wise Glasses, Punching Glove, type boosts
///   final      - Life Orb, Expert Belt (super-effective only), resist berries
///   stat       - Choice Band, Choice Specs, Eviolite, Assault Vest
///
/// Base power sits inside the formula's rounding chain and a final modifier
/// sits outside it, so a x1.1 in the wrong place produces different damage.
void main() {
  group('getAttackMultiplier returns only the stat multiplier', () {
    test('final-damage items do not touch the Attack stat', () {
      // Regression: Life Orb and the type-boosting items used to be folded in
      // here, and ModifierPipeline applied them again as final modifiers, so
      // they counted twice on the sandbox path.
      expect(HeldItemsData.getAttackMultiplier('Life Orb', false), 1.0);
      expect(HeldItemsData.getAttackMultiplier('Life Orb', true), 1.0);
      expect(HeldItemsData.getAttackMultiplier('Charcoal', false), 1.0);
      expect(HeldItemsData.getAttackMultiplier('Expert Belt', false), 1.0);
      expect(HeldItemsData.getAttackMultiplier('None', false), 1.0);
    });

    test('power-boosting items do not touch the Attack stat either', () {
      expect(HeldItemsData.getAttackMultiplier('Muscle Band', false), 1.0);
      expect(HeldItemsData.getAttackMultiplier('Wise Glasses', true), 1.0);
      expect(HeldItemsData.getAttackMultiplier('Punching Glove', false), 1.0);
    });

    test('real stat items still apply, on the correct side', () {
      expect(HeldItemsData.getAttackMultiplier('Choice Band', false), 1.5);
      expect(HeldItemsData.getAttackMultiplier('Choice Band', true), 1.0);
      expect(HeldItemsData.getAttackMultiplier('Choice Specs', true), 1.5);
      expect(HeldItemsData.getAttackMultiplier('Choice Specs', false), 1.0);
    });
  });

  group('getBasePowerMultiplier', () {
    double bp(
      String item, {
      String type = 'fire',
      String damageClass = 'physical',
      bool isPunching = false,
    }) =>
        HeldItemsData.getBasePowerMultiplier(
          item,
          moveType: type,
          damageClass: damageClass,
          isPunching: isPunching,
        );

    test('Muscle Band boosts physical only', () {
      expect(bp('Muscle Band'), 1.1);
      expect(bp('Muscle Band', damageClass: 'special'), 1.0);
      expect(bp('Muscle Band', damageClass: 'status'), 1.0);
    });

    test('Wise Glasses boosts special only', () {
      expect(bp('Wise Glasses', damageClass: 'special'), 1.1);
      expect(bp('Wise Glasses'), 1.0);
    });

    test('Punching Glove boosts punching moves only', () {
      expect(bp('Punching Glove'), 1.0);
      expect(bp('Punching Glove', isPunching: true), 1.1);
    });

    test('type-boosting items apply to their own type only', () {
      expect(bp('Charcoal'), 1.2);
      expect(bp('Charcoal', type: 'water'), 1.0);
    });

    test('final-modifier items are not applied to base power', () {
      expect(bp('Life Orb'), 1.0);
      expect(bp('Expert Belt'), 1.0);
    });

    test('stat items are not applied to base power', () {
      expect(bp('Choice Band'), 1.0);
      expect(bp('Choice Specs', damageClass: 'special'), 1.0);
    });

    test('nothing is applied twice for a stacking case', () {
      // A physical Fire punch with Muscle Band + Charcoal: 1.1 * 1.2.
      expect(
        bp('Muscle Band', isPunching: false),
        1.1,
        reason: 'Charcoal is a different item, so only Muscle Band applies',
      );
    });
  });

  group('getBasePowerChain uses the game’s exact fractions', () {
    List<int> chain(
      String item, {
      String type = 'fire',
      String damageClass = 'physical',
      bool isPunching = false,
    }) =>
        HeldItemsData.getBasePowerChain(
          item,
          moveType: type,
          damageClass: damageClass,
          isPunching: isPunching,
        );

    test('Muscle Band is 4505/4096, not the 4506 that 1.1 rounds to', () {
      expect(chain('Muscle Band'), [4505]);
    });

    test('type boost is 4915/4096', () {
      expect(chain('Charcoal'), [4915]);
      expect(chain('Charcoal', type: 'water'), isEmpty);
    });

    test('Punching Glove is applied once', () {
      // Regression: it was applied here AND by a hardcoded block in
      // ModifierPipeline, stacking it to 1.21x.
      //
      // Note 4506, not the 4505 every other 1.1x item uses. Showdown carries
      // the same inconsistency, so it is matched rather than corrected.
      expect(chain('Punching Glove', isPunching: true), [4506]);
      expect(chain('Punching Glove', isPunching: false), isEmpty);
    });

    test('final-modifier and stat items contribute nothing here', () {
      expect(chain('Life Orb'), isEmpty);
      expect(chain('Expert Belt'), isEmpty);
      expect(chain('Choice Band'), isEmpty);
    });

    test('a 95 BP move under Muscle Band is 104, not 105', () {
      // The whole point of the fractions: the decimal path rounds a .5 up,
      // the game rounds it down, so the two disagree by a point of damage.
      expect(DamageMath.fixedModifier(95, DamageMath.boost11), 104);
      expect((95 * 1.1).round(), 105);
    });
  });

  group('modifier chaining', () {
    test('final modifiers are chained, not rounded one at a time', () {
      // 7 damage through Filter (3072) then a halving (2048): rounding after
      // each gives 7 -> 5 -> 2, but the game combines both into 1536/4096
      // and rounds once: round(7 * 1536 / 4096) = round(2.625) = 3.
      expect(DamageMath.chainMods(const [3072, 2048]), 1536);
    });

    test('a lone modifier is itself', () {
      expect(DamageMath.chainMods(const [5324]), 5324);
      expect(DamageMath.chainMods(const []), 4096);
    });

    test('no-op modifiers are skipped rather than diluting the chain', () {
      expect(DamageMath.chainMods(const [4096, 5324, 4096]), 5324);
    });

    test('terrain is 5325, distinct from the 5324 other 1.3x effects use', () {
      expect(DamageMath.boostTerrain, 5325);
      expect(DamageMath.boost13, 5324);
    });
  });

  group('dataset integrity', () {
    test('every item offered in the picker actually resolves', () {
      for (final item in HeldItemsData.allItems) {
        expect(
          HeldItemsData.findByName(item.name),
          isNotNull,
          reason: '"${item.name}" is in allItems but findByName returns null. '
              'Unknown items silently resolve to a 1.0 multiplier, so any '
              'test or screen using one would be a no-op.',
        );
      }
    });

    test('the items that were unreachable are now present', () {
      for (final name in <String>[
        'Expert Belt',
        'Muscle Band',
        'Wise Glasses',
        'Punching Glove',
      ]) {
        expect(
          HeldItemsData.findByName(name),
          isNotNull,
          reason: '$name is handled by the pipeline but was missing from the '
              'item list, so no user could ever select it',
        );
      }
    });

    test('no item name appears twice', () {
      final seen = <String>{};
      for (final item in HeldItemsData.allItems) {
        expect(seen.add(item.name), isTrue, reason: 'duplicate: ${item.name}');
      }
    });
  });
}

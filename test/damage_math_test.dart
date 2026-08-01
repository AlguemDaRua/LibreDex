import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/utils/damage_math.dart';

void main() {
  group('Gen IX integer damage arithmetic', () {
    test('matches the published Showdown Abomasnow Blizzard roll table', () {
      // 252 SpA Abomasnow Blizzard vs 0 HP / 0 SpD Abomasnow, Gen 9.
      final range = DamageMath.calculate(
        level: 100,
        basePower: 110,
        attack: 283,
        defense: 206,
        stab: 1.5,
        effectiveness: 1,
      );
      expect(range.rolls, [162, 165, 166, 168, 169, 172, 174, 175,
        178, 180, 181, 183, 186, 187, 189, 192]);
    });

    test('matches current Showdown forced-critical and multi-hit vectors', () {
      // Vectors generated from @smogon/calc Gen 9 (2026-08-01), with the
      // shown final stats. They cover forced crits, per-hit rounding and the
      // 25%-base-damage Parental Bond child strike.
      final flowerTrick = DamageMath.calculate(
        level: 50, basePower: 70, attack: 162, defense: 115,
        stab: 1.5, effectiveness: 1, critical: true,
      );
      expect(flowerTrick.rolls,
          [84, 85, 87, 87, 88, 90, 90, 91, 93, 93, 94, 96, 96, 97, 99, 100]);

      final surgingStrikes = DamageMath.calculateMultiHit(
        basePowers: const [25, 25, 25], level: 50, attack: 200, defense: 130,
        stab: 1.5, effectiveness: 2, critical: true,
      );
      expect(surgingStrikes.perHit.first.rolls,
          [66, 68, 68, 68, 72, 72, 72, 72, 74, 74, 74, 74, 78, 78, 78, 80]);
      expect(surgingStrikes.total.min, 198);
      expect(surgingStrikes.total.max, 240);

      final tripleAxel = DamageMath.calculateMultiHit(
        basePowers: const [20, 40, 60], level: 50, attack: 172, defense: 115,
        stab: 1.5, effectiveness: 4,
      );
      expect(tripleAxel.perHit.map((hit) => [hit.min, hit.max]).toList(),
          [[72, 88], [136, 168], [204, 244]]);
      expect([tripleAxel.total.min, tripleAxel.total.max], [412, 500]);

      final parentalBond = DamageMath.calculateMultiHit(
        basePowers: const [85], level: 50, attack: 177, defense: 115,
        stab: 1.5, effectiveness: 1, parentalBond: true,
      );
      expect(parentalBond.perHit[1].rolls,
          [18, 18, 19, 19, 19, 19, 19, 19, 19, 21, 21, 21, 21, 21, 21, 22]);
      expect([parentalBond.total.min, parentalBond.total.max], [93, 110]);
    });
  });

  group('move and ability mechanics', () {
    test('type-changing abilities alter type and use their Gen IX BP bonus', () {
      expect(CombatUtils.effectiveMoveType(
        moveName: 'Hyper Voice', moveType: 'normal', attackerAbility: 'Pixilate',
      ), 'fairy');
      expect(CombatUtils.effectiveMoveType(
        moveName: 'Thunderbolt', moveType: 'electric', attackerAbility: 'Normalize',
      ), 'normal');
      expect(CombatUtils.typeChangingAbilityPowerMultiplier('Pixilate', 'normal'), 1.2);
    });

    test('Triple Axel is three independently rounded increasing-power hits', () {
      final result = DamageMath.calculateMultiHit(
        basePowers: const [20, 40, 60], level: 50, attack: 150, defense: 100,
        stab: 1.5, effectiveness: 1,
      );
      expect(result.perHit, hasLength(3));
      expect(result.perHit[1].min, greaterThan(result.perHit[0].min));
      expect(result.perHit[2].min, greaterThan(result.perHit[1].min));
      expect(result.total.min, result.perHit.fold(0, (sum, hit) => sum + hit.min));
    });

    test('Parental Bond exposes the reduced child hit separately', () {
      final result = DamageMath.calculateMultiHit(
        basePowers: const [90], level: 50, attack: 150, defense: 100,
        stab: 1.5, effectiveness: 1, parentalBond: true,
      );
      expect(result.perHit, hasLength(2));
      expect(result.perHit[1].max, lessThan(result.perHit[0].max));
      expect(result.total.max, result.perHit[0].max + result.perHit[1].max);
    });

    test('forced crit and Champions Rage Fist rules match Showdown', () {
      expect(CombatUtils.alwaysCriticalHit('Flower Trick'), isTrue);
      expect(CombatUtils.alwaysCriticalHit('Surging Strikes'), isTrue);
      expect(CombatUtils.guaranteedHitCount('Surging Strikes'), 3);
      expect(CombatUtils.isUnseenFistProtectionHit('Surging Strikes', 'Unseen Fist'), isTrue);
      expect(CombatUtils.breaksProtect('Phantom Force'), isTrue);
      expect(CombatUtils.resolveDynamicBasePower(
        moveName: 'Rage Fist', basePower: 50, rageFistHits: 6,
      ).basePower, 350);
      expect(CombatUtils.resolveDynamicBasePower(
        moveName: 'Rage Fist', basePower: 50, rageFistHits: 6,
        championsRules: true,
      ).basePower, 50);
    });
  });
}

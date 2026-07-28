import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';

/// Covers the damage calculator's gimmick base-power resolution: moves whose
/// database `power` is null (Low Kick, Grass Knot, Gyro Ball, ...) must still
/// compute real damage from battle context, and every rescaling gimmick must
/// follow the in-game rules.
void main() {
  group('resolveDynamicBasePower — weight gimmicks', () {
    test('Low Kick / Grass Knot use the defender weight tiers', () {
      for (final name in ['low kick', 'grass knot']) {
        expect(
          CombatUtils.resolveDynamicBasePower(moveName: name, basePower: 0, defenderWeightKg: 999.9).basePower,
          120,
          reason: '$name vs 999.9 kg (Groudon-class) must top out at 120',
        );
        expect(
          CombatUtils.resolveDynamicBasePower(moveName: name, basePower: 0, defenderWeightKg: 50).basePower,
          80,
        );
        expect(
          CombatUtils.resolveDynamicBasePower(moveName: name, basePower: 0, defenderWeightKg: 6.9).basePower,
          20,
        );
      }
    });

    test('Heavy Slam / Heat Crash use the attacker:defender weight ratio', () {
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'heavy slam', basePower: 0, attackerWeightKg: 460.0, defenderWeightKg: 90.0,
        ).basePower,
        120,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'heat crash', basePower: 0, attackerWeightKg: 6.0, defenderWeightKg: 999.9,
        ).basePower,
        40,
      );
    });

    test('missing weight context falls back to the given base power', () {
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'low kick', basePower: 50).basePower,
        50,
      );
    });

    test('the resolved note explains the rule applied', () {
      final note = CombatUtils.resolveDynamicBasePower(
        moveName: 'low kick', basePower: 0, defenderWeightKg: 999.9,
      ).note;
      expect(note, isNotNull);
      expect(note, contains('999.9'));
      expect(note, contains('120'));
    });
  });

  group('resolveDynamicBasePower — speed gimmicks', () {
    test('Gyro Ball is 25 × target/user speed, floored and capped at 150', () {
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'gyro ball', basePower: 0, attackerSpeedStat: 40, defenderSpeedStat: 400,
        ).basePower,
        150,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'gyro ball', basePower: 0, attackerSpeedStat: 201, defenderSpeedStat: 98,
        ).basePower,
        12, // 25 × 98/201 = 12.19 → 12
      );
    });

    test('Electro Ball tiers on the speed ratio', () {
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'electro ball', basePower: 0, attackerSpeedStat: 400, defenderSpeedStat: 90,
        ).basePower,
        150,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'electro ball', basePower: 0, attackerSpeedStat: 150, defenderSpeedStat: 90,
        ).basePower,
        60,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(
          moveName: 'electro ball', basePower: 0, attackerSpeedStat: 50, defenderSpeedStat: 90,
        ).basePower,
        40,
      );
    });
  });

  group('resolveDynamicBasePower — status & HP gimmicks', () {
    test('Venoshock doubles on poison or bad poison only', () {
      for (final status in ['poison', 'toxic']) {
        expect(
          CombatUtils.resolveDynamicBasePower(moveName: 'venoshock', basePower: 65, defenderStatus: status).basePower,
          130,
        );
      }
      for (final status in ['none', 'burn', 'paralysis']) {
        expect(
          CombatUtils.resolveDynamicBasePower(moveName: 'venoshock', basePower: 65, defenderStatus: status).basePower,
          65,
        );
      }
    });

    test('Crush Grip / Wring Out scale with the defender HP fraction', () {
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'crush grip', basePower: 0, defenderHpPercent: 50).basePower,
        60,
      );
    });

    test('Flail / Reversal tiers follow the attacker HP fraction', () {
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'flail', basePower: 0, attackerHpPercent: 3).basePower,
        200,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'reversal', basePower: 0, attackerHpPercent: 15).basePower,
        100,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'flail', basePower: 0, attackerHpPercent: 100).basePower,
        20,
      );
    });

    test('Hard Press scales with the defender HP fraction', () {
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'hard press', basePower: 0, defenderHpPercent: 25).basePower,
        25,
      );
    });
  });

  group('resolveDynamicBasePower — environment gimmicks', () {
    test('Weather Ball transforms type and doubles power in weather only', () {
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'weather ball', basePower: 50, weather: 'rainy').basePower,
        100,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'weather ball', basePower: 50, weather: 'none').basePower,
        50,
      );
    });

    test('Terrain Pulse transforms type and doubles power on terrain only', () {
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'terrain pulse', basePower: 50, terrain: 'misty').basePower,
        100,
      );
      expect(
        CombatUtils.resolveDynamicBasePower(moveName: 'terrain pulse', basePower: 50, terrain: 'none').basePower,
        50,
      );
    });
  });

  group('effectiveMoveType', () {
    test('Weather Ball follows the weather', () {
      expect(CombatUtils.effectiveMoveType(moveName: 'weather ball', moveType: 'normal', weather: 'sunny'), 'fire');
      expect(CombatUtils.effectiveMoveType(moveName: 'weather ball', moveType: 'normal', weather: 'rainy'), 'water');
      expect(CombatUtils.effectiveMoveType(moveName: 'weather ball', moveType: 'normal', weather: 'sandstorm'), 'rock');
      expect(CombatUtils.effectiveMoveType(moveName: 'weather ball', moveType: 'normal', weather: 'snow'), 'ice');
      expect(CombatUtils.effectiveMoveType(moveName: 'weather ball', moveType: 'normal', weather: 'none'), 'normal');
    });

    test('Terrain Pulse follows the terrain', () {
      expect(CombatUtils.effectiveMoveType(moveName: 'terrain pulse', moveType: 'normal', terrain: 'electric'), 'electric');
      expect(CombatUtils.effectiveMoveType(moveName: 'terrain pulse', moveType: 'normal', terrain: 'grassy'), 'grass');
      expect(CombatUtils.effectiveMoveType(moveName: 'terrain pulse', moveType: 'normal', terrain: 'psychic'), 'psychic');
      expect(CombatUtils.effectiveMoveType(moveName: 'terrain pulse', moveType: 'normal', terrain: 'misty'), 'fairy');
    });

    test('other moves pass through lowercased', () {
      expect(CombatUtils.effectiveMoveType(moveName: 'thunderbolt', moveType: 'Electric'), 'electric');
    });
  });

  group('gimmick registry vs bundled moves', () {
    test('every registered gimmick move exists in moves.json with a damaging class', () {
      final moves = jsonDecode(File('assets/data/moves.json').readAsStringSync()) as List<dynamic>;
      final byName = {
        for (final m in moves)
          (m['name'] as String).toLowerCase().replaceAll('-', ' ').replaceAll('_', ' '): m as Map<String, dynamic>,
      };
      for (final gimmick in CombatUtils.dynamicBasePowerMoves) {
        final row = byName[gimmick];
        expect(row, isNotNull, reason: 'registered gimmick move $gimmick missing from moves.json');
        expect(
          (row!['damageClass'] as String).toLowerCase(),
          isNot('status'),
          reason: '$gimmick must be selectable as a damaging move',
        );
      }
    });

    test('previously supported gimmicks keep their behavior', () {
      expect(CombatUtils.calculateDynamicBasePower(moveName: 'return', basePower: 0, friendship: 255), 102);
      expect(CombatUtils.calculateDynamicBasePower(moveName: 'eruption', basePower: 150, attackerHpPercent: 50), 75);
      expect(CombatUtils.calculateDynamicBasePower(moveName: 'acrobatics', basePower: 55), 110);
      expect(CombatUtils.calculateDynamicBasePower(moveName: 'acrobatics', basePower: 55, attackerHeldItem: 'Leftovers'), 55);
      // Non-gimmick moves always pass through untouched.
      expect(CombatUtils.calculateDynamicBasePower(moveName: 'thunderbolt', basePower: 90), 90);
      expect(CombatUtils.supportsDynamicBasePower('thunderbolt'), isFalse);
      expect(CombatUtils.supportsDynamicBasePower('Low-Kick'), isTrue);
    });
  });
}

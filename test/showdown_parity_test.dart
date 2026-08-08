/// Showdown Engine Parity & Verification Test Suite.
///
/// Verifies LibreDex battle engine calculations against pinned Pokémon Showdown
/// test vectors, fixed-point rounding rules, multi-hit mechanics, dynamic base
/// power moves, and Pokémon Champions ruleset compliance.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/data/battle_data_manifest.dart';
import 'package:libredex/features/calculator/utils/damage_math.dart';
import 'package:libredex/features/battle_engine/battle_engine.dart';

void main() {
  group('Showdown Parity & Versioning Manifest', () {
    test('BattleDataManifest exposes correct version pins', () {
      expect(BattleDataManifest.showdownVersionPin, contains('Gen IX'));
      expect(BattleDataManifest.championsRulesetVersion, contains('Champions'));
      expect(BattleDataManifest.engineVersion, equals('1.0.0'));
      expect(BattleDataManifest.summary, contains('LibreDex Battle Engine'));
    });
  });

  group('Showdown Parity Test Vectors', () {
    test('Vector 1: Abomasnow Blizzard vs Dragonite (Multiscale)', () {
      // Abomasnow Lv 50, Modest nature, 252 SpA EVs -> 158 SpA
      // Dragonite Lv 50, 0 HP / 0 SpD -> 166 HP, 120 SpD
      // Move: Blizzard (110 BP, Ice, Special, STAB = 1.5) vs Dragonite (Dragon/Flying = 4x Ice)
      // Dragonite Multiscale active at 100% HP -> 0.5x final modifier

      const abomasnow = Pokemon(
        id: 460, name: 'Abomasnow', form: 'normal', type1: 'grass', type2: 'ice',
        baseHp: 90, baseAtk: 92, baseDef: 75, baseSpAtk: 92, baseSpDef: 85, baseSpd: 60,
        isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false,
        spriteUrl: '', shinySpriteUrl: '', nationalDexNumber: 460,
        generation: 4, evolutionStage: 2, isChampions: false, isLegendsZA: false,
      );

      const dragonite = Pokemon(
        id: 149, name: 'Dragonite', form: 'normal', type1: 'dragon', type2: 'flying',
        baseHp: 91, baseAtk: 134, baseDef: 95, baseSpAtk: 100, baseSpDef: 100, baseSpd: 80,
        isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false,
        spriteUrl: '', shinySpriteUrl: '', nationalDexNumber: 149,
        generation: 1, evolutionStage: 3, isChampions: false, isLegendsZA: false,
      );

      final attacker = PokemonState.fromDatabase(
        abomasnow, level: 50, nature: 'modest',
        evs: {'hp': 0, 'atk': 0, 'def': 0, 'spa': 252, 'spd': 0, 'spe': 0},
      );

      final defender = PokemonState.fromDatabase(
        dragonite, level: 50, nature: 'serious', ability: 'multiscale', hpPercent: 100.0,
      );

      const move = MoveState(
        name: 'Blizzard', type: 'ice', basePower: 110, damageClass: 'special',
      );

      final bState = BattleState(
        attacker: attacker, defender: defender, move: move, field: const FieldState(),
      );

      final result = BattleEngine.calculate(bState);

      expect(result.rolls.length, equals(16));
      expect(result.typeEffectiveness, equals(4.0));
      expect(result.modifiers.any((m) => m.name.contains('Multiscale')), isTrue);

      // Verify exact Showdown damage roll output for this vector
      final expectedRolls = [164, 164, 168, 170, 170, 174, 176, 176, 180, 182, 182, 186, 188, 188, 192, 194];
      expect(result.rolls, equals(expectedRolls));
    });

    test('Vector 2: Tera Water Palafin Wave Crash in Rain with Choice Band', () {
      const palafin = Pokemon(
        id: 964, name: 'Palafin-Hero', form: 'hero', type1: 'water', type2: null,
        baseHp: 100, baseAtk: 160, baseDef: 97, baseSpAtk: 106, baseSpDef: 87, baseSpd: 100,
        isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false,
        spriteUrl: '', shinySpriteUrl: '', nationalDexNumber: 964,
        generation: 9, evolutionStage: 2, isChampions: false, isLegendsZA: false,
      );

      const tinglu = Pokemon(
        id: 988, name: 'Ting-Lu', form: 'normal', type1: 'dark', type2: 'ground',
        baseHp: 155, baseAtk: 110, baseDef: 125, baseSpAtk: 55, baseSpDef: 80, baseSpd: 45,
        isLegendary: true, isMythical: false, isParadox: false, isUltraBeast: false,
        spriteUrl: '', shinySpriteUrl: '', nationalDexNumber: 988,
        generation: 9, evolutionStage: 1, isChampions: false, isLegendsZA: false,
      );

      final attacker = PokemonState.fromDatabase(
        palafin, level: 50, nature: 'adamant', heldItem: 'Choice Band',
        teraActive: true, teraType: 'water',
        evs: {'hp': 0, 'atk': 252, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 252},
      );

      final defender = PokemonState.fromDatabase(
        tinglu, level: 50, nature: 'impish',
        evs: {'hp': 252, 'atk': 0, 'def': 252, 'spa': 0, 'spd': 4, 'spe': 0},
      );

      const move = MoveState(
        name: 'Wave Crash', type: 'water', basePower: 120, damageClass: 'physical',
      );

      final bState = BattleState(
        attacker: attacker, defender: defender, move: move,
        field: const FieldState(weather: 'rainy'),
      );

      final result = BattleEngine.calculate(bState);

      expect(result.typeEffectiveness, equals(2.0)); // Water vs Dark/Ground (2x Ground, 1x Dark = 2x)
      expect(result.modifiers.any((m) => m.name.contains('Rain')), isTrue);
      expect(result.minDamage, greaterThan(200));
    });

    test('Vector 3: Multi-hit Triple Axel 3-hit BP calculation parity', () {
      final multiResult = DamageMath.calculateMultiHit(
        basePowers: [20, 40, 60],
        level: 50,
        attack: 150,
        defense: 100,
        stab: 1.5,
        effectiveness: 1.0,
      );

      expect(multiResult.perHit.length, equals(3));
      expect(multiResult.total.rolls.length, equals(16));
      expect(multiResult.total.min, equals(
        multiResult.perHit[0].min + multiResult.perHit[1].min + multiResult.perHit[2].min,
      ));
    });

    test('Vector 4: Parental Bond child hit 25% base power reduction', () {
      final pbResult = DamageMath.calculateMultiHit(
        basePowers: [100],
        level: 50,
        attack: 200,
        defense: 100,
        stab: 1.5,
        effectiveness: 1.0,
        parentalBond: true,
      );

      expect(pbResult.perHit.length, equals(2)); // Parent hit + Child hit
      expect(pbResult.perHit[1].max, lessThan(pbResult.perHit[0].max));
    });

    test('Vector 5: Dynamic Base Power Facade when statused', () {
      const zangoose = Pokemon(
        id: 335, name: 'Zangoose', form: 'normal', type1: 'normal', type2: null,
        baseHp: 73, baseAtk: 115, baseDef: 60, baseSpAtk: 60, baseSpDef: 60, baseSpd: 90,
        isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false,
        spriteUrl: '', shinySpriteUrl: '', nationalDexNumber: 335,
        generation: 3, evolutionStage: 1, isChampions: false, isLegendsZA: false,
      );

      final statusedAttacker = PokemonState.fromDatabase(
        zangoose, level: 50, status: 'toxic', ability: 'toxic boost',
      );
      final defender = PokemonState.fromDatabase(zangoose, level: 50);

      const move = MoveState(
        name: 'Facade', type: 'normal', basePower: 70, damageClass: 'physical',
      );

      final bState = BattleState(
        attacker: statusedAttacker, defender: defender, move: move,
        field: const FieldState(),
      );

      final result = BattleEngine.calculate(bState);

      expect(result.effectiveBasePower, equals(140)); // 70 * 2 = 140
      expect(result.modifiers.any((m) => m.name.contains('Facade')), isTrue);
    });

    test('Vector 6: 0 Base Power attacking move surfaces warning', () {
      const pikachu = Pokemon(
        id: 25, name: 'Pikachu', form: 'normal', type1: 'electric', type2: null,
        baseHp: 35, baseAtk: 55, baseDef: 40, baseSpAtk: 50, baseSpDef: 50, baseSpd: 90,
        isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false,
        spriteUrl: '', shinySpriteUrl: '', nationalDexNumber: 25,
        generation: 1, evolutionStage: 1, isChampions: false, isLegendsZA: false,
      );

      final attacker = PokemonState.fromDatabase(pikachu, level: 50);
      final defender = PokemonState.fromDatabase(pikachu, level: 50);

      const move = MoveState(
        name: 'Custom Move', type: 'normal', basePower: 0, damageClass: 'physical',
      );

      final bState = BattleState(
        attacker: attacker, defender: defender, move: move, field: const FieldState(),
      );

      final result = BattleEngine.calculate(bState);

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.first, contains('Base power is 0'));
    });
  });
}

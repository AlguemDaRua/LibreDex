import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/battle_engine/battle_engine.dart';

void main() {
  late Pokemon pikachu;
  late Pokemon blastoise;

  setUp(() {
    pikachu = const Pokemon(
      id: 25,
      name: 'Pikachu',
      form: 'normal',
      type1: 'electric',
      type2: null,
      baseHp: 35,
      baseAtk: 55,
      baseDef: 40,
      baseSpAtk: 50,
      baseSpDef: 50,
      baseSpd: 90,
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: 25,
    );

    blastoise = const Pokemon(
      id: 9,
      name: 'Blastoise',
      form: 'normal',
      type1: 'water',
      type2: null,
      baseHp: 79,
      baseAtk: 83,
      baseDef: 100,
      baseSpAtk: 85,
      baseSpDef: 105,
      baseSpd: 78,
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: 9,
    );
  });

  group('BattleEngine - Pure Dart Engine', () {
    test('PokemonState creation and active types', () {
      final atkState = PokemonState.fromDatabase(pikachu, level: 50, nature: 'timid');
      expect(atkState.name, equals('Pikachu'));
      expect(atkState.level, equals(50));
      expect(atkState.activeTypes, equals(['electric']));

      // Tera Ground
      final teraState = atkState.copyWith(teraActive: true, teraType: 'ground');
      expect(teraState.activeTypes, equals(['ground']));
    });

    test('StatEngine calculates correct max HP and effective stats', () {
      final atkState = PokemonState.fromDatabase(
        pikachu,
        level: 50,
        ivs: {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
        evs: {'hp': 252, 'atk': 0, 'def': 0, 'spa': 252, 'spd': 0, 'spe': 4},
      );

      final hp = StatEngine.calculateMaxHp(atkState, BattleRuleset.mainline);
      expect(hp, equals(142)); // Pikachu Lv 50, 35 Base, 31 IV, 252 EV = 142 HP
    });

    test('ModifierPipeline applies STAB and Type Effectiveness correctly', () {
      final atkState = PokemonState.fromDatabase(pikachu, level: 50);
      final defState = PokemonState.fromDatabase(blastoise, level: 50);
      const moveState = MoveState(
        name: 'Thunderbolt',
        type: 'electric',
        basePower: 90,
        damageClass: 'special',
      );
      const fieldState = FieldState();

      final bState = BattleState(
        attacker: atkState,
        defender: defState,
        move: moveState,
        field: fieldState,
      );

      final result = BattleEngine.calculate(bState);

      expect(result.rolls.length, equals(16));
      expect(result.typeEffectiveness, equals(2.0)); // Electric vs Water = 2x
      expect(result.effectiveBasePower, equals(90));
      expect(result.modifiers.any((m) => m.name.contains('STAB')), isTrue);
      expect(result.modifiers.any((m) => m.name.contains('2× Type Effectiveness')), isTrue);
      expect(result.minDamage, greaterThan(0));
      expect(result.maxDamage, greaterThanOrEqualTo(result.minDamage));
    });

    test('ChampionsDamageEngine forces level 50 and handles SP points', () {
      final atkState = PokemonState.fromDatabase(
        pikachu,
        sps: {'hp': 10, 'atk': 0, 'def': 0, 'spa': 32, 'spd': 0, 'spe': 23},
      );
      final defState = PokemonState.fromDatabase(
        blastoise,
        sps: {'hp': 32, 'atk': 0, 'def': 32, 'spa': 0, 'spd': 1, 'spe': 0},
      );
      const moveState = MoveState(
        name: 'Thunderbolt',
        type: 'electric',
        basePower: 90,
        damageClass: 'special',
      );

      final bState = BattleState(
        attacker: atkState,
        defender: defState,
        move: moveState,
        field: const FieldState(),
        ruleset: BattleRuleset.champions,
      );

      final result = BattleEngine.calculate(bState);

      expect(result.rolls.length, equals(16));
      expect(result.minDamage, greaterThan(0));
      expect(result.koChance, isNotEmpty);
    });

    test('Burn halves physical damage in ModifierPipeline', () {
      final atkState = PokemonState.fromDatabase(
        pikachu,
        level: 50,
        status: 'burn',
      );
      final defState = PokemonState.fromDatabase(blastoise, level: 50);
      const physMove = MoveState(
        name: 'Volt Tackle',
        type: 'electric',
        basePower: 120,
        damageClass: 'physical',
      );

      final bState = BattleState(
        attacker: atkState,
        defender: defState,
        move: physMove,
        field: const FieldState(),
      );

      final result = BattleEngine.calculate(bState);
      expect(result.modifiers.any((m) => m.name.contains('Burn')), isTrue);
    });

    test('Multi-hit move (Triple Axel) sums all hits for total damage and KO calculation', () {
      const garchomp = Pokemon(
        id: 445,
        name: 'Garchomp',
        form: 'normal',
        type1: 'dragon',
        type2: 'ground',
        baseHp: 108,
        baseAtk: 130,
        baseDef: 95,
        baseSpAtk: 80,
        baseSpDef: 85,
        baseSpd: 102,
        isLegendary: false,
        isMythical: false,
        isParadox: false,
        isUltraBeast: false,
        spriteUrl: '',
        shinySpriteUrl: '',
        nationalDexNumber: 445,
      );

      const weavile = Pokemon(
        id: 461,
        name: 'Weavile',
        form: 'normal',
        type1: 'dark',
        type2: 'ice',
        baseHp: 70,
        baseAtk: 120,
        baseDef: 65,
        baseSpAtk: 45,
        baseSpDef: 85,
        baseSpd: 125,
        isLegendary: false,
        isMythical: false,
        isParadox: false,
        isUltraBeast: false,
        spriteUrl: '',
        shinySpriteUrl: '',
        nationalDexNumber: 461,
      );

      final atkState = PokemonState.fromDatabase(weavile, level: 100);
      final defState = PokemonState.fromDatabase(garchomp, level: 100);
      const tripleAxel = MoveState(
        name: 'Triple Axel',
        type: 'ice',
        basePower: 20,
        damageClass: 'physical',
      );

      final bState = BattleState(
        attacker: atkState,
        defender: defState,
        move: tripleAxel,
        field: const FieldState(),
      );

      final result = BattleEngine.calculate(bState);
      // Triple Axel (20 -> 40 -> 60 BP) 4x effective vs Garchomp
      expect(result.minDamage, greaterThan(300));
      expect(result.minPercentage, greaterThan(100.0));
      expect(result.koChance, equals('guaranteed OHKO'));
    });
  });
}

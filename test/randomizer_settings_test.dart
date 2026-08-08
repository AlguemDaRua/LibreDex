import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/viewmodels/randomizer_settings_provider.dart';

void main() {
  group('RandomizerSettings Model & Criteria Tests', () {
    const dummyPikachu = Pokemon(
      id: 25,
      name: 'Pikachu',
      form: '',
      type1: 'electric',
      type2: null,
      baseHp: 35,
      baseAtk: 55,
      baseDef: 40,
      baseSpAtk: 50,
      baseSpDef: 50,
      baseSpd: 90, // BST = 320
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: 25,
      generation: 1,
      evolutionStage: 0,
      isChampions: false,
      isLegendsZA: false,
    );

    const dummyCharizard = Pokemon(
      id: 6,
      name: 'Charizard',
      form: '',
      type1: 'fire',
      type2: 'flying',
      baseHp: 78,
      baseAtk: 84,
      baseDef: 78,
      baseSpAtk: 109,
      baseSpDef: 85,
      baseSpd: 100, // BST = 534
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: 6,
      generation: 1,
      evolutionStage: 2,
      isChampions: false,
      isLegendsZA: false,
    );

    const dummyRayquaza = Pokemon(
      id: 384,
      name: 'Rayquaza',
      form: '',
      type1: 'dragon',
      type2: 'flying',
      baseHp: 105,
      baseAtk: 150,
      baseDef: 90,
      baseSpAtk: 150,
      baseSpDef: 90,
      baseSpd: 95, // BST = 680
      isLegendary: true,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: 384,
      generation: 3,
      evolutionStage: 0,
      isChampions: false,
      isLegendsZA: false,
    );

    test('default settings allow all pokemon', () {
      const settings = RandomizerSettings();
      expect(settings.poolMode, equals(RandomPoolMode.all));
      expect(settings.instantRollOnTap, isFalse);
      expect(settings.matchesCustomCriteria(dummyPikachu), isTrue);
      expect(settings.matchesCustomCriteria(dummyCharizard), isTrue);
      expect(settings.matchesCustomCriteria(dummyRayquaza), isTrue);
    });

    test('custom type filter works correctly', () {
      const settings = RandomizerSettings(
        poolMode: RandomPoolMode.custom,
        selectedTypes: {'fire'},
      );
      expect(settings.matchesCustomCriteria(dummyPikachu), isFalse);
      expect(settings.matchesCustomCriteria(dummyCharizard), isTrue);
      expect(settings.matchesCustomCriteria(dummyRayquaza), isFalse);
    });

    test('custom gen filter works correctly', () {
      const settings = RandomizerSettings(
        poolMode: RandomPoolMode.custom,
        selectedGens: {3},
      );
      expect(settings.matchesCustomCriteria(dummyPikachu), isFalse);
      expect(settings.matchesCustomCriteria(dummyCharizard), isFalse);
      expect(settings.matchesCustomCriteria(dummyRayquaza), isTrue);
    });

    test('BST range filter works correctly', () {
      const settings = RandomizerSettings(
        poolMode: RandomPoolMode.custom,
        minBst: 500,
        maxBst: 600,
      );
      expect(settings.matchesCustomCriteria(dummyPikachu), isFalse); // 320
      expect(settings.matchesCustomCriteria(dummyCharizard), isTrue); // 534
      expect(settings.matchesCustomCriteria(dummyRayquaza), isFalse); // 680
    });

    test('JSON serialization & deserialization', () {
      const settings = RandomizerSettings(
        poolMode: RandomPoolMode.custom,
        selectedTypes: {'electric', 'dragon'},
        selectedGens: {1, 3},
        minBst: 300,
        maxBst: 700,
        fullyEvolvedOnly: true,
        instantRollOnTap: true,
      );

      final jsonMap = settings.toJson();
      final restored = RandomizerSettings.fromJson(jsonMap);

      expect(restored.poolMode, equals(RandomPoolMode.custom));
      expect(restored.selectedTypes, equals({'electric', 'dragon'}));
      expect(restored.selectedGens, equals({1, 3}));
      expect(restored.minBst, equals(300));
      expect(restored.maxBst, equals(700));
      expect(restored.fullyEvolvedOnly, isTrue);
      expect(restored.instantRollOnTap, isTrue);
    });
  });
}

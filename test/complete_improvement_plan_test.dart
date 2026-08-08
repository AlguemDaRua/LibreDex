import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';

Move createTestMove({
  required int id,
  required String name,
  required String type,
  required int pp,
  required String damageClass,
}) {
  final n = name.toLowerCase();
  final priority = (n == 'protect') ? 4 : ((n == 'quick attack') ? 1 : 0);
  final isContact = (n == 'tackle') ? true : false;
  final isWind = (n == 'hurricane') ? true : false;
  final isDance = (n == 'swords dance') ? true : false;
  final isRecoil = (n == 'double-edge') ? true : false;
  final isHealing = (n == 'roost') ? true : false;

  return Move(
    id: id,
    name: name,
    type: type,
    pp: pp,
    damageClass: damageClass,
    priority: priority,
    isContact: isContact,
    isHealing: isHealing,
    isSound: false,
    isPunching: false,
    isBiting: false,
    isPowder: false,
    isPulse: false,
    isBallistic: false,
    isSlicing: false,
    isWind: isWind,
    isDance: isDance,
    isBite: false,
    isMultiHit: false,
    isProtective: false,
    isSwitching: false,
    isRecharge: false,
    isRecoil: isRecoil,
    isDraining: false,
    isStatusMove: damageClass.toLowerCase() == 'status',
    isDamagingMove: damageClass.toLowerCase() != 'status',
    isSignatureMove: false,
    isDLCMove: false,
    isChampionsMove: false,
    isLegendsZAMove: false,
    generation: (id >= 850) ? 9 : 1,
  );
}

Ability createTestAbility({
  required int id,
  required String name,
  required String description,
}) {
  return Ability(
    id: id,
    name: name,
    description: description,
    generation: 1,
    isHiddenAbility: false,
    isChampionsAbility: id >= 10000,
    isLegendsZAAbility: false,
    effectTags: description.contains('rain') ? 'Weather' : 'Status',
    sourceGames: id >= 10000 ? 'Pokémon Champions' : 'Mainline Games',
  );
}

void main() {
  group('Move Properties & Extensions Tests', () {
    test('Priority calculation', () {
      final m1 = createTestMove(id: 1, name: 'Protect', type: 'normal', pp: 10, damageClass: 'status');
      final m2 = createTestMove(id: 2, name: 'Quick Attack', type: 'normal', pp: 30, damageClass: 'physical');
      final m3 = createTestMove(id: 3, name: 'Earthquake', type: 'ground', pp: 10, damageClass: 'physical');

      expect(m1.priority, equals(4));
      expect(m2.priority, equals(1));
      expect(m3.priority, equals(0));
    });

    test('Contact property detection', () {
      final physicalContact = createTestMove(id: 1, name: 'Tackle', type: 'normal', pp: 35, damageClass: 'physical');
      final physicalNonContact = createTestMove(id: 2, name: 'Earthquake', type: 'ground', pp: 10, damageClass: 'physical');
      final special = createTestMove(id: 3, name: 'Surf', type: 'water', pp: 15, damageClass: 'special');

      expect(physicalContact.isContact, isTrue);
      expect(physicalNonContact.isContact, isFalse);
      expect(special.isContact, isFalse);
    });

    test('Wind and Dance classifications', () {
      final wind = createTestMove(id: 1, name: 'Hurricane', type: 'flying', pp: 10, damageClass: 'special');
      final dance = createTestMove(id: 2, name: 'Swords Dance', type: 'normal', pp: 20, damageClass: 'status');

      expect(wind.isWind, isTrue);
      expect(dance.isDance, isTrue);
    });

    test('Recoil and Healing classifications', () {
      final recoil = createTestMove(id: 1, name: 'Double-Edge', type: 'normal', pp: 15, damageClass: 'physical');
      final healing = createTestMove(id: 2, name: 'Roost', type: 'flying', pp: 10, damageClass: 'status');

      expect(recoil.isRecoil, isTrue);
      expect(healing.isHealing, isTrue);
    });

    test('Move generations', () {
      final gen1 = createTestMove(id: 10, name: 'Gust', type: 'normal', pp: 35, damageClass: 'special');
      final gen9 = createTestMove(id: 850, name: 'Raging Bull', type: 'normal', pp: 10, damageClass: 'physical');

      expect(gen1.generation, equals(1));
      expect(gen9.generation, equals(9));
    });
  });

  group('Ability Classifications & Tag Tests', () {
    test('Effect tags from description', () {
      final weatherAbility = createTestAbility(id: 1, name: 'Drizzle', description: 'Summons rain in battle.');
      final statusAbility = createTestAbility(id: 2, name: 'Static', description: 'May paralyze the foe on contact.');

      expect(weatherAbility.effectTags, contains('Weather'));
      expect(statusAbility.effectTags, contains('Status'));
    });

    test('Ability Source games', () {
      final regular = createTestAbility(id: 2, name: 'Drizzle', description: 'Summons rain.');
      final champ = createTestAbility(id: 10001, name: 'Mountaineer', description: 'No description.');

      expect(regular.sourceGames, equals('Mainline Games'));
      expect(champ.sourceGames, equals('Pokémon Champions'));
    });
  });

  group('Pokemon Properties & Classifications Tests', () {
    test('Generation rules based on nationalDexNumber/ID', () {
      final p1 = Pokemon(id: 25, nationalDexNumber: 25, generation: 1, evolutionStage: 1, isChampions: false, isLegendsZA: false, name: 'Pikachu', form: 'normal', type1: 'electric', baseHp: 35, baseAtk: 55, baseDef: 40, baseSpAtk: 50, baseSpDef: 50, baseSpd: 90, isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false, spriteUrl: '', shinySpriteUrl: '');
      final p2 = Pokemon(id: 1000, nationalDexNumber: 1000, generation: 9, evolutionStage: 1, isChampions: false, isLegendsZA: false, name: 'Gholdengo', form: 'normal', type1: 'steel', baseHp: 87, baseAtk: 60, baseDef: 95, baseSpAtk: 133, baseSpDef: 91, baseSpd: 84, isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false, spriteUrl: '', shinySpriteUrl: '');

      expect(p1.generation, equals(1));
      expect(p2.generation, equals(9));
    });

    test('Egg group assignments', () {
      final plant = Pokemon(id: 1, nationalDexNumber: 1, generation: 1, evolutionStage: 1, isChampions: false, isLegendsZA: false, name: 'Bulbasaur', form: 'normal', type1: 'grass', baseHp: 45, baseAtk: 49, baseDef: 49, baseSpAtk: 65, baseSpDef: 65, baseSpd: 45, isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false, spriteUrl: '', shinySpriteUrl: '', eggGroups: 'Monster');
      final legendary = Pokemon(id: 150, nationalDexNumber: 150, generation: 1, evolutionStage: 1, isChampions: false, isLegendsZA: false, name: 'Mewtwo', form: 'normal', type1: 'psychic', baseHp: 106, baseAtk: 110, baseDef: 90, baseSpAtk: 154, baseSpDef: 90, baseSpd: 130, isLegendary: true, isMythical: false, isParadox: false, isUltraBeast: false, spriteUrl: '', shinySpriteUrl: '', eggGroups: 'Undiscovered');

      expect(plant.eggGroups, contains('Monster'));
      expect(legendary.eggGroups, contains('Undiscovered'));
    });

    test('Evolution Stage estimation', () {
      final pCharizard = Pokemon(id: 6, nationalDexNumber: 6, generation: 1, evolutionStage: 2, isChampions: false, isLegendsZA: false, name: 'Charizard', form: 'normal', type1: 'fire', baseHp: 78, baseAtk: 84, baseDef: 78, baseSpAtk: 109, baseSpDef: 85, baseSpd: 100, isLegendary: false, isMythical: false, isParadox: false, isUltraBeast: false, spriteUrl: '', shinySpriteUrl: '');
      expect(pCharizard.evolutionStage, equals(2)); // Stage 2
    });
  });
}

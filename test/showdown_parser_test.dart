import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/team_builder/utils/showdown_parser.dart';

void main() {
  group('ShowdownParser', () {
    const p1 = Pokemon(
      id: 25,
      nationalDexNumber: 25,
      name: 'pikachu',
      form: 'normal',
      type1: 'electric',
      type2: null,
      baseHp: 35,
      baseAtk: 55,
      baseDef: 40,
      baseSpAtk: 50,
      baseSpDef: 50,
      baseSpd: 90,
      spriteUrl: '',
      shinySpriteUrl: '',
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
    );

    const p2 = Pokemon(
      id: 10037,
      nationalDexNumber: 38,
      name: 'ninetales',
      form: 'alola',
      type1: 'ice',
      type2: 'fairy',
      baseHp: 73,
      baseAtk: 67,
      baseDef: 75,
      baseSpAtk: 81,
      baseSpDef: 100,
      baseSpd: 109,
      spriteUrl: '',
      shinySpriteUrl: '',
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
    );

    test('exportTeam formats species names and forms accurately', () {
      final text = ShowdownParser.exportTeam([p1, p2]);
      expect(text, contains('Pikachu'));
      expect(text, contains('Ninetales-Alola'));
      expect(text, contains('EVs: 252 HP / 4 Def / 252 Spe'));
    });
  });
}

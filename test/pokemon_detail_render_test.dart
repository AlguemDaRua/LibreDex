import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

void main() {
  const dummyBulbasaur = Pokemon(
    id: 1,
    name: 'bulbasaur',
    form: 'normal',
    type1: 'grass',
    type2: 'poison',
    baseHp: 45,
    baseAtk: 49,
    baseDef: 49,
    baseSpAtk: 65,
    baseSpDef: 65,
    baseSpd: 45,
    isLegendary: false,
    isMythical: false,
    isParadox: false,
    isUltraBeast: false,
    spriteUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
    shinySpriteUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png',
    nationalDexNumber: 1,
  );

  testWidgets('PokemonDetailScreen renders basic tabs and header without crashing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokemonAbilitiesStreamProvider(1).overrideWith((ref) => Stream.value([])),
          pokemonMovesStreamProvider(1).overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: PokemonDetailScreen(forms: [dummyBulbasaur]),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('#001 BULBASAUR'), findsOneWidget);
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('STATS'), findsOneWidget);
    expect(find.text('MOVES'), findsOneWidget);
  });
}

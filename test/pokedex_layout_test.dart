import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/core/theme/app_theme.dart';

void main() {
  testWidgets('PokedexScreen renders list layout without SliverGeometry errors', (tester) async {
    const mockPokemon = Pokemon(
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
      generation: 1,
      evolutionStage: 1,
      isChampions: false,
      isLegendsZA: false,
    );

    tester.view.physicalSize = const Size(1080, 2400); // Phone size
    tester.view.devicePixelRatio = 2.625;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokedexProvider.overrideWith((ref) => Stream.value([mockPokemon])),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: const PokedexScreen()),
      ),
    );

    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 500));
    
    // Dump tree to debug if it fails
    if (find.textContaining('ulbasaur', skipOffstage: false).evaluate().isEmpty) {
      debugDumpApp();
    }

    expect(find.textContaining('ulbasaur', skipOffstage: false), findsWidgets);
    
    // Reset view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

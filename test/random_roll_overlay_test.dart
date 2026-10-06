import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/widgets/random_roll_overlay.dart';

void main() {
  testWidgets('RandomRollOverlay renders and completes roll sequence', (
    tester,
  ) async {
    const candidate = Pokemon(
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
      baseSpd: 90,
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

    Pokemon? selectedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                RandomRollOverlay.show(
                  context,
                  candidatePool: [candidate],
                  onViewDetails: (pokemon) {
                    selectedResult = pokemon;
                  },
                );
              },
              child: const Text('Roll'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Roll'));
    await tester.pump(); // Open dialog

    expect(find.text('RANDOMIZING...'), findsOneWidget);

    // Pump timers until animation completes
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('TARGET ACQUIRED!'), findsOneWidget);
    expect(find.text('PIKACHU'), findsOneWidget);
    expect(find.text('VIEW POKÉMON DETAILS'), findsOneWidget);

    await tester.tap(find.text('VIEW POKÉMON DETAILS'));
    await tester.pumpAndSettle();

    expect(selectedResult, equals(candidate));
  });

  testWidgets('RandomRollOverlay rolls a team of six distinct Pokémon', (
    tester,
  ) async {
    Pokemon makePokemon(int id, String name) => Pokemon(
      id: id,
      name: name,
      form: '',
      type1: 'normal',
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
      nationalDexNumber: id,
      generation: 1,
      evolutionStage: 0,
      isChampions: false,
      isLegendsZA: false,
    );

    final pool = <Pokemon>[
      makePokemon(1, 'Bulbasaur'),
      makePokemon(2, 'Ivysaur'),
      makePokemon(3, 'Venusaur'),
      makePokemon(4, 'Charmander'),
      makePokemon(5, 'Charmeleon'),
      makePokemon(6, 'Charizard'),
      makePokemon(7, 'Squirtle'),
      makePokemon(8, 'Wartortle'),
    ];

    Pokemon? selectedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                RandomRollOverlay.show(
                  context,
                  candidatePool: pool,
                  rollCount: 6,
                  onViewDetails: (pokemon) {
                    selectedResult = pokemon;
                  },
                );
              },
              child: const Text('Roll'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Roll'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('TEAM ACQUIRED!'), findsOneWidget);
    // A team is tapped card by card, so the single-pick button is gone.
    expect(find.text('VIEW POKÉMON DETAILS'), findsNothing);
    expect(find.text('ROLL AGAIN'), findsOneWidget);

    // Six of the eight are shown, and they are all different.
    final shown = pool
        .where((p) => tester.widgetList(find.text(p.name)).isNotEmpty)
        .toList();
    expect(shown, hasLength(6));
    expect(shown.map((p) => p.name).toSet(), hasLength(6));

    await tester.tap(find.text(shown.first.name));
    await tester.pumpAndSettle();

    expect(selectedResult, isNotNull);
    expect(pool, contains(selectedResult));
  });
}

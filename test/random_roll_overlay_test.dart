import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/widgets/random_roll_overlay.dart';

void main() {
  testWidgets('RandomRollOverlay renders and completes roll sequence', (tester) async {
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
}

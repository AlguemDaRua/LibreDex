import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/data/species_data.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';

void main() {
  group('PokedexScreen', () {
    testWidgets('renders the app bar title with an empty database', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // Override the stream so the test never opens a real database.
          overrides: [
            pokedexProvider.overrideWith((ref) => Stream.value(<Pokemon>[])),
          ],
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      expect(find.text('LibreDex'), findsOneWidget);
    });
  });

  group('FormFacts', () {
    const snorlax = FormFacts(heightM: 2.1, weightKg: 460.0, baseExp: 189);
    const gastly = FormFacts(heightM: 1.3, weightKg: 0.1, baseExp: 62);

    test('formats weight in metric and imperial', () {
      expect(snorlax.weightLabel, '460.0 kg (1014.1 lbs)');
    });

    test('derives Low Kick base power from weight', () {
      // >= 200 kg is the heaviest bracket, <= 9.9 kg is the lightest.
      expect(snorlax.lowKickPower, 120);
      expect(gastly.lowKickPower, 20);
      expect(const FormFacts(heightM: 1, weightKg: 50, baseExp: 1).lowKickPower, 80);
      expect(const FormFacts(heightM: 1, weightKg: 49.9, baseExp: 1).lowKickPower, 60);
    });

    test('derives Heavy Slam power from the weight ratio', () {
      expect(snorlax.heavySlamPower(90), 120); // 5.1x the target's weight
      expect(snorlax.heavySlamPower(115), 100); // exactly 4x
      expect(snorlax.heavySlamPower(230), 60); // exactly 2x
      expect(snorlax.heavySlamPower(300), 40); // under 2x is the floor
      expect(snorlax.heavySlamPower(0), 0); // guards divide-by-zero
    });
  });

  group('GenderRatio', () {
    test('labels a genderless species', () {
      const ratio = GenderRatio(genderless: true, malePercent: 0, femalePercent: 0);
      expect(ratio.label, 'Genderless');
    });

    test('keeps half percentages but trims whole ones', () {
      const starter = GenderRatio(genderless: false, malePercent: 87.5, femalePercent: 12.5);
      expect(starter.label, '87.5% Male / 12.5% Female');

      const even = GenderRatio(genderless: false, malePercent: 50, femalePercent: 50);
      expect(even.label, '50% Male / 50% Female');
    });
  });

  group('SpriteQuality', () {
    test('rewrites HOME urls to pixel sprites for the small tier', () {
      const home = 'https://raw.githubusercontent.com/PokeAPI/sprites/master'
          '/sprites/pokemon/other/home/25.png';
      const homeShiny = 'https://raw.githubusercontent.com/PokeAPI/sprites/master'
          '/sprites/pokemon/other/home/shiny/25.png';

      expect(
        DeepSyncController.resolveUrl(home, SpriteQuality.small),
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
      );
      expect(
        DeepSyncController.resolveUrl(homeShiny, SpriteQuality.small),
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/25.png',
      );
      // Standard quality keeps the original high-resolution URL.
      expect(DeepSyncController.resolveUrl(home, SpriteQuality.standard), home);
    });
  });
}

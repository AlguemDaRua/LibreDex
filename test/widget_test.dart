import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/data/species_data.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
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

    test('formats weight in metric and imperial', () {
      expect(snorlax.weightLabel, '460.0 kg (1014.1 lbs)');
    });
  });

  group('CombatUtils weight gimmick tiers', () {
    // The tier logic moved from FormFacts into the damage calculator, where
    // weight gimmicks are resolved against both combatants.
    test('Low Kick / Grass Knot brackets', () {
      expect(CombatUtils.lowKickPowerFor(460.0), 120); // Snorlax
      expect(CombatUtils.lowKickPowerFor(200.0), 120);
      expect(CombatUtils.lowKickPowerFor(100.0), 100);
      expect(CombatUtils.lowKickPowerFor(50), 80);
      expect(CombatUtils.lowKickPowerFor(49.9), 60);
      expect(CombatUtils.lowKickPowerFor(10), 40);
      expect(CombatUtils.lowKickPowerFor(0.1), 20); // Gastly
    });

    test('Heavy Slam / Heat Crash weight ratios', () {
      expect(CombatUtils.heavySlamPowerFor(460.0, 90), 120); // 5.1x
      expect(CombatUtils.heavySlamPowerFor(460.0, 115), 100); // exactly 4x
      expect(CombatUtils.heavySlamPowerFor(460.0, 230), 60); // exactly 2x
      expect(CombatUtils.heavySlamPowerFor(460.0, 300), 40); // under 2x floor
      expect(CombatUtils.heavySlamPowerFor(460.0, 0), 0); // divide-by-zero guard
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

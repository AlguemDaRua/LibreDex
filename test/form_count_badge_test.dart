import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/widgets/content_badge.dart';
import 'package:libredex/features/pokedex/widgets/pokemon_grid_card.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Pokemon makePokemon(int id, String name, {String form = 'normal'}) =>
      Pokemon(
        id: id,
        name: name,
        form: form,
        type1: 'fire',
        type2: null,
        baseHp: 78,
        baseAtk: 84,
        baseDef: 78,
        baseSpAtk: 109,
        baseSpDef: 85,
        baseSpd: 100,
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

  group('ContentBadge.forms', () {
    testWidgets('labels the count of forms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ContentBadge.forms(count: 4)),
        ),
      );

      expect(find.text('4 FORMS'), findsOneWidget);
    });

    testWidgets('carries a tooltip explaining the count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBadge.forms(count: 3, tooltip: '3 forms - tap'),
          ),
        ),
      );

      expect(find.text('3 FORMS'), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('PokemonGridCard form badge', () {
    Future<void> pumpCard(WidgetTester tester, List<Pokemon> group) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: PokemonGridCard(
                  group: group,
                  isDark: false,
                  globalShinyMode: false,
                  showShinyOnly: false,
                  regulation: null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows a badge when the species has several forms', (
      tester,
    ) async {
      final group = [
        makePokemon(6, 'Charizard'),
        makePokemon(10006, 'Charizard', form: 'Mega X'),
        makePokemon(10007, 'Charizard', form: 'Mega Y'),
        makePokemon(10008, 'Charizard', form: 'Gmax'),
      ];

      await pumpCard(tester, group);

      expect(find.text('4 FORMS'), findsOneWidget);
    });

    testWidgets('shows no badge for a single-form species', (tester) async {
      await pumpCard(tester, [makePokemon(6, 'Charizard')]);

      expect(find.text('1 FORMS'), findsNothing);
      expect(find.byType(ContentBadge), findsNothing);
    });
  });
}

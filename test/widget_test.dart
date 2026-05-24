import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/main.dart';

void main() {
  testWidgets('Smoke test for LibreDexBaseSetup', (WidgetTester tester) async {
    // Build our app and trigger a frame, overriding pokedexProvider with static stream
    // to bypass database instantiation and query close timer leaks in test environment.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokedexProvider.overrideWith((ref) => Stream.value(<Pokemon>[])),
        ],
        child: const LibreDexApp(),
      ),
    );

    // Verify that our base title text is found in the AppBar.
    expect(find.text('LibreDex'), findsOneWidget);
  });
}

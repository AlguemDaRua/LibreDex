import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';
import 'package:libredex/features/movedex/views/movedex_screen.dart';
import 'package:libredex/features/abilitydex/views/abilitydex_screen.dart';
import 'package:libredex/features/naturedex/views/naturedex_screen.dart';
import 'package:libredex/features/typechart/views/typechart_screen.dart';
import 'package:libredex/features/calculator/views/damage_calculator_screen.dart';
import 'package:libredex/features/settings/views/settings_screen.dart';

/// Unified home wrapper screen that dynamically displays sub-screens based on the active index
/// and handles pop signals cleanly to avoid accidental app termination.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentMenuIndexProvider);

    Widget activeBody;
    switch (currentIndex) {
      case 0:
        activeBody = const PokedexScreen();
        break;
      case 1:
        activeBody = const MovedexScreen();
        break;
      case 2:
        activeBody = const AbilitydexScreen();
        break;
      case 3:
        activeBody = const NaturedexScreen();
        break;
      case 4:
        activeBody = const TypeChartScreen();
        break;
      case 5:
        activeBody = const DamageCalculatorScreen();
        break;
      case 6:
        activeBody = const SettingsScreen();
        break;
      default:
        activeBody = const PokedexScreen();
    }

    // Intercept back actions. If we are on any sub-page, pressing "Back" returns us to Pokédex (0).
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex > 0) {
          ref.read(currentMenuIndexProvider.notifier).setIndex(0);
        }
      },
      child: activeBody,
    );
  }
}

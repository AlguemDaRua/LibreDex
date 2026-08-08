import 'package:flutter/material.dart';

/// Single source of truth for every top-level destination.
/// No more magic 0..9 ints scattered across 8 files.
enum AppSection {
  pokedex(0, 'Pokédex', Icons.catching_pokemon, Icons.catching_pokemon_outlined),
  teamBuilder(1, 'Teams', Icons.groups_rounded, Icons.groups_outlined),
  statCompare(2, 'Compare', Icons.compare_arrows_rounded, Icons.compare_arrows_outlined),
  movedex(3, 'Moves', Icons.flash_on_rounded, Icons.flash_on_outlined),
  abilitydex(4, 'Abilities', Icons.auto_awesome_rounded, Icons.auto_awesome_outlined),
  itemdex(5, 'Items', Icons.inventory_2_rounded, Icons.inventory_2_outlined),
  naturedex(6, 'Natures', Icons.analytics_rounded, Icons.analytics_outlined),
  typeChart(7, 'Type Chart', Icons.grid_on_rounded, Icons.grid_on_outlined),
  calculator(8, 'Calc', Icons.calculate_rounded, Icons.calculate_outlined),
  settings(9, 'Settings', Icons.settings_rounded, Icons.settings_outlined);

  const AppSection(this.index, this.label, this.selectedIcon, this.unselectedIcon);

  final int index;
  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;

  static AppSection fromIndex(int i) =>
      AppSection.values.firstWhere((s) => s.index == i, orElse: () => AppSection.pokedex);
}

/// What appears in the adaptive primary nav.
/// On phones (<600dp) this becomes a NavigationBar.
/// On tablets (≥600dp) this becomes a NavigationRail.
/// Only 5 slots to stay Material 3 compliant — everything else lives in the "More" sheet.
class PrimaryNav {
  PrimaryNav._();

  /// The 4 most-used tools + a single overflow entry.
  static const List<AppSection> bottomBarSections = [
    AppSection.pokedex,
    AppSection.teamBuilder,
    AppSection.movedex,
    AppSection.calculator,
  ];

  /// True if this section is reachable directly from the bar/rail.
  static bool isPrimary(AppSection s) => bottomBarSections.contains(s);

  /// BottomBar index for a given section, or 4 == "More/Hub".
  static int barIndexFor(AppSection section) {
    final idx = bottomBarSections.indexOf(section);
    return idx == -1 ? 4 : idx;
  }

  /// AppSection targeted when the user taps a bar/rail slot.
  /// Returns null for the overflow slot — caller should open the Hub sheet.
  static AppSection? sectionForBarIndex(int barIndex) {
    if (barIndex < 0 || barIndex >= bottomBarSections.length) return null;
    return bottomBarSections[barIndex];
  }
}

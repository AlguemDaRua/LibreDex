import 'package:flutter/material.dart';

/// Single source of truth for every top-level destination.
enum AppSection {
  pokedex('Pokédex', 'Pokédex', Icons.catching_pokemon, Icons.catching_pokemon_outlined),
  teamBuilder('Teams', 'Team Builder', Icons.groups_rounded, Icons.groups_outlined),
  statCompare('Compare', 'Stat Compare', Icons.compare_arrows_rounded, Icons.compare_arrows_outlined),
  movedex('Moves', 'MoveDex', Icons.flash_on_rounded, Icons.flash_on_outlined),
  abilitydex('Abilities', 'AbilityDex', Icons.auto_awesome_rounded, Icons.auto_awesome_outlined),
  itemdex('Items', 'ItemDex', Icons.inventory_2_rounded, Icons.inventory_2_outlined),
  naturedex('Natures', 'NatureDex', Icons.analytics_rounded, Icons.analytics_outlined),
  typeChart('Type Chart', 'Type Chart', Icons.grid_on_rounded, Icons.grid_on_outlined),
  calculator('Calc', 'Damage Calc', Icons.calculate_rounded, Icons.calculate_outlined),
  settings('Settings', 'Settings', Icons.settings_rounded, Icons.settings_outlined);

  const AppSection(
    this.label,
    this.hubTitle,
    this.selectedIcon,
    this.unselectedIcon,
  );

  /// Short label used by the bottom bar and navigation rail.
  final String label;

  /// Full destination name used by the feature hub.
  final String hubTitle;

  final IconData selectedIcon;
  final IconData unselectedIcon;

  static AppSection fromIndex(int i) => AppSection.values.firstWhere(
        (section) => section.index == i,
        orElse: () => AppSection.pokedex,
      );
}

/// What appears in the adaptive primary nav.
/// Only 5 slots are shown; the final slot opens the Feature Hub.
class PrimaryNav {
  PrimaryNav._();

  static const List<AppSection> bottomBarSections = [
    AppSection.pokedex,
    AppSection.teamBuilder,
    AppSection.movedex,
    AppSection.calculator,
  ];

  static const String overflowLabel = 'More';
  static const IconData overflowSelectedIcon = Icons.apps_rounded;
  static const IconData overflowUnselectedIcon = Icons.apps_outlined;

  /// BottomBar index for a section, or the final slot for the Feature Hub.
  static int barIndexFor(AppSection section) {
    final index = bottomBarSections.indexOf(section);
    return index == -1 ? bottomBarSections.length : index;
  }

  /// AppSection targeted when a primary navigation destination is tapped.
  /// Returns null for the overflow destination.
  static AppSection? sectionForBarIndex(int barIndex) {
    if (barIndex < 0 || barIndex >= bottomBarSections.length) return null;
    return bottomBarSections[barIndex];
  }
}

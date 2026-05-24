import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/theme_provider.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';
import 'package:libredex/features/movedex/views/movedex_screen.dart';
import 'package:libredex/features/abilitydex/views/abilitydex_screen.dart';
import 'package:libredex/features/naturedex/views/naturedex_screen.dart';
import 'package:libredex/features/typechart/views/typechart_screen.dart';
import 'package:libredex/features/settings/views/settings_screen.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.black : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : AppTheme.pokemonRed,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 32,
                        color: isDark ? AppTheme.pokemonRed : Colors.white,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'LibreDex',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '100% Offline-First Dex',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.grid_view_rounded,
                    label: 'Pokédex',
                    route: 'pokedex',
                    destination: const PokedexScreen(),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.flash_on_rounded,
                    label: 'MoveDex',
                    route: 'moves',
                    destination: const MovedexScreen(),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.auto_awesome_rounded,
                    label: 'AbilityDex',
                    route: 'abilities',
                    destination: const AbilitydexScreen(),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.analytics_rounded,
                    label: 'NatureDex',
                    route: 'natures',
                    destination: const NaturedexScreen(),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.grid_on_rounded,
                    label: 'Type Chart',
                    route: 'type_chart',
                    destination: const TypeChartScreen(),
                  ),
                  Divider(height: 32, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: 'settings',
                    destination: const SettingsScreen(),
                  ),
                ],
              ),
            ),

            // Premium 3-Button Theme Mode Selector at the bottom of the drawer
            Divider(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THEME MODE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeButton(ref, ThemeMode.system, Icons.settings_brightness_rounded, 'System', isDark),
                      _buildThemeButton(ref, ThemeMode.light, Icons.light_mode_rounded, 'Light', isDark),
                      _buildThemeButton(ref, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark', isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    WidgetRef ref,
    ThemeMode mode,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final currentMode = ref.watch(themeModeProvider);
    final isSelected = currentMode == mode;

    final selectedBg = isDark ? AppTheme.pokemonRed.withValues(alpha: 0.2) : AppTheme.pokemonRed.withValues(alpha: 0.1);
    final selectedBorder = AppTheme.pokemonRed;
    final unselectedBorder = isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? selectedBorder : unselectedBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppTheme.pokemonRed
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? Colors.white : AppTheme.pokemonRed)
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required Widget destination,
  }) {
    final isSelected = currentRoute == route;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppTheme.pokemonRed.withValues(alpha: 0.15) : AppTheme.pokemonRed.withValues(alpha: 0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? (isDark ? AppTheme.pokemonRed : AppTheme.pokemonRed.withValues(alpha: 0.5))
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppTheme.pokemonRed
              : (isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppTheme.pokemonRed)
                : (isDark ? Colors.grey[300] : Colors.grey[800]),
            fontSize: 14,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isSelected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/theme_provider.dart';
import 'package:libredex/core/theme/theme_switcher.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';

/// Workspace & Quick Tools Drawer.
/// Serves as a non-redundant productivity hub with active team slots,
/// favorite counts, quick settings, and direct tool shortcuts.
class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teamSlots = ref.watch(teamBuilderProvider);
    final filledSlotsCount = teamSlots.where((id) => id != null).length;
    final favoritesCount = ref.watch(favoritePokemonProvider).length;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Drawer Header with App Title & Subtitle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 56, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : AppTheme.pokemonRed,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.pokemonRed.withValues(alpha: 0.2) : Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.catching_pokemon,
                          size: 26,
                          color: isDark ? AppTheme.pokemonRed : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LibreDex',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Trainer Workspace & Tools',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  // ACTIVE TEAM WORKSPACE CARD
                  _buildSectionHeader('ACTIVE TEAM WORKSPACE'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(currentMenuIndexProvider.notifier).setIndex(1); // Team Builder
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181818) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.groups_rounded, size: 18, color: AppTheme.pokemonRed),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Battle Team',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              Text(
                                '$filledSlotsCount / 6 filled',
                                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final pId = teamSlots[index];
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: pId != null
                                      ? AppTheme.pokemonRed.withValues(alpha: 0.15)
                                      : (isDark ? const Color(0xFF222222) : const Color(0xFFE0E0E0)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: pId != null ? AppTheme.pokemonRed : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: pId != null
                                      ? const Icon(Icons.catching_pokemon, size: 18, color: AppTheme.pokemonRed)
                                      : Text(
                                          '${index + 1}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // QUICK STATS & UTILITIES
                  _buildSectionHeader('QUICK SHORTCUTS'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickCard(
                          context: context,
                          icon: Icons.star_rounded,
                          color: Colors.amber,
                          title: 'Favorites',
                          subtitle: '$favoritesCount saved',
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(currentMenuIndexProvider.notifier).setIndex(0); // Pokédex
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickCard(
                          context: context,
                          icon: Icons.compare_arrows_rounded,
                          color: const Color(0xFF8B5CF6),
                          title: 'Stat Compare',
                          subtitle: 'Side by side',
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(currentMenuIndexProvider.notifier).setIndex(2); // Stat Compare
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // REFERENCE TOOLS LIST
                  _buildSectionHeader('REFERENCE & TOOLS'),
                  const SizedBox(height: 6),

                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.catching_pokemon,
                    label: 'Pokédex',
                    route: 'pokedex',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.flash_on_rounded,
                    label: 'MoveDex',
                    route: 'moves',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.auto_awesome_rounded,
                    label: 'AbilityDex',
                    route: 'abilities',
                    index: 4,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.inventory_2_rounded,
                    label: 'ItemDex',
                    route: 'items',
                    index: 5,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.analytics_rounded,
                    label: 'NatureDex',
                    route: 'natures',
                    index: 6,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.grid_on_rounded,
                    label: 'Type Chart',
                    route: 'type_chart',
                    index: 7,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.calculate_rounded,
                    label: 'Damage Calculator',
                    route: 'calculator',
                    index: 8,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: 'settings',
                    index: 9,
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'APPEARANCE MODE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ThemeChoiceButton(
                        mode: ThemeMode.system,
                        icon: Icons.settings_brightness_rounded,
                        label: 'System',
                      ),
                      _ThemeChoiceButton(
                        mode: ThemeMode.light,
                        icon: Icons.light_mode_rounded,
                        label: 'Light',
                      ),
                      _ThemeChoiceButton(
                        mode: ThemeMode.dark,
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark',
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181818) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String route,
    required int index,
  }) {
    final isSelected = currentRoute == route;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppTheme.pokemonRed.withValues(alpha: 0.15) : AppTheme.pokemonRed.withValues(alpha: 0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected
              ? AppTheme.pokemonRed
              : (isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppTheme.pokemonRed
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!isSelected) {
            ref.read(currentMenuIndexProvider.notifier).setIndex(index);
          }
        },
      ),
    );
  }
}

class _ThemeChoiceButton extends ConsumerWidget {
  final ThemeMode mode;
  final IconData icon;
  final String label;

  const _ThemeChoiceButton({
    required this.mode,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final isSelected = currentTheme == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null ? box.localToGlobal(box.size.center(Offset.zero)) : null;
        await switchThemeWithWavy(context: context, ref: ref, mode: mode, origin: origin);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.pokemonRed
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

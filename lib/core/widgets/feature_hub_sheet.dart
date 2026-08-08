import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/navigation/app_sections.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/theme_provider.dart';
import 'package:libredex/core/theme/theme_switcher.dart';

/// Modal bottom sheet displaying all 10 tools & settings in an organized hub.
class FeatureHubSheet extends ConsumerWidget {
  const FeatureHubSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeatureHubSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101010) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pokemonRed.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apps_rounded,
                      color: AppTheme.pokemonRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LibreDex Hub',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'All Pokémon tools in one place',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Theme Quick Switcher — now plays the wavy reveal (origin = button center)
                  IconButton(
                    icon: Icon(
                      currentTheme == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : currentTheme == ThemeMode.light
                              ? Icons.light_mode_rounded
                              : Icons.brightness_auto_rounded,
                      size: 20,
                      color: AppTheme.pokemonRed,
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () async {
                      await cycleThemeWithWavy(context, ref);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DATABASES SECTION
                    _buildSectionHeader('REFERENCE DATABASES'),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      children: [
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'Pokédex',
                          subtitle: '1025+ Pokémon',
                          icon: Icons.catching_pokemon,
                          color: const Color(0xFFE3350D),
                          index: 0,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'MoveDex',
                          subtitle: '900+ Moves & BP',
                          icon: Icons.flash_on_rounded,
                          color: const Color(0xFFF7D02C),
                          index: 3,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'AbilityDex',
                          subtitle: 'Passive abilities',
                          icon: Icons.auto_awesome_rounded,
                          color: const Color(0xFFA78BFA),
                          index: 4,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'ItemDex',
                          subtitle: 'Held items & balls',
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF34D399),
                          index: 5,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'NatureDex',
                          subtitle: 'Stat multipliers',
                          icon: Icons.analytics_rounded,
                          color: const Color(0xFFF59E0B),
                          index: 6,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'Type Chart',
                          subtitle: 'Type match-ups',
                          icon: Icons.grid_on_rounded,
                          color: const Color(0xFF60A5FA),
                          index: 7,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // COMPETITIVE TOOLS SECTION
                    _buildSectionHeader('COMPETITIVE & BATTLE TOOLS'),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      children: [
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'Team Builder',
                          subtitle: 'Build & export teams',
                          icon: Icons.groups_rounded,
                          color: const Color(0xFFEC4899),
                          index: 1,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'Damage Calc',
                          subtitle: 'Showdown battle engine',
                          icon: Icons.calculate_rounded,
                          color: const Color(0xFF10B981),
                          index: 8,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'Stat Compare',
                          subtitle: 'Side-by-side stats',
                          icon: Icons.compare_arrows_rounded,
                          color: const Color(0xFF8B5CF6),
                          index: 2,
                        ),
                        _buildHubTile(
                          context: context,
                          ref: ref,
                          title: 'Settings',
                          subtitle: 'Artwork & theme',
                          icon: Icons.settings_rounded,
                          color: const Color(0xFF6B7280),
                          index: 9,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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

  Widget _buildHubTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(currentMenuIndexProvider);
    final isSelected = currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (currentIndex != index) {
            ref.read(currentMenuIndexProvider.notifier).setIndex(index);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF181818) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

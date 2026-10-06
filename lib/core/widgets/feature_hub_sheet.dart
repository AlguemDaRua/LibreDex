import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/data/champions_regulation.dart';
import 'package:libredex/core/navigation/app_sections.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/responsive.dart';
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
    final regulation = ref.watch(championsRegulationProvider).asData?.value;
    final isTablet = Responsive.isTablet(context);

    // Tablet: center the sheet and cap width so it never feels like a stretched phone sheet.
    Widget sheet = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
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
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Theme Quick Switcher — reveals outward from exact button touch origin
                    Builder(
                      builder: (btnContext) {
                        Offset? lastTapPos;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) {
                            lastTapPos = details.globalPosition;
                          },
                          child: IconButton(
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
                              final box =
                                  btnContext.findRenderObject() as RenderBox?;
                              final buttonCenter = box != null && box.hasSize
                                  ? box.localToGlobal(
                                      box.size.center(Offset.zero),
                                    )
                                  : null;
                              await cycleThemeWithWavy(
                                btnContext,
                                ref,
                                origin: lastTapPos ?? buttonCenter,
                              );
                            },
                          ),
                        );
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CHAMPIONS REGULATION SECTION
                      _buildSectionHeader('POKÉMON CHAMPIONS · REGULATION M-C'),
                      const SizedBox(height: 10),
                      _buildRegulationOverviewCard(regulation, isDark),
                      const SizedBox(height: 12),
                      // Responsive columns: 3 on tablet, 2 on phone — every rotation perfect
                      GridView.count(
                        crossAxisCount: Responsive.hubColumns(context),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: Responsive.isTablet(context)
                            ? 3.6
                            : 3.2,
                        children: [
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.pokedex,
                            color: const Color(0xFFE3350D),
                          ),
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.movedex,
                            color: const Color(0xFFF7D02C),
                          ),
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.abilitydex,
                            color: const Color(0xFFA78BFA),
                          ),
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.itemdex,
                            color: const Color(0xFF34D399),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildSectionHeader('REFERENCE'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: Responsive.hubColumns(context),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: Responsive.isTablet(context)
                            ? 3.6
                            : 3.2,
                        children: [
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.naturedex,
                            color: const Color(0xFFF59E0B),
                          ),
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.typeChart,
                            color: const Color(0xFF60A5FA),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildSectionHeader('TEAM & BATTLE'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: Responsive.hubColumns(context),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: Responsive.isTablet(context)
                            ? 3.6
                            : 3.2,
                        children: [
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.teamBuilder,
                            color: const Color(0xFFEC4899),
                          ),
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.calculator,
                            color: const Color(0xFF10B981),
                          ),
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.statCompare,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildSectionHeader('APP'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: Responsive.hubColumns(context),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: Responsive.isTablet(context)
                            ? 3.6
                            : 3.2,
                        children: [
                          _buildHubTile(
                            context: context,
                            ref: ref,
                            section: AppSection.settings,
                            color: const Color(0xFF6B7280),
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

    if (isTablet) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: sheet,
        ),
      );
    }
    return sheet;
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

  Widget _buildRegulationOverviewCard(
    ChampionsRegulationCatalog? regulation,
    bool isDark,
  ) {
    const accent = Colors.deepPurpleAccent;
    final period = regulation?.officialAnnouncementPeriod ?? '';
    final gameVersion = regulation?.gameVersion ?? '';
    final dataDate = regulation?.asOf ?? '';
    final rosterCount = regulation?.rosterEntryCount ?? 0;
    final newPokemonCount = regulation?.officialNewPokemonCount ?? 0;
    final newMegaCount = regulation?.newMegaFormIds.length ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171322) : const Color(0xFFF6F2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      regulation?.regulationName ??
                          'Pokémon Champions Regulation M-C',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF211A31),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (gameVersion.isNotEmpty || dataDate.isNotEmpty)
                      Text(
                        [
                          if (gameVersion.isNotEmpty) 'Game v$gameVersion',
                          if (dataDate.isNotEmpty) 'Data snapshot $dataDate',
                        ].join(' · '),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'M-C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Eligibility ≠ origin · M-C moves, abilities & items',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Tooltip(
                message:
                    'Browse regulation eligibility and M-C-specific data. Availability is separate from game origin: older content can be eligible without being new to Champions.',
                triggerMode: TooltipTriggerMode.tap,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  height: 1.35,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          if (period.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: accent,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Official period: $period',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (regulation?.patchSummary.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.system_update_rounded,
                  color: accent,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    regulation!.patchSummary,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey[300]
                          : const Color(0xFF4B4655),
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (rosterCount > 0 || newPokemonCount > 0 || newMegaCount > 0) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (rosterCount > 0)
                  _buildRegulationFactPill(
                    icon: Icons.catching_pokemon_rounded,
                    label: '$rosterCount roster entries',
                    isDark: isDark,
                  ),
                if (newPokemonCount > 0)
                  _buildRegulationFactPill(
                    icon: Icons.add_circle_outline_rounded,
                    label: '$newPokemonCount newly available Pokémon',
                    isDark: isDark,
                  ),
                if (newMegaCount > 0)
                  _buildRegulationFactPill(
                    icon: Icons.auto_awesome_rounded,
                    label: '$newMegaCount new Mega forms',
                    isDark: isDark,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegulationFactPill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.deepPurpleAccent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF3D315A),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubTile({
    required BuildContext context,
    required WidgetRef ref,
    required AppSection section,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(currentMenuIndexProvider);
    final isSelected = currentIndex == section.index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (currentIndex != section.index) {
            ref.read(currentMenuIndexProvider.notifier).setIndex(section.index);
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
                  : (isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFE5E7EB)),
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
                child: Icon(section.selectedIcon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.hubTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

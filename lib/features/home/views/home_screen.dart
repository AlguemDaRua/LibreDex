import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/navigation/navigation_style_provider.dart';
import 'package:libredex/core/navigation/section_back_stack.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/artwork_download_dialog.dart';
import 'package:libredex/core/widgets/feature_hub_sheet.dart';
import 'package:libredex/features/abilitydex/views/abilitydex_screen.dart';
import 'package:libredex/features/calculator/views/damage_calculator_screen.dart';
import 'package:libredex/features/itemdex/views/itemdex_screen.dart';
import 'package:libredex/features/movedex/views/movedex_screen.dart';
import 'package:libredex/features/naturedex/views/naturedex_screen.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';
import 'package:libredex/features/settings/views/settings_screen.dart';
import 'package:libredex/features/stat_comparison/views/stat_comparison_screen.dart';
import 'package:libredex/features/team_builder/views/team_builder_screen.dart';
import 'package:libredex/features/typechart/views/typechart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hosts the main sections of the app and keeps the artwork-download banner
/// pinned above whichever section is active.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _hasPromptedThisSession = false;

  final Set<int> _visitedIndices = {0};
  final SectionBackStack _backStack = SectionBackStack();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptForArtwork());
  }

  Future<void> _maybePromptForArtwork() async {
    if (_hasPromptedThisSession) return;
    _hasPromptedThisSession = true;

    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(kArtworkDownloadPromptDisabledKey) ?? false) {
      return;
    }
    if (!mounted) return;

    await showFirstLaunchArtworkDownloadDialog(context);
  }

  Widget _buildSection(int index) {
    switch (index) {
      case 0:
        return const PokedexScreen();
      case 1:
        return const TeamBuilderScreen();
      case 2:
        return const StatComparisonScreen();
      case 3:
        return const MovedexScreen();
      case 4:
        return const AbilitydexScreen();
      case 5:
        return const ItemDexScreen();
      case 6:
        return const NaturedexScreen();
      case 7:
        return const TypeChartScreen();
      case 8:
        return const DamageCalculatorScreen();
      case 9:
        return const SettingsScreen();
      default:
        return const PokedexScreen();
    }
  }

  int _getBottomNavIndex(int menuIndex) {
    switch (menuIndex) {
      case 0:
        return 0; // Pokédex
      case 1:
        return 1; // Teams
      case 3:
        return 2; // Moves
      case 8:
        return 3; // Calc
      default:
        return 4; // Hub / More
    }
  }

  void _onBottomNavTapped(int navIndex) {
    switch (navIndex) {
      case 0:
        ref.read(currentMenuIndexProvider.notifier).setIndex(0);
        break;
      case 1:
        ref.read(currentMenuIndexProvider.notifier).setIndex(1);
        break;
      case 2:
        ref.read(currentMenuIndexProvider.notifier).setIndex(3);
        break;
      case 3:
        ref.read(currentMenuIndexProvider.notifier).setIndex(8);
        break;
      case 4:
        FeatureHubSheet.show(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentMenuIndexProvider);
    final navStyle = ref.watch(navigationStyleProvider);
    _visitedIndices.add(currentIndex);
    _backStack.record(currentIndex);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomNavIndex = _getBottomNavIndex(currentIndex);
    final showBottomNav = navStyle == 'both' || navStyle == 'bottomBar';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final int? target = _backStack.goBack();
        if (target == null) {
          SystemNavigator.pop();
        } else {
          ref.read(currentMenuIndexProvider.notifier).setIndex(target);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const _DownloadBanner(),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: List.generate(
                  10,
                  (index) => _visitedIndices.contains(index)
                      ? _buildSection(index)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: showBottomNav
            ? NavigationBar(
                selectedIndex: bottomNavIndex,
                onDestinationSelected: _onBottomNavTapped,
                backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                indicatorColor: AppTheme.pokemonRed.withValues(alpha: 0.18),
                elevation: 8,
                height: 64,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.catching_pokemon_outlined),
                    selectedIcon: Icon(Icons.catching_pokemon, color: AppTheme.pokemonRed),
                    label: 'Pokédex',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.groups_outlined),
                    selectedIcon: Icon(Icons.groups_rounded, color: AppTheme.pokemonRed),
                    label: 'Teams',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.flash_on_outlined),
                    selectedIcon: Icon(Icons.flash_on_rounded, color: AppTheme.pokemonRed),
                    label: 'Moves',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calculate_outlined),
                    selectedIcon: Icon(Icons.calculate_rounded, color: AppTheme.pokemonRed),
                    label: 'Calc',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.apps_outlined),
                    selectedIcon: Icon(Icons.apps_rounded, color: AppTheme.pokemonRed),
                    label: 'Hub',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

/// Compact, always-visible progress strip shown while artwork downloads.
///
/// It sits above the active screen rather than covering it, so the app stays
/// fully usable while data is being fetched in the background.
class _DownloadBanner extends ConsumerWidget {
  const _DownloadBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(deepSyncControllerProvider);
    if (!sync.isVisible) return const SizedBox.shrink();

    final controller = ref.read(deepSyncControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFailed = sync.status == DownloadStatus.failed;

    return Material(
      color: isDark ? const Color(0xFF101010) : Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    hasFailed ? Icons.cloud_off_rounded : Icons.cloud_download_rounded,
                    size: 18,
                    color: hasFailed ? Colors.orangeAccent : AppTheme.pokemonRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasFailed
                          ? 'Artwork download paused'
                          : sync.status == DownloadStatus.paused
                              ? 'Download paused'
                              : 'Downloading artwork for offline use',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: hasFailed ? Colors.orangeAccent : AppTheme.pokemonRed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!hasFailed)
                    Text(
                      '${sync.completed}/${sync.total}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  if (sync.status == DownloadStatus.running)
                    _BannerAction(
                      icon: Icons.pause_rounded,
                      tooltip: 'Pause',
                      onPressed: controller.pause,
                    ),
                  if (sync.status == DownloadStatus.paused)
                    _BannerAction(
                      icon: Icons.play_arrow_rounded,
                      tooltip: 'Resume',
                      onPressed: controller.resume,
                    ),
                  _BannerAction(
                    icon: Icons.close_rounded,
                    tooltip: hasFailed ? 'Dismiss' : 'Cancel download',
                    onPressed: hasFailed ? controller.acknowledge : controller.cancel,
                  ),
                ],
              ),
              if (!hasFailed) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: sync.progress,
                    minHeight: 5,
                    backgroundColor: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.pokemonRed),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                hasFailed
                    ? (sync.errorMessage ?? 'Download interrupted.')
                    : '${(sync.progress * 100).toStringAsFixed(0)}% · ${sync.currentLabel}',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _BannerAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
    );
  }
}

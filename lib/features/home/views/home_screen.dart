import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/offline_download_dialog.dart';
import 'package:libredex/features/abilitydex/views/abilitydex_screen.dart';
import 'package:libredex/features/calculator/views/damage_calculator_screen.dart';
import 'package:libredex/features/movedex/views/movedex_screen.dart';
import 'package:libredex/features/naturedex/views/naturedex_screen.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';
import 'package:libredex/features/settings/views/settings_screen.dart';
import 'package:libredex/features/typechart/views/typechart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preference key marking that the first-run offline download prompt was shown.
const String kOfflinePromptShownKey = 'promptedOfflineDownload';

/// Hosts the main sections of the app and keeps the offline download banner
/// pinned above whichever section is active.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static bool _hasPromptedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptForDownload());
  }

  Future<void> _maybePromptForDownload() async {
    if (_hasPromptedThisSession) return;
    _hasPromptedThisSession = true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(kOfflinePromptShownKey) ?? false) return;
    if (!mounted) return;

    await prefs.setBool(kOfflinePromptShownKey, true);
    if (!mounted) return;
    await showOfflineDownloadDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentMenuIndexProvider);

    // Intercept back: from any sub-section, Back returns to the Pokédex first.
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(currentMenuIndexProvider.notifier).setIndex(0);
      },
      child: Column(
        children: [
          const _DownloadBanner(),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: const [
                PokedexScreen(),
                MovedexScreen(),
                AbilitydexScreen(),
                NaturedexScreen(),
                TypeChartScreen(),
                DamageCalculatorScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact, always-visible progress strip shown while sprites download.
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
                          ? 'Offline download paused'
                          : sync.status == DownloadStatus.paused
                              ? 'Download paused'
                              : 'Downloading sprites for offline use',
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

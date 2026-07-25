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
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflinePromptDialog extends ConsumerStatefulWidget {
  const OfflinePromptDialog({super.key});

  @override
  ConsumerState<OfflinePromptDialog> createState() => _OfflinePromptDialogState();
}

class _OfflinePromptDialogState extends ConsumerState<OfflinePromptDialog> {
  bool _doNotAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Download Offline Data?', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Would you like to download all Moves, Abilities, and Sprites for complete offline usage without internet? (Approx 150MB)',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _doNotAskAgain,
                activeColor: AppTheme.pokemonRed,
                onChanged: (val) {
                  setState(() => _doNotAskAgain = val ?? false);
                },
              ),
              const Expanded(
                child: Text('Do not ask again', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_doNotAskAgain) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('promptedOfflineDownload', true);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.pokemonRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            if (_doNotAskAgain) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('promptedOfflineDownload', true);
            }
            ref.read(deepSyncRepositoryProvider).startDeepSync();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/// Unified home wrapper screen that dynamically displays sub-screens based on the active index
/// and handles pop signals cleanly to avoid accidental app termination.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOfflinePrompt();
    });
  }

  Future<void> _checkOfflinePrompt() async {
    if (_hasPromptedThisSession) return;
    _hasPromptedThisSession = true;

    final prefs = await SharedPreferences.getInstance();
    final bool prompted = prefs.getBool('promptedOfflineDownload') ?? false;

    if (!prompted && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OfflinePromptDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentMenuIndexProvider);
    final deepSyncState = ref.watch(deepSyncProgressProvider);

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget bodyWithBanner = Column(
      children: [
        if (deepSyncState.progress > 0 && !deepSyncState.isComplete)
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 8, left: 16, right: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Background Sync',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.pokemonRed),
                    ),
                    Text(
                      '${(deepSyncState.progress * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: deepSyncState.progress,
                    backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.pokemonRed),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deepSyncState.message,
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        Expanded(child: activeBody),
      ],
    );

    // Intercept back actions. If we are on any sub-page, pressing "Back" returns us to Pokédex (0).
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex > 0) {
          ref.read(currentMenuIndexProvider.notifier).setIndex(0);
        }
      },
      child: bodyWithBanner,
    );
  }
}

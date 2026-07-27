import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/theme_provider.dart';
import 'package:libredex/core/widgets/ultra_wormhole_transition.dart';
import 'package:libredex/features/home/views/home_screen.dart';
import 'package:libredex/features/pokedex/repositories/sync_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LibreDexApp()));
}

class LibreDexApp extends ConsumerWidget {
  const LibreDexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'LibreDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) => UltraWormholeTransition(
        trigger: themeMode,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const StartupGate(),
    );
  }
}

/// Seeds the bundled database on first launch, then shows the app.
///
/// Seeding reads JSON from the app bundle only, so this never depends on a
/// network connection and cannot leave the user on an empty screen.
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  late Future<void> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = _seedIfNeeded();
  }

  Future<void> _seedIfNeeded() async {
    final repo = ref.read(syncRepositoryProvider);
    if (!await repo.isSeeded) await repo.seedBundledData();
  }

  void _retry() => setState(() => _bootstrap = _seedIfNeeded());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StartupScreen();
        }
        if (snapshot.hasError) {
          return _StartupScreen(error: '${snapshot.error}', onRetry: _retry);
        }
        return const HomeScreen();
      },
    );
  }
}

/// First-launch screen shown while the bundled database is unpacked.
class _StartupScreen extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const _StartupScreen({this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = error != null;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasError ? Icons.error_outline_rounded : Icons.catching_pokemon,
                size: 84,
                color: hasError ? Colors.orangeAccent : AppTheme.pokemonRed,
              ),
              const SizedBox(height: 28),
              Text(
                hasError ? 'Could not prepare the database' : 'LibreDex',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                hasError
                    ? error!
                    : 'Unpacking the offline Pokédex — every Pokémon, move and '
                        'ability is bundled, so no connection is needed.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (hasError)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.pokemonRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                )
              else
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

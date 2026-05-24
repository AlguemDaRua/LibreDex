import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/repositories/sync_repository.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';

class InitialSyncScreen extends ConsumerStatefulWidget {
  const InitialSyncScreen({super.key});

  @override
  ConsumerState<InitialSyncScreen> createState() => _InitialSyncScreenState();
}

class _InitialSyncScreenState extends ConsumerState<InitialSyncScreen> {
  bool _syncStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSync();
    });
  }

  Future<void> _startSync() async {
    if (_syncStarted) return;
    setState(() {
      _syncStarted = true;
    });

    try {
      await ref.read(syncRepositoryProvider).performFullInitialSync();
      if (mounted) {
        // Redirection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PokedexScreen()),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _syncStarted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(syncProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinning Pokéball Icon
              Icon(
                Icons.catching_pokemon,
                size: 90,
                color: AppTheme.pokemonRed,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'LibreDex Initializing',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Downloading Pokedex, sprites, abilities and moves for 100% offline usage. Please wait...',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xFF161616) : const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.pokemonRed),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Percent Label
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.pokemonRed,
                ),
              ),
              const SizedBox(height: 32),

              // Status Description mapping progress percentage
              Text(
                _getStatusMessage(progress),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(double progress) {
    if (progress <= 0.05) {
      return 'Fetching Generation 1 base indexes from PokeAPI...';
    } else if (progress <= 0.40) {
      return 'Downloading Kanto Pokémon details, base stats and official artwork...';
    } else if (progress <= 0.60) {
      return 'Extracting and downloading unique Pokémon abilities...';
    } else if (progress < 1.0) {
      return 'Downloading full MoveDex data (accuracy, power and category)...';
    } else {
      return 'Database fully synchronized! Directing to Pokédex...';
    }
  }
}

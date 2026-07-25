import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/repositories/sync_repository.dart';
import 'package:libredex/features/home/views/home_screen.dart';
import 'package:libredex/core/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: LibreDexApp(),
    ),
  );
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
      home: const StartupGate(),
    );
  }
}

class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<bool>(
      future: () async {
        final existing = await db.select(db.pokemonTable).get();
        if (existing.isEmpty) {
          await ref.read(syncRepositoryProvider).seedBundledData();
        }
        return true;
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed),
              ),
            ),
          );
        }

        return const HomeScreen();
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/views/pokedex_screen.dart';

void main() {
  // Wrap the app in a ProviderScope to initialize Riverpod
  runApp(
    const ProviderScope(
      child: LibreDexApp(),
    ),
  );
}

class LibreDexApp extends StatelessWidget {
  const LibreDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibreDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically adapts to system preferences
      home: const PokedexScreen(),
    );
  }
}

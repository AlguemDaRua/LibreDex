import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';

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
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibreDex Base Setup'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.catching_pokemon,
                  size: 100,
                  color: isDark ? AppTheme.pokemonRed : AppTheme.pokemonRed,
                ),
                const SizedBox(height: 24),
                Text(
                  'LibreDex Core Setup Ready!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Phase 2 - Core Engine successfully compiled.\n'
                  'AMOLED Dark Mode & database setup fully loaded.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildFeatureStatus(
                  context: context,
                  icon: Icons.palette,
                  title: 'AMOLED Theme Engine',
                  description: 'Custom Material 3 theme colors loaded.',
                ),
                _buildFeatureStatus(
                  context: context,
                  icon: Icons.calculate,
                  title: 'Mathematical Stat Calculator',
                  description: 'Calculations for HP and Nature stats finalized.',
                ),
                _buildFeatureStatus(
                  context: context,
                  icon: Icons.storage,
                  title: 'Drift Offline Database',
                  description: 'SQL many-to-many relationship structures compiled.',
                ),
                _buildFeatureStatus(
                  context: context,
                  icon: Icons.http,
                  title: 'Dio API Service Engine',
                  description: 'Unified connections with robust network timeouts.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureStatus({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.pokemonBlue.withValues(alpha: 0.2),
          child: Icon(icon, color: AppTheme.pokemonBlue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      ),
    );
  }
}

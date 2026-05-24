import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/splash/views/initial_sync_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'settings'),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Section Header
            Text(
              'OFFLINE DATA MANAGEMENT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Sync Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storage_rounded, color: AppTheme.pokemonRed, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Local Storage Status',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All Generation 1 Pokémon base stats, official artwork sprites, Ability descriptions and Move tables are downloaded locally. The application functions 100% without internet.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Force Re-Sync Button
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              leading: const Icon(Icons.sync_problem_rounded, color: AppTheme.pokemonRed),
              title: Text('Force Complete Re-Sync', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14)),
              subtitle: const Text('Redownload and recreate the entire Gen 1 SQL database', style: TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => _confirmResetAndSync(context, ref),
            ),

            const SizedBox(height: 32),

            // Section Header: General
            Text(
              'APPLICATION INFO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // App Version Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('App Name', 'LibreDex', isDark),
                  const Divider(height: 1),
                  _buildInfoRow('Version', '1.0.0+Offline', isDark),
                  const Divider(height: 1),
                  _buildInfoRow('Source Code', 'Open Source (GPL)', isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetAndSync(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Database Reset?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'This action will clear all local tables (Pokémon, Moves and Abilities) and restart the global initialization sync wizard. Internet connection is required for initial seed.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                final db = ref.read(databaseProvider);
                // Clear tables in SQLite
                await db.transaction(() async {
                  await db.delete(db.pokemonAbilitiesTable).go();
                  await db.delete(db.pokemonMovesTable).go();
                  await db.delete(db.pokemonTable).go();
                  await db.delete(db.moveTable).go();
                  await db.delete(db.abilityTable).go();
                });

                if (context.mounted) {
                  // Forward back to Splash Sync Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const InitialSyncScreen()),
                  );
                }
              },
              child: const Text('Reset & Sync', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(value, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}

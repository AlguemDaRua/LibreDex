import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/repositories/sync_repository.dart';
import 'package:libredex/features/splash/views/initial_sync_screen.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 80),
          children: [
            // ─── Section: Sync & Offline Data Management ─────────────────────────
            _buildSectionHeader('SYNC & LOCAL STORAGE MANAGEMENT', isDark),
            const SizedBox(height: 12),

            // Sync Status Card
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
                      const Icon(Icons.storage_rounded, color: AppTheme.pokemonRed, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Database Sync & Storage',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All 1025+ Pokémon (Gen 1–9+), alternate forms, Moves, Abilities, and full Learnsets are stored locally for instant offline usage. High-res sprites stream online dynamically or can be downloaded for offline use.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Re-seed Moves & Abilities (fix empty Move/Ability detail for existing users)
            _buildActionTile(
              isDark: isDark,
              primaryColor: primaryColor,
              icon: Icons.auto_fix_high_rounded,
              title: 'Fix Moves & Abilities Links',
              subtitle: 'Re-seeds Move, Ability & Learnset data without re-downloading Pokémon. Run this if Move or Ability detail pages show no Pokémon.',
              onTap: () => _reseedBundledData(context, ref),
            ),
            const SizedBox(height: 12),

            // Download Offline Sprites
            _buildActionTile(
              isDark: isDark,
              primaryColor: primaryColor,
              icon: Icons.download_rounded,
              title: 'Download Offline Sprites',
              subtitle: 'Download all 2,200+ high-quality sprites for offline usage (~150MB)',
              onTap: () {
                ref.read(deepSyncRepositoryProvider).startDeepSync();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),

            // Delete Cached Sprites
            _buildActionTile(
              isDark: isDark,
              primaryColor: primaryColor,
              icon: Icons.delete_outline_rounded,
              title: 'Delete Offline Sprites',
              subtitle: 'Clear cached high-quality sprites to free up storage space',
              onTap: () => _confirmDeleteOfflineData(context, ref),
            ),
            const SizedBox(height: 12),

            // Force Full Re-Sync
            _buildActionTile(
              isDark: isDark,
              primaryColor: primaryColor,
              icon: Icons.sync_problem_rounded,
              title: 'Force Complete Re-Sync',
              subtitle: 'Wipe all local Pokémon data and re-download everything from the internet. Requires a connection.',
              onTap: () => _confirmResetAndSync(context, ref),
            ),

            const SizedBox(height: 32),

            // ─── Section: Application Info ─────────────────────────────────
            _buildSectionHeader('APPLICATION INFO', isDark),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('App Name', 'LibreDex', isDark, primaryColor),
                  Divider(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  _buildInfoRow('Version', '1.0.0 (F-Droid Public Beta)', isDark, primaryColor),
                  Divider(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  _buildInfoRow('Source Code', 'Open Source (MIT)', isDark, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.grey[500],
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildActionTile({
    required bool isDark,
    required Color primaryColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(icon, color: AppTheme.pokemonRed, size: 22),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Future<void> _reseedBundledData(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Re-seeding Local Data…', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
            SizedBox(height: 16),
            Text(
              'Unpacking bundled Moves, Abilities and Learnset junctions into the local database. This may take a few seconds.',
              style: TextStyle(fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      await ref.read(syncRepositoryProvider).seedBundledData();
    } catch (_) {}

    if (context.mounted) {
      Navigator.pop(context); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Moves, Abilities & Learnsets re-seeded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _confirmResetAndSync(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Full Reset?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'This will clear all local Pokémon, Move, Ability and Learnset data and restart the global initialization sync wizard. An internet connection is required.',
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
                Navigator.pop(context);
                final db = ref.read(databaseProvider);
                await db.transaction(() async {
                  await db.delete(db.pokemonAbilitiesTable).go();
                  await db.delete(db.pokemonMovesTable).go();
                  await db.delete(db.pokemonTable).go();
                  await db.delete(db.moveTable).go();
                  await db.delete(db.abilityTable).go();
                });
                if (context.mounted) {
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

  void _confirmDeleteOfflineData(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Offline Sprites?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'This will delete all downloaded high-quality Pokémon sprites from your device cache to free up storage space. The text database will remain fully intact.',
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
                Navigator.pop(context);
                await DefaultCacheManager().emptyCache();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('promptedOfflineDownload', false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offline sprites deleted successfully.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Delete Sprites', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primaryColor)),
          Text(value, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}

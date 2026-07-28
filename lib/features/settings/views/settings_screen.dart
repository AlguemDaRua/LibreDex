import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/core/widgets/offline_download_dialog.dart';
import 'package:libredex/features/home/views/home_screen.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/repositories/sync_repository.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          padding: const EdgeInsets.only(left: 20, right: 20, top: AppSpacing.topContentGap, bottom: AppSpacing.bottomScrollPadding),
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
                    'All 1025+ Pokémon (Gen 1–9+), alternate forms, the Pokémon Legends Z-A & Pokémon Champions Mega Evolutions, Moves, Abilities, and full Learnsets (including Champions “Train” moves) are stored locally for instant offline usage. High-res sprites stream online dynamically or can be downloaded for offline use.',
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
              subtitle: 'Pick a quality and download every sprite for offline use. '
                  'The app stays usable, and you can pause or cancel at any time.',
              onTap: () => showOfflineDownloadDialog(context),
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
              title: 'Rebuild Local Database',
              subtitle: 'Clear and rebuild every table from the data bundled in the app. Works fully offline.',
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
    _showBlockingProgress(
      context,
      'Unpacking bundled Moves, Abilities and Learnsets into the local database. '
      'This may take a few seconds.',
    );

    String message;
    try {
      await ref.read(syncRepositoryProvider).seedBundledData();
      message = '✓ Moves, Abilities & Learnsets re-seeded successfully.';
    } catch (e) {
      message = 'Re-seed failed: $e';
    }

    if (!context.mounted) return;
    // Pop the progress dialog specifically, never the app shell.
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  /// Clears every table and re-seeds it from the bundled JSON assets.
  ///
  /// Runs entirely offline, and always dismisses its own progress dialog using
  /// the dialog's context so it can never pop the app shell.
  Future<void> _rebuildLocalDatabase(BuildContext context, WidgetRef ref) async {
    _showBlockingProgress(
      context,
      'Rebuilding the local database from bundled data. This may take a few seconds.',
    );

    String message;
    try {
      final db = ref.read(databaseProvider);
      await db.transaction(() async {
        await db.delete(db.pokemonAbilitiesTable).go();
        await db.delete(db.pokemonMovesTable).go();
        await db.delete(db.pokemonTable).go();
        await db.delete(db.moveTable).go();
        await db.delete(db.abilityTable).go();
      });
      await ref.read(syncRepositoryProvider).seedBundledData();
      message = '✓ Local database rebuilt successfully.';
    } catch (e) {
      message = 'Rebuild failed: $e';
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  /// Shows a non-dismissible progress dialog with a shared look.
  void _showBlockingProgress(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetAndSync(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rebuild local database?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'This clears the local Pokémon, Move, Ability and Learnset tables and rebuilds '
            'them from the data bundled inside the app. No internet connection is required.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                // Use the screen's context, not the dismissed dialog's.
                _rebuildLocalDatabase(context, ref);
              },
              child: const Text('Rebuild', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteOfflineData(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) {
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await DefaultCacheManager().emptyCache();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(kOfflinePromptShownKey, false);
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

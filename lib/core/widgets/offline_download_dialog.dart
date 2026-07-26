import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';

/// Shows the sprite-quality picker and starts the download if confirmed.
///
/// Used by both the first-run prompt and the Settings screen so the two paths
/// can never drift apart.
Future<void> showOfflineDownloadDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const OfflineDownloadDialog(),
  );
}

/// Lets the user pick a sprite quality before downloading for offline use.
class OfflineDownloadDialog extends ConsumerStatefulWidget {
  const OfflineDownloadDialog({super.key});

  @override
  ConsumerState<OfflineDownloadDialog> createState() => _OfflineDownloadDialogState();
}

class _OfflineDownloadDialogState extends ConsumerState<OfflineDownloadDialog> {
  SpriteQuality _quality = SpriteQuality.standard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      title: const Row(
        children: [
          Icon(Icons.cloud_download_rounded, color: AppTheme.pokemonRed, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use LibreDex offline',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All stats, moves, abilities and learnsets already work offline. '
            'Download the artwork too so images appear without a connection.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 18),
          for (final quality in SpriteQuality.values)
            _QualityOption(
              quality: quality,
              selected: _quality == quality,
              onTap: () => setState(() => _quality = quality),
            ),
          const SizedBox(height: 6),
          Text(
            'You can keep using the app while it downloads, and pause or cancel any time.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.pokemonRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            // Fire and forget: the loop reports progress through the banner.
            ref.read(deepSyncControllerProvider.notifier).start(quality: _quality);
            Navigator.pop(context);
          },
          child: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _QualityOption extends StatelessWidget {
  final SpriteQuality quality;
  final bool selected;
  final VoidCallback onTap;

  const _QualityOption({
    required this.quality,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? AppTheme.pokemonRed.withValues(alpha: isDark ? 0.16 : 0.08)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? AppTheme.pokemonRed
                  : (isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB)),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? AppTheme.pokemonRed : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quality.label,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quality.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                quality.approximateSizeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

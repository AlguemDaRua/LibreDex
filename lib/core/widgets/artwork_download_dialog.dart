import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preference that suppresses the optional first-launch artwork prompt.
const String kArtworkDownloadPromptDisabledKey =
    'artwork_download_prompt_disabled';

/// Shows the artwork-quality picker from Settings or another explicit action.
Future<void> showArtworkDownloadDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ArtworkDownloadDialog(),
  );
}

/// Shows the optional first-launch artwork prompt.
///
/// No download starts unless the user selects [Download]. Choosing [Ask me
/// later] leaves the prompt available for a future app launch, while [Never
/// ask again] only hides this prompt; the download remains in Settings.
Future<void> showFirstLaunchArtworkDownloadDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ArtworkDownloadDialog(isFirstLaunchPrompt: true),
  );
}

/// Lets the user pick an artwork quality for offline use.
class ArtworkDownloadDialog extends ConsumerStatefulWidget {
  const ArtworkDownloadDialog({
    super.key,
    this.isFirstLaunchPrompt = false,
  });

  final bool isFirstLaunchPrompt;

  @override
  ConsumerState<ArtworkDownloadDialog> createState() =>
      _ArtworkDownloadDialogState();
}

class _ArtworkDownloadDialogState extends ConsumerState<ArtworkDownloadDialog> {
  SpriteQuality _quality = SpriteQuality.standard;
  bool _isSubmitting = false;

  Future<void> _disableFirstLaunchPrompt() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(kArtworkDownloadPromptDisabledKey, true);
  }

  Future<void> _neverAskAgain() async {
    setState(() => _isSubmitting = true);
    try {
      await _disableFirstLaunchPrompt();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _startDownload() async {
    setState(() => _isSubmitting = true);
    try {
      // A manual download from Settings is also an answer to the first-launch
      // question, so it should not be asked again on the next launch.
      try {
        await _disableFirstLaunchPrompt();
      } catch (_) {
        // A preferences write must not prevent a user-requested download.
      }
      ref.read(deepSyncControllerProvider.notifier).start(quality: _quality);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
              'Download artwork',
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
            'Reference data is already stored on this device. Download the artwork too '
            'to save a durable offline library of Pokémon images.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          if (widget.isFirstLaunchPrompt) ...[
            const SizedBox(height: 10),
            Text(
              'Nothing downloads unless you choose Download. Ask me later will ask again next time, and Settings is always available.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 18),
          for (final quality in SpriteQuality.values)
            _QualityOption(
              quality: quality,
              selected: _quality == quality,
              onTap: _isSubmitting
                  ? null
                  : () => setState(() => _quality = quality),
            ),
          const SizedBox(height: 6),
          Text(
            'Artwork is downloaded from the internet. You can keep using the app, pause or cancel any time.',
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
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(
            widget.isFirstLaunchPrompt ? 'Ask me later' : 'Not now',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        if (widget.isFirstLaunchPrompt)
          TextButton(
            onPressed: _isSubmitting ? null : _neverAskAgain,
            child: const Text('Never ask again'),
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.pokemonRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSubmitting ? null : _startDownload,
          child: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _QualityOption extends StatelessWidget {
  final SpriteQuality quality;
  final bool selected;
  final VoidCallback? onTap;

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

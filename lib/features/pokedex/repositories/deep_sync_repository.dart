import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';

/// Sprite quality the user can pick before starting an offline download.
enum SpriteQuality {
  /// Pixel sprites from the games — tiny download, good for limited storage.
  small(
    label: 'Small',
    description: 'Pixel game sprites',
    approximateSizeLabel: '~15 MB',
  ),

  /// Pokémon HOME renders — the artwork the app shows by default.
  standard(
    label: 'Standard',
    description: 'High-quality HOME renders',
    approximateSizeLabel: '~150 MB',
  );

  const SpriteQuality({
    required this.label,
    required this.description,
    required this.approximateSizeLabel,
  });

  final String label;
  final String description;
  final String approximateSizeLabel;
}

/// Lifecycle of the offline sprite download.
enum DownloadStatus { idle, running, paused, completed, failed }

/// Immutable snapshot of the offline sprite download, rendered by the UI.
@immutable
class DeepSyncState {
  final DownloadStatus status;
  final int completed;
  final int total;
  final int failed;

  /// Name of the Pokémon currently being fetched, for the progress banner.
  final String currentLabel;
  final String? errorMessage;

  const DeepSyncState({
    this.status = DownloadStatus.idle,
    this.completed = 0,
    this.total = 0,
    this.failed = 0,
    this.currentLabel = '',
    this.errorMessage,
  });

  double get progress => total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);

  bool get isActive => status == DownloadStatus.running || status == DownloadStatus.paused;

  /// Whether the progress banner should be visible.
  bool get isVisible => isActive || status == DownloadStatus.failed;

  DeepSyncState copyWith({
    DownloadStatus? status,
    int? completed,
    int? total,
    int? failed,
    String? currentLabel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeepSyncState(
      status: status ?? this.status,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      failed: failed ?? this.failed,
      currentLabel: currentLabel ?? this.currentLabel,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives the offline sprite download.
///
/// The download runs as a plain async loop that yields between each image, so
/// the UI thread stays responsive and the whole app remains usable while data
/// is being fetched. It can be paused, resumed and cancelled at any time.
class DeepSyncController extends Notifier<DeepSyncState> {
  static const int _maxConsecutiveFailures = 25;

  final BaseCacheManager _cacheManager;

  /// Completes while the download is paused; null when running.
  Completer<void>? _pauseGate;
  bool _cancelRequested = false;
  bool _isRunning = false;

  DeepSyncController({BaseCacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  @override
  DeepSyncState build() => const DeepSyncState();

  /// Rewrites a HOME sprite URL to the much smaller pixel sprite variant.
  @visibleForTesting
  static String resolveUrl(String url, SpriteQuality quality) {
    if (quality == SpriteQuality.standard) return url;
    // HOME:  .../sprites/pokemon/other/home/25.png       (and /home/shiny/25.png)
    // Pixel: .../sprites/pokemon/25.png                  (and /shiny/25.png)
    return url
        .replaceFirst('/other/home/shiny/', '/shiny/')
        .replaceFirst('/other/home/', '/')
        .replaceFirst('/other/official-artwork/shiny/', '/shiny/')
        .replaceFirst('/other/official-artwork/', '/');
  }

  Future<void> start({SpriteQuality quality = SpriteQuality.standard}) async {
    if (_isRunning) return;
    _isRunning = true;
    _cancelRequested = false;
    _pauseGate = null;

    try {
      final db = ref.read(databaseProvider);
      final pokemon = await db.select(db.pokemonTable).get();

      if (pokemon.isEmpty) {
        state = const DeepSyncState(status: DownloadStatus.completed);
        return;
      }

      state = DeepSyncState(
        status: DownloadStatus.running,
        total: pokemon.length,
        currentLabel: 'Preparing download…',
      );

      var completed = 0;
      var failed = 0;
      var consecutiveFailures = 0;

      for (final p in pokemon) {
        if (_cancelRequested) {
          state = const DeepSyncState();
          return;
        }

        // Block here while paused, without burning CPU.
        final gate = _pauseGate;
        if (gate != null) await gate.future;
        if (_cancelRequested) {
          state = const DeepSyncState();
          return;
        }

        state = state.copyWith(currentLabel: p.name);

        var sawFailure = false;
        for (final url in {p.spriteUrl, p.shinySpriteUrl}) {
          if (url.isEmpty) continue;
          final resolved = resolveUrl(url, quality);
          try {
            final cached = await _cacheManager.getFileFromCache(resolved);
            if (cached == null) await _cacheManager.downloadFile(resolved);
          } catch (_) {
            sawFailure = true;
          }
        }

        completed++;
        if (sawFailure) {
          failed++;
          consecutiveFailures++;
        } else {
          consecutiveFailures = 0;
        }

        // A long unbroken failure streak means the network is gone; stop early
        // instead of grinding through 2,000 doomed requests.
        if (consecutiveFailures >= _maxConsecutiveFailures) {
          state = state.copyWith(
            status: DownloadStatus.failed,
            completed: completed,
            failed: failed,
            errorMessage: 'Download stopped — no internet connection detected. '
                'Your existing data is safe; resume any time.',
          );
          return;
        }

        state = state.copyWith(completed: completed, failed: failed);
      }

      state = state.copyWith(
        status: DownloadStatus.completed,
        currentLabel: '',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: DownloadStatus.failed,
        errorMessage: 'Download failed: $e',
      );
    } finally {
      _isRunning = false;
      _pauseGate = null;
    }
  }

  void pause() {
    if (state.status != DownloadStatus.running) return;
    _pauseGate = Completer<void>();
    state = state.copyWith(status: DownloadStatus.paused);
  }

  void resume() {
    if (state.status != DownloadStatus.paused) return;
    _pauseGate?.complete();
    _pauseGate = null;
    state = state.copyWith(status: DownloadStatus.running);
  }

  void cancel() {
    _cancelRequested = true;
    // Release a paused loop so it can observe the cancellation and exit.
    _pauseGate?.complete();
    _pauseGate = null;
    if (!_isRunning) state = const DeepSyncState();
  }

  /// Dismisses a finished or failed run so the banner disappears.
  void acknowledge() {
    if (_isRunning) return;
    state = const DeepSyncState();
  }
}

final deepSyncControllerProvider =
    NotifierProvider<DeepSyncController, DeepSyncState>(() {
  return DeepSyncController();
});

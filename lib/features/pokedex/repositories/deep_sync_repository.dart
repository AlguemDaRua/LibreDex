import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/storage/offline_artwork_store.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';

/// Artwork quality the user can pick before starting an optional download.
enum SpriteQuality {
  /// Pixel sprites from the games — small and useful on limited storage.
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

/// Lifecycle of the optional artwork download.
enum DownloadStatus { idle, running, paused, completed, failed }

/// Immutable snapshot of the artwork download, rendered by the UI.
@immutable
class DeepSyncState {
  const DeepSyncState({
    this.status = DownloadStatus.idle,
    this.completed = 0,
    this.total = 0,
    this.failed = 0,
    this.currentLabel = '',
    this.errorMessage,
  });

  final DownloadStatus status;
  final int completed;
  final int total;
  final int failed;

  /// Name of the Pokémon currently being fetched, for the progress banner.
  final String currentLabel;
  final String? errorMessage;

  double get progress =>
      total == 0 ? 0 : (completed / total).clamp(0.0, 1.0).toDouble();

  bool get isActive =>
      status == DownloadStatus.running || status == DownloadStatus.paused;

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

/// Summary for the durable, user-requested offline artwork library.
final offlineArtworkSummaryProvider = FutureProvider<OfflineArtworkSummary>(
  (ref) => OfflineArtworkStore.instance.summary(),
);

/// Drives the optional artwork download.
///
/// Three workers download independent Pokémon at a time. Existing durable
/// files are skipped, so starting the same quality again resumes an interrupted
/// library without re-downloading finished artwork.
class DeepSyncController extends Notifier<DeepSyncState> {
  static const int _parallelDownloads = 3;
  static const int _maxAllFailureAttempts = 25;
  static const int _attemptsPerArtwork = 2;

  final OfflineArtworkStore _artworkStore;

  /// Completes while the download is paused; null when running.
  Completer<void>? _pauseGate;
  bool _cancelRequested = false;
  bool _isRunning = false;

  DeepSyncController({OfflineArtworkStore? artworkStore})
      : _artworkStore = artworkStore ?? OfflineArtworkStore.instance;

  @override
  DeepSyncState build() => const DeepSyncState();

  /// Rewrites a HOME sprite URL to the much smaller pixel sprite variant.
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

      var nextIndex = 0;
      var completed = 0;
      var failed = 0;
      var abortForMissingConnection = false;

      Future<void> worker() async {
        while (true) {
          if (_cancelRequested || abortForMissingConnection) return;
          if (!await _waitUntilResumed()) return;

          if (nextIndex >= pokemon.length) return;
          final current = pokemon[nextIndex++];
          state = state.copyWith(currentLabel: current.name);

          final sawFailure = await _downloadPokemon(current, quality);
          if (_cancelRequested || abortForMissingConnection) return;

          completed++;
          if (sawFailure) failed++;

          // Stop only when every early request failed. Individual missing
          // images should not stop a usable partial library.
          if (completed >= _maxAllFailureAttempts && failed == completed) {
            abortForMissingConnection = true;
            state = state.copyWith(
              status: DownloadStatus.failed,
              completed: completed,
              failed: failed,
              errorMessage: 'Download stopped — no internet connection detected. '
                  'Your downloaded artwork is safe; resume any time.',
            );
            return;
          }

          state = state.copyWith(completed: completed, failed: failed);
        }
      }

      await Future.wait([
        for (var workerIndex = 0;
            workerIndex < _parallelDownloads && workerIndex < pokemon.length;
            workerIndex++)
          worker(),
      ]);

      if (_cancelRequested) {
        state = const DeepSyncState();
      } else if (!abortForMissingConnection) {
        state = state.copyWith(
          status: DownloadStatus.completed,
          currentLabel: '',
          clearError: true,
        );
      }
    } catch (error) {
      state = state.copyWith(
        status: DownloadStatus.failed,
        errorMessage: 'Download failed: $error',
      );
    } finally {
      _isRunning = false;
      _pauseGate = null;
      _artworkStore.notifyLibraryChanged();
      ref.invalidate(offlineArtworkSummaryProvider);
    }
  }

  Future<bool> _waitUntilResumed() async {
    while (_pauseGate != null) {
      final gate = _pauseGate;
      if (gate != null) await gate.future;
      if (_cancelRequested) return false;
    }
    return !_cancelRequested;
  }

  /// Returns whether either render failed after retrying.
  Future<bool> _downloadPokemon(Pokemon pokemon, SpriteQuality quality) async {
    var sawFailure = false;
    for (final sourceUrl in {pokemon.spriteUrl, pokemon.shinySpriteUrl}) {
      if (sourceUrl.isEmpty || _cancelRequested) continue;
      if (!await _waitUntilResumed()) return sawFailure;

      if (await _artworkStore.hasArtwork(sourceUrl, quality: quality.name)) {
        continue;
      }

      try {
        await _downloadArtworkWithRetry(sourceUrl, quality);
      } catch (_) {
        sawFailure = true;
      }
    }
    return sawFailure;
  }

  Future<void> _downloadArtworkWithRetry(
    String sourceUrl,
    SpriteQuality quality,
  ) async {
    Object? lastError;
    for (var attempt = 0; attempt < _attemptsPerArtwork; attempt++) {
      if (_cancelRequested || !await _waitUntilResumed()) return;
      try {
        await _artworkStore.downloadArtwork(
          sourceUrl: sourceUrl,
          remoteUrl: resolveUrl(sourceUrl, quality),
          quality: quality.name,
        );
        return;
      } catch (error) {
        lastError = error;
        if (attempt + 1 < _attemptsPerArtwork) {
          await Future<void>.delayed(Duration(milliseconds: 350 * (attempt + 1)));
        }
      }
    }
    throw lastError ?? StateError('Artwork download failed.');
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
    // Release paused workers so they can observe the cancellation and exit.
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
    NotifierProvider<DeepSyncController, DeepSyncState>(DeepSyncController.new);

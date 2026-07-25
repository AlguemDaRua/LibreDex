import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'deep_sync_repository.g.dart';

class DeepSyncState {
  final double progress;
  final String message;
  final bool isComplete;
  
  DeepSyncState({required this.progress, required this.message, required this.isComplete});
}

@riverpod
class DeepSyncProgress extends _$DeepSyncProgress {
  @override
  DeepSyncState build() => DeepSyncState(progress: 0.0, message: '', isComplete: false);

  void update(double progress, String message, {bool isComplete = false}) {
    state = DeepSyncState(progress: progress, message: message, isComplete: isComplete);
  }
}

@riverpod
DeepSyncRepository deepSyncRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final pokemonRepo = ref.watch(pokemonRepositoryProvider);
  return DeepSyncRepository(db, pokemonRepo, ref);
}

class DeepSyncRepository {
  final AppDatabase db;
  final PokemonRepository pokemonRepo;
  final Ref ref;
  bool _isRunning = false;

  DeepSyncRepository(this.db, this.pokemonRepo, this.ref);

  Future<void> startDeepSync() async {
    if (_isRunning) return;
    _isRunning = true;
    
    try {
      final progressNotifier = ref.read(deepSyncProgressProvider.notifier);
      progressNotifier.update(0.01, 'Checking Deep Sync...', isComplete: false);

      final allPokemon = await db.select(db.pokemonTable).get();
      final total = allPokemon.length;

      if (total == 0) {
        progressNotifier.update(1.0, '', isComplete: true);
        _isRunning = false;
        return;
      }

      int completed = 0;
      final cacheManager = DefaultCacheManager();

      for (final p in allPokemon) {
        progressNotifier.update(completed / total, 'Downloading Offline Sprites: ${p.name} [${completed + 1}/$total]');

        try {
          if (p.spriteUrl.isNotEmpty) {
            final fileInfo = await cacheManager.getFileFromCache(p.spriteUrl);
            if (fileInfo == null) {
              await cacheManager.downloadFile(p.spriteUrl);
            }
          }
        } catch (_) {}

        try {
          if (p.shinySpriteUrl.isNotEmpty) {
            final fileInfo = await cacheManager.getFileFromCache(p.shinySpriteUrl);
            if (fileInfo == null) {
              await cacheManager.downloadFile(p.shinySpriteUrl);
            }
          }
        } catch (_) {}

        completed++;
      }

      progressNotifier.update(1.0, 'Sprite Download Complete!', isComplete: true);
    } catch (e) {
      debugPrint('Deep Sync Failed: $e');
    } finally {
      _isRunning = false;
    }
  }
}

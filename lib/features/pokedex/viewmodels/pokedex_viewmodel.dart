import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';

/// Standard StreamProvider that exposes the reactive list of Pokémon from the database stream.
/// Exempt from Riverpod code-generator phase dependency resolution issues.
final pokedexProvider = StreamProvider.autoDispose<List<Pokemon>>((ref) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchAllPokemon();
});

/// Standard AsyncNotifier that manages Pokémon API synchronization state.
/// We extend AsyncNotifier and make it auto-dispose through the provider declaration.
class PokedexSyncNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is idle (completed success with null/void)
    return null;
  }

  /// Triggers API pull and manages local loading/success/error state.
  Future<void> syncPokedex() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(pokemonRepositoryProvider);
      await repo.syncPokedex();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Standard AsyncNotifierProvider.autoDispose exposing the synchronization notifier state.
final pokedexSyncNotifierProvider = AsyncNotifierProvider.autoDispose<PokedexSyncNotifier, void>(() {
  return PokedexSyncNotifier();
});

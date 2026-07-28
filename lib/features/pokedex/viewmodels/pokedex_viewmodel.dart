import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/repositories/sync_repository.dart';

/// Reactive list of every Pokémon in the local database.
final pokedexProvider = StreamProvider.autoDispose<List<Pokemon>>((ref) {
  return ref.watch(pokemonRepositoryProvider).watchAllPokemon();
});

/// Re-seeds the database from the bundled assets and tracks the loading state.
class PokedexSyncNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Rebuilds the local dataset from the app bundle. Works entirely offline.
  Future<void> reseed() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(syncRepositoryProvider).seedBundledData(),
    );
  }
}

final pokedexSyncNotifierProvider =
    AsyncNotifierProvider.autoDispose<PokedexSyncNotifier, void>(() {
  return PokedexSyncNotifier();
});

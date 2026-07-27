import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritePokemonProvider = NotifierProvider<FavoritePokemonNotifier, Set<int>>(
  FavoritePokemonNotifier.new,
);

class FavoritePokemonNotifier extends Notifier<Set<int>> {
  static const _prefsKey = 'favorite_pokemon_dex_numbers';

  @override
  Set<int> build() {
    _load();
    return <int>{};
  }

  bool isFavorite(int dexNumber) => state.contains(dexNumber);

  Future<void> toggle(int dexNumber) async {
    final next = {...state};
    if (!next.add(dexNumber)) next.remove(dexNumber);
    state = next;
    await _save(next);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? const <String>[];
    state = saved.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> _save(Set<int> value) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = value.toList()..sort();
    await prefs.setStringList(_prefsKey, sorted.map((id) => '$id').toList());
  }
}

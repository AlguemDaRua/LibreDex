import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final teamBuilderProvider = NotifierProvider<TeamBuilderNotifier, List<int?>>(
  TeamBuilderNotifier.new,
);

class TeamBuilderNotifier extends Notifier<List<int?>> {
  static const _prefsKey = 'team_builder_slots';
  static const teamSize = 6;

  @override
  List<int?> build() {
    _load();
    return List<int?>.filled(teamSize, null);
  }

  Future<bool> addPokemon(int pokemonId) async {
    if (state.contains(pokemonId)) return true;
    final emptyIndex = state.indexWhere((id) => id == null);
    if (emptyIndex == -1) return false;
    await setSlot(emptyIndex, pokemonId);
    return true;
  }

  Future<void> setSlot(int index, int? pokemonId) async {
    if (index < 0 || index >= teamSize) return;
    final next = [...state];
    next[index] = pokemonId;
    state = next;
    await _save(next);
  }

  Future<void> removePokemon(int pokemonId) async {
    final next = state.map((id) => id == pokemonId ? null : id).toList();
    state = next;
    await _save(next);
  }

  Future<void> clear() async {
    final next = List<int?>.filled(teamSize, null);
    state = next;
    await _save(next);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? const <String>[];
    final slots = List<int?>.filled(teamSize, null);
    for (var i = 0; i < slots.length && i < saved.length; i++) {
      slots[i] = int.tryParse(saved[i]);
    }
    state = slots;
  }

  Future<void> _save(List<int?> slots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      slots.map((id) => id?.toString() ?? '').toList(),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls whether evolution pages prefer the current PokéAPI chain.
///
/// Turning this off guarantees that evolution pages use only the bundled
/// records and do not make their optional network request.
final liveEvolutionDataProvider =
    NotifierProvider<LiveEvolutionDataNotifier, bool>(LiveEvolutionDataNotifier.new);

class LiveEvolutionDataNotifier extends Notifier<bool> {
  static const _preferenceKey = 'use_live_evolution_data';

  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, enabled);
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    state = preferences.getBool(_preferenceKey) ?? true;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'navigation_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentMenuIndex extends _$CurrentMenuIndex {
  static const _prefsKey = 'last_menu_index';

  @override
  int build() {
    _loadLastIndex();
    return 0;
  }

  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefsKey);
    if (saved != null && saved >= 0 && saved <= 9) state = saved;
  }

  Future<void> setIndex(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, index);
  }
}

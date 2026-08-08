import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// LEGACY — kept only so existing installs that saved 'both'/'drawer' don't crash.
// New installs use the adaptive bar/rail (see HomeScreen + AppSection) and never read this.
const String _kNavStyleKey = 'user_navigation_style';

@Deprecated('Replaced by adaptive AppSection + HomeScreen rail/bar — do not use in new code')
final navigationStyleProvider = NotifierProvider<NavigationStyleNotifier, String>(
  NavigationStyleNotifier.new,
);

class NavigationStyleNotifier extends Notifier<String> {
  @override
  String build() {
    _loadPreference();
    return 'both';
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kNavStyleKey);
    if (saved != null && ['both', 'bottomBar', 'drawer'].contains(saved)) {
      state = saved;
    }
  }

  Future<void> setStyle(String style) async {
    if (!['both', 'bottomBar', 'drawer'].contains(style)) return;
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNavStyleKey, style);
  }
}

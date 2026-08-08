import 'dart:async';

/// Small reusable debounce primitive for search fields and other high-frequency
/// user input. Call [schedule] on every keystroke and [dispose] with the view.
class DebouncedQuery {
  DebouncedQuery({this.delay = const Duration(milliseconds: 250)});
  final Duration delay;
  Timer? _timer;
  void schedule(String value, void Function(String) callback) {
    _timer?.cancel();
    _timer = Timer(delay, () => callback(value));
  }
  void dispose() => _timer?.cancel();
}

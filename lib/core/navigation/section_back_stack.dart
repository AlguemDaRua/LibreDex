/// Tracks the order in which home sections were visited, so the system back
/// button can retrace the user's steps instead of always teleporting to the
/// Pokédex.
///
/// Why this exists: the app keeps its nine sections inside one
/// [IndexedStack] and flips between them from the drawer, from cross-feature
/// shortcuts (Team Builder → Damage Calculator) and from the persisted
/// last-used section. Without a history, pressing back on the calculator
/// straight after "Open in calculator" dumped the user on the Pokédex and
/// lost where they were working.
///
/// Rules:
/// * Section switches pushed by [record] stack up like browser history.
/// * Pressing back ([goBack]) pops to the previously visited section.
/// * The Pokédex ([rootIndex]) is the sink: once the user is there, back
///   returns `null` and the system may close the app. Reaching the root
///   through any navigation also clears the stack, so back always exits
///   from home.
/// * Duplicate records of the current section are ignored.
///
/// Pushed routes (Pokémon details, settings sheets, ...) live on the normal
/// Navigator stack and are unaffected — back still pops those first.
class SectionBackStack {
  static const int rootIndex = 0;

  int _current = rootIndex;
  final List<int> _stack = <int>[];

  /// The section the user is currently on.
  int get current => _current;

  /// Copies of the sections awaiting a back press, oldest first.
  List<int> get stack => List<int>.unmodifiable(_stack);

  /// Records a transition to [next]. Called whenever the active section
  /// changes, regardless of how (drawer tap, persisted restore, in-app
  /// shortcut). Transitions caused by [goBack] must also be recorded — the
  /// stack is already consistent, so they register as no-ops.
  void record(int next) {
    if (next == _current) return;
    if (next == rootIndex) {
      // Home is the back-navigation sink.
      _stack.clear();
      _current = rootIndex;
      return;
    }
    _stack.add(_current);
    _current = next;
  }

  /// Pops one step of section history and returns the section to show, or
  /// `null` when already home with nothing left — meaning the system should
  /// handle the back press (usually closing the app).
  int? goBack() {
    while (_stack.isNotEmpty && _stack.last == _current) {
      _stack.removeLast();
    }
    if (_stack.isNotEmpty) {
      _current = _stack.removeLast();
      return _current;
    }
    if (_current != rootIndex) {
      _current = rootIndex;
      return rootIndex;
    }
    return null;
  }
}

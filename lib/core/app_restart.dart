import 'package:flutter/widgets.dart';

/// Recreates a keyed app subtree after intentionally deleting local data.
class AppRestart extends StatefulWidget {
  const AppRestart({
    super.key,
    required this.child,
  });

  final Widget child;

  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartState>()?._restart();
  }

  @override
  State<AppRestart> createState() => _AppRestartState();
}

class _AppRestartState extends State<AppRestart> {
  var _generation = 0;

  void _restart() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_generation),
      child: widget.child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/theme_provider.dart';
import 'package:libredex/core/widgets/wavy_theme_transition.dart';

/// Helper that toggles theme *through* the wavy reveal so the animation plays.
/// Call this from any IconButton/GestureDetector instead of calling
/// `ref.read(themeModeProvider.notifier).setThemeMode(...)` directly.
Future<void> switchThemeWithWavy({
  required BuildContext context,
  required WidgetRef ref,
  required ThemeMode mode,
  Offset? origin,
}) async {
  final scope = ThemeTransitionScope.maybeOf(context);
  final tapPosition = origin ??
      () {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          return box.localToGlobal(box.size.center(Offset.zero));
        }
        final size = MediaQuery.of(context).size;
        return Offset(size.width / 2, size.height / 2);
      }();

  if (scope != null) {
    await scope.transitionTo(
      origin: tapPosition,
      applyTheme: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
    );
  } else {
    await ref.read(themeModeProvider.notifier).setThemeMode(mode);
  }
}

/// Cycle System → Dark → Light → System with animation.
Future<void> cycleThemeWithWavy(BuildContext context, WidgetRef ref) async {
  final current = ref.read(themeModeProvider);
  final next = switch (current) {
    ThemeMode.system => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.light,
    ThemeMode.light => ThemeMode.system,
    _ => ThemeMode.system,
  };
  // Use the button's center as origin
  await switchThemeWithWavy(context: context, ref: ref, mode: next);
}

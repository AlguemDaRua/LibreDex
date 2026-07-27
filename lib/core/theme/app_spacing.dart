/// Shared layout rhythm for every LibreDex screen.
///
/// Before this, padding values were slightly different magic numbers per
/// feature (12/16/20 horizontal, 80/90/96 bottom clearance...). Keep the
/// canonical values here so every screen breathes the same way and scroll
/// content always clears the system navigation area.
class AppSpacing {
  AppSpacing._();

  /// Standard horizontal page padding for list and detail screens.
  static const double pagePadding = 16.0;

  /// Breathing room between the app bar (or pinned header) and the first
  /// content block. Replaces the cramped 12dp some screens used.
  static const double topContentGap = 16.0;

  /// Minimum bottom clearance for scrollable content so the last item never
  /// hides behind system navigation gestures.
  static const double bottomScrollPadding = 96.0;

  /// Inner padding for cards and info containers.
  static const double cardPadding = 16.0;
}

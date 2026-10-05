import 'package:flutter/material.dart';

/// Responsive helpers — single source for every rotation / tablet check.
/// No duplicate MediaQuery logic scattered across screens.
class Responsive {
  Responsive._();
  static bool isTablet(BuildContext c) => MediaQuery.of(c).size.width >= 700;
  static bool isWideTablet(BuildContext c) => MediaQuery.of(c).size.width >= 1000;
  static bool isLandscape(BuildContext c) => MediaQuery.of(c).orientation == Orientation.landscape;
  static double pagePadding(BuildContext c) => isTablet(c) ? 24 : 16;
  static double gridMaxExtent(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1200) return 260;
    if (w >= 900) return 250;
    if (w >= 700) return 220;
    if (w >= 600) return 200;
    return 180;
  }
  static int hubColumns(BuildContext c) => isTablet(c) ? 3 : 2;
  static EdgeInsets sheetPadding(BuildContext c) => EdgeInsets.symmetric(
        horizontal: isTablet(c) ? 24 : 16,
        vertical: isTablet(c) ? 20 : 16,
      );
}

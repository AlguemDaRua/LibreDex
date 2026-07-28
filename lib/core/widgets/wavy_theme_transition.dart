import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Gives a descendant a way to change themes through a source-aware reveal.
///
/// Theme controls provide their global tap position, allowing the transition
/// to start at the control instead of at an arbitrary point on the screen.
class ThemeTransitionScope extends InheritedWidget {
  const ThemeTransitionScope({
    super.key,
    required this.transitionTo,
    required super.child,
  });

  final Future<void> Function({
    required Offset origin,
    required FutureOr<void> Function() applyTheme,
  }) transitionTo;

  static ThemeTransitionScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeTransitionScope>();
  }

  @override
  bool updateShouldNotify(ThemeTransitionScope oldWidget) => false;
}

/// Reveals the new theme through an organic, wavy edge that expands from the
/// selected theme control.
///
/// The current screen is captured once before the theme changes. That captured
/// frame sits above the new theme while a custom-painted, irregular opening
/// spreads outward. Capturing once keeps scrolling and normal app rendering
/// inexpensive; only the short transition redraws a single image and path.
class WavyThemeTransition extends StatefulWidget {
  const WavyThemeTransition({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<WavyThemeTransition> createState() => _WavyThemeTransitionState();
}

class _WavyThemeTransitionState extends State<WavyThemeTransition>
    with SingleTickerProviderStateMixin {
  final GlobalKey _captureKey = GlobalKey();
  late final AnimationController _controller;

  ui.Image? _previousFrame;
  Offset _origin = Offset.zero;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _releaseFrame();
      });
  }

  /// Captures the current page, applies the requested theme, then reveals the
  /// updated page from [origin]. Motion-reduction settings always win.
  Future<void> _transitionTo({
    required Offset origin,
    required FutureOr<void> Function() applyTheme,
  }) async {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || _isCapturing || _controller.isAnimating) {
      await Future<void>.sync(applyTheme);
      return;
    }

    _isCapturing = true;
    try {
      ui.Image? frame;
      try {
        frame = await _captureCurrentFrame();
      } catch (_) {
        // Some platform surfaces cannot be rasterized. Theme selection should
        // still work even when the decorative transition cannot be captured.
        await Future<void>.sync(applyTheme);
        return;
      }

      if (!mounted) {
        frame?.dispose();
        return;
      }

      if (frame == null) {
        await Future<void>.sync(applyTheme);
        return;
      }

      _releaseFrame();
      final renderBox = context.findRenderObject() as RenderBox?;
      setState(() {
        _previousFrame = frame;
        _origin = renderBox?.globalToLocal(origin) ?? origin;
      });

      // ThemeModeNotifier updates its Riverpod state before its first await.
      // Do not hold the animation for a small preferences write.
      unawaited(Future<void>.sync(applyTheme));
      _controller.forward(from: 0);
    } finally {
      _isCapturing = false;
    }
  }

  Future<ui.Image?> _captureCurrentFrame() async {
    final renderObject = _captureKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    // A full 3x or 4x screenshot is needlessly expensive for a one-second
    // cover layer. Two physical pixels per logical pixel keeps text crisp.
    final pixelRatio = math.min(devicePixelRatio, 2.0).toDouble();
    return renderObject.toImage(pixelRatio: pixelRatio);
  }

  void _releaseFrame() {
    final frame = _previousFrame;
    if (frame == null) return;
    if (mounted) setState(() => _previousFrame = null);
    frame.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    _previousFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeTransitionScope(
      transitionTo: _transitionTo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            key: _captureKey,
            child: widget.child,
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final frame = _previousFrame;
                if (frame == null || _controller.isDismissed) {
                  return const SizedBox.shrink();
                }

                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _WavyThemeRevealPainter(
                      frame: frame,
                      origin: _origin,
                      progress: Curves.easeInOutCubic.transform(_controller.value),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WavyThemeRevealPainter extends CustomPainter {
  const _WavyThemeRevealPainter({
    required this.frame,
    required this.origin,
    required this.progress,
  });

  final ui.Image frame;
  final Offset origin;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final bounds = Offset.zero & size;
    final source = Rect.fromLTWH(
      0,
      0,
      frame.width.toDouble(),
      frame.height.toDouble(),
    );
    final reveal = _buildRevealPath(size);

    // The saved layer makes BlendMode.clear cut through only the captured
    // frame, leaving the newly themed widgets visible below the hole.
    canvas.saveLayer(bounds, Paint());
    canvas.drawImageRect(frame, source, bounds, Paint()..filterQuality = FilterQuality.medium);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawPath(reveal, clearPaint);
    _drawTrailingWisps(canvas, size, clearPaint);

    // A restrained rim helps the moving edge read as a fluid contamination
    // rather than a perfect circular wipe.
    final edgeOpacity = (1 - progress).clamp(0.0, 1.0).toDouble();
    if (edgeOpacity > 0) {
      canvas.drawPath(
        reveal,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.16 * edgeOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      canvas.drawPath(
        reveal,
        Paint()
          ..color = const Color(0xFFE3350D).withValues(alpha: 0.24 * edgeOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.5,
      );
    }
    canvas.restore();
  }

  Path _buildRevealPath(Size size) {
    const samples = 180;
    final coverRadius = _coverRadius(size);
    final baseRadius = math.max(1.0, coverRadius * progress).toDouble();
    final waveAmplitude =
        math.min(size.shortestSide * 0.045, baseRadius * 0.30).toDouble();
    final path = Path();

    for (var index = 0; index <= samples; index++) {
      final angle = math.pi * 2 * index / samples;
      final ripple =
          math.sin(angle * 5 - progress * math.pi * 3.2) * 0.65 +
          math.sin(angle * 9 + progress * math.pi * 2.1) * 0.25 +
          math.cos(angle * 14 - progress * math.pi * 1.5) * 0.10;
      final radius = math.max(0.0, baseRadius + ripple * waveAmplitude).toDouble();
      final point = origin + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _drawTrailingWisps(Canvas canvas, Size size, Paint clearPaint) {
    if (progress < 0.06 || progress > 0.93) return;

    final coverRadius = _coverRadius(size);
    final baseRadius = coverRadius * progress;
    final life = math.sin(progress * math.pi).clamp(0.0, 1.0).toDouble();
    final maxWispRadius =
        math.min(size.shortestSide * 0.032, 19.0).toDouble() * life;

    for (var index = 0; index < 7; index++) {
      final angle = -0.8 + index * (math.pi * 2 / 7) + progress * 0.35;
      final double drift =
          (index.isEven ? 1.0 : -1.0) * (7.0 + index * 1.8);
      final double distance = baseRadius + drift + maxWispRadius;
      final center =
          origin + Offset(math.cos(angle), math.sin(angle)) * distance;
      final double radius =
          maxWispRadius * (0.45 + (index % 3) * 0.16);
      canvas.drawCircle(center, radius, clearPaint);
    }
  }

  double _coverRadius(Size size) {
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    final furthestCorner = corners
        .map((corner) => (corner - origin).distance)
        .reduce(math.max)
        .toDouble();
    return furthestCorner + size.shortestSide * 0.10;
  }

  @override
  bool shouldRepaint(covariant _WavyThemeRevealPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.origin != origin ||
        oldDelegate.progress != progress;
  }
}

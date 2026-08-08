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
      duration: const Duration(milliseconds: 1150),
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

                // Dramatic curve: fast explosive burst expanding into smooth fluid fill
                final curvedValue = Curves.fastOutSlowIn.transform(_controller.value);

                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _WavyThemeRevealPainter(
                      frame: frame,
                      origin: _origin,
                      progress: curvedValue,
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

    canvas.saveLayer(bounds, Paint());
    canvas.drawImageRect(frame, source, bounds, Paint()..filterQuality = FilterQuality.medium);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawPath(reveal, clearPaint);
    _drawTrailingWisps(canvas, size, clearPaint);

    final edgeOpacity = (1 - progress * 0.95).clamp(0.0, 1.0).toDouble();
    if (edgeOpacity > 0) {
      // 1. Dramatic outer Poké-Red pulse ring
      canvas.drawPath(
        reveal,
        Paint()
          ..color = const Color(0xFFE3350D).withValues(alpha: 0.45 * edgeOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // 2. Secondary energetic cyan/amber accent ring
      canvas.drawPath(
        reveal,
        Paint()
          ..color = const Color(0xFF30A7D7).withValues(alpha: 0.35 * edgeOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0,
      );

      // 3. Inner crisp white core rim
      canvas.drawPath(
        reveal,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.70 * edgeOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    canvas.restore();
  }

  Path _buildRevealPath(Size size) {
    const samples = 220;
    final coverRadius = _coverRadius(size);
    final baseRadius = math.max(1.0, coverRadius * progress).toDouble();
    final waveAmplitude =
        math.min(size.shortestSide * 0.08, baseRadius * 0.40).toDouble();
    final path = Path();

    for (var index = 0; index <= samples; index++) {
      final angle = math.pi * 2 * index / samples;
      final ripple =
          math.sin(angle * 6 - progress * math.pi * 4.2) * 0.70 +
          math.sin(angle * 11 + progress * math.pi * 2.8) * 0.30 +
          math.cos(angle * 18 - progress * math.pi * 1.8) * 0.15;
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
    if (progress < 0.04 || progress > 0.95) return;

    final coverRadius = _coverRadius(size);
    final baseRadius = coverRadius * progress;
    final life = math.sin(progress * math.pi).clamp(0.0, 1.0).toDouble();
    final maxWispRadius =
        math.min(size.shortestSide * 0.045, 26.0).toDouble() * life;

    for (var index = 0; index < 12; index++) {
      final angle = -0.8 + index * (math.pi * 2 / 12) + progress * 0.60;
      final double drift =
          (index.isEven ? 1.2 : -1.2) * (9.0 + index * 2.2);
      final double distance = baseRadius + drift + maxWispRadius;
      final center =
          origin + Offset(math.cos(angle), math.sin(angle)) * distance;
      final double radius =
          maxWispRadius * (0.50 + (index % 4) * 0.18);
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
    return furthestCorner + size.shortestSide * 0.12;
  }

  @override
  bool shouldRepaint(covariant _WavyThemeRevealPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.origin != origin ||
        oldDelegate.progress != progress;
  }
}

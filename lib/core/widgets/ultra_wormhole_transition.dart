import 'dart:math' as math;

import 'package:flutter/material.dart';

class UltraWormholeTransition extends StatefulWidget {
  final Widget child;
  final Object trigger;

  const UltraWormholeTransition({
    super.key,
    required this.child,
    required this.trigger,
  });

  @override
  State<UltraWormholeTransition> createState() => _UltraWormholeTransitionState();
}

class _UltraWormholeTransitionState extends State<UltraWormholeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  DateTime _lastToggle = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant UltraWormholeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger == widget.trigger) return;

    final now = DateTime.now();
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion || now.difference(_lastToggle) < const Duration(milliseconds: 320)) {
      // Rapid toggles should feel instant rather than queueing visual effects.
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
    _lastToggle = now;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.isDismissed || _controller.isCompleted) {
                return const SizedBox.shrink();
              }
              return RepaintBoundary(
                child: CustomPaint(
                  painter: _WormholePainter(
                    progress: Curves.easeOutCubic.transform(_controller.value),
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WormholePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _WormholePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final longest = math.sqrt(size.width * size.width + size.height * size.height);
    final center = Offset(
      size.width * (0.12 + 0.78 * progress),
      size.height * (0.92 - 0.80 * progress),
    );
    final radius = longest * (0.08 + progress * 0.72);
    final fade = (1 - progress).clamp(0.0, 1.0);

    final voidPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFF060014) : const Color(0xFFEFF6FF)).withValues(alpha: 0.92 * fade),
          const Color(0xFF22104D).withValues(alpha: 0.72 * fade),
          Colors.transparent,
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, voidPaint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (18 * fade).clamp(0.0, 18.0)
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF67E8F9).withValues(alpha: fade),
          const Color(0xFFA78BFA).withValues(alpha: fade),
          const Color(0xFFF0ABFC).withValues(alpha: fade),
          const Color(0xFF67E8F9).withValues(alpha: fade),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.72, rimPaint);

    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.55 * fade);
    for (var i = 0; i < 18; i++) {
      final angle = i * math.pi / 9 + progress * math.pi * 1.7;
      final distance = radius * (0.18 + (i % 6) * 0.105);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(point, 1.2 + (i % 3), sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WormholePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

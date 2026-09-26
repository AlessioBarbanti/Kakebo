import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/shared/theme/color.dart';

class Enso extends StatelessWidget {
  const Enso({super.key});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 1400),
    curve: const Cubic(.2, .8, .2, 1),
    builder: (context, t, child) => Opacity(
      opacity: t,
      child: Transform.rotate(
        angle: -120 * (1 - t) * math.pi / 180,
        child: Transform.scale(scale: .85 + .15 * t, child: child),
      ),
    ),
    child: const CustomPaint(size: Size.square(120), painter: _EnsoPainter()),
  );
}

class _EnsoPainter extends CustomPainter {
  const _EnsoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), d = ok(.3, .02, 160);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..shader = SweepGradient(
        transform: const GradientRotation(110 * math.pi / 180), // CSS conic "from 200deg"
        colors: [
          d.withValues(alpha: 0),
          d.withValues(alpha: .5),
          ok(.28, .02, 160, .9),
          d.withValues(alpha: .6),
          d.withValues(alpha: 0),
          d.withValues(alpha: 0),
        ],
        stops: const [0, 30 / 360, 200 / 360, 320 / 360, 336 / 360, 1],
      ).createShader(Rect.fromCircle(center: c, radius: size.width / 2));
    canvas.drawCircle(c, 52.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

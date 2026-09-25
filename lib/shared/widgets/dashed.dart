import 'package:flutter/material.dart';

class Dashed extends CustomPainter {
  Dashed(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(RRect.fromRectAndRadius((Offset.zero & size).deflate(.75), Radius.circular(radius)));
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Dashed old) => old.color != color;
}

/// Numeric text field that follows outside changes (e.g. the 50/30/20 rule) without fighting the user.

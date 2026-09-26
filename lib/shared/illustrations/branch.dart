import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/seasons.dart';

/// The month's pace: ten buds on an ink branch, open while spending keeps up with the days gone by.
class Branch extends StatelessWidget {
  const Branch({super.key, this.height = 100});
  final double height;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    return Semantics(
      label: tr.flowers(app.bloomed),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _BranchPainter(app.bloomed, app.season)),
      ),
    );
  }
}

class _BranchPainter extends CustomPainter {
  _BranchPainter(this.bloomed, this.s);
  final int bloomed;
  final Season s;

  static final _ink = ok(.36, .03, 60), _bud = ok(.6, .07, 140);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // A slight S rising to the right, thick at the root and thin at the tip, like one brush stroke.
    final m =
        (Path()
              ..moveTo(0, h * .6)
              ..cubicTo(w * .35, h * .72, w * .65, h * .38, w, h * .42))
            .computeMetrics()
            .first;
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const steps = 40;
    for (var i = 0; i < steps; i++) {
      canvas.drawPath(m.extractPath(m.length * i / steps, m.length * (i + 1) / steps), stroke..strokeWidth = 5.5 - 4 * i / steps);
    }
    final petal = Paint()..color = s.bloom, heart = Paint()..color = s.ink, bud = Paint()..color = _bud;
    for (var i = 0; i < 10; i++) {
      final t = m.getTangentForOffset(m.length * (.07 + i * .095))!, v = t.vector / t.vector.distance;
      // Twigs alternate sides, lean toward the tip and vary in length, so no two flowers sit alike.
      final side = i.isEven ? 1.0 : -1.0, len = h * (.14 + .05 * (i * 7 % 3));
      final dir = Offset(v.dy, -v.dx) * side * .85 + v * .5, end = t.position + dir * len;
      canvas.drawLine(t.position, end, stroke..strokeWidth = 1.6);
      if (i < bloomed) {
        final r = h * (.085 + .012 * (i * 5 % 4));
        for (var k = 0; k < 5; k++) {
          canvas
            ..save()
            ..translate(end.dx, end.dy)
            ..rotate(k * 2 * math.pi / 5 + i * .4)
            ..drawOval(Rect.fromCenter(center: Offset(0, -r * .55), width: r * .8, height: r * 1.1), petal)
            ..restore();
        }
        canvas.drawCircle(end, r * .32, heart);
      } else {
        canvas.drawOval(Rect.fromCenter(center: end, width: h * .085, height: h * .11), bud);
      }
    }
  }

  @override
  bool shouldRepaint(_BranchPainter old) => old.bloomed != bloomed || old.s != s;
}

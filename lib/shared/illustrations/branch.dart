import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/widgets/controls.dart';

/// The savings branch: ten buds that bloom as the month stays on pace.
class Branch extends StatelessWidget {
  const Branch({super.key, this.height = 100});
  final double height;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final s = app.season, bloomed = app.bloomed, mid = height / 2, brown = ok(.48, .04, 60);
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          double x(int i) => c.maxWidth * (5 + i * 10) / 100;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: mid - 2,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: brown, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              for (var i = 0; i < 10; i++) ...[
                Positioned(
                  left: x(i) - 1,
                  top: i.isEven ? mid - 24 : mid,
                  width: 2,
                  height: 24,
                  child: ColoredBox(color: brown),
                ),
                Positioned(left: x(i) - 13, top: (i.isEven ? mid - 24 : mid + 24) - 13, width: 26, height: 26, child: _Flower(i < bloomed, s)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Flower extends StatelessWidget {
  const _Flower(this.open, this.s);
  final bool open;
  final Season s;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (open)
        for (final r in const [0, 72, 144, 216, 288])
          Positioned(
            left: 8,
            top: 0,
            width: 10,
            height: 13,
            child: Transform.rotate(
              angle: r * math.pi / 180,
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: ShapeDecoration(color: s.bloom, shape: const OvalBorder()),
              ),
            ),
          ),
      Center(child: dot(open ? 8 : 11, open ? s.ink : ok(.6, .07, 140))),
    ],
  );
}

/// 済 month seal, stamped in with a slight overshoot.

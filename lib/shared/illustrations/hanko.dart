import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/theme/tokens.dart';

class Hanko extends StatelessWidget {
  const Hanko(this.month, {super.key});
  final DateTime month;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 550),
    curve: Curves.easeOut,
    builder: (context, t, child) {
      final scale = t < .6 ? 1.8 - .86 * t / .6 : .94 + .06 * (t - .6) / .4;
      return Opacity(
        opacity: math.min(1, t / .6),
        child: Transform.rotate(
          angle: -8 * math.pi / 180,
          child: Transform.scale(scale: scale, child: child),
        ),
      );
    },
    child: Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        border: Border.all(color: sealRed, width: 3),
        borderRadius: BorderRadius.circular(12),
        color: card.withValues(alpha: .55),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            '済',
            style: serif(38, w: FontWeight.w700, c: sealRed, h: 1),
          ),
          Text('${kanjiMesi[month.month - 1]} · ${month.year}', style: serif(11, c: sealRed, ls: 1.1)),
        ],
      ),
    ),
  );
}

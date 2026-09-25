import 'dart:math' as math;

import 'package:flutter/painting.dart';

double _gamma(double x) => x <= 0.0031308 ? 12.92 * x : 1.055 * math.pow(x, 1 / 2.4) - 0.055;

/// CSS `oklch(l c h / a)` → sRGB, so the design tokens carry over unchanged.
Color ok(double l, double c, double h, [double alpha = 1]) {
  final r = h * math.pi / 180, a = c * math.cos(r), b = c * math.sin(r);
  double cube(double v) => v * v * v;
  final lp = cube(l + 0.3963377774 * a + 0.2158037573 * b);
  final mp = cube(l - 0.1055613458 * a - 0.0638541728 * b);
  final sp = cube(l - 0.0894841775 * a - 1.2914855480 * b);
  double ch(double v) => _gamma(v).clamp(0.0, 1.0);
  return Color.from(
    alpha: alpha,
    red: ch(4.0767416621 * lp - 3.3077115913 * mp + 0.2309699292 * sp),
    green: ch(-1.2684380046 * lp + 2.6097574011 * mp - 0.3413193965 * sp),
    blue: ch(-0.0041960863 * lp - 0.7034186147 * mp + 1.7076147010 * sp),
  );
}

import 'package:flutter/material.dart';

import 'package:kakebo/model/time.dart';
import 'package:kakebo/shared/theme/color.dart';

final bg = ok(.975, .012, 140);
final ink = ok(.32, .03, 160);
final green = ok(.42, .06, 160);
final onGreen = ok(.98, .01, 140);
final muted = ok(.4, .03, 160);
final card = ok(.99, .006, 140);
final line = ok(.92, .02, 150);
final sealRed = ok(.55, .17, 28);
final shadow = [BoxShadow(color: ok(.4, .04, 150, .1), blurRadius: 4, offset: const Offset(0, 1))];

const mincho = 'Shippori Mincho', gothic = 'Zen Kaku Gothic New';

TextStyle serif(double size, {FontWeight w = FontWeight.w600, Color? c, double? h, double? ls}) =>
    TextStyle(fontFamily: mincho, fontSize: size, fontWeight: w, color: c ?? ink, height: h, letterSpacing: ls);
TextStyle sans(double size, {FontWeight w = FontWeight.w400, Color? c, double? h, double? ls}) =>
    TextStyle(fontFamily: gothic, fontSize: size, fontWeight: w, color: c ?? ink, height: h, letterSpacing: ls);

/// A stored "21:30" shown the phone's way: 21:30, or 9:30 PM where the phone uses a 12-hour clock.
String clock(BuildContext context, String hhmm) {
  final (h, m) = hm(hhmm);
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: h, minute: m),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
}

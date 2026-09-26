import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';

/// Small caps-style section label ("REGISTRO", "DIARIO"…).
Widget kicker(String s) => Text(s, style: sans(13, ls: 1.56, c: ok(.42, .04, 160)));

Widget heading(String kick, String title) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 6,
  children: [
    kicker(kick),
    Text(title, style: serif(26, h: 1.2)),
  ],
);

Widget dot(double size, Color c, {double radius = 99}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(radius)),
);

class Btn extends StatelessWidget {
  const Btn(this.label, this.onTap, {super.key, this.color, this.pad = const EdgeInsets.symmetric(horizontal: 30, vertical: 15)});
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final EdgeInsets pad;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? green,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: pad,
        child: Text(
          label,
          style: sans(15, w: FontWeight.w700, c: onGreen),
        ),
      ),
    ),
  );
}

/// Plain text that acts as a button, with a 48 dp touch target.
class TapText extends StatelessWidget {
  const TapText(this.label, this.onTap, {super.key, this.style, this.pad = EdgeInsets.zero});
  final String label;
  final VoidCallback onTap;
  final TextStyle? style;
  final EdgeInsets pad;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: pad,
          child: Align(
            widthFactor: 1,
            child: Text(label, style: style ?? sans(14, c: ok(.38, .04, 160))),
          ),
        ),
      ),
    ),
  );
}

Widget segmented(List<(String, String)> opts, String sel, ValueChanged<String> pick) => Container(
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(color: ok(.94, .025, 150), borderRadius: BorderRadius.circular(14)),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      for (final (k, label) in opts)
        Semantics(
          button: true,
          selected: sel == k,
          child: GestureDetector(
            onTap: () => pick(k),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40), // 48 with the track's padding
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: sel == k ? card : Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: Text(label, style: sans(14, w: sel == k ? FontWeight.w700 : FontWeight.w400)),
            ),
          ),
        ),
    ],
  ),
);

class Toggle extends StatelessWidget {
  const Toggle(this.on, {super.key});
  final bool on;

  // TalkBack hears on/off, not just a shape that looks like a switch.
  @override
  Widget build(BuildContext context) => Semantics(
    toggled: on,
    child: Container(
      width: 46,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: on ? ok(.56, .08, 155) : ok(.85, .01, 160), borderRadius: BorderRadius.circular(14)),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: card,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: ok(.3, .02, 160, .25), blurRadius: 2, offset: const Offset(0, 1))],
          ),
        ),
      ),
    ),
  );
}

/// Horizontal stacked bar; each part is (fraction of full width, color).
class Bar extends StatelessWidget {
  const Bar(this.parts, {super.key, required this.height, required this.gap, required this.track});
  final List<(double, Color)> parts;
  final double height, gap;
  final Color track;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final kids = <Widget>[];
      var room = c.maxWidth;
      for (final (f, color) in parts) {
        if (f <= 0 || room <= 0) continue;
        if (kids.isNotEmpty) {
          kids.add(SizedBox(width: gap));
          room -= gap;
        }
        final w = math.max(0.0, math.min(room, f * c.maxWidth));
        kids.add(Container(width: w, color: color));
        room -= w;
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height,
          color: track,
          child: Row(children: kids),
        ),
      );
    },
  );
}

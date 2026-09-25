import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'kakebo.dart';

late final Kakebo app;

final bg = ok(.975, .012, 140);
final ink = ok(.32, .03, 160);
final green = ok(.42, .06, 160);
final onGreen = ok(.98, .01, 140);
final muted = ok(.4, .03, 160);
final card = ok(.99, .006, 140);
final line = ok(.92, .02, 150);
final sealRed = ok(.55, .17, 28);
final shadow = [BoxShadow(color: ok(.4, .04, 150, .1), blurRadius: 4, offset: const Offset(0, 1))];

TextStyle serif(double size, {FontWeight w = FontWeight.w600, Color? c, double? h, double? ls}) =>
    GoogleFonts.shipporiMincho(fontSize: size, fontWeight: w, color: c ?? ink, height: h, letterSpacing: ls);
TextStyle sans(double size, {FontWeight w = FontWeight.w400, Color? c, double? h, double? ls}) =>
    GoogleFonts.zenKakuGothicNew(fontSize: size, fontWeight: w, color: c ?? ink, height: h, letterSpacing: ls);

/// Small caps-style section label ("REGISTRO", "DIARIO"…).
Widget kicker(String s) => Text(s, style: sans(13, ls: 1.56, c: ok(.42, .04, 160)));

Widget heading(String kick, String title) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 6,
  children: [
    kicker(kick),
    Text(title, style: serif(30, h: 1.2)),
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

/// Plain text that acts as a button, with a 44px touch target.
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
        constraints: const BoxConstraints(minHeight: 44),
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
        GestureDetector(
          onTap: () => pick(k),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: sel == k ? card : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            child: Text(label, style: sans(14, w: sel == k ? FontWeight.w700 : FontWeight.w400)),
          ),
        ),
    ],
  ),
);

class Toggle extends StatelessWidget {
  const Toggle(this.on, {super.key});
  final bool on;

  @override
  Widget build(BuildContext context) => Container(
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

/// Staggered fade-up of each child when a screen opens (the design's `data-reveal`).
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.children, this.spacing = 0});
  final List<Widget> children;
  final double spacing;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  static const _ms = 1790.0; // 120ms lead + 7 × 110ms stagger + 900ms each
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _ms.toInt()),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) _c.value = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: widget.spacing,
      children: [
        for (final (i, w) in widget.children.indexed)
          AnimatedBuilder(
            animation: _c,
            child: w,
            builder: (context, child) {
              final start = (120 + math.min(i, 7) * 110) / _ms;
              final t = Interval(start, start + 900 / _ms, curve: const Cubic(.22, .8, .3, 1)).transform(_c.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
              );
            },
          ),
      ],
    );
  }
}

/// The savings branch: ten buds that bloom as the month stays on pace.
class Branch extends StatelessWidget {
  const Branch({super.key, this.height = 100});
  final double height;

  @override
  Widget build(BuildContext context) {
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

/// Ink circle drawn in with one brush turn.
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

/// Breathing circle: 4s in, 4s out.
class Breath extends StatefulWidget {
  const Breath({super.key});

  @override
  State<Breath> createState() => _BreathState();
}

class _BreathState extends State<Breath> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) {
      final t = _c.value;
      final inhale = t < .45
          ? 1.0
          : t < .5
          ? (.5 - t) / .05
          : t < .95
          ? 0.0
          : (t - .95) / .05;
      return Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: .8 - .2 * math.cos(2 * math.pi * t),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  radius: .707,
                  colors: [ok(.9, .05, 295, .9), ok(.93, .035, 150, .6), ok(.93, .035, 150, 0)],
                  stops: const [0, .6, .72],
                ),
              ),
            ),
          ),
          Opacity(
            opacity: inhale,
            child: Text('Inspira', style: serif(18)),
          ),
          Opacity(
            opacity: 1 - inhale,
            child: Text('Espira', style: serif(18)),
          ),
        ],
      );
    },
  );
}

/// Dashed rounded outline (the "envelope" around the money left to spend).
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
class NumField extends StatefulWidget {
  const NumField(this.value, this.onChanged, {super.key, required this.style, this.align = TextAlign.start, this.fill});
  final double value;
  final ValueChanged<double> onChanged;
  final TextStyle style;
  final TextAlign align;
  final Color? fill;

  @override
  State<NumField> createState() => _NumFieldState();
}

String _num(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
double _parse(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;

class _NumFieldState extends State<NumField> {
  late final _c = TextEditingController(text: _num(widget.value));

  @override
  void didUpdateWidget(NumField old) {
    super.didUpdateWidget(old);
    if (_parse(_c.text) != widget.value) _c.text = _num(widget.value);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textAlign: widget.align,
    style: widget.style,
    onChanged: (v) => widget.onChanged(_parse(v)),
    decoration: InputDecoration(
      isDense: true,
      filled: widget.fill != null,
      fillColor: widget.fill,
      contentPadding: widget.fill != null ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : EdgeInsets.zero,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    ),
  );
}

InputDecoration softInput(String hint, Color fill, double radius, EdgeInsets pad) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: fill,
  contentPadding: pad,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
);

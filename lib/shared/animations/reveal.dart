import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  // Fade and slide happen at compositing: each child is painted once into its own layer, not on every frame.
  Widget _item(int i, Widget w) {
    final start = (120 + math.min(i, 7) * 110) / _ms;
    final t = _c.drive(CurveTween(curve: Interval(start, start + 900 / _ms, curve: const Cubic(.22, .8, .3, 1))));
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, child) => Transform.translate(offset: Offset(0, 14 * (1 - t.value)), child: child),
        child: RepaintBoundary(child: w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) _c.value = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: widget.spacing,
      children: [for (final (i, w) in widget.children.indexed) _item(i, w)],
    );
  }
}

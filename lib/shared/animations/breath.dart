import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';

class Breath extends StatefulWidget {
  const Breath({super.key});

  @override
  State<Breath> createState() => _BreathState();
}

class _BreathState extends State<Breath> with SingleTickerProviderStateMixin {
  // Shared players so a bowl can ring out after the screen moves on; mixes with the user's music instead of pausing it.
  static final _bowls = [AudioPlayer(), AudioPlayer()];
  static final _ctx = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();
  int _phase = -1;
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 8))
    ..addListener(_ring)
    ..repeat();

  /// A higher bowl as the circle starts to grow (inhale), a lower one as it starts to shrink (exhale).
  void _ring() {
    final p = _c.value < .5 ? 0 : 1;
    if (p == _phase) return;
    _phase = p;
    _bowls[p].play(AssetSource(p == 0 ? 'sounds/inspira.wav' : 'sounds/espira.wav'), volume: .6, ctx: _ctx);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Scale and fades run at compositing level: the gradient and the words are painted once.
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      ScaleTransition(
        scale: _c.drive(const _Fn(_size)),
        child: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(radius: .707, colors: [ok(.9, .05, 295, .9), ok(.93, .035, 150, .6), ok(.93, .035, 150, 0)], stops: const [0, .6, .72]),
            ),
          ),
        ),
      ),
      FadeTransition(
        opacity: _c.drive(const _Fn(_inhale)),
        child: Text(tr.breatheIn, style: serif(18)),
      ),
      FadeTransition(
        opacity: _c.drive(const _Fn(_exhale)),
        child: Text(tr.breatheOut, style: serif(18)),
      ),
    ],
  );
}

double _size(double t) => .8 - .2 * math.cos(2 * math.pi * t); // .6 → 1 → .6
double _inhale(double t) => t < .45
    ? 1
    : t < .5
    ? (.5 - t) / .05
    : t < .95
    ? 0
    : (t - .95) / .05;
double _exhale(double t) => 1 - _inhale(t);

class _Fn extends Animatable<double> {
  const _Fn(this.f);
  final double Function(double) f;

  @override
  double transform(double t) => f(t);
}

/// Dashed rounded outline (the "envelope" around the money left to spend).

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/animations/swipe.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/state/kakebo.dart';

typedef _Item = ({String kanji, String name, String jp, Color ink, Color soft});

/// Kanji, prints and fallback of each intro step; the words are tr.steps[i].
class _Step {
  const _Step(this.kanji, this.art, this.fallback);
  final String kanji, fallback;
  final (String, Alignment)? art;
}

const _q4jp = ['いくらあるか', 'いくら貯めたいか', 'いくら使っているか', 'どう改善できるか'];

const _steps = [
  _Step('家計簿', ('assets/art/plum.jpg', Alignment(0, -.64)), '梅'),
  _Step('四君子', null, '四'),
  _Step('四問', ('assets/art/chrys.jpg', Alignment.center), '菊'),
];

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  Kakebo get app => AppScope.read(context);
  int step = 0, art = 0; // art moves to the next step at once, the text after its exit
  double drag = 0;
  double? op;
  bool dragging = false;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _move(double d, double? o, bool g) => setState(() {
    drag = d;
    op = o;
    dragging = g;
  });

  void finish() => app.update(() {
    app.onboarded = true;
    app.screen = 'monthStart';
  });

  void goStep(int n) {
    if (n < 0 || n > 2 || n == step) return;
    final dir = n > step ? 1 : -1;
    _t?.cancel();
    art = n;
    _move(drag - dir * 220.0, 0, false); // keep going the way the finger went
    _t = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      step = n;
      _move(dir * 90.0, 0, true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _move(0, 1, false);
      });
    });
  }

  void next() => step < 2 ? goStep(step + 1) : finish();

  @override
  Widget build(BuildContext context) {
    AppScope.watch(context);
    final ob = _steps[step], pad = MediaQuery.paddingOf(context);
    final items = <_Item>[
      if (step == 1)
        for (final p in pillars.values) (kanji: p.kanji, name: p.name, jp: p.virtue, ink: p.ink, soft: p.soft),
      if (step == 2)
        for (var i = 0; i < 4; i++) (kanji: '${i + 1}', name: tr.fourQuestions[i], jp: _q4jp[i], ink: ink, soft: ok(.94, .03, 150)),
    ];
    final out = op == 0;
    final dur = Duration(
      milliseconds: dragging
          ? 0
          : out
          ? 200
          : 500,
    );
    const curve = Curves.easeOutCubic;

    return GestureDetector(
      onHorizontalDragUpdate: (d) => _move(drag + d.delta.dx, null, true),
      onHorizontalDragEnd: (e) {
        final dir = fling(e, drag, 60);
        if (dir < 0) return next();
        if (dir > 0 && step > 0) return goStep(step - 1);
        _move(0, null, false);
      },
      child: ColoredBox(
        color: bg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The prints never slide: the next step's fade in on top at once, then the old ones leave underneath.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: const Interval(0, .6, curve: Curves.easeInOut),
              switchOutCurve: const Interval(0, .4),
              layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
              child: RepaintBoundary(key: ValueKey(art), child: _art(art, pad)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [bg, bg.withValues(alpha: .96), bg.withValues(alpha: .5), bg.withValues(alpha: 0)],
                  stops: const [0, .52, .72, 1],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 120, 24, 36 + pad.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          opacity: op ?? (1 - drag.abs() / 260).clamp(.1, 1),
                          duration: dur,
                          curve: Curves.easeOut,
                          child: AnimatedContainer(
                            duration: dur,
                            curve: curve,
                            transform: Matrix4.translationValues(drag * .5, 0, 0),
                            child: RepaintBoundary(child: _content(ob, tr.steps[step], items)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _art(int i, EdgeInsets pad) {
    final s = _steps[i];
    final prints = s.art != null ? [s.art!] : [for (final p in pillars.values) (p.img, p.pos)];
    final (tone, kanji) = [
      (pillars['wants']!.soft, pillars['wants']!.ink),
      (ok(.94, .03, 150), pillars['needs']!.ink),
      (pillars['unexpected']!.soft, pillars['unexpected']!.ink),
    ][i];
    return Stack(
      fit: StackFit.expand,
      children: [
        // Shown only if a print fails to load.
        Container(
          color: tone,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: pad.top + 40),
          child: Opacity(
            opacity: .35,
            child: Text(s.fallback, style: serif(180, h: 1, c: kanji)),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (img, pos) in prints)
              Expanded(
                child: Image.asset(img, fit: BoxFit.cover, alignment: pos, gaplessPlayback: true, errorBuilder: (_, _, _) => const SizedBox()),
              ),
          ],
        ),
      ],
    );
  }

  Widget _content(_Step ob, StepText text, List<_Item> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('家計簿 · KAKEBO', style: serif(13, ls: 1.82, c: ok(.45, .08, 10))),
          TapText(tr.skip, finish, style: sans(14, c: ok(.38, .04, 160))),
        ],
      ),
      const SizedBox(height: 20),
      Text(ob.kanji, style: serif(44, h: 1, c: green)),
      const SizedBox(height: 16),
      Text(text.title, style: serif(28, h: 1.25)),
      const SizedBox(height: 10),
      Text(text.body, style: sans(15, h: 1.65, c: ok(.36, .03, 160))),
      const SizedBox(height: 24),
      Column(
        spacing: 8,
        children: [
          for (final it in items)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: it.soft, borderRadius: BorderRadius.circular(18)),
              child: Row(
                spacing: 14,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      it.kanji,
                      textAlign: TextAlign.center,
                      style: serif(22, c: it.ink),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(it.name, style: sans(15, w: FontWeight.w700)),
                        Text(it.jp, style: sans(13, c: ok(.38, .03, 160))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => goStep(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == step ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(color: i == step ? green : ok(.85, .03, 150), borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ),
            ],
          ),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                if (step > 0)
                  TapText(
                    tr.back,
                    () => goStep(step - 1),
                    style: sans(15, c: ok(.38, .04, 160)),
                    pad: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                Btn(text.cta, next),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

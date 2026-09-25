import 'dart:async';

import 'package:flutter/material.dart';

import 'kakebo.dart';
import 'ui.dart';

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

class MonthStart extends StatelessWidget {
  const MonthStart({super.key});

  @override
  Widget build(BuildContext context) {
    watch(context);
    final pm = app.planMonth, fixed = app.fixedTotal, income = app.income, avail = app.available;
    final sub = ok(.42, .03, 160);
    Widget field(String label, String hint, double value, ValueChanged<double> set, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(label, style: sans(13, w: FontWeight.w700)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 6,
            children: [
              Expanded(
                child: NumField(value, set, style: serif(28, w: FontWeight.w700)),
              ),
              Text(currency, style: serif(24)),
            ],
          ),
          Text(hint, style: sans(12, h: 1.4, c: sub)),
        ],
      ),
    );

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 40 + MediaQuery.paddingOf(context).bottom),
        child: Reveal(
          children: [
            Align(alignment: Alignment.centerLeft, child: TapText(tr.backToLedger, () => app.go('home'))),
            Padding(padding: const EdgeInsets.only(top: 24), child: kicker(monthYearCaps(pm))),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(tr.setupTitle, style: serif(26, h: 1.3)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Column(
                spacing: 12,
                children: [
                  field(tr.income, tr.incomeHint, income, (v) => app.update(() => app.income = v), ok(.93, .04, 155)),
                  field(
                    tr.savingGoal,
                    tr.savingHint,
                    app.save,
                    (v) => app.update(() {
                      app.save = v;
                      app.rule = false;
                    }),
                    ok(.94, .035, 10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: ok(.99, .006, 140, .8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ok(.9, .025, 150)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              Text(tr.ruleTitle, style: sans(13, w: FontWeight.w700)),
                              Text(tr.ruleBody, style: sans(12, h: 1.45, c: sub)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: app.toggleRule,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: app.rule ? ok(.93, .04, 155) : green, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              app.rule ? tr.applied : tr.apply,
                              style: sans(14, w: FontWeight.w700, c: app.rule ? ink : onGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (app.rule)
                      Column(
                        children: [
                          for (final (pct, label, note, v) in [
                            ('50%', pillars['needs']!.name, fixed > income * .5 ? tr.fixedOverHalf : tr.fixedPart(fmt(fixed)), .5),
                            ('30%', tr.otherPillars, tr.shareAmongThree, .3),
                            ('20%', tr.savings, tr.becomesGoal, .2),
                          ])
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: ok(.93, .02, 150))),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    width: 38,
                                    child: Text(pct, style: serif(15, w: FontWeight.w700)),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 1,
                                      children: [
                                        Text(label, style: sans(14)),
                                        Text(note, style: sans(12, c: sub)),
                                      ],
                                    ),
                                  ),
                                  Text(fmt((income * v).round()), style: serif(16)),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(color: ok(.95, .025, 150), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text(tr.fixedTitle, style: sans(13, w: FontWeight.w700)),
                              Text(tr.fixedHint, style: sans(12, c: sub)),
                            ],
                          ),
                          Text(fmt(fixed), style: serif(24, w: FontWeight.w700)),
                        ],
                      ),
                    ),
                    for (final r in app.fixed) _FixedRow(r, key: ValueKey(r.id)),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: TapText(
                        tr.addFixed,
                        () => app.update(() => app.fixed.add(Fixed(DateTime.now().millisecondsSinceEpoch, tr.newItem, 0))),
                        style: sans(14, w: FontWeight.w700, c: ok(.4, .06, 160)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12), child: _Budgets()),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: CustomPaint(
                foregroundPainter: Dashed(ok(.78, .05, 150), 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: BoxDecoration(color: ok(.99, .006, 140, .7), borderRadius: BorderRadius.circular(20)),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(tr.mindful, style: sans(14, w: FontWeight.w700)),
                          Text(tr.perWeek(fmt((avail * 7 / app.dim).round())), style: sans(13, c: ok(.45, .03, 160))),
                        ],
                      ),
                      Text(fmt(avail), style: serif(32, w: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Align(alignment: Alignment.centerRight, child: Btn(tr.startMonth(monthName(pm)), () => app.go('home'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedRow extends StatelessWidget {
  const _FixedRow(this.r, {super.key});
  final Fixed r;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: card)),
    ),
    child: Row(
      spacing: 8,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: r.name,
            onChanged: (v) => app.update(() => r.name = v),
            style: sans(15),
            decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6)),
          ),
        ),
        SizedBox(
          width: 80,
          child: NumField(r.amt, (v) => app.update(() => r.amt = v), style: serif(16), align: TextAlign.right, fill: card),
        ),
        Text(currency, style: serif(15)),
        Semantics(
          button: true,
          label: tr.remove(r.name),
          child: InkResponse(
            onTap: () => app.update(() => app.fixed.remove(r)),
            radius: 22,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: Text('×', style: sans(20, c: ok(.38, .04, 160))),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Monthly budget per pillar: split automatically from what is available until the user types one.
class _Budgets extends StatelessWidget {
  const _Budgets();

  @override
  Widget build(BuildContext context) {
    watch(context);
    final auto = app.budgets == null, gap = app.available - app.budgeted, sub = ok(.42, .03, 160);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: ok(.99, .006, 140, .8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ok(.9, .025, 150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(tr.budgetsTitle, style: sans(13, w: FontWeight.w700)),
          Text(auto ? tr.budgetsAuto : tr.budgetsMine, style: sans(12, c: sub)),
          const SizedBox(height: 4),
          for (final MapEntry(:key, value: p) in pillars.entries)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ok(.93, .02, 150))),
              ),
              child: Row(
                spacing: 10,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      p.kanji,
                      textAlign: TextAlign.center,
                      style: serif(20, c: p.ink),
                    ),
                  ),
                  Expanded(child: Text(p.name, style: sans(15))),
                  SizedBox(
                    width: 90,
                    child: NumField(app.budget(key), (v) => app.setBudget(key, v), style: serif(16), align: TextAlign.right, fill: ok(.95, .025, 150)),
                  ),
                  Text(currency, style: serif(15)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            auto || gap.abs() < 1
                ? tr.allAssigned
                : gap > 0
                ? tr.toAssign(fmt(gap))
                : tr.overBy(fmt(-gap)),
            style: sans(13, w: FontWeight.w700, c: gap < -.5 && !auto ? sealRed : sub),
          ),
          if (!auto)
            TapText(
              tr.splitAgain,
              app.autoBudgets,
              style: sans(14, w: FontWeight.w700, c: ok(.4, .06, 160)),
            ),
        ],
      ),
    );
  }
}

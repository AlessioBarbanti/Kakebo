import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/month_setup/month_start.dart' show FixedList;
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/animations/swipe.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/shared/widgets/inputs.dart';
import 'package:kakebo/state/kakebo.dart';

/// The book, its four pillars, its four questions, then the month's setup answering the first two.
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  // One print per step, all from Hiroshige's One Hundred Famous Views of Edo (baked by tool/art.py), each framed on its subject:
  // Fuji over Suruga-chō, the plum of the four gentlemen, the questions' moon, autumn maples for the month ahead.
  static const _prints = [('suruga', Alignment(0, -.5)), ('plum', Alignment(0, -.8)), ('kyobashi', Alignment(0, -.8)), ('mama', Alignment(0, -1))];
  static const _kanji = ['家計簿', '四君子', '四問'];
  static const _setup = 3;
  final _scroll = ScrollController();
  int step = 0;
  double _drag = 0;

  Kakebo get app => AppScope.read(context);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void goStep(int n) {
    if (n < 0 || n > _setup || n == step) return;
    setState(() => step = n);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void finish() => app.update(() {
    app.onboarded = true;
    app.screen = 'home';
  });

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final h = MediaQuery.sizeOf(context).height, setup = step == _setup;
    final motion = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 700);
    // One grid for every step: the print's band, and the title block at the same height below it.
    // The setup's band is shorter, to make room for its answers.
    final band = h * (setup ? .30 : .51), top = h * (setup ? .20 : .37);
    return ColoredBox(
      color: bg,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (_) => _drag = 0,
                  onHorizontalDragUpdate: (d) => _drag += d.delta.dx,
                  onHorizontalDragEnd: (e) => goStep(step - fling(e, _drag, 60)), // never past the setup: only its button starts the month
                  child: SingleChildScrollView(
                    controller: _scroll,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ExcludeSemantics(
                            child: AnimatedContainer(
                              duration: motion,
                              curve: Curves.easeInOut,
                              height: band,
                              // Prints cross-fade in place: the new one over the old, which stays until it is covered.
                              child: AnimatedSwitcher(
                                duration: motion,
                                switchOutCurve: const Threshold(0),
                                layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
                                child: _print(_prints[step]),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedContainer(duration: motion, curve: Curves.easeInOut, height: top),
                              Text('家計簿 · KAKEBO', style: serif(13, ls: 1.82, c: ok(.45, .08, 10))),
                              const SizedBox(height: 20),
                              // The words leave first, then the next ones come in where they were.
                              AnimatedSwitcher(
                                duration: motion,
                                switchInCurve: const Interval(.35, 1, curve: Curves.easeOut),
                                switchOutCurve: const Interval(.65, 1, curve: Curves.easeIn),
                                layoutBuilder: (current, previous) => Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
                                child: KeyedSubtree(key: ValueKey(step), child: _content(app)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!setup)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 12, 0),
                        child: TextButton(
                          onPressed: () => goStep(_setup),
                          style: TextButton.styleFrom(
                            backgroundColor: bg.withValues(alpha: .85),
                            foregroundColor: ink,
                            minimumSize: const Size(64, 40),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(tr.skip, style: sans(14, c: ink)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _footer(app),
        ],
      ),
    );
  }

  /// The same crop and fade on every print: full colour at the top, gone into the page's bg by the band's end.
  /// The print itself fades (a mask, not a bg overlay), so no row of it shows at a fractional band edge.
  Widget _print((String, Alignment) print) => ShaderMask(
    key: ValueKey(print),
    blendMode: BlendMode.dstIn,
    shaderCallback: (bounds) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Color(0x26FFFFFF), Color(0x00FFFFFF)],
      stops: [.35, .72, 1],
    ).createShader(bounds),
    child: Image.asset(
      'assets/art/print_${print.$1}.webp',
      fit: BoxFit.cover,
      alignment: print.$2,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox(),
    ),
  );

  Widget _content(Kakebo app) {
    final setup = step == _setup, pm = app.planMonth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(setup ? kanjiMesi[pm.month - 1] : _kanji[step], style: serif(44, h: 1, c: green)),
        const SizedBox(height: 16),
        Semantics(header: true, child: Text(setup ? tr.setupTitle(monthName(pm)) : tr.steps[step].title, style: serif(28, h: 1.25))),
        const SizedBox(height: 10),
        Text(setup ? tr.setupFirst : tr.steps[step].body, style: sans(15, h: 1.6, c: muted)),
        if (step > 0) const SizedBox(height: 20),
        if (step == 1) _rows([for (final p in pillars.values) (Text(p.kanji, style: serif(22, c: p.ink)), Text(p.virtue, style: sans(15, h: 1.4)))]),
        if (step == 2) _rows([for (final (i, q) in tr.fourQuestions.indexed) (_number(i), Text(q, style: sans(15, h: 1.4)))]),
        if (setup) ..._answers(app),
      ],
    );
  }

  Widget _number(int i) => Text('${i + 1}', style: serif(22, c: ink));

  /// Plain rows between hairlines: a glyph (pillar kanji or question number) and its words.
  Widget _rows(List<(Widget, Widget)> rows) => Column(
    children: [
      for (final (glyph, child) in rows)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 14,
            children: [
              SizedBox(width: 28, child: Center(child: glyph)),
              Expanded(child: child),
            ],
          ),
        ),
      Divider(height: 1, thickness: 1, color: line),
    ],
  );

  /// The first two questions answered: income (fixed costs folded under it) and the savings goal.
  List<Widget> _answers(Kakebo app) {
    Widget answer(String question, double value, ValueChanged<double> set, String hint, [Widget? more]) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(question, style: sans(15, h: 1.4)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 8,
          children: [
            Expanded(
              child: NumField(value, set, style: serif(24, w: FontWeight.w700)),
            ),
            Text(currency, style: serif(20)),
          ],
        ),
        Text(hint, style: sans(12, h: 1.4, c: muted)),
        ?more,
      ],
    );
    return [
      _rows([
        (
          _number(0),
          answer(
            tr.fourQuestions[0],
            app.income,
            (v) => app.update(() => app.income = v),
            tr.incomeHint,
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: muted,
              collapsedIconColor: muted,
              title: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(tr.fixedTitle, style: sans(14, c: muted)),
                  Text(fmt(app.fixedTotal), style: serif(16, w: FontWeight.w700)),
                ],
              ),
              children: const [FixedList()],
            ),
          ),
        ),
        (
          _number(1),
          answer(
            tr.fourQuestions[1],
            app.save,
            (v) => app.update(() {
              app.save = v;
              app.rule = false;
            }),
            tr.savingHint,
          ),
        ),
      ]),
    ];
  }

  /// Progress, then Back always on the left and the main button always on the right, the same width until the last.
  /// On the setup, what is left to spend stays in view above its button, however long the form grows.
  Widget _footer(Kakebo app) {
    final avail = app.available;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 12,
              children: [
                Semantics(
                  label: tr.introProgress(step + 1, _setup + 1),
                  child: ExcludeSemantics(
                    child: Row(
                      spacing: 6,
                      children: [
                        for (var i = 0; i <= _setup; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: i == step ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(color: i == step ? green : ok(.85, .03, 150), borderRadius: BorderRadius.circular(3)),
                          ),
                      ],
                    ),
                  ),
                ),
                if (step == _setup)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          tr.mindful,
                          textAlign: TextAlign.end,
                          style: sans(12, c: muted),
                        ),
                        Text(fmt(avail), style: serif(24, w: FontWeight.w700)),
                        Text(
                          tr.perWeek(fmt((avail * 7 / app.dim).round())),
                          textAlign: TextAlign.end,
                          style: sans(12, c: muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Bottom-aligned: a button that wraps at large text grows upward and Back stays put.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 12,
              children: [
                // Both give way at large text, the button twice as much room as Back.
                if (step > 0)
                  Flexible(
                    child: TapText(tr.back, () => goStep(step - 1), style: sans(15, c: muted)),
                  )
                else
                  const SizedBox(),
                Flexible(
                  flex: 2,
                  child: FilledButton(
                    onPressed: step == _setup ? finish : () => goStep(step + 1),
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: onGreen,
                      minimumSize: const Size(148, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      step == _setup ? tr.startMonth(monthName(app.planMonth)) : tr.next,
                      textAlign: TextAlign.center,
                      style: sans(15, w: FontWeight.w700, c: onGreen),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

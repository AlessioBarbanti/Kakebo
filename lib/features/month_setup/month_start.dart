import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/fixed_expense.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/animations/reveal.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/shared/widgets/dashed.dart';
import 'package:kakebo/shared/widgets/inputs.dart';

class MonthStart extends StatelessWidget {
  const MonthStart({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
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
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    return Container(
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
}

/// Monthly budget per pillar: split automatically from what is available until the user types one.
class _Budgets extends StatelessWidget {
  const _Budgets();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
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

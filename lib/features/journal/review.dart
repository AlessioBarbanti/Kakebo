import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/journal/reflection_field.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/shared/animations/reveal.dart';
import 'package:kakebo/shared/illustrations/branch.dart';
import 'package:kakebo/shared/illustrations/hanko.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';

class Review extends StatelessWidget {
  const Review({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final s = app.season, mk = monthKey(app.label), month = monthName(app.label), next = monthName(app.nextMonth), sealed = app.isSealed;
    final questions = [
      (tr.fourQuestions[0], fmt(app.income - app.fixedTotal), tr.incomeMinusFixed),
      (tr.fourQuestions[1], fmt(app.save), tr.goalFor(month)),
      (tr.fourQuestions[2], fmt(app.spent), tr.acrossPillars),
    ];
    final dim = ok(.34, .04, 160);

    return Reveal(
      spacing: 16,
      children: [
        Align(alignment: Alignment.centerLeft, child: TapText(tr.backToJournal, () => app.go('journal'))),
        heading(tr.reviewKicker, tr.reviewTitle),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: s.soft, borderRadius: BorderRadius.circular(28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              // Three different measures, each with its own name: what is left, the goal, the pace.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(tr.residualNow.toUpperCase(), style: sans(12, ls: 1.68, c: ok(.38, .04, 160))), // the calendar's label too
                  Text(fmt(app.onTrack), style: serif(36, w: FontWeight.w700)),
                  Text(tr.residualNote(fmt(app.save), fmt(app.left)), style: sans(13, h: 1.5, c: dim)),
                ],
              ),
              for (final (label, value) in [(tr.goal, fmt(app.save)), (tr.branchTitle, tr.flowers(app.bloomed))])
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .8))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(label, style: sans(14, w: FontWeight.w700)),
                      ),
                      Text(value, style: serif(17)),
                    ],
                  ),
                ),
              const Branch(height: 64),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(tr.paceExplanation, style: sans(13, c: dim)),
                children: [Text(tr.branchRule, style: sans(13, h: 1.5, c: dim))],
              ),
              if (sealed) Align(alignment: Alignment.centerRight, child: Hanko(app.label)),
            ],
          ),
        ),
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(tr.monthNumbers, style: serif(19)),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                for (final (i, (q, value, note)) in questions.indexed)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: ok(.95, .025, 150), borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          tr.question(i + 1),
                          style: sans(12, w: FontWeight.w700, c: ok(.4, .04, 160)),
                        ),
                        Text(q, style: serif(19, h: 1.35)),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(value, style: serif(28, w: FontWeight.w700)),
                        ),
                        Text(note, style: sans(13, c: ok(.42, .03, 160))),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ok(.88, .04, 150), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(tr.reflectionInvitation, style: sans(14, h: 1.5, c: muted)),
              for (final (field, title) in [('good', tr.monthGood), ('change', tr.monthChange), ('intention', tr.monthIntention)]) ...[
                const SizedBox(height: 12),
                ReflectionField(
                  key: ValueKey('$mk-$field'),
                  title: title,
                  value: field == 'intention' ? app.improve[mk] ?? '' : app.reflections[mk]?[field] ?? '',
                  onChanged: (v) => app.update(() {
                    if (field == 'intention') {
                      app.improve[mk] = v;
                    } else {
                      (app.reflections[mk] ??= {})[field] = v;
                    }
                  }),
                ),
              ],
              Text(tr.reflectionAutosaved, style: sans(12, h: 1.5, c: muted)),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Btn(
            sealed ? tr.plan(next) : tr.sealMonth(month),
            sealed ? () => app.go('monthStart') : app.seal,
            color: sealed ? green : sealRed,
            pad: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          ),
        ),
      ],
    );
  }
}

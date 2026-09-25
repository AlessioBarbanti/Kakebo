import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
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
import 'package:kakebo/shared/widgets/inputs.dart';

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
      spacing: 24,
      children: [
        Align(alignment: Alignment.centerLeft, child: TapText(tr.backToJournal, () => app.go('journal'))),
        heading(tr.reviewKicker, tr.reviewTitle),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: s.soft, borderRadius: BorderRadius.circular(28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(tr.soFar(month.toUpperCase()), style: sans(12, ls: 1.68, c: ok(.38, .04, 160))),
                      Text(fmt(app.onTrack), style: serif(44, w: FontWeight.w700)),
                    ],
                  ),
                  Text(tr.towardSaving(fmt(app.save)), style: sans(14, c: dim)),
                ],
              ),
              const Branch(height: 110),
              Text(tr.flowerWorth(fmt(app.save / 10), fmt(app.bloomed * app.save / 10), fmt(app.save)), style: sans(13, c: dim)),
              if (sealed) Align(alignment: Alignment.centerRight, child: Hanko(app.label)),
            ],
          ),
        ),
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
              Text(
                tr.question(4),
                style: sans(12, w: FontWeight.w700, c: ok(.4, .04, 160)),
              ),
              Text(tr.fourQuestions[3], style: serif(19, h: 1.35)),
              TextFormField(
                initialValue: app.improve[mk] ?? '',
                onChanged: (v) => app.update(() => app.improve[mk] = v),
                minLines: 4,
                maxLines: null,
                style: sans(15, h: 1.6),
                decoration: softInput(tr.smallResolution(next), ok(.96, .02, 150), 14, const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              ),
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

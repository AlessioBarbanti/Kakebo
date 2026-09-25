import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/animations/reveal.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/state/kakebo.dart';

/// Diary history, newest first: evening thoughts, Sunday recaps of this month, sealed months.
List<(String, String, String, Color)> _timeline(Kakebo app) {
  final items = <(DateTime, String, String, String, Color)>[];
  final now = app.now, today = DateTime(now.year, now.month, now.day);
  app.thoughts.forEach((k, v) {
    final d = DateTime.parse(k);
    items.add((d, tr.eveningThought, k == dateKey(now) ? tr.today : shortDay(d), v, ok(.72, .06, 295)));
  });
  if (app.flags['weekly']!) {
    final first = app.period.start, budget = app.available * 7 / app.dim;
    for (var mon = DateTime(first.year, first.month, first.day - first.weekday + 1); ; mon = DateTime(mon.year, mon.month, mon.day + 7)) {
      final sun = DateTime(mon.year, mon.month, mon.day + 6);
      if (!sun.isBefore(today)) break;
      final list = app.entries.where((e) => !e.date.isBefore(mon) && !e.date.isAfter(sun)).toList(), total = sum(list);
      final by = Kakebo.spentBy(list).entries.reduce((a, b) => b.value > a.value ? b : a);
      final quiet = List.generate(7, (i) => DateTime(mon.year, mon.month, mon.day + i)).where((d) => !list.any((e) => e.date == d)).length;
      items.add((
        sun,
        tr.week('${dayMonth(mon)} – ${dayMonth(sun)}'),
        fmt(total),
        total == 0 ? tr.weekNoSpending : tr.weekText(total <= budget, pillars[by.key]!.name, quiet),
        app.season.ink,
      ));
    }
  }
  app.sealed.forEach((mk, saved) {
    final m = DateTime.parse('$mk-01'), next = DateTime(m.year, m.month + 1), goal = (app.improve[mk] ?? '').trim();
    items.add((
      app.periodFor(m).last,
      tr.questionsOf(monthName(m)),
      tr.sealedSaved(fmt(saved)),
      goal.isEmpty ? tr.monthClosed : tr.resolutionFor(monthName(next), goal),
      sealRed,
    ));
  });
  items.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, kind, meta, text, dot) in items.take(20)) (kind, meta, text, dot)];
}

class Journal extends StatelessWidget {
  const Journal({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final t = app.thoughtToday, at = clock(context, app.thoughtTime);
    Widget diary(String title, String when, String status, Color statusFg, String preview, Color color, String to) => GestureDetector(
      onTap: () => app.go(to),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: 10,
              children: [
                Flexible(child: Text(title, style: serif(20))),
                Text(
                  status,
                  style: sans(13, w: FontWeight.w700, c: statusFg),
                ),
              ],
            ),
            Text(when, style: sans(13, c: ok(.38, .03, 160))),
            Text(
              preview,
              style: serif(16, w: FontWeight.w500, h: 1.55, c: ok(.3, .03, 160)),
            ),
          ],
        ),
      ),
    );

    return Reveal(
      spacing: 14,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              heading(tr.journalKicker, tr.journalTitle),
              Text(tr.journalIntro, style: sans(14, h: 1.55, c: muted)),
            ],
          ),
        ),
        diary(
          tr.eveningThought,
          tr.everyDayAt(at),
          t != null ? tr.written : tr.toWrite,
          t != null ? ok(.4, .08, 155) : ok(.38, .05, 295),
          t != null
              ? '“$t”'
              : app.evening
              ? tr.eveningNow
              : tr.opensAt(at),
          ok(.955, .02, 295),
          'thought',
        ),
        diary(
          tr.theMonth,
          tr.questionsFrom(dayMonth(app.period.last)),
          app.isSealed ? tr.sealed : tr.open,
          ok(.48, .15, 28),
          app.isSealed ? tr.monthSealed(monthTitle(app.label)) : tr.questionsHint,
          ok(.95, .025, 28),
          'review',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                child: Text(tr.timeline, style: serif(18)),
              ),
              for (final (kind, meta, text, color) in _timeline(app))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14,
                      children: [
                        SizedBox(
                          width: 12,
                          child: Column(
                            children: [
                              Padding(padding: const EdgeInsets.only(top: 5), child: dot(10, color)),
                              Expanded(
                                child: Container(width: 2, margin: const EdgeInsets.only(top: 4), color: ok(.9, .02, 150)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 4,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      kind,
                                      style: sans(12, w: FontWeight.w700, c: muted),
                                    ),
                                    Text(meta, style: sans(12, c: muted)),
                                  ],
                                ),
                                Text(text, style: sans(15, h: 1.55)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

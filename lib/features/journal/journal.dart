import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/journal/reflection_field.dart';
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
List<(String, String, String, Color, String?)> _timeline(Kakebo app) {
  final items = <(DateTime, String, String, String, Color, String?)>[];
  final now = app.now, today = DateTime(now.year, now.month, now.day);
  app.thoughts.forEach((k, v) {
    final d = DateTime.parse(k);
    items.add((d, tr.eveningThought, k == dateKey(now) ? tr.today : shortDay(d), v, ok(.72, .06, 295), null));
  });
  if (app.flags['weekly']!) {
    final first = app.period.start;
    for (var mon = DateTime(first.year, first.month, first.day - first.weekday + 1); ; mon = DateTime(mon.year, mon.month, mon.day + 7)) {
      final sun = DateTime(mon.year, mon.month, mon.day + 6);
      if (!sun.isBefore(today)) break;
      final list = app.entries.where((e) => !e.date.isBefore(mon) && !e.date.isAfter(sun)).toList(), total = sum(list);
      final by = Kakebo.spentBy(list).entries.reduce((a, b) => b.value > a.value ? b : a);
      items.add((
        sun,
        tr.week('${dayMonth(mon)} – ${dayMonth(sun)}'),
        fmt(total),
        total == 0 ? tr.weekNoSpending : tr.weekFullest(pillars[by.key]!.name),
        app.season.ink,
        dateKey(sun),
      ));
    }
  }
  for (final mk in {...app.sealed.keys, ...app.reflections.keys, ...app.improve.keys}) {
    final saved = app.sealed[mk];
    if (saved == null && (mk == monthKey(app.label) || ![app.improve[mk] ?? '', ...?app.reflections[mk]?.values].any((v) => v.trim().isNotEmpty))) continue;
    final m = DateTime.parse('$mk-01'), next = DateTime(m.year, m.month + 1), goal = (app.improve[mk] ?? '').trim();
    items.add((
      app.periodFor(m).last,
      tr.questionsOf(monthName(m)),
      saved == null ? tr.reflectionMemory : tr.sealedSaved(fmt(saved)),
      [
        if ((app.reflections[mk]?['good'] ?? '').trim().isNotEmpty) '${tr.monthGood}\n${app.reflections[mk]!['good']}',
        if ((app.reflections[mk]?['change'] ?? '').trim().isNotEmpty) '${tr.monthChange}\n${app.reflections[mk]!['change']}',
        goal.isEmpty ? tr.monthClosed : tr.resolutionFor(monthName(next), goal),
      ].join('\n\n'),
      sealRed,
      null,
    ));
  }
  // Keep written weekly reflections accessible after the budgeting month changes.
  for (final e in app.weeklyReflections.entries) {
    if (e.value.trim().isEmpty || items.any((item) => item.$6 == e.key)) continue;
    final sun = DateTime.parse(e.key);
    final mon = DateTime(sun.year, sun.month, sun.day - 6);
    items.add((sun, tr.week('${dayMonth(mon)} – ${dayMonth(sun)}'), '', '', app.season.ink, e.key));
  }
  items.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, kind, meta, text, dot, week) in items) (kind, meta, text, dot, week)];
}

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  int visibleMemories = 20;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final memories = _timeline(app);
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
        if (app.currentIntention.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(tr.intentionForThisMonth, style: serif(19)),
                Text(app.currentIntention, style: sans(15, h: 1.6)),
                Text(tr.intentionGentle, style: sans(13, h: 1.5, c: muted)),
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
              for (final (kind, meta, text, color, week) in memories.take(visibleMemories))
                Padding(
                  key: week == null ? null : ValueKey('week-$week'),
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
                                if (text.isNotEmpty) Text(text, style: sans(15, h: 1.55)),
                                if (week != null)
                                  ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    shape: const Border(),
                                    collapsedShape: const Border(),
                                    title: Text(tr.weekReflection, style: sans(14, c: muted)),
                                    subtitle: (app.weeklyReflections[week] ?? '').trim().isEmpty
                                        ? null
                                        : Text(app.weeklyReflections[week]!, maxLines: 2, overflow: TextOverflow.ellipsis, style: sans(14, h: 1.5)),
                                    children: [
                                      ReflectionField(
                                        key: ValueKey('reflection-$week'),
                                        title: tr.weekReflectionPrompt,
                                        value: app.weeklyReflections[week] ?? '',
                                        onChanged: (v) => app.update(() => app.weeklyReflections[week] = v),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(tr.reflectionAutosaved, style: sans(12, c: muted)),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (memories.length > visibleMemories) Center(child: TapText(tr.moreMemories, () => setState(() => visibleMemories += 20))),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
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

/// How deep a day's shade is, 0 to 1: what went on wants, culture and the unexpected against their daily share of the month
/// (twice the share or more is the deepest). Needs stay out, so the weekly shop is not a heavy day; with no share left,
/// any such spending shows in full.
double dayShade(Iterable<Entry> day, double share) {
  final free = sum(day.where((e) => e.p != 'needs'));
  if (free == 0) return 0;
  return share <= 0 ? 1 : math.min(1, free / share / 2);
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Kakebo get app => AppScope.read(context);
  String view = 'month';
  late DateTime selDay = DateTime(app.now.year, app.now.month, app.now.day);
  late int selMonth = app.label.month - 1;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    return Reveal(
      spacing: 24,
      children: [
        heading(
          tr.calendarKicker,
          view == 'year'
              ? '${app.label.year}'
              : app.monthStart == 1
              ? monthTitle(app.label)
              : '${dayMonth(app.period.start)} – ${dayMonth(app.period.last)}',
        ),
        Align(alignment: Alignment.centerLeft, child: segmented([('month', tr.month), ('year', tr.year)], view, (k) => setState(() => view = k))),
        view == 'year' ? _year() : _month(),
      ],
    );
  }

  Widget _month() {
    // The grid shows the current budgeting month, which may run e.g. from the 27th to the 26th.
    final now = app.now, today = DateTime(now.year, now.month, now.day), first = app.period.start, offset = first.weekday - 1;
    final cells = ((offset + app.dim) / 7).ceil() * 7;
    final byDay = <String, List<Entry>>{};
    for (final e in app.month) {
      byDay.putIfAbsent(dateKey(e.date), () => []).add(e);
    }
    final sel = byDay[dateKey(selDay)] ?? [];
    // A day says how it went against the rhythm, never whether it was good: a green shade for the free pillars
    // against their daily share (dayShade), no red and no figures. What was spent is in the day's card, a tap away.
    final share = pillars.keys.where((k) => k != 'needs').fold(0.0, (a, k) => a + app.budget(k)) / app.dim;
    final shade = ok(.6, .09, 155);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Container(
          // No inner padding or column gaps: seven 48 dp targets fit at 360 wide.
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(26), boxShadow: shadow),
          child: Column(
            children: [
              Row(
                children: [
                  for (final w in weekdayLetters)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          w,
                          textAlign: TextAlign.center,
                          style: sans(12, c: ok(.45, .04, 160)),
                        ),
                      ),
                    ),
                ],
              ),
              GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: math.max(52, MediaQuery.textScalerOf(context).scale(20) + 30),
                  mainAxisSpacing: 2,
                ),
                children: [
                  for (var i = 0; i < cells; i++)
                    if (i < offset || i - offset >= app.dim)
                      const SizedBox()
                    else
                      () {
                        final d = DateTime(first.year, first.month, first.day + i - offset), day = byDay[dateKey(d)] ?? [], t = sum(day), isSel = d == selDay;
                        return Semantics(
                          button: true,
                          selected: isSel,
                          label: t == 0 ? dayLabel(d) : '${dayLabel(d)}, ${fmt(t)}',
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => selDay = d),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel ? green : shade.withValues(alpha: .45 * dayShade(day, share)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: d == today && !isSel ? ok(.62, .1, 10) : Colors.transparent, width: 1.5),
                              ),
                              child: Text(
                                '${d.day}',
                                textAlign: TextAlign.center,
                                style: sans(
                                  16,
                                  c: isSel
                                      ? onGreen
                                      : d.isAfter(today)
                                      ? ok(.55, .02, 160)
                                      : ink,
                                ),
                              ),
                            ),
                          ),
                        );
                      }(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    Container(
                      width: 22,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(colors: [shade.withValues(alpha: .08), shade.withValues(alpha: .45)]),
                      ),
                    ),
                    Flexible(
                      child: Text(tr.dayShade, style: sans(12, c: muted)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: ok(.95, .025, 150), borderRadius: BorderRadius.circular(26)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(child: Text(dayLabel(selDay), style: serif(20))),
                  Text(fmt(sum(sel)), style: serif(17, c: ok(.42, .04, 160))),
                ],
              ),
              const SizedBox(height: 8),
              for (final e in sel)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openAdd(context, edit: e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: card)),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: e.pillar.soft, shape: BoxShape.circle),
                          child: Text(e.pillar.kanji, style: serif(14, c: e.pillar.ink)),
                        ),
                        Expanded(child: Text(e.note, style: sans(15))),
                        Text(fmt(e.amt), style: serif(16)),
                      ],
                    ),
                  ),
                ),
              if (sel.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    spacing: 14,
                    children: [
                      Image.asset(pillars.values.elementAt(selDay.day % 4).art, width: 64, height: 64, excludeFromSemantics: true),
                      Expanded(
                        child: Text(tr.quietDay, style: sans(15, h: 1.5, c: ok(.45, .03, 160))),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _year() {
    final now = app.now, year = app.label.year, avail = app.available;
    // ponytail: past months use today's income and fixed costs unless sealed; store a monthly snapshot if those change often.
    final months = [
      for (var i = 0; i < 12; i++)
        () {
          final m = DateTime(year, i + 1), p = app.periodFor(m), list = app.inPeriod(p), mk = monthKey(m), current = mk == monthKey(app.label);
          if (p.start.isAfter(now) || (!current && list.isEmpty && !app.sealed.containsKey(mk))) {
            return null;
          }
          final total = sum(list);
          return (
            by: Kakebo.spentBy(list),
            total: total,
            current: current,
            saved: current ? app.onTrack : app.sealed[mk] ?? math.max(0.0, app.income - app.fixedTotal - total),
          );
        }(),
    ];
    final sm = months[selMonth], se = seasonOf(selMonth);
    // Each month is its spending against what was available: the pale column is the available, the narrow fill what went,
    // rising above the column when it went over. Pillars wait in the month's card, a tap away.
    final top = [avail, for (final m in months) ?m?.total].reduce(math.max), track = ok(.93, .02, 150), fill = ok(.56, .08, 155);
    double h(double v) => v / (top == 0 ? 1 : top) * 170;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(26), boxShadow: shadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              SizedBox(
                height: 210,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 4,
                  children: [
                    for (final (i, m) in months.indexed)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: selMonth == i,
                          label: m == null ? monthTitle(DateTime(year, i + 1)) : tr.spentOf(monthTitle(DateTime(year, i + 1)), fmt(m.total), fmt(avail)),
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => selMonth = i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              spacing: 6,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: m == null ? 6 : math.max(6, h(avail)),
                                      decoration: BoxDecoration(
                                        color: track,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: selMonth == i ? [BoxShadow(color: green, spreadRadius: 2)] : null,
                                      ),
                                    ),
                                    if (m != null && m.total > 0)
                                      FractionallySizedBox(
                                        widthFactor: .5,
                                        child: Container(
                                          height: math.max(4, h(m.total)),
                                          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(6)),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(monthLetter(i + 1), style: sans(12, w: selMonth == i ? FontWeight.w700 : FontWeight.w400)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (final (color, label) in [(track, tr.availableLabel), (fill, tr.spentLabel)])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        dot(10, color, radius: 3),
                        Text(label, style: sans(12, c: muted)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: se.soft, borderRadius: BorderRadius.circular(26)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${monthTitle(DateTime(year, selMonth + 1))} $year', style: serif(22)),
                  Text(se.plant, style: serif(20, c: se.ink)),
                ],
              ),
              if (sm != null)
                for (final MapEntry(:key, value: p) in pillars.entries)
                  Row(
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          p.kanji,
                          textAlign: TextAlign.center,
                          style: serif(16, c: p.ink),
                        ),
                      ),
                      Expanded(
                        child: Text(p.name, style: sans(14, c: muted)),
                      ),
                      Text(fmt(sm.by[key]!), style: serif(15)),
                    ],
                  ),
              if (sm != null)
                for (final (label, value) in [(tr.spentInPillars, sm.total), (sm.current ? tr.residualNow : tr.savedLabel, sm.saved), (tr.goal, app.save)])
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .8))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: sans(14)),
                        Text(fmt(value), style: serif(16)),
                      ],
                    ),
                  ),
              Text(
                sm == null
                    ? app.periodFor(DateTime(year, selMonth + 1)).start.isAfter(now)
                          ? tr.monthAhead
                          : tr.monthEmpty
                    : sm.current
                    ? tr.monthNow
                    : sm.saved >= app.save
                    ? tr.monthReached
                    : tr.missedBy(fmt(app.save - sm.saved)),
                style: sans(13, h: 1.5, c: ok(.36, .03, 160)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

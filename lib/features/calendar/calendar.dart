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
    // A day's mark says how much, never whether it was good: no red, and the legend below says where the step is.
    final light = ok(.7, .07, 150), deep = ok(.45, .08, 155);

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
                        final d = DateTime(first.year, first.month, first.day + i - offset), t = sum(byDay[dateKey(d)] ?? []), isSel = d == selDay;
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
                                color: isSel ? green : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: d == today && !isSel ? ok(.62, .1, 10) : Colors.transparent, width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 5,
                                children: [
                                  Text(
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
                                  dot(
                                    t > 50 ? 8 : 6,
                                    t == 0
                                        ? Colors.transparent
                                        : isSel
                                        ? onGreen.withValues(alpha: t > 50 ? 1 : .6)
                                        : t > 50
                                        ? deep
                                        : light,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 6,
                  children: [
                    for (final (size, color, label) in [(6.0, light, tr.dayWithSpending), (8.0, deep, tr.dayOver(fmt(50)))])
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          dot(size, color),
                          Text(label, style: sans(12, c: muted)),
                        ],
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
    final now = app.now, year = app.label.year, keys = pillars.keys.toList();
    // ponytail: past months use today's income and fixed costs unless sealed; store a monthly snapshot if those change often.
    final months = [
      for (var i = 0; i < 12; i++)
        () {
          final m = DateTime(year, i + 1), p = app.periodFor(m), list = app.inPeriod(p), mk = monthKey(m), current = mk == monthKey(app.label);
          if (p.start.isAfter(now) || (!current && list.isEmpty && !app.sealed.containsKey(mk))) {
            return null;
          }
          final by = Kakebo.spentBy(list), total = sum(list);
          return (
            by: [for (final k in keys) by[k]!],
            total: total,
            current: current,
            saved: current ? app.onTrack : app.sealed[mk] ?? math.max(0.0, app.income - app.fixedTotal - total),
          );
        }(),
    ];
    final sm = months[selMonth], se = seasonOf(selMonth);

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
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => selMonth = i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: 6,
                            children: [
                              () {
                                final h = math.max(6.0, (m?.total ?? 0) / 1500 * 170);
                                return Container(
                                  width: 34,
                                  height: h,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: ok(.94, .02, 150),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: selMonth == i ? [BoxShadow(color: green, spreadRadius: 2)] : null,
                                  ),
                                  child: Column(
                                    verticalDirection: VerticalDirection.up,
                                    children: [
                                      if (m != null)
                                        for (final (k, v) in m.by.indexed)
                                          Container(height: h * v / (m.total == 0 ? 1 : m.total), color: pillars[keys[k]]!.ink),
                                    ],
                                  ),
                                );
                              }(),
                              dot(
                                8,
                                m == null
                                    ? Colors.transparent
                                    : m.current
                                    ? ok(.8, .03, 150)
                                    : m.saved >= app.save
                                    ? sealRed
                                    : ok(.85, .01, 160),
                              ),
                              Text(monthLetter(i + 1), style: sans(12, w: selMonth == i ? FontWeight.w700 : FontWeight.w400)),
                            ],
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
                  for (final p in pillars.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        dot(10, p.ink, radius: 3),
                        Text(p.name, style: sans(12, c: muted)),
                      ],
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      dot(8, sealRed),
                      Text(tr.goalReached, style: sans(12, c: muted)),
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
                for (final (label, value) in [(tr.spentInPillars, sm.total), (sm.current ? tr.onTrack : tr.savedLabel, sm.saved), (tr.goal, app.save)])
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

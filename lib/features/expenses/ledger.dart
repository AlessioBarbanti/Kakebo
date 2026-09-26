import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/animations/reveal.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/state/kakebo.dart';

class Ledger extends StatefulWidget {
  const Ledger({super.key});

  @override
  State<Ledger> createState() => _LedgerState();
}

class _LedgerState extends State<Ledger> {
  Kakebo get app => AppScope.read(context);
  String range = 'month';
  String? open;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final week = range == 'week', list = week ? app.week : app.month;
    final by = Kakebo.spentBy(list), total = sum(list), share = 7 / app.dim;
    final budget = week ? app.available * share : app.available;

    return Reveal(
      spacing: 24,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 16,
          children: [
            heading(tr.ledgerKicker, tr.ledgerTitle),
            segmented([('week', tr.thisWeek), ('month', tr.thisMonth)], range, (k) => setState(() => range = k)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(26), boxShadow: shadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                children: [
                  Text(fmt(total), style: serif(34, w: FontWeight.w700)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(tr.ofAvailable(fmt(budget.round())), style: sans(14, c: ok(.42, .04, 160))),
                  ),
                ],
              ),
              Bar(
                [for (final MapEntry(:key, value: p) in pillars.entries) (by[key]! / (budget == 0 ? 1 : budget), p.ink)],
                height: 10,
                gap: 3,
                track: ok(.94, .02, 150),
              ),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  for (final p in pillars.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        dot(10, p.ink),
                        Text(p.name, style: sans(13)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        Column(
          spacing: 14,
          children: [for (final MapEntry(:key, value: p) in pillars.entries) _card(key, p, list, by[key]!, week ? app.budget(key) * share : app.budget(key))],
        ),
      ],
    );
  }

  Widget _card(String key, Pillar p, List<Entry> list, double spent, double b) {
    final sub = ok(.42, .03, 160), items = list.where((e) => e.p == key).toList(), isOpen = open == key;
    // Neutral card: the pillar's colour stays in its sprig, bar and marks.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24), boxShadow: shadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: isOpen,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => open = isOpen ? null : key),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Row(
                  spacing: 12,
                  children: [
                    Image.asset(p.art, width: 60, height: 60, excludeFromSemantics: true),
                    Expanded(
                      child: Column(
                        spacing: 7,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.name, style: sans(15, w: FontWeight.w700)),
                              Text(fmt(spent), style: serif(17)),
                            ],
                          ),
                          Container(
                            height: 6,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(3)),
                            child: FractionallySizedBox(
                              widthFactor: math.min(1, spent / b),
                              child: Container(
                                decoration: BoxDecoration(color: p.ink, borderRadius: BorderRadius.circular(3)),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(tr.leftOf(fmt(math.max(0, (b - spent).round())), fmt(b.round())), style: sans(12, c: sub)),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? .5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more, color: sub),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(86, 0, 48, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(tr.noneInPillar, style: sans(13, c: muted)),
                    ),
                  for (final e in items)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => openAdd(context, edit: e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: line)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            Flexible(child: Text('${dayMonth(e.date)} · ${e.note}', style: sans(14))),
                            Text(fmt(e.amt), style: serif(14)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

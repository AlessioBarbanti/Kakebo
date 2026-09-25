import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/animations/reveal.dart';
import 'package:kakebo/shared/illustrations/branch.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/state/kakebo.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final s = app.season, by = Kakebo.spentBy(app.month), avail = app.available, today = app.today;
    final rest = app.dim - app.day, perDay = (app.left / (rest < 1 ? 1 : rest)).floor();
    final pi = app.now.day % phrases.length, phrase = (phrases[pi].$1, phrases[pi].$2, tr.proverbs[pi]);
    final notice = app.flags['thoughtOn']! && app.thoughtToday == null && app.evening;

    return Reveal(
      spacing: 40,
      children: [
        if (notice)
          GestureDetector(
            onTap: () => app.go('thought'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ok(.95, .025, 295), borderRadius: BorderRadius.circular(24)),
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(radius: .707, colors: [ok(.99, .01, 295), ok(.88, .05, 295)], stops: const [0, .7]),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(tr.eveningThought, style: sans(12, c: ok(.4, .04, 290))),
                        Text(tr.happyQuestion, style: serif(19, h: 1.3)),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      tr.write,
                      style: sans(14, w: FontWeight.w700, c: onGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(tr.leftFor(monthName(app.label)), style: sans(14, c: muted)),
              Text(fmt(app.left), style: serif(56, w: FontWeight.w700, h: 1.05)),
              Text(rest < 1 ? tr.spendToday : tr.perDay(fmt(perDay), rest), style: sans(14, c: muted)),
              const SizedBox(height: 8),
              Bar([for (final MapEntry(:key, value: p) in pillars.entries) (by[key]! / (avail == 0 ? 1 : avail), p.ink)], height: 6, gap: 2, track: line),
              Text(tr.spentShare(app.spentPct), style: sans(12, c: ok(.42, .03, 160))),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => app.go('ledger'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(22), boxShadow: shadow),
            child: Row(
              children: [
                for (final MapEntry(:key, value: p) in pillars.entries)
                  Expanded(
                    child: Column(
                      spacing: 3,
                      children: [
                        Text(p.kanji, style: serif(22, c: p.ink)),
                        Text(p.name, style: sans(12, c: muted)),
                        Text(fmt(by[key]!.round()), style: serif(15)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                spacing: 8,
                children: [
                  Flexible(child: Text(tr.branchTitle, style: serif(18))),
                  Text(
                    tr.flowers(app.bloomed),
                    style: sans(13, w: FontWeight.w700, c: s.deep),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Branch()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(tr.branchRule(fmt(app.save / 10), fmt(app.bloomed * app.save / 10), fmt(app.save)), style: sans(13, h: 1.5, c: muted)),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.today, style: serif(18)),
                  TapText(
                    tr.addShort,
                    () => openAdd(context),
                    style: sans(14, w: FontWeight.w700, c: ok(.38, .06, 160)),
                  ),
                ],
              ),
            ),
            for (final e in today)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openAdd(context, edit: e),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: line)),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          e.pillar.kanji,
                          textAlign: TextAlign.center,
                          style: serif(17, c: e.pillar.ink),
                        ),
                      ),
                      Expanded(child: Text(e.note, style: sans(15))),
                      Text(fmt(e.amt), style: serif(16)),
                    ],
                  ),
                ),
              ),
            if (today.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: line)),
                ),
                child: Text(app.entries.isEmpty ? tr.emptyLedger : tr.quietToday, style: sans(14, h: 1.55, c: muted)),
              ),
          ],
        ),
        if (app.flags['phraseOn']!)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              spacing: 8,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(width: 24, height: 1, color: ok(.8, .03, 150)),
                ),
                Text(
                  phrase.$1,
                  textAlign: TextAlign.center,
                  style: serif(22, h: 1.3, c: s.deep),
                ),
                Text(
                  phrase.$2,
                  textAlign: TextAlign.center,
                  style: sans(12, ls: .72, c: ok(.42, .03, 160)),
                ),
                Text(
                  phrase.$3,
                  textAlign: TextAlign.center,
                  style: serif(16, w: FontWeight.w500, h: 1.55),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

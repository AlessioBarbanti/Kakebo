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
    final notice = app.flags['thoughtOn']! && app.thoughtToday == null && app.evening;

    return Reveal(
      spacing: 28,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(tr.today, style: serif(18)),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: line)),
                ),
                child: Row(
                  spacing: 14,
                  children: [
                    Image.asset(pillars.values.elementAt(app.now.day % 4).art, width: 64, height: 64, excludeFromSemantics: true),
                    Expanded(
                      child: Text(app.entries.isEmpty ? tr.emptyLedger : tr.quietToday, style: sans(14, h: 1.55, c: muted)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        // One compact line; the thought itself keeps its own quiet screen.
        if (notice)
          Semantics(
            button: true,
            child: Material(
              color: ok(.95, .025, 295),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => app.go('thought'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(radius: .707, colors: [ok(.99, .01, 295), ok(.88, .05, 295)], stops: const [0, .7]),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 1,
                          children: [
                            Text(tr.eveningThought, style: sans(12, c: ok(.4, .04, 290))),
                            Text(tr.happyQuestion, style: serif(16, h: 1.3)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: ok(.4, .04, 290)),
                    ],
                  ),
                ),
              ),
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
        // The branch shows pace, not money: its flowers are never turned into euros.
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
              child: Text(tr.branchRule, style: sans(13, h: 1.5, c: muted)),
            ),
          ],
        ),
      ],
    );
  }
}

/// A thought for today under the greeting: its meaning, then the original, romaji and source on tap.
class DailyPhrase extends StatefulWidget {
  const DailyPhrase({super.key});

  @override
  State<DailyPhrase> createState() => _DailyPhraseState();
}

class _DailyPhraseState extends State<DailyPhrase> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final i = app.phraseIndex, sub = ok(.42, .03, 160);
    final (jp, romaji) = phrases[i];
    final (meaning, source) = tr.phraseMeanings[i];
    return MergeSemantics(
      child: Semantics(
        button: true,
        expanded: open,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => open = !open),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    spacing: 6,
                    children: [
                      Expanded(
                        child: Text(
                          meaning,
                          style: serif(15, w: FontWeight.w500, h: 1.4, c: app.season.deep),
                        ),
                      ),
                      Icon(open ? Icons.expand_less : Icons.expand_more, size: 20, color: sub),
                    ],
                  ),
                ),
                if (open)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(jp, style: serif(20, h: 1.4)),
                        Text(romaji, style: sans(12, ls: .5, c: sub)),
                        Text(source ?? tr.japaneseSaying, style: sans(12, c: sub)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

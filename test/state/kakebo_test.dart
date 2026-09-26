import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/model/pillar_suggestion.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  setUpAll(initL10n);
  setUp(() {
    setLocale(const Locale('it', 'IT'));
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
  });
  tearDown(() => Kakebo.clock = DateTime.now);
  test('demo month: budgets split by pillar shares, savings branch at the pace of the month', () {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    final k = Kakebo()..seedDemo();
    expect(k.fixedTotal, 1150);
    expect(k.available, 1350);
    expect(k.spent, closeTo(526.6, 1e-9));
    expect(k.spentPct, 39);
    expect(k.bloomed, 8); // pace 0.49 ≤ 1 → 10 × 24/30
    expect(k.week.length, 5); // Mon 21 → Thu 24
    expect(suggest('Cena da Mario'), 'wants');
    expect(k.dim, 30);
    expect([for (final p in pillars.keys) k.budget(p)], [600, 300, 200, 250]); // the pillars' shares of 1350
    k.income = 3000; // 200 more available → budgets follow
    expect(k.budget('needs'), 689);
    k.setBudget('wants', 400); // from now on they are the user's
    k.income = 2800;
    expect([for (final p in pillars.keys) k.budget(p)], [689, 400, 230, 287]);
    expect(k.budgeted, 1606);
    k.autoBudgets();
    expect(k.budget('needs'), 600);
  });

  test('a month starting on payday (the 27th) runs 27 Aug – 26 Sep and is called September', () {
    Kakebo.clock = () => DateTime(2026, 9, 25, 12);
    final k = Kakebo()..monthStart = 27;
    expect(k.period.start, DateTime(2026, 8, 27));
    expect(k.period.last, DateTime(2026, 9, 26));
    expect(k.label, DateTime(2026, 9));
    expect(k.dim, 31);
    expect(k.day, 30);
    k.entries = [
      Entry(DateTime(2026, 8, 26), 'luglio-agosto', 1, 'needs'),
      Entry(DateTime(2026, 8, 27), 'primo giorno', 2, 'needs'),
      Entry(DateTime(2026, 9, 27), 'ottobre', 4, 'needs'),
    ];
    expect(k.spent, 2);
    expect(k.periodFor(DateTime(2026, 10)).start, DateTime(2026, 9, 27));
    k.monthStart = 1; // back to calendar months
    expect(k.period.start, DateTime(2026, 9));
    expect(k.dim, 30);
  });

  test('state survives a save/load round trip', () {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    final a = Kakebo()..seedDemo();
    a.addEntry(3.5, 'Caffè', 'wants');
    final b = Kakebo()..read(jsonDecode(jsonEncode(a.toJson())));
    expect(b.entries.length, a.entries.length);
    expect(b.entries.first.note, 'Caffè');
    expect(b.spent, a.spent);
    expect(b.sealed, a.sealed);
    expect(b.thoughts, a.thoughts);
  });

  test('a month seals from the first day of the next, and by itself when that one ends too, across the new year', () {
    final k = Kakebo()
      ..income = 1000
      ..save = 100
      ..entries = [Entry(DateTime(2026, 9, 10), 'Spesa', 300, 'needs')];
    Kakebo.clock = () => DateTime(2026, 9, 26);
    expect((k.reviewPeriod.start, k.canSeal), (DateTime(2026, 9), false)); // September is still running
    k.seal();
    expect(k.sealed, isEmpty);

    Kakebo.clock = () => DateTime(2026, 10, 1);
    expect((k.reviewPeriod.start, k.canSeal), (DateTime(2026, 9), true)); // all of October to seal it
    expect(k.closeForgotten(), isFalse);

    Kakebo.clock = () => DateTime(2026, 11, 1);
    expect(k.closeForgotten(), isTrue); // forgotten through October: it seals itself, with its figures
    expect(k.sealed, {'2026-09': 700}); // 1000 income − 0 fixed − 300 spent
    expect((k.reviewPeriod.start, k.canSeal), (DateTime(2026, 11), false)); // nothing written in October

    // December waits through January; November, still open, seals itself on 1 January.
    k.entries = [Entry(DateTime(2026, 11, 5), 'a', 50, 'wants'), Entry(DateTime(2026, 12, 5), 'b', 80, 'wants')];
    Kakebo.clock = () => DateTime(2027, 1, 1);
    expect(k.closeForgotten(), isTrue);
    expect(k.sealed['2026-11'], 950);
    expect((k.reviewPeriod.start, k.canSeal), (DateTime(2026, 12), true));
    k.seal();
    expect(k.sealed['2026-12'], 920);
    expect((k.reviewPeriod.start, k.canSeal), (DateTime(2027, 1), false)); // January is next, sealed from 1 February

    // With the month starting on payday (the 27th), "September" runs 27 Aug – 26 Sep and seals from 27 September.
    final p = Kakebo()
      ..monthStart = 27
      ..entries = [Entry(DateTime(2026, 9, 20), 'c', 10, 'needs')];
    Kakebo.clock = () => DateTime(2026, 9, 26);
    expect(p.canSeal, isFalse);
    Kakebo.clock = () => DateTime(2026, 9, 27);
    expect((p.labelOf(p.reviewPeriod), p.canSeal), (DateTime(2026, 9), true));
  });
}

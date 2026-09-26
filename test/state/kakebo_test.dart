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
    a.seal();
    final b = Kakebo()..read(jsonDecode(jsonEncode(a.toJson())));
    expect(b.entries.length, a.entries.length);
    expect(b.entries.first.note, 'Caffè');
    expect(b.spent, a.spent);
    expect(b.isSealed, isTrue);
    expect(b.thoughts, a.thoughts);
  });
}

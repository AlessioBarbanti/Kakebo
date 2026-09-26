import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  setUpAll(initL10n);
  setUp(() {
    setLocale(const Locale('it', 'IT'));
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
  });
  tearDown(() => Kakebo.clock = DateTime.now);
  test('backup restores everything; a wrong file changes nothing; reset empties', () {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    final a = Kakebo()..seedDemo();
    a.setBudget('wants', 350);
    a.thoughtTime = '19:45';
    final b = Kakebo();
    expect(b.restore(a.backup()), isTrue);
    expect(b.entries.length, a.entries.length);
    expect(b.budget('wants'), 350);
    expect(b.thoughtTime, '19:45');
    expect(b.restore('{"not": "a backup"}'), isFalse);
    expect(b.restore('garbage'), isFalse);
    expect(b.entries.length, a.entries.length);
    b.reset();
    expect(b.entries, isEmpty);
    expect(b.budgets, isNull);
    expect(b.onboarded, isFalse);
  });

  test('CSV opens in an Italian spreadsheet', () {
    final k = Kakebo()..entries = [Entry(DateTime(2026, 9, 24), 'Caffè "doppio"', 2.5, 'wants')];
    final lines = k.csv().substring(1).split(String.fromCharCodes(const [13, 10]));
    expect(k.csv().codeUnitAt(0), 0xFEFF);
    expect(lines, ['data;nota;importo;pilastro', '2026-09-24;"Caffè ""doppio""";2,5;Desideri']);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  setUpAll(initL10n);
  setUp(() {
    setLocale(const Locale('it', 'IT'));
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
  });
  tearDown(() => Kakebo.clock = DateTime.now);
  test('euro like it-IT Intl', () {
    expect(fmt(850), '850 €');
    expect(fmt(12.8), '12,80 €');
    expect(fmt(1650), '1.650 €');
    expect(fmt(1234.5), '1.234,50 €');
    expect(fmt(10.001), '10,00 €');
  });

  test('English texts, region money and dates; Italian again afterwards', () {
    addTearDown(() => setLocale(const Locale('it', 'IT')));
    setLocale(const Locale('en', 'GB'));
    expect(fmt(1650), '£1,650');
    expect(tr.leftFor('September'), 'Left for September');
    expect(dayLabel(DateTime(2026, 9, 24)), 'Thursday 24 September');
    expect(pillars['wants']!.name, 'Wants');
    setLocale(const Locale('fr', 'FR')); // not translated yet: English words, French money
    expect(tr.today, 'Today');
    expect(fmt(12.5), contains('12,50'));
    setLocale(const Locale('it', 'IT'));
    expect(fmt(1650), '1.650 €');
    expect(tr.flowers(1), '1 fiore su 10');
  });

  test('a new saying every day, running on across months, with a meaning in each language', () {
    final app = Kakebo();
    int on(DateTime d) {
      Kakebo.clock = () => d;
      return app.phraseIndex;
    }

    // Before, the choice was the day of the month: it jumped back when a month ended.
    expect(on(DateTime(2026, 10, 1, 8)), (on(DateTime(2026, 9, 30, 23)) + 1) % phrases.length);
    expect({for (var d = 0; d < phrases.length; d++) on(DateTime(2026, 9, 1 + d))}.length, phrases.length);
    for (final l in const [Locale('it', 'IT'), Locale('en', 'GB')]) {
      setLocale(l);
      expect(tr.phraseMeanings.length, phrases.length, reason: '$l');
    }
  });
}

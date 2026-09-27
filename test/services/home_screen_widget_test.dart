import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/kakebo_app.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/services/home_screen_widget.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  setUpAll(initL10n);
  setUp(() => setLocale(const Locale('it', 'IT')));
  tearDown(() => Kakebo.clock = DateTime.now);

  int at(DateTime t) => t.millisecondsSinceEpoch;

  test('the widget follows the day, the evening until 4 while the thought waits, then the month to seal', () {
    Kakebo.clock = () => DateTime(2026, 9, 29, 12);
    final k = Kakebo()..seedDemo();
    final f = frames(k);
    // Now: the day, as on Today.
    expect(f.first, containsPair('at', 0));
    expect((f.first['kind'], f.first['title'], f.first['sub']), ('day', fmt(k.left), tr.perDayBrief(fmt(k.left.floor()))));
    expect((f.first['tick'], f.first['stamp']), (29 / 30, '九月'));
    // The thought's time, then 4 in the morning, then the last day, its evening, and the month over.
    expect(
      [for (final x in f.skip(1)) (x['at'], x['kind'])],
      [
        (at(DateTime(2026, 9, 29, 21)), 'evening'),
        (at(DateTime(2026, 9, 30, 4)), 'day'),
        (at(DateTime(2026, 9, 30, 21)), 'evening'),
        (at(DateTime(2026, 10, 1, 4)), 'close'),
      ],
    );
    expect(f[2]['sub'], tr.spendToday); // the last day
    final close = f.last;
    expect((close['title'], close['note']), (tr.widgetSealTitle('Settembre'), tr.widgetSaved(fmt(k.onTrack), fmt(k.save))));
    expect((close['tick'], close['stamp']), (1.0, '九月'));

    // Once tonight's thought is written, tonight is no longer asked; without reminders, no evening at all.
    k.thoughts['2026-09-29'] = 'Il tè';
    expect(frames(k).skip(1).first['at'], at(DateTime(2026, 9, 30))); // the next day, from midnight
    k.flags['thoughtOn'] = false;
    expect(frames(k).where((x) => x['kind'] == 'evening'), isEmpty);
  });

  test('while the month before waits for its seal, the widget asks for it; sealed, the day comes back', () {
    Kakebo.clock = () => DateTime(2026, 10, 3, 10);
    final k = Kakebo()
      ..income = 1000
      ..flags['thoughtOn'] = false
      ..entries = [Entry(DateTime(2026, 9, 10), 'Spesa', 300, 'needs')];
    expect((frames(k).first['kind'], frames(k).first['kicker']), ('close', tr.closeBy(dayMonth(DateTime(2026, 10, 31)))));
    k.seal();
    expect(frames(k).first['kind'], 'day');
    expect(frames(k).last['kind'], 'day'); // nothing written in October: nothing to seal when it ends
  });

  testWidgets('a pillar on the widget opens the add sheet with that pillar, over whatever the app showed', (t) async {
    Kakebo.clock = () => DateTime(2026, 9, 24, 12);
    final sent = <Object?>[];
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('kakebo/widget'), (call) async {
      if (call.method == 'show') sent.add(jsonDecode(call.arguments as String));
      return call.method == 'launch' ? {'screen': 'add', 'pillar': 'culture'} : null; // started by the widget
    });
    final app = Kakebo()
      ..seedDemo()
      ..onboarded = true
      ..screen = 'ledger';
    await t.pumpWidget(AppScope(notifier: app, child: const KakeboApp()));
    await HomeScreenWidget(app).init();
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(app.screen, 'home');
    expect(t.widget<AddSheet>(find.byType(AddSheet)).pillar, 'culture');

    expect(sent, hasLength(1));
    app.refresh();
    expect(sent, hasLength(1)); // nothing new to show
    app.addEntry(10, 'Tè', 'wants');
    expect(sent, hasLength(2));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/shell.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  late Kakebo app;
  setUpAll(initL10n);
  setUp(() {
    app = Kakebo();
    setLocale(const Locale('it', 'IT'));
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
  });
  tearDown(() => Kakebo.clock = DateTime.now);
  testWidgets('swiping left moves to the next tab', (t) async {
    app.onboarded = true;
    app.go('home');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pump(const Duration(seconds: 2));
    await t.dragFrom(const Offset(795, 450), const Offset(-300, 0)); // from the empty side margin
    await t.pumpAndSettle();
    expect(app.screen, 'ledger');
    expect(find.text('Dove sono andati'), findsOneWidget);
  });

  testWidgets('released swipe keeps going instead of bouncing back', (t) async {
    app.go('home');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pump(const Duration(seconds: 2));
    double x() => t.widget<Container>(find.byWidgetPredicate((w) => w is Container && w.transform != null)).transform!.getTranslation().x;
    final g = await t.startGesture(const Offset(795, 450));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(-30, 0)); // a real finger: many small moves
      await t.pump(const Duration(milliseconds: 16));
    }
    var prev = x();
    expect(prev, lessThan(-100)); // the content followed the finger
    await g.up();
    for (var i = 0; i < 15; i++) {
      await t.pump(const Duration(milliseconds: 16)); // the outgoing phase lasts 260 ms
      expect(x(), lessThanOrEqualTo(prev), reason: 'frame $i moved back toward the centre');
      prev = x();
    }
    await t.pumpAndSettle();
  });

  testWidgets('screens follow state changes: settings button, new expense', (t) async {
    app.go('home');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pump(const Duration(seconds: 2));
    await t.tap(find.bySemanticsLabel('Impostazioni'));
    await t.pumpAndSettle();
    expect(app.screen, 'settings');
    expect(find.text('IMPOSTAZIONI'), findsOneWidget);
    app.go('home');
    app.addEntry(4.5, 'Tè al parco', 'wants');
    await t.pumpAndSettle();
    expect(find.text('Tè al parco'), findsOneWidget); // Oggi shows it right away
  });

  testWidgets('a scrolled-away greeting stays hidden on the next tab, a visible one stays visible', (t) async {
    app.go('home');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pump(const Duration(seconds: 2));
    bool greeting() => find.text(app.greeting).evaluate().isNotEmpty && t.getRect(find.text(app.greeting)).bottom > 0;
    expect(greeting(), isTrue);
    await t.dragFrom(const Offset(795, 500), const Offset(0, -400)); // scroll down
    await t.pumpAndSettle();
    expect(greeting(), isFalse);
    await t.dragFrom(const Offset(795, 450), const Offset(-300, 0)); // next tab
    await t.pumpAndSettle();
    expect(app.screen, 'ledger');
    expect(greeting(), isFalse, reason: 'greeting came back');
    expect(t.getRect(find.text('REGISTRO')).top, greaterThan(0), reason: 'new tab starts at its top');
    await t.dragFrom(const Offset(795, 300), const Offset(0, 600)); // back to the top
    await t.pumpAndSettle();
    await t.dragFrom(const Offset(795, 450), const Offset(-300, 0));
    await t.pumpAndSettle();
    expect(app.screen, 'journal');
    expect(greeting(), isTrue);
  });
}

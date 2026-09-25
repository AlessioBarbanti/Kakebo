import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/home.dart';
import 'package:kakebo/intro.dart';
import 'package:kakebo/kakebo.dart';
import 'package:kakebo/shell.dart';
import 'package:kakebo/ui.dart';

void main() {
  setUpAll(() async {
    await initL10n(); // Italian texts, it_IT money and dates
    app = Kakebo(); // the UI reads the global app state
  });

  test('oklch → sRGB', () {
    final red = ok(.628, .2577, 29.23); // CSS reference for #ff0000
    expect((red.r * 255).round(), 255);
    expect((red.g * 255).round(), 0);
    expect((red.b * 255).round(), 0);
    expect((ok(1, 0, 0).g * 255).round(), 255);
  });

  test('euro like it-IT Intl', () {
    expect(fmt(850), '850 €');
    expect(fmt(12.8), '12,80 €');
    expect(fmt(1650), '1.650 €');
    expect(fmt(1234.5), '1.234,50 €');
    expect(fmt(10.001), '10,00 €');
  });

  test('budget and savings branch follow the design', () {
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
    expect([for (final p in pillars.keys) k.budget(p)], [600, 300, 200, 250]); // the design's split of 1350
    k.income = 3000; // 200 more available → budgets follow
    expect(k.budget('needs'), 689);
    k.setBudget('wants', 400); // from now on they are the user's
    k.income = 2800;
    expect([for (final p in pillars.keys) k.budget(p)], [689, 400, 230, 287]);
    expect(k.budgeted, 1606);
    k.autoBudgets();
    expect(k.budget('needs'), 600);
  });

  testWidgets('keypad: two decimals max, note suggests pillar, save adds entry', (t) async {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) => TextButton(onPressed: () => openAdd(c), child: const Text('apri')),
        ),
      ),
    );
    await t.tap(find.text('apri'));
    await t.pumpAndSettle();
    for (final k in ['1', '2', ',', '5', '0', '7']) {
      await t.tap(find.text(k));
    }
    await t.enterText(find.byType(TextField), 'Cena fuori');
    await t.pump();
    expect(find.text('12,50\u00A0€'), findsOneWidget);
    expect(find.text('Pilastro suggerito dalla nota: Desideri'), findsOneWidget);
    await t.tap(find.text('Salva'));
    expect(app.entries.single.amt, 12.5);
    expect(app.entries.single.p, 'wants');
  });

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

  testWidgets('every settings row does what it says', (t) async {
    t.view.physicalSize = const Size(1080, 6000); // tall enough to show the whole page
    t.view.devicePixelRatio = 2.625;
    addTearDown(t.view.reset);
    Future<void> open() async {
      app.go('settings');
      await t.pumpAndSettle();
    }

    Future<void> tapRow(String label) async {
      await t.tap(find.text(label));
      await t.pumpAndSettle();
    }

    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await open();
    for (final (label, flag) in [
      ('Riepilogo della domenica', 'weekly'),
      ('Frase del giorno', 'phraseOn'),
      ('Nota serale', 'reminders'),
      ('Notifica del pensiero', 'thoughtOn'),
    ]) {
      final before = app.flags[flag]!;
      await tapRow(label);
      expect(app.flags[flag], !before, reason: label);
      await tapRow(label);
    }
    for (final label in ['Orario', 'Orario della nota']) {
      await tapRow(label);
      expect(find.byType(TimePickerDialog), findsOneWidget, reason: label);
      await tapRow('Cancel');
    }
    for (final label in ['Esporta registro', 'Salva un backup', 'Ripristina un backup']) {
      expect(find.text(label), findsOneWidget); // the file dialogs themselves are Android's
    }
    for (final (label, screen) in [
      ('Entrate e spese fisse', 'monthStart'),
      ('Scrivi il pensiero di oggi', 'thought'),
      ("Rivedi l'introduzione", 'onboarding'),
    ]) {
      await open();
      await t.tap(find.text(label));
      expect(app.screen, screen, reason: label);
    }
    await open();
    await tapRow('Licenze');
    expect(find.byType(LicensePage), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    app.addEntry(9, 'Da cancellare', 'needs');
    await tapRow('Cancella tutti i dati');
    await tapRow('Annulla');
    expect(app.entries, isNotEmpty);
    await tapRow('Cancella tutti i dati');
    await tapRow('Cancella');
    expect(app.entries, isEmpty);
    expect(app.screen, 'onboarding');
  });

  testWidgets('tapping an expense edits it; deleting it can be undone', (t) async {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    app.onboarded = true;
    app.addEntry(7, 'Pane', 'needs');
    app.go('home');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Pane'));
    await t.pumpAndSettle();
    await t.tap(find.text('Pane'));
    await t.pumpAndSettle();
    expect(find.text('Modifica spesa'), findsOneWidget);
    expect(find.descendant(of: find.byType(AddSheet), matching: find.text('7\u00A0€')), findsOneWidget);
    await t.tap(find.text('⌫'));
    await t.tap(find.text('9'));
    await t.tap(find.text('Salva'));
    await t.pumpAndSettle();
    expect(app.entries.first.amt, 9);
    expect(app.entries.first.note, 'Pane');
    await t.tap(find.text('Pane'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Elimina spesa'));
    await t.pumpAndSettle();
    await t.tap(find.text('Elimina spesa'));
    await t.pumpAndSettle();
    expect(app.entries.where((e) => e.note == 'Pane'), isEmpty);
    await t.tap(find.text('Annulla'));
    await t.pumpAndSettle();
    expect(app.entries.first.note, 'Pane');
  });

  testWidgets('intro: prints cross-fade in place, next text follows without a gap', (t) async {
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Onboarding())),
      ),
    );
    await t.pumpAndSettle();
    final w = t.getSize(find.byType(Onboarding)).width;
    await t.tap(find.text('Avanti'));
    await t.pump(const Duration(milliseconds: 150));
    final prints = find.byType(Image);
    expect(prints, findsNWidgets(5)); // the old print and the four new ones, together
    for (final r in [for (var i = 0; i < 5; i++) t.getRect(prints.at(i))]) {
      expect(r.top, 0);
      expect(r.left % (w / 4), closeTo(0, .01), reason: 'prints must not slide'); // every left edge sits on a quarter
    }
    await t.pump(const Duration(milliseconds: 100)); // 250 ms: the old text is gone, the new one is on its way
    expect(find.text('Quattro pilastri, quattro gentiluomini'), findsOneWidget);
    await t.pumpAndSettle();
    expect(prints, findsNWidgets(4));
  });

  test('a month starting on payday (the 27th) runs 27 Aug – 26 Sep and is called September', () {
    Kakebo.clock = () => DateTime(2026, 9, 25, 12);
    final k = Kakebo()..monthStart = 27;
    expect(k.period.start, DateTime(2026, 8, 27));
    expect(k.period.last, DateTime(2026, 9, 26));
    expect(k.label, DateTime(2026, 9));
    expect(k.dim, 31);
    expect(k.day, 30);
    k.entries = [Entry(DateTime(2026, 8, 26), 'luglio-agosto', 1, 'needs'), Entry(DateTime(2026, 8, 27), 'primo giorno', 2, 'needs'), Entry(DateTime(2026, 9, 27), 'ottobre', 4, 'needs')];
    expect(k.spent, 2);
    expect(k.periodFor(DateTime(2026, 10)).start, DateTime(2026, 9, 27));
    k.monthStart = 1; // back to calendar months
    expect(k.period.start, DateTime(2026, 9));
    expect(k.dim, 30);
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

  test('pillar suggestion matches word starts in Italian and English', () {
    expect(suggest('Cena da Mario'), 'wants');
    expect(suggest('Regalo per i parenti'), 'wants'); // "parenti" is not "rent"
    expect(suggest('Weekly groceries'), 'needs');
    expect(suggest('Ciotola in ceramica'), isNull);
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

  test('backup restores everything; a wrong file changes nothing; reset empties', () {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    final a = Kakebo()..seedDemo();
    a.setBudget('wants', 350);
    a.noteTime = '19:45';
    final b = Kakebo();
    expect(b.restore(a.backup()), isTrue);
    expect(b.entries.length, a.entries.length);
    expect(b.budget('wants'), 350);
    expect(b.noteTime, '19:45');
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

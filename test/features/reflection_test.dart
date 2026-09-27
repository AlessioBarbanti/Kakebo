import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/shell.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/features/journal/journal.dart';
import 'package:kakebo/features/journal/review.dart';
import 'package:kakebo/features/journal/thought.dart';
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

  test('reflections survive backup, edits and undo; older data still loads', () {
    final app = Kakebo()..addEntry(12, 'Libro', 'culture');
    app.editEntry(app.entries.single, 12, 'Libro', 'culture', reflection: 'Mi ha fatto compagnia');
    app.editEntry(app.entries.single, 13, 'Libro', 'culture');
    final entry = app.entries.single;
    app.restoreEntry(app.removeEntry(entry), entry);
    app.reflections['2026-09'] = {'good': 'Tempo insieme', 'change': 'Più attenzione'};
    app.improve['2026-09'] = 'Scegliere con calma';
    app.weeklyReflections['2026-09-20'] = 'La passeggiata';
    final restored = Kakebo();
    expect(restored.restore(app.backup()), isTrue);
    expect(restored.entries.single.reflection, 'Mi ha fatto compagnia');
    expect(restored.reflections, app.reflections);
    expect(restored.weeklyReflections, app.weeklyReflections);
    final legacy = jsonDecode(app.backup()) as Map<String, dynamic>;
    legacy.remove('reflections');
    legacy.remove('weeklyReflections');
    (legacy['entries'][0] as Map).remove('reflection');
    expect(restored.restore(jsonEncode(legacy)), isTrue);
    expect(restored.reflections, isEmpty);
    expect(restored.weeklyReflections, isEmpty);
    expect(restored.entries.single.reflection, isEmpty);
    expect(restored.improve['2026-09'], 'Scegliere con calma');
    restored.reset();
    expect(restored.improve, isEmpty);
    expect(restored.reflections, isEmpty);
    expect(restored.weeklyReflections, isEmpty);
  });

  test('intention follows the budgeting period, including year boundaries', () {
    final app = Kakebo()..monthStart = 27;
    app.improve.addAll({'2026-08': 'Agosto', '2026-09': 'Settembre', '2026-12': 'Dicembre'});
    Kakebo.clock = () => DateTime(2026, 9, 26);
    expect(app.currentIntention, 'Agosto');
    Kakebo.clock = () => DateTime(2026, 9, 27);
    expect(app.currentIntention, 'Settembre');
    Kakebo.clock = () => DateTime(2026, 12, 27);
    expect(app.currentIntention, 'Dicembre');
  });

  Future<void> mount(WidgetTester t, Kakebo app, Widget child) async {
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('monthly answers save independently and remain when reopened', (t) async {
    final app = Kakebo();
    await mount(t, app, const Review());
    for (final (i, value) in ['Tempo insieme', 'Meno fretta', 'Scegliere con calma'].indexed) {
      final field = find.byType(TextFormField).at(i);
      await t.ensureVisible(field);
      await t.enterText(field, value);
      await t.pump();
    }
    expect(app.reflections['2026-09'], {'good': 'Tempo insieme', 'change': 'Meno fretta'});
    expect(app.improve['2026-09'], 'Scegliere con calma');
    await t.pumpWidget(const SizedBox());
    await mount(t, app, const Review());
    expect(find.text('Tempo insieme'), findsOneWidget);
    expect(find.text('Scegliere con calma'), findsOneWidget);
  });

  testWidgets('expense reflection saves only on Save and can be cleared', (t) async {
    final app = Kakebo()..addEntry(10, 'Libro', 'culture');
    Future<void> open() async {
      await t.pumpWidget(
        AppScope(
          notifier: app,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => openAdd(context, edit: app.entries.single),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    await open();
    await t.ensureVisible(find.text(tr.expenseReflection));
    await t.tap(find.text(tr.expenseReflection));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const ValueKey('expenseReflection')), 'Una bella lettura');
    expect(app.entries.single.reflection, isEmpty);
    await t.ensureVisible(find.text(tr.save));
    await t.tap(find.text(tr.save));
    await t.pumpAndSettle();
    expect(app.entries.single.reflection, 'Una bella lettura');
    await open();
    await t.enterText(find.byKey(const ValueKey('expenseReflection')), '');
    await t.ensureVisible(find.text(tr.save));
    await t.tap(find.text(tr.save));
    await t.pumpAndSettle();
    expect(app.entries.single.reflection, isEmpty);
  });

  testWidgets('diary action opens a thought instead of an expense', (t) async {
    final app = Kakebo()..go('journal');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text(tr.addExpense), findsNothing);
    await t.tap(find.text(tr.writeThought));
    expect(app.screen, 'thought');
  });

  testWidgets('the diary keeps only the evening and the month; sealed months show what was written', (t) async {
    final app = Kakebo()
      ..entries = [Entry(DateTime(2026, 9, 9), 'Spesa', 40, 'needs')]
      ..weeklyReflections['2026-09-13'] =
          'La passeggiata' // written before the week left the diary
      ..sealed.addAll({'2026-07': 300, '2026-08': 200})
      ..improve['2026-07'] = 'Meno cene fuori';
    await mount(t, app, const Journal());
    expect(find.textContaining('settimana'), findsNothing);
    expect(find.text('La passeggiata'), findsNothing);
    expect(find.text(tr.resolutionFor('agosto', 'Meno cene fuori')), findsOneWidget);
    expect(find.text(tr.sealedSaved(fmt(200))), findsOneWidget); // August, sealed with nothing written: no stock line under it
  });

  testWidgets('outside the evening the thought is closed, and the Diary button annotates an expense', (t) async {
    Kakebo.clock = () => DateTime(2026, 9, 25, 10);
    final app = Kakebo()..go('journal');
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Thought())),
      ),
    );
    await t.pump(const Duration(seconds: 1));
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text(tr.backToToday), findsOneWidget);
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Shell())),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text(tr.writeThought), findsNothing);
    expect(find.text(tr.addExpense), findsOneWidget);
  });

  testWidgets('words begun before 4 in the morning are kept for the evening before', (t) async {
    Kakebo.clock = () => DateTime(2026, 9, 25, 3, 58);
    final app = Kakebo();
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Thought())),
      ),
    );
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Giovedì 24 settembre'), findsOneWidget);
    await t.enterText(find.byType(TextFormField), 'La luna sul tetto');
    Kakebo.clock = () => DateTime(2026, 9, 25, 4, 1);
    app.refresh();
    await t.pump();
    await t.ensureVisible(find.text(tr.keepThought));
    await t.tap(find.text(tr.keepThought));
    await t.pump(const Duration(seconds: 1));
    expect(app.thoughts, {'2026-09-24': 'La luna sul tetto'});
  });

  testWidgets('the evening thought opens straight on writing while the meditation is off, as by default', (t) async {
    final app = Kakebo();
    expect(app.flags['breathe'], isFalse);
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: const MaterialApp(home: Scaffold(body: Thought())),
      ),
    );
    await t.pump(const Duration(seconds: 1));
    expect(find.text(tr.happyQuestion), findsOneWidget);
    expect(find.text(tr.breathFirst), findsNothing);
  });

  testWidgets('unfinished monthly reflections remain in the diary and older memories can be reached', (t) async {
    final app = Kakebo();
    app.reflections['2026-08'] = {'good': 'Una giornata al lago'};
    for (var day = 1; day <= 24; day++) {
      app.thoughts['2026-09-${day.toString().padLeft(2, '0')}'] = 'Ricordo $day';
    }
    await mount(t, app, const Journal());
    expect(find.textContaining('Una giornata al lago'), findsNothing);
    await t.ensureVisible(find.text(tr.moreMemories));
    await t.tap(find.text(tr.moreMemories));
    await t.pumpAndSettle();
    expect(find.textContaining('Una giornata al lago'), findsOneWidget);
    expect(find.text(tr.reflectionMemory), findsOneWidget);
  });
}

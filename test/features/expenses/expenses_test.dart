import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/shell.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
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
  testWidgets('keypad: two decimals max, note suggests pillar, save adds entry', (t) async {
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: MaterialApp(
          home: Builder(
            builder: (c) => TextButton(onPressed: () => openAdd(c), child: const Text('apri')),
          ),
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
}

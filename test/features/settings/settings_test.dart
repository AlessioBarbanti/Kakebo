import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/shell.dart';
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
    for (final (label, flag) in [('Riepilogo della domenica', 'weekly'), ('Frase del giorno', 'phraseOn'), ('Promemoria serale', 'thoughtOn')]) {
      final before = app.flags[flag]!;
      await tapRow(label);
      expect(app.flags[flag], !before, reason: label);
      await tapRow(label);
    }
    for (final label in ['Orario']) {
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
}

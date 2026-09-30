import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/shell.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/receipt.dart';
import 'package:kakebo/services/receipt_scanner.dart';
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

  testWidgets('a new expense has no pillar until one is picked', (t) async {
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
    await t.tap(find.text('8'));
    expect(find.text('Scegli un pilastro'), findsOneWidget);
    await t.tap(find.text('Salva'));
    expect(app.entries, isEmpty);
    await t.tap(find.text('Cultura'));
    await t.tap(find.text('Salva'));
    expect(app.entries.single.p, 'culture');
  });

  testWidgets('an expense forgotten yesterday is dated back and takes its place in the ledger', (t) async {
    app.addEntry(5, 'Pane', 'needs'); // today, Thursday 24 September
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
    await t.tap(find.text('9'));
    await t.tap(find.text('Cultura'));
    await t.tap(find.text('Oggi'));
    await t.pumpAndSettle();
    await t.tap(find.text('23'));
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(find.text('Ieri'), findsOneWidget);
    await t.tap(find.text('Salva'));
    expect([for (final e in app.entries) (e.note, e.date)], [('Pane', DateTime(2026, 9, 24)), ('Cultura', DateTime(2026, 9, 23))]);
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
    await t.tap(find.byIcon(Icons.backspace_outlined));
    await t.tap(find.text('9'));
    await t.ensureVisible(find.text('Salva'));
    await t.pumpAndSettle();
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

    await t.tap(find.text('Pane'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Elimina spesa'));
    await t.pumpAndSettle();
    await t.tap(find.text('Elimina spesa'));
    await t.pumpAndSettle();
    expect(find.text('Spesa eliminata'), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    expect(find.text('Spesa eliminata'), findsNothing, reason: 'the undo offer leaves on its own');
  });

  group('a receipt', () {
    final real = ReceiptScanner.read;
    tearDown(() => ReceiptScanner.read = real);

    /// A receipt as recognition reads it: one line per printed row, each 20 px high.
    List<ReceiptLine> printed(String text) => [
      for (final (i, row) in text.trim().split('\n').indexed) ReceiptLine(row, [(0, i * 30.0), (300, i * 30.0), (300, i * 30.0 + 20), (0, i * 30.0 + 20)]),
    ];

    Future<void> open(WidgetTester t) async {
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
    }

    Future<void> scan(WidgetTester t, {String from = 'Fotografa lo scontrino'}) async {
      await t.tap(find.byTooltip('Leggi uno scontrino'));
      await t.pumpAndSettle();
      await t.tap(find.text(from));
      await t.pumpAndSettle();
    }

    testWidgets('fills in the total, the shop and its day; nothing is added until Save', (t) async {
      bool? fromCamera;
      ReceiptScanner.read = ({required camera}) async {
        fromCamera = camera;
        return printed('''
ESSELUNGA S.P.A.
DOCUMENTO COMMERCIALE
TOTALE COMPLESSIVO 5,38
Pagamento contante 10,00
22-09-2026 18:42
''');
      };
      await open(t);
      await scan(t);
      expect(fromCamera, isTrue);
      expect(find.text('5,38\u00A0€'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Esselunga'), findsOneWidget);
      expect(find.text(shortDay(DateTime(2026, 9, 22))), findsOneWidget);
      expect(find.text('Pilastro suggerito dalla nota: Necessità'), findsOneWidget);
      expect(find.text('Dallo scontrino: controlla prima di salvare'), findsOneWidget);
      expect(app.entries, isEmpty);

      await t.tap(find.text('Salva'));
      expect([for (final e in app.entries) (e.amt, e.note, e.date, e.p)], [(5.38, 'Esselunga', DateTime(2026, 9, 22), 'needs')]);
    });

    testWidgets("never over the user's note, nor on a day an expense cannot go to; says when it cannot read", (t) async {
      var receipt = printed('BAR CENTRALE\nTOTALE 12,00\n01-01-2026');
      ReceiptScanner.read = ({required camera}) async => receipt;
      await open(t);
      await t.enterText(find.byType(TextField), 'Pranzo con Luca');
      await scan(t, from: 'Scegli una foto');
      expect(find.text('12\u00A0€'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Pranzo con Luca'), findsOneWidget);
      expect(find.text('Oggi'), findsOneWidget, reason: 'January is long sealed');

      receipt = printed('BAR CENTRALE\nCAFFE 1,20\n24/09/2026');
      await scan(t);
      expect(find.text('Non trovo il totale: scrivilo tu'), findsOneWidget);
      expect(find.text('12\u00A0€'), findsOneWidget, reason: 'the amount already there stays');

      ReceiptScanner.read = ({required camera}) async => throw Exception('no camera');
      await scan(t);
      expect(find.text('Non riesco a leggere lo scontrino'), findsOneWidget);

      ReceiptScanner.read = ({required camera}) async => receipt;
      receipt = printed('BAR CENTRALE\nTOTALE 4,50');
      await scan(t);
      expect(find.text('Dallo scontrino: controlla prima di salvare'), findsOneWidget);
      receipt = []; // a photo with no text in it
      await scan(t);
      expect(find.text('Non riesco a leggere lo scontrino'), findsOneWidget);

      ReceiptScanner.read = ({required camera}) async => null; // the camera closed without a photo
      await scan(t);
      expect(find.text('4,50\u00A0€'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Pranzo con Luca'), findsOneWidget);
      expect(app.entries, isEmpty);
    });

    testWidgets('a receipt shop replaces the one before it; an expense being edited has no receipt to read', (t) async {
      var receipt = printed('BAR CENTRALE\nTOTALE 3,00');
      ReceiptScanner.read = ({required camera}) async => receipt;
      await open(t);
      await scan(t);
      receipt = printed('FARMACIA COMUNALE\nTOTALE 8,90');
      await scan(t); // the wrong receipt first, then the right one
      expect(find.widgetWithText(TextField, 'Farmacia Comunale'), findsOneWidget);
      expect(find.text('8,90\u00A0€'), findsOneWidget);
      await t.tap(find.text('Salva'));
      await t.pumpAndSettle();

      await t.pumpWidget(
        AppScope(
          notifier: app,
          child: MaterialApp(
            home: Builder(
              builder: (c) => TextButton(
                onPressed: () => openAdd(c, edit: app.entries.single),
                child: const Text('modifica'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('modifica'));
      await t.pumpAndSettle();
      expect(find.byTooltip('Leggi uno scontrino'), findsNothing);
    });
  });
}

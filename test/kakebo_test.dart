import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakebo/home.dart';
import 'package:kakebo/kakebo.dart';
import 'package:kakebo/ui.dart';

void main() {
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
  });

  testWidgets('keypad: two decimals max, note suggests pillar, save adds entry', (t) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
    app = Kakebo();
    await t.pumpWidget(MaterialApp(home: Builder(builder: (c) => TextButton(onPressed: () => openAdd(c), child: const Text('apri')))));
    await t.tap(find.text('apri'));
    await t.pumpAndSettle();
    for (final k in ['1', '2', ',', '5', '0', '7']) {
      await t.tap(find.text(k));
    }
    await t.enterText(find.byType(TextField), 'Cena fuori');
    await t.pump();
    expect(find.text('12,50 €'), findsOneWidget);
    expect(find.text('Pilastro suggerito dalla nota: Desideri'), findsOneWidget);
    await t.tap(find.text('Salva'));
    expect(app.entries.single.amt, 12.5);
    expect(app.entries.single.p, 'wants');
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

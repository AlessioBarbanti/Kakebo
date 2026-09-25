import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/onboarding/onboarding.dart';
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
}

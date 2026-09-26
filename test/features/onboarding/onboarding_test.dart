import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/onboarding/onboarding.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  setUpAll(initL10n);
  setUp(() {
    setLocale(const Locale('it', 'IT'));
    Kakebo.clock = () => DateTime(2026, 9, 24, 21);
  });
  tearDown(() => Kakebo.clock = DateTime.now);

  Future<Kakebo> mount(WidgetTester t, {double scale = 1}) async {
    t.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final app = Kakebo();
    await t.pumpWidget(const SizedBox()); // a fresh intro, not the previous mount's step
    await t.pumpWidget(
      AppScope(
        notifier: app,
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: const Size(360, 800), textScaler: TextScaler.linear(scale), padding: const EdgeInsets.only(top: 24, bottom: 24)),
            child: const Scaffold(body: Onboarding()),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    return app;
  }

  final next = find.byType(FilledButton), back = find.text('Indietro'), logo = find.text('家計簿 · KAKEBO');

  testWidgets('one grid: logo, kanji, title, Skip, Next and Back keep their place, the prints fade in place', (t) async {
    final app = await mount(t);
    final grid = [t.getRect(logo), t.getRect(find.text('家計簿')), t.getRect(find.text(tr.step1Title)), t.getRect(find.text('Salta')), t.getRect(next)];

    await t.tap(next);
    await t.pump(); // starts the switch
    await t.pump(const Duration(milliseconds: 350)); // halfway through
    final prints = find.byType(Image);
    expect(prints, findsNWidgets(2)); // Suruga-chō and the plum together, one over the other
    expect({for (var i = 0; i < 2; i++) t.getRect(prints.at(i))}, hasLength(1)); // same place, no slide
    // Halfway, the old print is already half gone: it fades out, it does not wait at full strength and vanish at the end.
    final fades = [for (var i = 0; i < 2; i++) t.widget<FadeTransition>(find.ancestor(of: prints.at(i), matching: find.byType(FadeTransition)).first)];
    for (final f in fades) {
      expect(f.opacity.value, inExclusiveRange(.2, .8));
    }
    await t.pumpAndSettle();

    final backAt = t.getRect(back);
    void sameGrid(String kanji, String title) {
      expect([logo, find.text(kanji), find.text(title), find.text('Salta')].map((f) => t.getRect(f).top), [for (final r in grid.take(4)) r.top]);
      expect(t.getRect(next), grid.last, reason: 'Next keeps its place and width');
      expect(t.getRect(back), backAt);
    }

    sameGrid('四君子', tr.step2Title);
    await t.tap(next);
    await t.pumpAndSettle();
    sameGrid('四問', tr.step3Title);

    await t.tap(next);
    await t.pumpAndSettle();
    expect(find.text('Prepara settembre'), findsOneWidget);
    expect(find.text('Salta'), findsNothing);
    expect(t.getRect(back), backAt);
    expect(t.getRect(next).right, grid.last.right, reason: 'the wider last button still ends on the right');

    await t.tap(find.text('Inizia settembre'));
    expect(app.onboarded, isTrue);
    expect(app.screen, 'home');
  });

  testWidgets('every step fits 360 px in both languages, at 1× and 2× text', (t) async {
    for (final locale in ['it', 'en']) {
      for (final scale in [1.0, 2.0]) {
        setLocale(Locale(locale));
        await mount(t, scale: scale);
        for (var i = 0; i < 4; i++) {
          expect(t.takeException(), isNull, reason: '$locale ×$scale step $i');
          if (i < 3) await t.tap(next);
          await t.pumpAndSettle();
        }
      }
    }
  });

  testWidgets('Skip opens the setup; its three answers save, a blank fixed cost waits open, a swipe never starts the month', (t) async {
    final app = await mount(t);
    await t.tap(find.text('Salta'));
    await t.pumpAndSettle();
    expect(find.text('Prepara settembre'), findsOneWidget);

    // Swipes start on the print, above the fields.
    await t.dragFrom(const Offset(180, 150), const Offset(-250, 0));
    await t.pumpAndSettle();
    expect(app.screen, 'onboarding');
    expect(find.text('Prepara settembre'), findsOneWidget);
    await t.dragFrom(const Offset(180, 150), const Offset(250, 0));
    await t.pumpAndSettle();
    expect(find.text(tr.step3Title), findsOneWidget);
    await t.tap(next);
    await t.pumpAndSettle();

    // Fields in order: income, the blank fixed cost waiting open (name, amount), the savings goal.
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));
    expect(find.text(tr.newItem), findsOneWidget);
    await t.enterText(fields.first, '3000');
    expect(app.income, 3000);
    await t.enterText(fields.at(1), 'Affitto');
    await t.enterText(fields.at(2), '900');
    expect((app.fixed.single.name, app.fixed.single.amt), ('Affitto', 900));
    await t.enterText(fields.last, '500');
    expect(app.save, 500);
    await t.ensureVisible(find.text(tr.addFixed));
    await t.tap(find.text(tr.addFixed));
    await t.pump();
    expect(app.fixed, hasLength(2));

    // A goal beyond what is left after fixed costs is allowed, but said.
    await t.enterText(find.byType(TextField).first, '1000');
    await t.enterText(find.byType(TextField).last, '3000');
    await t.pump();
    expect(find.text(tr.goalOverMargin(fmt(100))), findsOneWidget);
    expect(app.available, 0);
  });
}

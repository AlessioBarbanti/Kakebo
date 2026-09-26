// Screenshots of every screen, its top and (when it scrolls) its bottom, into screenshots/<screen>/:
//   flutter test tool/screenshots_test.dart
// Pixel 9 size (1080 × 2424), Italian, the design's demo data on 24 September 2026 at 21:30.
// Drawn by the test engine with the app's fonts and art; no status bar, navigation bar or keyboard.
// The screenshots folder is emptied first, so it always matches the current app.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/bootstrap.dart' show artwork;
import 'package:kakebo/app/kakebo_app.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/features/home/home.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/state/kakebo.dart';

typedef Act = Future<void> Function(WidgetTester t, Kakebo app);

Future<void> _tap(WidgetTester t, Finder f) async {
  await t.tap(f);
  await _settle(t);
}

// Frame by frame for 3 s, so chained timers and animations (intro steps, tab fades) finish;
// not pumpAndSettle, because the breathing circle never settles.
Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 30; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

/// Folder, file name, screen to open, what to do there before shooting.
final List<(String, String, String, Act?)> _shots = [
  for (var i = 0; i < 4; i++)
    (
      'onboarding',
      '${i + 1}',
      'onboarding',
      (t, _) async {
        for (var n = 0; n < i; n++) {
          await _tap(t, find.text(tr.next));
        }
      },
    ),
  (
    'onboarding',
    '4_fixed_open',
    'onboarding',
    (t, _) async {
      await _tap(t, find.text(tr.skip));
      await _tap(t, find.text(tr.fixedTitle));
    },
  ),
  ('home', 'evening', 'home', null),
  ('home', 'saying_open', 'home', (t, _) => _tap(t, find.byType(DailyPhrase))),
  ('add_expense', 'new', 'home', (t, _) => _tap(t, find.text(tr.addExpense))),
  ('add_expense', 'edit', 'home', (t, app) => _tap(t, find.text(app.today.first.note))),
  ('ledger', 'month', 'ledger', null),
  ('ledger', 'week', 'ledger', (t, _) => _tap(t, find.text(tr.thisWeek))),
  ('ledger', 'pillar_open', 'ledger', (t, _) => _tap(t, find.text(tr.pillarNeeds).last)),
  ('journal', 'journal', 'journal', null),
  ('review', 'review', 'review', null),
  ('calendar', 'month', 'calendar', null),
  ('calendar', 'year', 'calendar', (t, _) => _tap(t, find.text(tr.year))),
  ('settings', 'settings', 'settings', null),
  ('month_start', 'month_start', 'monthStart', null),
  ('month_start', 'rule_open', 'monthStart', (t, _) => _tap(t, find.text(tr.ruleTitle))),
  ('thought', 'breathe', 'thought', null),
  ('thought', 'write', 'thought', (t, _) => _tap(t, find.text(tr.ready))),
  (
    'thought',
    'saved',
    'thought',
    (t, app) async {
      app.update(() => app.thoughts[dateKey(app.now)] = 'Il profumo del tè sul balcone.');
      await _settle(t);
    },
  ),
];

void main() {
  testWidgets('screenshots of every screen', (t) async {
    await initL10n();
    setLocale(const Locale('it', 'IT'));
    // Both: MaterialApp resolves from the list, so the Material texts and the 24-hour clock are Italian too.
    t.platformDispatcher.localeTestValue = const Locale('it', 'IT');
    t.platformDispatcher.localesTestValue = const [Locale('it', 'IT')];
    t.view
      ..physicalSize = const Size(1080, 2424)
      ..devicePixelRatio = 2.625;
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearLocaleTestValue);
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    for (final (family, files) in [
      ('Shippori Mincho', ['ShipporiMincho-Medium', 'ShipporiMincho-SemiBold', 'ShipporiMincho-Bold']),
      ('Zen Kaku Gothic New', ['ZenKakuGothicNew-Regular', 'ZenKakuGothicNew-Medium', 'ZenKakuGothicNew-Bold']),
    ]) {
      final loader = FontLoader(family);
      for (final f in files) {
        loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
      }
      await loader.load();
    }
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    Kakebo.clock = () => DateTime(2026, 9, 24, 21, 30);
    addTearDown(() => Kakebo.clock = DateTime.now);
    debugDisableShadows = false; // real elevation shadows instead of the test engine's black outlines

    final out = Directory('screenshots');
    if (out.existsSync()) out.deleteSync(recursive: true);
    final key = GlobalKey();
    Future<void> save(String path) => t.runAsync(() async {
      final image = await (key.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: 2.625);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('${out.path}/$path.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });

    try {
      for (final (folder, name, screen, act) in _shots) {
        // A fresh app for every shot: scroll position and each screen's own state start over.
        await t.pumpWidget(const SizedBox());
        final app = Kakebo()
          ..seedDemo()
          ..onboarded = true
          ..flags['sound'] =
              false // no audio plugin in tests
          ..screen = screen;
        await t.pumpWidget(
          RepaintBoundary(
            key: key,
            child: AppScope(notifier: app, child: const KakeboApp()),
          ),
        );
        await t.runAsync(() => Future.wait([for (final a in artwork) precacheImage(AssetImage(a), t.element(find.byType(KakeboApp)))]));
        await _settle(t);
        if (act != null) await act(t, app);
        await save('$folder/${name}_top');

        // The bottom sheet scrolls on its own; everything else scrolls in the screen's first scroll view.
        final sheet = find.descendant(of: find.byType(AddSheet), matching: find.byType(Scrollable));
        final position = t.state<ScrollableState>(sheet.evaluate().isNotEmpty ? sheet.first : find.byType(Scrollable).first).position;
        if (position.maxScrollExtent > 0) {
          position.jumpTo(position.maxScrollExtent);
          await _settle(t);
          await save('$folder/${name}_bottom');
        }
      }
      await t.pumpWidget(const SizedBox());
    } finally {
      debugDisableShadows = true; // the test binding checks it is back on
    }
  });
}

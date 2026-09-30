// Screenshots of every screen, its top and (when it scrolls) its bottom, into screenshots/<screen>/:
//   flutter test tool/screenshots_test.dart --plain-name "every screen"
// Pixel 9 size (1080 × 2424), Italian, the demo data on 24 September 2026 at 21:30.
// The Google Play images, in Italian and English, into fastlane/metadata/android/<language>/images/:
//   flutter test tool/screenshots_test.dart --plain-name "Google Play"
// Phone screenshots at 1080 × 2160 (Play takes at most 2:1) and the 1024 × 500 feature graphic.
// Drawn by the test engine with the app's fonts and art; no status bar, navigation bar or keyboard.
// Every PNG is saved without alpha, as Play asks. Each output folder is emptied first, so it always matches the current app.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/bootstrap.dart' show artwork;
import 'package:kakebo/app/kakebo_app.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/features/expenses/receipt_photo.dart';
import 'package:kakebo/features/home/home.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/receipt.dart';
import 'package:kakebo/services/receipt_scanner.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';
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
  ('home', 'evening', 'home', null),
  ('home', 'saying_open', 'home', (t, _) => _tap(t, find.byType(DailyPhrase))),
  ('add_expense', 'new', 'home', (t, _) => _tap(t, find.text(tr.addExpense))),
  ('add_expense', 'edit', 'home', (t, app) => _tap(t, find.text(app.today.first.note))),
  ('add_expense', 'receipt', 'home', (t, _) => _receipt(t)),
  (
    'add_expense',
    'receipt_photo',
    'home',
    (t, _) async {
      await _receipt(t);
      await _tap(t, find.byType(ReceiptThumb));
    },
  ),
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
  (
    'thought',
    'breathe',
    'home',
    (t, app) async {
      app.update(() => app.flags['breathe'] = true); // the meditation is off unless chosen in Settings
      app.go('thought');
      await _settle(t);
    },
  ),
  ('thought', 'write', 'thought', null),
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

/// A new expense read from a receipt: recognition swapped for the receipt's rows, and a drawing of it as the photo kept.
Future<void> _receipt(WidgetTester t) async {
  const rows = ['ESSELUNGA S.P.A.', 'DOCUMENTO COMMERCIALE', 'LATTE INTERO 1,29', 'PANE COMUNE 2,10', 'TOTALE COMPLESSIVO 23,40', '23-09-2026 18:42'];
  final real = ReceiptScanner.read, folder = Directory.systemTemp.createTempSync('receipts');
  ReceiptPhotos.dir = folder;
  addTearDown(() {
    ReceiptScanner.read = real;
    ReceiptPhotos.dir = null;
    folder.deleteSync(recursive: true);
  });
  final paper = img.Image(width: 600, height: 800)..clear(img.ColorRgb8(120, 104, 88)); // on a wooden table
  img.fillRect(paper, x1: 90, y1: 30, x2: 510, y2: 800, color: img.ColorRgb8(250, 248, 242));
  for (final (i, r) in rows.indexed) {
    img.drawString(paper, r, font: img.arial24, x: 120, y: 80 + i * 60, color: img.ColorRgb8(70, 70, 70));
  }
  final photo = File('${folder.path}/receipt.png')..writeAsBytesSync(img.encodePng(paper));
  ReceiptScanner.read = ({required camera}) async => (
    lines: [
      for (final (i, r) in rows.indexed) ReceiptLine(r, [(0, i * 30.0), (300, i * 30.0), (300, i * 30.0 + 20), (0, i * 30.0 + 20)]),
    ],
    photo: 'receipt.png',
  );
  // Decoded before any widget asks for it: a load started under the test's fake clock would never finish.
  final app = t.element(find.byType(KakeboApp));
  await t.runAsync(
    () => Future.wait([
      precacheImage(ResizeImage(FileImage(photo), width: (34 * t.view.devicePixelRatio).round()), app), // the thumbnail
      precacheImage(FileImage(photo), app), // the photo opened whole
    ]),
  );
  await _tap(t, find.text(tr.addExpense));
  await _tap(t, find.byTooltip(tr.scanReceipt));
  await _tap(t, find.text(tr.receiptCamera));
}

/// The Play listing's screenshots, in the order the store shows them: screen, what to do there.
final List<(String, Act?)> _play = [
  ('onboarding', null),
  ('home', null),
  ('home', (t, _) => _tap(t, find.text(tr.addExpense))),
  ('ledger', null),
  ('calendar', null),
  ('calendar', (t, _) => _tap(t, find.text(tr.year))),
  ('journal', null),
  ('review', null),
];

/// Play language folder, locale, the feature graphic's line (broken by hand, so its two lines balance).
const _listings = [('it-IT', Locale('it', 'IT'), 'Il registro\ndi casa giapponese'), ('en-US', Locale('en', 'US'), 'The Japanese\nhousehold ledger')];

final _key = GlobalKey();

/// The app's fonts, the demo clock and real shadows, then [shoot]; everything is put back afterwards.
Future<void> _session(WidgetTester t, Future<void> Function() shoot) async {
  await initL10n();
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
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearLocaleTestValue);
  addTearDown(t.platformDispatcher.clearLocalesTestValue);
  debugDisableShadows = false; // real elevation shadows instead of the test engine's black outlines
  try {
    await shoot();
    await t.pumpWidget(const SizedBox());
  } finally {
    debugDisableShadows = true; // the test binding checks it is back on
  }
}

void _locale(WidgetTester t, Locale locale) {
  setLocale(locale);
  // Both: MaterialApp resolves from the list, so the Material texts and the 24-hour clock follow too.
  t.platformDispatcher.localeTestValue = locale;
  t.platformDispatcher.localesTestValue = [locale];
}

void _size(WidgetTester t, Size size, double ratio) => t.view
  ..physicalSize = size
  ..devicePixelRatio = ratio;

/// A fresh app for every shot, on [screen] with the demo data: scroll position and each screen's own state start over.
Future<Kakebo> _open(WidgetTester t, String screen, Act? act) async {
  await t.pumpWidget(const SizedBox());
  final app = Kakebo()
    ..seedDemo()
    ..onboarded = true
    ..flags['sound'] =
        false // no audio plugin in tests
    ..screen = screen;
  await t.pumpWidget(
    RepaintBoundary(
      key: _key,
      child: AppScope(notifier: app, child: const KakeboApp()),
    ),
  );
  await t.runAsync(() => Future.wait([for (final a in artwork) precacheImage(AssetImage(a), t.element(find.byType(KakeboApp)))]));
  await _settle(t);
  if (act != null) await act(t, app);
  return app;
}

/// What is on screen, as a PNG without alpha.
Future<void> _save(WidgetTester t, String path) => t.runAsync(() async {
  final image = await (_key.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: t.view.devicePixelRatio);
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgb = img.Image.fromBytes(width: image.width, height: image.height, bytes: rgba!.buffer, numChannels: 4).convert(numChannels: 3);
  image.dispose();
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(rgb));
});

void main() {
  testWidgets('screenshots of every screen', (t) async {
    await _session(t, () async {
      _locale(t, const Locale('it', 'IT'));
      _size(t, const Size(1080, 2424), 2.625);
      final out = Directory('screenshots');
      if (out.existsSync()) out.deleteSync(recursive: true);
      for (final (folder, name, screen, act) in _shots) {
        await _open(t, screen, act);
        await _save(t, '${out.path}/$folder/${name}_top.png');

        // The bottom sheet scrolls on its own; everything else scrolls in the screen's first scroll view.
        final sheet = find.descendant(of: find.byType(AddSheet), matching: find.byType(Scrollable));
        final position = t.state<ScrollableState>(sheet.evaluate().isNotEmpty ? sheet.first : find.byType(Scrollable).first).position;
        if (position.maxScrollExtent > 0) {
          position.jumpTo(position.maxScrollExtent);
          await _settle(t);
          await _save(t, '${out.path}/$folder/${name}_bottom.png');
        }
      }
    });
  });

  testWidgets('Google Play images', (t) async {
    await _session(t, () async {
      for (final (language, locale, line) in _listings) {
        _locale(t, locale);
        final out = Directory('fastlane/metadata/android/$language/images');
        if (out.existsSync()) out.deleteSync(recursive: true);

        _size(t, const Size(1080, 2160), 2.625);
        for (final (i, (screen, act)) in _play.indexed) {
          await _open(t, screen, act);
          await _save(t, '${out.path}/phoneScreenshots/${i + 1}.png');
        }

        _size(t, const Size(1024, 500), 1);
        await t.pumpWidget(RepaintBoundary(key: _key, child: _FeatureGraphic(line)));
        await t.runAsync(() => precacheImage(const AssetImage(_FeatureGraphic.art), t.element(find.byType(_FeatureGraphic))));
        await t.pump();
        await _save(t, '${out.path}/featureGraphic.png');
      }
    });
  });
}

/// The store's banner, laid out like the intro's first page: the name and a line on the page, Fuji fading into it.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic(this.line);

  final String line;
  static const art = 'assets/art/print_suruga.webp';

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: 620,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) =>
                  const LinearGradient(colors: [Color(0x00FFFFFF), Color(0x40FFFFFF), Colors.white], stops: [0, .35, .7]).createShader(bounds),
              child: Image.asset(art, fit: BoxFit.cover, alignment: const Alignment(0, -.75)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('家計簿 · KAKEBO', style: serif(18, ls: 2.5, c: ok(.45, .08, 10))),
                const SizedBox(height: 20),
                Text('家計簿', style: serif(96, h: 1, c: green)),
                const SizedBox(height: 24),
                Text(line, style: serif(38, h: 1.2, c: ink)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

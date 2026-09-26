import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/kakebo_app.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/services/reminders.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/state/kakebo.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Texts in the phone's language (Italian or English), money and dates in its region; followed if it changes.
  await initL10n();
  setLocale(PlatformDispatcher.instance.locale);
  // Demo/screenshot helpers: --dart-define=DEMO=true --dart-define=TODAY=2026-09-24T21:30
  const demo = bool.fromEnvironment('DEMO'), today = String.fromEnvironment('TODAY');
  if (today.isNotEmpty) Kakebo.clock = () => DateTime.parse(today);
  // Decode every artwork while the launch screen is still up, so no screen waits for an image.
  final (loaded, _) = await (Kakebo.load(), _precache()).wait;
  final app = loaded;
  WidgetsBinding.instance.addObserver(_LocaleWatcher(app));
  if (demo && app.entries.isEmpty) app.seedDemo();
  await Reminders(app).init();
  // Frame-time log for tuning animations on a real phone: --dart-define=FRAMES=true, then `adb logcat -s flutter`.
  if (const bool.fromEnvironment('FRAMES')) {
    SchedulerBinding.instance.addTimingsCallback((ts) {
      for (final t in ts) {
        debugPrint('frame ${t.buildDuration.inMicroseconds} ${t.rasterDuration.inMicroseconds} ${t.totalSpan.inMicroseconds}');
      }
    });
  }
  // Back from background: greeting, season and "today" may have moved on.
  AppLifecycleListener(onResume: app.refresh);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([tr.prints], tr.printsList);
    for (final (family, file) in [(mincho, 'ShipporiMincho'), (gothic, 'ZenKakuGothicNew')]) {
      yield LicenseEntryWithLineBreaks([family], await rootBundle.loadString('assets/fonts/OFL-$file.txt'));
    }
  });
  runApp(AppScope(notifier: app, child: const KakeboApp()));
}

class _LocaleWatcher with WidgetsBindingObserver {
  _LocaleWatcher(this.app);
  final Kakebo app;
  @override
  void didChangeLocales(List<Locale>? locales) {
    setLocale(PlatformDispatcher.instance.locale);
    app.refresh();
  }
}

const artwork = [
  'assets/art/plum.jpg',
  'assets/art/bamboo.jpg',
  'assets/art/orchid.jpg',
  'assets/art/chrys.jpg',
  'assets/art/paper.webp',
  'assets/art/sprig_bamboo.webp',
  'assets/art/sprig_plum.webp',
  'assets/art/sprig_orchid.webp',
  'assets/art/sprig_chrys.webp',
];

Future<void> _precache() => Future.wait([
  for (final path in artwork)
    () {
      final done = Completer<void>(), stream = AssetImage(path).resolve(ImageConfiguration.empty);
      late final ImageStreamListener l;
      void finish() {
        stream.removeListener(l); // the decoded image stays in the ImageCache
        done.complete();
      }

      l = ImageStreamListener((_, _) => finish(), onError: (_, _) => finish());
      stream.addListener(l);
      return done.future;
    }(),
]);

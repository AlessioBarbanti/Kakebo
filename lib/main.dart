import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'intro.dart';
import 'kakebo.dart';
import 'notify.dart';
import 'shell.dart';
import 'thought.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Texts in the phone's language (Italian or English), money and dates in its region; followed if it changes.
  await initL10n();
  setLocale(PlatformDispatcher.instance.locale);
  WidgetsBinding.instance.addObserver(_LocaleWatcher());
  // Demo/screenshot helpers: --dart-define=DEMO=true --dart-define=TODAY=2026-09-24T21:30 (web also ?today=…&screen=…)
  const demo = bool.fromEnvironment('DEMO');
  final today = (demo ? Uri.base.queryParameters['today'] : null) ?? const String.fromEnvironment('TODAY');
  if (today.isNotEmpty) Kakebo.clock = () => DateTime.parse(today);
  // Decode every artwork while the launch screen is still up, so no screen waits for an image.
  final (loaded, _) = await (Kakebo.load(), _precache()).wait;
  app = loaded;
  if (demo) {
    if (app.entries.isEmpty) app.seedDemo();
    app.screen = Uri.base.queryParameters['screen'] ?? app.screen;
  }
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
  @override
  void didChangeLocales(List<Locale>? locales) {
    setLocale(PlatformDispatcher.instance.locale);
    app.refresh();
  }
}

const artwork = ['assets/art/plum.jpg', 'assets/art/bamboo.jpg', 'assets/art/orchid.jpg', 'assets/art/chrys.jpg', 'assets/art/ink_plum_wash.png'];

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

class KakeboApp extends StatelessWidget {
  const KakeboApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kakebo',
    debugShowCheckedModeBanner: false,
    supportedLocales: const [Locale('it'), Locale('en')],
    // Same choice as setLocale: Italian, otherwise English (Material dialogs match the app's texts).
    // Keeping the country gives e.g. en_GB its 24-hour clock in the time picker.
    localeResolutionCallback: (l, _) => l?.languageCode == 'it' ? Locale('it', l?.countryCode) : Locale('en', l?.languageCode == 'en' ? l?.countryCode : null),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: green, surface: bg, onSurface: ink),
      scaffoldBackgroundColor: bg,
      fontFamily: gothic,
    ),
    home: const Root(),
  );
}

class Root extends StatelessWidget {
  const Root({super.key});

  static String _back(String s) => switch (s) {
    'review' => 'journal',
    'monthStart' when !app.onboarded => 'onboarding',
    _ => 'home',
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final s = app.screen;
      return PopScope(
        canPop: s == 'home' || (s == 'onboarding' && !app.onboarded),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) app.go(_back(s));
        },
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Backdrop(),
              // Keeps screen animations from repainting the backdrop, and vice versa.
              RepaintBoundary(
                child: switch (s) {
                  'onboarding' => const Onboarding(),
                  'monthStart' => const MonthStart(),
                  'thought' => const Thought(),
                  _ => const Shell(),
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Seasonal wash behind every screen: a soft sun, an ink plum branch, two petals.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key});

  @override
  Widget build(BuildContext context) {
    watch(context);
    final s = app.season;
    Widget circle(double size, Color c) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c),
    );
    return RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Stack(
            children: [
              Positioned(top: -150, right: -130, child: circle(400, s.soft.withValues(alpha: .85))),
              // Pre-baked by tool/wash.dart: grayscale, contrast, radial fade and 22% opacity.
              Positioned(top: -30, right: -70, width: 320, height: 460, child: Image.asset('assets/art/ink_plum_wash.png', fit: BoxFit.fill)),
              Positioned(top: 150, right: 70, child: circle(16, s.bloom.withValues(alpha: .8))),
              Positioned(top: 200, right: 36, child: circle(8, s.bloom.withValues(alpha: .8))),
              Positioned(bottom: -190, left: -170, child: circle(440, ok(.93, .04, 150, .7))),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'intro.dart';
import 'kakebo.dart';
import 'shell.dart';
import 'thought.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Demo/screenshot helpers: --dart-define=TODAY=2026-09-24T21:30 --dart-define=DEMO=true
  const today = String.fromEnvironment('TODAY');
  if (today.isNotEmpty) Kakebo.clock = () => DateTime.parse(today);
  app = await Kakebo.load();
  if (const bool.fromEnvironment('DEMO')) {
    if (app.entries.isEmpty) app.seedDemo();
    app.screen = Uri.base.queryParameters['screen'] ?? app.screen; // web screenshots: ?screen=ledger
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KakeboApp());
}

class KakeboApp extends StatelessWidget {
  const KakeboApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kakebo',
    debugShowCheckedModeBanner: false,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: green, surface: bg),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.zenKakuGothicNewTextTheme().apply(bodyColor: ink, displayColor: ink),
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
              switch (s) {
                'onboarding' => const Onboarding(),
                'monthStart' => const MonthStart(),
                'thought' => const Thought(),
                _ => const Shell(),
              },
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
    final s = app.season;
    Widget circle(double size, Color c) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c),
    );
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          children: [
            Positioned(top: -150, right: -130, child: circle(400, s.soft.withValues(alpha: .85))),
            Positioned(
              top: -30,
              right: -70,
              width: 320,
              height: 460,
              child: Opacity(
                opacity: .22,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const RadialGradient(
                    center: Alignment(.3, -.3),
                    radius: .69,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0, .35, .75],
                  ).createShader(r),
                  child: ColorFiltered(
                    // grayscale(1) contrast(1.25)
                    colorFilter: const ColorFilter.matrix([
                      .26575, .894, .09025, 0, -31.875, //
                      .26575, .894, .09025, 0, -31.875,
                      .26575, .894, .09025, 0, -31.875,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Image.asset('assets/art/ink_plum.jpg', fit: BoxFit.cover, alignment: const Alignment(-.2, -.5)),
                  ),
                ),
              ),
            ),
            Positioned(top: 150, right: 70, child: circle(16, s.bloom.withValues(alpha: .8))),
            Positioned(top: 200, right: 36, child: circle(8, s.bloom.withValues(alpha: .8))),
            Positioned(bottom: -190, left: -170, child: circle(440, ok(.93, .04, 150, .7))),
          ],
        ),
      ),
    );
  }
}

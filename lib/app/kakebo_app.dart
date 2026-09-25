import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:kakebo/app/root.dart';
import 'package:kakebo/shared/theme/tokens.dart';

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

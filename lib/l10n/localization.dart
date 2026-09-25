import 'dart:ui';

export 'generated/app_localizations.dart';
import 'formatters.dart';
import 'generated/app_localizations.dart';

/// Texts in the phone's language (Italian, otherwise English), from lib/l10n/app_*.arb.
AppLocalizations tr = lookupAppLocalizations(const Locale('it'));

void setLocale(Locale device) {
  tr = lookupAppLocalizations(Locale(device.languageCode == 'it' ? 'it' : 'en'));
  setFormatLocale(device, tr.code);
}

typedef PillarText = ({String name, String jp, String virtue});
typedef StepText = ({String title, String body, String cta});

/// The ARB files are flat; these put the numbered messages back into the lists the app walks through.
extension Lists on AppLocalizations {
  String get code => localeName;
  Map<String, PillarText> get pillars => {
    'needs': (name: pillarNeeds, jp: pillarNeedsJp, virtue: pillarNeedsVirtue),
    'wants': (name: pillarWants, jp: pillarWantsJp, virtue: pillarWantsVirtue),
    'culture': (name: pillarCulture, jp: pillarCultureJp, virtue: pillarCultureVirtue),
    'unexpected': (name: pillarUnexpected, jp: pillarUnexpectedJp, virtue: pillarUnexpectedVirtue),
  };
  Map<String, (String, String)> get seasons => {
    'winter': (seasonWinter, seasonWinterPlant),
    'spring': (seasonSpring, seasonSpringPlant),
    'summer': (seasonSummer, seasonSummerPlant),
    'autumn': (seasonAutumn, seasonAutumnPlant),
  };
  List<String> get proverbs => [proverb1Meaning, proverb2Meaning, proverb3Meaning, proverb4Meaning, proverb5Meaning, proverb6Meaning, proverb7Meaning];
  List<String> get defaultFixed => [defaultFixed1, defaultFixed2, defaultFixed3, defaultFixed4, defaultFixed5];
  List<String> get csvHeader => [csvDate, csvNote, csvAmount, csvPillar];
  List<StepText> get steps => [
    (title: step1Title, body: step1Body, cta: step1Cta),
    (title: step2Title, body: step2Body, cta: step2Cta),
    (title: step3Title, body: step3Body, cta: step3Cta),
  ];
  List<String> get fourQuestions => [fourQuestion1, fourQuestion2, fourQuestion3, fourQuestion4];
  List<String> get tabs => [tabToday, tabLedger, tabJournal, tabCalendar];
  String weekText(bool onPace, String pillar, int quietDays) =>
      '${weekPace('$onPace')}. ${weekFullest(pillar)}${quietDays >= 2 ? ' ${weekQuiet(quietDays)}' : ''}';
}

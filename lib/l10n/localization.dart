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

typedef PillarText = ({String name, String virtue});
typedef StepText = ({String title, String body});

/// The ARB files are flat; these put the numbered messages back into the lists the app walks through.
extension Lists on AppLocalizations {
  String get code => localeName;
  Map<String, PillarText> get pillars => {
    'needs': (name: pillarNeeds, virtue: pillarNeedsVirtue),
    'wants': (name: pillarWants, virtue: pillarWantsVirtue),
    'culture': (name: pillarCulture, virtue: pillarCultureVirtue),
    'unexpected': (name: pillarUnexpected, virtue: pillarUnexpectedVirtue),
  };
  Map<String, (String, String)> get seasons => {
    'winter': (seasonWinter, seasonWinterPlant),
    'spring': (seasonSpring, seasonSpringPlant),
    'summer': (seasonSummer, seasonSummerPlant),
    'autumn': (seasonAutumn, seasonAutumnPlant),
  };

  /// Meaning of each saying in `phrases` (seasons.dart), with its source; null for a traditional Japanese saying.
  List<(String, String?)> get phraseMeanings => [
    (phrase1, null),
    (phrase2, phrase2Source),
    (phrase3, null),
    (phrase4, phrase4Source),
    (phrase5, null),
    (phrase6, null),
    (phrase7, null),
    (phrase8, phrase8Source),
    (phrase9, null),
    (phrase10, null),
    (phrase11, phrase11Source),
    (phrase12, null),
    (phrase13, phrase13Source),
    (phrase14, null),
    (phrase15, null),
    (phrase16, null),
    (phrase17, phrase17Source),
    (phrase18, null),
    (phrase19, null),
    (phrase20, phrase20Source),
    (phrase21, null),
    (phrase22, null),
    (phrase23, phrase23Source),
    (phrase24, null),
    (phrase25, null),
    (phrase26, null),
    (phrase27, phrase27Source),
    (phrase28, null),
    (phrase29, null),
    (phrase30, null),
  ];
  List<String> get defaultFixed => [defaultFixed1, defaultFixed2, defaultFixed3, defaultFixed4, defaultFixed5];
  List<String> get csvHeader => [csvDate, csvNote, csvAmount, csvPillar];
  List<StepText> get steps => [(title: step1Title, body: step1Body), (title: step2Title, body: step2Body), (title: step3Title, body: step3Body)];
  List<String> get fourQuestions => [fourQuestion1, fourQuestion2, fourQuestion3, fourQuestion4];
  List<String> get tabs => [tabToday, tabLedger, tabJournal, tabCalendar];
}

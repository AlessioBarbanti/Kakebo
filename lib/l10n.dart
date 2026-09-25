import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';

export 'l10n/app_localizations.dart';

/// Texts in the phone's language (Italian, otherwise English), from lib/l10n/app_*.arb.
AppLocalizations tr = lookupAppLocalizations(const Locale('it'));

// Dates follow the app's language; money and numbers follow the phone's region (it_IT → "1.650 €", en_GB → "£1,650").
String _dates = 'it';
NumberFormat _money0 = NumberFormat.simpleCurrency(locale: 'it_IT', decimalDigits: 0);
NumberFormat _money2 = NumberFormat.simpleCurrency(locale: 'it_IT', decimalDigits: 2);

Future<void> initL10n() => initializeDateFormatting();

void setLocale(Locale device) {
  tr = lookupAppLocalizations(Locale(device.languageCode == 'it' ? 'it' : 'en'));
  // verifiedLocale falls back from e.g. fr_FR to fr when the region has no data of its own.
  final c = device.countryCode == null ? '' : '_${device.countryCode}';
  _dates = Intl.verifiedLocale('${tr.code}$c', DateFormat.localeExists, onFailure: (_) => tr.code)!;
  final money = Intl.verifiedLocale('${device.languageCode}$c', NumberFormat.localeExists, onFailure: (_) => _dates)!;
  _money0 = NumberFormat.simpleCurrency(locale: money, decimalDigits: 0);
  _money2 = NumberFormat.simpleCurrency(locale: money, decimalDigits: 2);
}

/// Money like the design: whole amounts without decimals ("850 €"), otherwise two ("12,80 €").
String fmt(num n) => (n % 1 != 0 ? _money2 : _money0).format((n * 100).round() / 100);

/// An amount being typed ("12," while entering 12,50), with the currency where the region puts it.
String money(String typed) => '${_money0.positivePrefix}${typed.replaceAll('.', _money0.symbols.DECIMAL_SEP)}${_money0.positiveSuffix}';
String get currency => _money0.currencySymbol;
String get decimalSep => _money0.symbols.DECIMAL_SEP;

String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String dayLabel(DateTime d) => cap(DateFormat.MMMMEEEEd(_dates).format(d)); // Giovedì 24 settembre
String shortDay(DateTime d) => cap(DateFormat.MMMEd(_dates).format(d)); // Gio 24 set
String dayMonth(DateTime d) => DateFormat.MMMd(_dates).format(d); // 24 set
String monthName(DateTime d) => DateFormat.MMMM(_dates).format(d); // settembre / September
String monthTitle(DateTime d) => cap(monthName(d)); // Settembre
String monthYearCaps(DateTime d) => DateFormat.yMMMM(_dates).format(d).toUpperCase(); // SETTEMBRE 2026
String monthLetter(int month) => DateFormat('MMMMM', _dates).format(DateTime(2026, month));
List<String> get weekdayLetters => [for (var i = 21; i < 28; i++) DateFormat('EEEEE', _dates).format(DateTime(2026, 9, i))]; // from Monday

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

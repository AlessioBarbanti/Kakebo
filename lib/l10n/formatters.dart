import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Dates follow the app's language; money and numbers follow the phone's region (it_IT → "1.650 €", en_GB → "£1,650").
String _dates = 'it';
NumberFormat _money0 = NumberFormat.simpleCurrency(locale: 'it_IT', decimalDigits: 0);
NumberFormat _money2 = NumberFormat.simpleCurrency(locale: 'it_IT', decimalDigits: 2);

Future<void> initL10n() => initializeDateFormatting();

void setFormatLocale(Locale device, String language) {
  // verifiedLocale falls back from e.g. fr_FR to fr when the region has no data of its own.
  final c = device.countryCode == null ? '' : '_${device.countryCode}';
  _dates = Intl.verifiedLocale('$language$c', DateFormat.localeExists, onFailure: (_) => language)!;
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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:kakebo/app/kakebo_app.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/features/home/home.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/time.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/state/kakebo.dart';

/// The home screen widget (android/…/KakeboWidget.kt): one question per moment, as the app itself asks it.
/// - the day: what is left this month and about how much a day, as on Today; + or a pillar to add an expense;
/// - the evening, from the thought's time until 4 while it is unwritten (and reminders are on): the evening question;
/// - once the month is over and waits for its seal: the month to close, as in the Diary.
/// Below, the month as a line: ink for the share of what is available already spent, a notch for today.
/// Android draws it on its own, so the app works out every moment ahead, each from the time it begins, as it will be if
/// nothing more is spent; it sends them again whenever anything changes.
class HomeScreenWidget {
  HomeScreenWidget(this.k);
  final Kakebo k;
  static const _channel = MethodChannel('kakebo/widget');
  String? _sent;

  Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'open') _open(call.arguments as Map?);
    });
    k.addListener(_send);
    _send();
    _open(await _channel.invokeMethod<Map>('launch'));
  }

  /// Only when something shown changes: typing the month's numbers saves at every key, and most saves change nothing here.
  void _send() {
    if (!k.onboarded) return;
    final texts = jsonEncode({'frames': frames(k), 'texts': _texts()});
    if (texts == _sent) return;
    _sent = texts;
    _channel.invokeMethod('show', texts);
  }

  static Map<String, Object> _texts() => {
    'add': tr.addExpense,
    'write': tr.writeThought,
    for (final MapEntry(:key, value: p) in tr.pillars.entries) key: '${tr.addExpense}: ${p.name}',
  };

  /// A tap on the widget: Today with the add sheet (with its pillar, if one was tapped), the evening thought or the review.
  void _open(Map? tap) {
    if (tap == null || !k.onboarded) return;
    switch (tap['screen']) {
      case 'thought' || 'review':
        k.go(tap['screen'] as String);
      case 'add':
        k.go('home');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final nav = KakeboApp.navigator.currentState!..popUntil((r) => r.isFirst);
          openAdd(nav.context, pillar: tap['pillar'] as String?);
        });
    }
  }
}

/// The widget's moments from now until the next month has begun (its first night over), each with the time it starts
/// (0: already). A moment changes only at midnight, at 4 in the morning or at the thought's time, so those are the times
/// looked at. What comes after needs the new month's figures: the app sends them when it next opens.
List<Map<String, Object>> frames(Kakebo k) {
  final now = k.now, end = k.period.end, last = DateTime(end.year, end.month, end.day, Kakebo.nightEnd);
  final (h, m) = hm(k.thoughtTime);
  final times = <DateTime>[
    for (var d = DateTime(now.year, now.month, now.day); !d.isAfter(end); d = DateTime(d.year, d.month, d.day + 1)) ...[
      d,
      DateTime(d.year, d.month, d.day, Kakebo.nightEnd),
      DateTime(d.year, d.month, d.day, h, m),
    ],
  ]..sort();
  final out = <Map<String, Object>>[];
  for (final t in [now, ...times.where((t) => t.isAfter(now) && !t.isAfter(last))]) {
    final f = _moment(k, t);
    if (out.isEmpty || jsonEncode({...out.last}..remove('at')) != jsonEncode(f)) out.add({'at': t == now ? 0 : t.millisecondsSinceEpoch, ...f});
  }
  return out;
}

Map<String, Object> _moment(Kakebo k, DateTime t) {
  final over = !t.isBefore(k.period.end);
  if (k.flags['thoughtOn']! && k.eveningAt(t) && k.thoughts[Kakebo.eveningOf(t)] == null) {
    return {
      'kind': 'evening',
      'kicker': tr.eveningThought,
      'title': tr.happyQuestion,
      'note': '${tr.leftFor(monthName(k.label))} ${fmt(k.left)}',
      'button': tr.write,
      ..._line(k, k.period, daysBetween(k.period.start, DateTime.parse(Kakebo.eveningOf(t))) + 1), // after midnight, still that evening's day
    };
  }
  // The month waiting for its seal: the one before now, or this one once it is over.
  if (over ? k.used(k.period) : k.canSeal) {
    final p = over ? k.period : k.previous, next = k.periodAt(p.end);
    return {
      'kind': 'close',
      'kicker': tr.closeBy(dayMonth(next.last)),
      'title': tr.widgetSealTitle(monthTitle(k.labelOf(p))),
      'small': tr.widgetClose(monthName(k.labelOf(p))),
      'note': tr.widgetSaved(fmt(k.onTrackIn(p)), fmt(k.planOf(p).save)),
      'button': tr.widgetReview,
      ..._line(k, p, p.days),
    };
  }
  final d = (daysBetween(k.period.start, t) + 1).clamp(1, k.dim); // a month with nothing written, over: its last day stays
  return {
    'kind': 'day',
    'kicker': tr.leftFor(monthName(k.label)),
    'title': fmt(k.left),
    'sub': perDayText(k.left, k.dim - d, brief: true),
    ..._line(k, k.period, d),
  };
}

/// The month as a line: the share of what is available already spent, today's notch, the month's kanji.
Map<String, Object> _line(Kakebo k, Period p, int day) {
  final spent = k.spentIn(p), available = k.availableIn(p);
  final ink = available > 0 ? (spent / available).clamp(0.0, 1.0) : (spent > 0 ? 1.0 : 0.0);
  return {'ink': ink, 'tick': day / p.days, 'stamp': kanjiMesi[k.labelOf(p).month - 1], 'line': tr.spentShare((ink * 100).round())};
}

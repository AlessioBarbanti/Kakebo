import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/time.dart';
import 'package:kakebo/state/kakebo.dart';

/// Evening system notifications, kept in sync with the settings and today's diary.
/// Android only: the web build (used for screenshots) has no alarms.
class Reminders {
  Reminders(this.k);
  final Kakebo k;
  final _p = FlutterLocalNotificationsPlugin();
  bool _asked = false, _wanted = false;

  /// The running instance on Android; null on the web and in tests.
  static Reminders? instance;

  /// Whether Android lets us ring at the exact minute ("Sveglie e promemoria"); null until known.
  bool? exact;
  Timer? _debounce;

  NotificationDetails get _details => NotificationDetails(android: AndroidNotificationDetails('sera', tr.channel, channelDescription: tr.channelInfo));

  Future<void> init() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    instance = this;
    await _p.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@drawable/ic_stat_kakebo')),
      onDidReceiveNotificationResponse: (r) => _open(r.payload),
    );
    final launch = await _p.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _open(launch!.notificationResponse?.payload);
    }
    k.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 1), sync);
    });
    await sync();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Opens Android's "Sveglie e promemoria" page; the app re-checks when it comes back to the foreground.
  Future<void> askExact() async => await _android?.requestExactAlarmsPermission();

  void _open(String? payload) {
    if (k.onboarded) k.go(payload == 'thought' ? 'thought' : 'home');
  }

  // ponytail: one-shot alarms for the next 14 days, renewed each time the app opens; unopened longer → reminders pause.
  Future<void> sync() async {
    if (!k.onboarded) return;
    final thought = k.flags['thoughtOn']!, note = k.flags['reminders']!;
    if (thought || note) {
      if (!_wanted) _asked = false; // switched back on: ask again (Android stops asking after two refusals)
      if (!_asked && !const ['onboarding', 'monthStart'].contains(k.screen)) {
        _asked = true;
        await _android?.requestNotificationsPermission();
      }
    }
    _wanted = thought || note;

    final can = await _android?.canScheduleExactNotifications() ?? false;
    if (can != exact) {
      exact = can;
      k.refresh(); // show the new state in Settings
    }

    await _p.cancelAll();
    final now = k.now;
    final (th, tm) = hm(k.thoughtTime);
    final (nh, nm) = hm(k.noteTime);
    for (var d = 0; d < 14; d++) {
      final thoughtAt = DateTime(now.year, now.month, now.day + d, th, tm), noteAt = DateTime(now.year, now.month, now.day + d, nh, nm);
      if (thought && thoughtAt.isAfter(now) && !(d == 0 && k.thoughtToday != null)) {
        await _at(100 + d, thoughtAt, tr.eveningThought, tr.happyQuestion, 'thought');
      }
      if (note && noteAt.isAfter(now) && !(d == 0 && k.today.isNotEmpty)) {
        await _at(200 + d, noteAt, tr.noteTitle, tr.noteBody, 'note');
      }
    }
  }

  Future<void> _at(int id, DateTime when, String title, String body, String payload) => _p.zonedSchedule(
    id: id,
    // Local wall time → absolute instant, so DST changes are already accounted for.
    scheduledDate: tz.TZDateTime.from(when, tz.UTC),
    title: title,
    body: body,
    payload: payload,
    notificationDetails: _details,
    // Without the exact-alarm permission Android may deliver up to an hour late.
    androidScheduleMode: exact ?? false ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
  );
}

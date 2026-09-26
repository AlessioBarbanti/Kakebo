import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/model/fixed_expense.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/model/time.dart';
import 'package:kakebo/services/backup.dart';
import 'package:kakebo/services/storage.dart';

double _nz(double v) => v == 0 ? 1 : v;

class Kakebo extends ChangeNotifier {
  static DateTime Function() clock = DateTime.now;
  DateTime get now => clock();

  // Persisted.
  bool onboarded = false, rule = false;
  double income = 2800, save = 300;
  // A new ledger starts with one blank fixed cost, as if "add" had just been pressed: a row to fill, nothing to delete.
  List<Fixed> fixed = [Fixed(1, tr.newItem, 0)];
  List<Entry> entries = [];
  Map<String, String> thoughts = {}; // yyyy-mm-dd → text
  Map<String, String> improve = {}; // yyyy-mm → answer to question 4
  Map<String, Map<String, String>> reflections = {}; // budgeting month → good/change
  Map<String, String> weeklyReflections = {}; // Sunday yyyy-mm-dd → reflection
  Map<String, double> sealed = {}; // yyyy-mm → saved when sealed
  // thoughtOn: the one evening reminder; breathe: guided breaths before writing the thought (off unless chosen).
  Map<String, bool> flags = {'weekly': true, 'phraseOn': true, 'thoughtOn': true, 'breathe': false, 'sound': true};
  String thoughtTime = '21:00';
  int monthStart = 1; // day the budgeting month begins (1–28), e.g. payday
  Map<String, double>? budgets; // null → what is available, split by the pillars' shares

  // Transient.
  String screen = 'onboarding';

  KakeboStorage? _storage;

  static Future<Kakebo> load({KakeboStorage? storage}) async {
    final k = Kakebo(), store = storage ?? PreferencesStorage();
    final data = await store.load();
    if (data != null) k.read(data);
    k._storage = store;
    k.screen = k.onboarded ? 'home' : 'onboarding';
    if (k.closeForgotten()) k.notifyListeners(); // months left open since the last launch
    return k;
  }

  void read(Map j) {
    onboarded = j['onboarded'];
    rule = j['rule'];
    income = (j['income'] as num).toDouble();
    save = (j['save'] as num).toDouble();
    fixed = [for (final f in j['fixed']) Fixed(f['id'], f['name'], (f['amt'] as num).toDouble())];
    entries = [for (final e in j['entries']) Entry.fromJson(e)];
    thoughts = Map.from(j['thoughts']);
    improve = Map.from(j['improve']);
    reflections = {for (final e in (j['reflections'] as Map? ?? {}).entries) e.key as String: Map<String, String>.from(e.value as Map)};
    weeklyReflections = Map<String, String>.from(j['weeklyReflections'] as Map? ?? {});
    sealed = {for (final e in (j['sealed'] as Map).entries) e.key: (e.value as num).toDouble()};
    flags = {...flags, ...Map<String, bool>.from(j['flags'])};
    thoughtTime = j['thoughtTime'];
    monthStart = j['monthStart'] ?? 1;
    budgets = j['budgets'] == null ? null : {for (final e in (j['budgets'] as Map).entries) e.key as String: (e.value as num).toDouble()};
  }

  Map<String, Object> toJson() => {
    'onboarded': onboarded,
    'rule': rule,
    'income': income,
    'save': save,
    'fixed': [
      for (final f in fixed) {'id': f.id, 'name': f.name, 'amt': f.amt},
    ],
    'entries': entries,
    'thoughts': thoughts,
    'improve': improve,
    'reflections': reflections,
    'weeklyReflections': weeklyReflections,
    'sealed': sealed,
    'flags': flags,
    'thoughtTime': thoughtTime,
    'monthStart': monthStart,
    'budgets': ?budgets,
  };

  // ponytail: whole state rewritten as one JSON blob per change; move to drift/SQLite when history spans years.
  @override
  void notifyListeners() {
    super.notifyListeners();
    _storage?.save(toJson());
  }

  void update(VoidCallback f) {
    f();
    notifyListeners();
  }

  void go(String s) => update(() => screen = s);

  /// Redraw for a new hour/day (greeting, evening notice, "today"); saves only if a forgotten month has just sealed itself.
  void refresh() => closeForgotten() ? notifyListeners() : super.notifyListeners();

  // The current budgeting month ("period"): the calendar month unless it starts on another day.
  Period periodAt(DateTime d) {
    final s = DateTime(d.year, d.month - (d.day < monthStart ? 1 : 0), monthStart);
    return Period(s, DateTime(s.year, s.month + 1, monthStart));
  }

  Period get period => periodAt(now);

  /// A period is named after the month holding most of its days: 27 Aug – 26 Sep is September.
  DateTime labelOf(Period p) => DateTime(p.start.year, p.start.month + (monthStart > 16 ? 1 : 0));
  Period periodFor(DateTime month) => periodAt(DateTime(month.year, month.month - (monthStart > 16 ? 1 : 0), monthStart));
  DateTime get label => labelOf(period);
  List<Entry> inPeriod(Period p) => entries.where((e) => p.has(e.date)).toList();
  List<Entry> get month => inPeriod(period);
  int get day => daysBetween(period.start, now) + 1; // 1 on the period's first day
  int get dim => period.days;
  List<Entry> get today => entries.where((e) => dateKey(e.date) == dateKey(now)).toList();
  DateTime get weekStart => DateTime(now.year, now.month, now.day - now.weekday + 1);
  List<Entry> get week => entries.where((e) => !e.date.isBefore(weekStart)).toList();
  static Map<String, double> spentBy(Iterable<Entry> l) => {for (final k in pillars.keys) k: sum(l.where((e) => e.p == k))};

  double get fixedTotal => fixed.fold(0.0, (a, r) => a + r.amt);
  double get available => math.max(0, income - fixedTotal - save);
  double get spent => sum(month);
  double get left => math.max(0, available - spent);
  double get onTrack => math.max(0, income - fixedTotal - spent);
  double spentIn(Period p) => sum(inPeriod(p));
  double leftIn(Period p) => math.max(0, available - spentIn(p));
  double onTrackIn(Period p) => math.max(0, income - fixedTotal - spentIn(p));
  int get spentPct => math.min(100, (spent / _nz(available) * 100).round());

  /// Flowers on the savings branch: one per tenth of the goal, blooming while spending keeps the month's pace.
  int get bloomed => bloomedIn(period);

  /// The same for any month; one that is over counts all its days.
  int bloomedIn(Period p) {
    final elapsed = p.start == period.start ? day / dim : 1.0, pace = spentIn(p) / _nz(available) / elapsed;
    return (10 * elapsed * (pace <= 1 ? 1 : math.max(0, 2 - pace))).round();
  }

  /// From the evening thought's time until 5 in the morning.
  bool get evening {
    final (h, m) = hm(thoughtTime);
    return now.hour * 60 + now.minute >= h * 60 + m || now.hour < 5;
  }

  /// Monthly budget of a pillar: yours once set, otherwise its share of what is available.
  double budget(String k) => budgets?[k] ?? (available * pillars[k]!.share).roundToDouble();
  double get budgeted => pillars.keys.fold(0.0, (a, k) => a + budget(k));
  void setBudget(String k, double v) => update(() => budgets = {for (final p in pillars.keys) p: p == k ? v : budget(p)});
  void autoBudgets() => update(() => budgets = null);
  String? get thoughtToday => thoughts[dateKey(now)];
  String get currentIntention => improve[monthKey(DateTime(label.year, label.month - 1))]?.trim() ?? '';

  // Closing a month. It is sealed once it is over, during all of the month after it; still open when that one ends too, it
  // seals itself. At most one month waits, and dates (not month strings) carry it across the new year.

  /// The budgeting month before this one.
  Period get previous {
    final s = period.start;
    return periodAt(DateTime(s.year, s.month, s.day - 1));
  }

  /// Anything written for that month: an expense, a reflection or an intention.
  bool _used(Period p) {
    final mk = monthKey(labelOf(p));
    return entries.any((e) => p.has(e.date)) || reflections.containsKey(mk) || improve.containsKey(mk);
  }

  /// The month the review is about: the one just over while it waits for its seal, otherwise this one, still running.
  Period get reviewPeriod => _used(previous) && !sealed.containsKey(monthKey(labelOf(previous))) ? previous : period;

  /// Whether the month under review can be sealed now: only once it is over.
  bool get canSeal => reviewPeriod.start != period.start;

  /// Seals the month under review with what it saved.
  void seal() {
    if (!canSeal) return;
    final p = reviewPeriod;
    update(() => sealed[monthKey(labelOf(p))] = onTrackIn(p));
  }

  /// Seals, with their figures and no reflections, the months still open although the month after them is over too.
  /// True if any was sealed (the caller saves).
  bool closeForgotten() {
    final before = previous.start, open = <String, Period>{};
    for (final e in entries) {
      final p = periodAt(e.date);
      if (p.start.isBefore(before)) open.putIfAbsent(monthKey(labelOf(p)), () => p);
    }
    for (final mk in {...reflections.keys, ...improve.keys}) {
      final p = periodFor(DateTime.parse('$mk-01'));
      if (p.start.isBefore(before)) open.putIfAbsent(mk, () => p);
    }
    open.removeWhere((mk, _) => sealed.containsKey(mk));
    for (final MapEntry(key: mk, value: p) in open.entries) {
      sealed[mk] = onTrackIn(p);
    }
    return open.isNotEmpty;
  }

  void toggleRule() => update(() {
    rule = !rule;
    if (rule) save = (income * .2).roundToDouble();
  });

  /// A new expense, today unless [on] says another day (one written down late).
  void addEntry(double amt, String note, String p, {DateTime? on}) =>
      update(() => _insertByDate(Entry(_day(on ?? now), note.isEmpty ? tr.pillars[p]!.name : note, amt, p)));

  void editEntry(Entry old, double amt, String note, String p, {String? reflection, DateTime? on}) => update(() {
    final e = Entry(on == null ? old.date : _day(on), note.isEmpty ? tr.pillars[p]!.name : note, amt, p, reflection: reflection ?? old.reflection);
    if (e.date == old.date) {
      entries[entries.indexOf(old)] = e;
    } else {
      entries.remove(old);
      _insertByDate(e);
    }
  });

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The ledger stays newest first: an expense dated back goes first among its own day's, above the older ones.
  void _insertByDate(Entry e) {
    final i = entries.indexWhere((x) => !x.date.isAfter(e.date));
    entries.insert(i < 0 ? entries.length : i, e);
  }

  /// Removes an expense and returns where it was, for undo.
  int removeEntry(Entry e) {
    final i = entries.indexOf(e);
    update(() => entries.removeAt(i));
    return i;
  }

  void restoreEntry(int i, Entry e) => update(() => entries.insert(i, e));

  /// Full backup (everything the app stores), as a file the user keeps.
  String backup() => Backup.encode(toJson());

  /// Replaces all data with a backup; false (and nothing changed) if the file is not a Kakebo backup.
  bool restore(String text) {
    try {
      final j = Backup.decode(text);
      if (j == null) return false;
      Kakebo().read(j); // validate on a scratch copy first
      update(() {
        read(j);
        closeForgotten();
        screen = onboarded ? 'home' : 'onboarding';
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Back to a fresh install: every expense, thought and setting is gone.
  void reset() => update(() {
    read(jsonDecode(jsonEncode(Kakebo().toJson())));
    screen = 'onboarding';
  });

  /// Spreadsheet-ready for the phone's region: "1,5" with ";" where the comma is decimal, else "1.5" with ",".
  /// Starts with a BOM so Excel reads the accents.
  String csv() => Backup.csv(entries, headers: tr.csvHeader, decimalSep: decimalSep, pillarName: (key) => tr.pillars[key]!.name);

  /// Demo data, placed in the current month (`--dart-define=DEMO=true`).
  void seedDemo() {
    fixed = [
      for (final (i, amt) in const [850.0, 120.0, 30.0, 25.0, 125.0].indexed) Fixed(i + 1, tr.defaultFixed[i], amt),
    ];
    const seed = [
      (24, 'Matcha e un libro da Hondana', 12.8, 'culture'),
      (24, 'Spesa: tofu, verdure, riso', 34.2, 'needs'),
      (23, 'Ricarica abbonamento treno', 25.0, 'needs'),
      (22, 'Fiori per la tavola', 9.5, 'wants'),
      (21, 'Riparazione gomma bici', 18.0, 'unexpected'),
      (20, 'Biglietti del concerto', 42.0, 'culture'),
      (19, 'Cena con Giulia', 38.0, 'wants'),
      (18, 'Farmacia', 14.6, 'needs'),
      (15, 'Spesa settimanale', 68.4, 'needs'),
      (12, 'Ciotola in ceramica', 26.0, 'wants'),
      (10, 'Tessera del museo', 15.0, 'culture'),
      (8, 'Spesa settimanale', 71.2, 'needs'),
      (5, 'Caffè in grani', 16.0, 'wants'),
      (3, 'Dentista', 60.0, 'unexpected'),
      (2, 'Spesa settimanale', 64.9, 'needs'),
      (1, 'Quaderno e penne', 11.0, 'culture'),
    ];
    const past = [
      [520, 260, 140, 120, 360],
      [500, 190, 120, 60, 420],
      [540, 300, 180, 210, 220],
      [510, 240, 200, 90, 380],
      [530, 280, 160, 40, 440],
      [560, 340, 220, 150, 180],
      [490, 310, 260, 120, 310],
      [470, 380, 240, 80, 330],
    ];
    final shift = day - 24; // keep "today" on the demo's busiest day
    entries = [
      for (final (d, n, a, p) in seed)
        if (d + shift >= 1) Entry(DateTime(now.year, now.month, d + shift), n, a, p),
    ];
    final keys = pillars.keys.toList();
    for (var m = now.month - 1, i = past.length - 1; m >= 1 && i >= 0; m--, i--) {
      for (var k = 0; k < 4; k++) {
        entries.add(Entry(DateTime(now.year, m, 15), 'Totale del mese', past[i][k].toDouble(), keys[k]));
      }
      sealed[monthKey(DateTime(now.year, m))] = past[i][4].toDouble();
    }
    improve[monthKey(DateTime(now.year, now.month - 1))] = 'una sola cena fuori a settimana.';
    thoughts[dateKey(DateTime(now.year, now.month, day - 1))] = 'La luce sul fiume tornando a casa in bici.';
    thoughts[dateKey(DateTime(now.year, now.month, day - 2))] = 'I fiori sul tavolo di cucina.';
    notifyListeners();
  }
}

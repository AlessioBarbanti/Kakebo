import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';

export 'l10n.dart';

double _gamma(double x) => x <= 0.0031308 ? 12.92 * x : 1.055 * math.pow(x, 1 / 2.4) - 0.055;

/// CSS `oklch(l c h / a)` → sRGB, so the design tokens carry over unchanged.
Color ok(double l, double c, double h, [double alpha = 1]) {
  final r = h * math.pi / 180, a = c * math.cos(r), b = c * math.sin(r);
  double cube(double v) => v * v * v;
  final lp = cube(l + 0.3963377774 * a + 0.2158037573 * b);
  final mp = cube(l - 0.1055613458 * a - 0.0638541728 * b);
  final sp = cube(l - 0.0894841775 * a - 1.2914855480 * b);
  double ch(double v) => _gamma(v).clamp(0.0, 1.0);
  return Color.from(
    alpha: alpha,
    red: ch(4.0767416621 * lp - 3.3077115913 * mp + 0.2309699292 * sp),
    green: ch(-1.2684380046 * lp + 2.6097574011 * mp - 0.3413193965 * sp),
    blue: ch(-0.0041960863 * lp - 0.7034186147 * mp + 1.7076147010 * sp),
  );
}

const kanjiMesi = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];
String dateKey(DateTime d) => d.toIso8601String().substring(0, 10);
String monthKey(DateTime d) => d.toIso8601String().substring(0, 7);

/// One of the four pillars; its words come in the app's language.
class Pillar {
  Pillar({required this.key, required this.kanji, required this.ink, required this.soft, required this.share, required this.img, required this.pos});
  final String key, kanji, img;
  final Color ink, soft;
  final double share;
  final Alignment pos;
  String get name => tr.pillars[key]!.name;
  String get jp => tr.pillars[key]!.jp;
  String get virtue => tr.pillars[key]!.virtue;
}

final pillars = {
  'needs': Pillar(
    key: 'needs',
    kanji: '竹',
    ink: ok(.56, .08, 155),
    soft: ok(.93, .04, 155),
    share: 600 / 1350, // the design's split of what is available
    img: 'assets/art/bamboo.jpg',
    pos: const Alignment(0, -.3),
  ),
  'wants': Pillar(
    key: 'wants',
    kanji: '梅',
    ink: ok(.6, .1, 10),
    soft: ok(.94, .035, 10),
    share: 300 / 1350, // the design's split of what is available
    img: 'assets/art/plum.jpg',
    pos: const Alignment(0, -.76),
  ),
  'culture': Pillar(
    key: 'culture',
    kanji: '蘭',
    ink: ok(.58, .08, 295),
    soft: ok(.94, .03, 295),
    share: 200 / 1350, // the design's split of what is available
    img: 'assets/art/orchid.jpg',
    pos: Alignment.center,
  ),
  'unexpected': Pillar(
    key: 'unexpected',
    kanji: '菊',
    ink: ok(.62, .1, 80),
    soft: ok(.95, .045, 90),
    share: 250 / 1350, // the design's split of what is available
    img: 'assets/art/chrys.jpg',
    pos: Alignment.center,
  ),
};

class Season {
  Season(this.key, this.plant, this.deep, this.ink, this.soft, this.bloom);
  final String key, plant;
  final Color deep, ink, soft, bloom;
  String get name => tr.seasons[key]!.$1;
  String get plantName => tr.seasons[key]!.$2;
}

final seasons = {
  'winter': Season('winter', '南天', ok(.44, .13, 25), ok(.56, .16, 25), ok(.95, .025, 25), ok(.72, .14, 25)),
  'spring': Season('spring', '桜', ok(.47, .08, 15), ok(.68, .09, 15), ok(.955, .025, 15), ok(.89, .05, 15)),
  'summer': Season('summer', '金魚', ok(.47, .12, 35), ok(.66, .14, 38), ok(.955, .03, 45), ok(.82, .1, 42)),
  'autumn': Season('autumn', '月', ok(.46, .08, 80), ok(.7, .1, 85), ok(.96, .035, 90), ok(.88, .08, 90)),
};
Season seasonOf(int month0) =>
    seasons[[11, 0, 1].contains(month0)
        ? 'winter'
        : month0 < 5
        ? 'spring'
        : month0 < 8
        ? 'summer'
        : 'autumn']!;

/// Japanese proverbs (text, romaji); their meaning is tr.proverbs[i].
const phrases = [
  ('塵も積もれば山となる', 'Chiri mo tsumoreba yama to naru'),
  ('足るを知る', 'Taru o shiru'),
  ('急がば回れ', 'Isogaba maware'),
  ('安物買いの銭失い', 'Yasumono-gai no zeni-ushinai'),
  ('石の上にも三年', 'Ishi no ue ni mo san-nen'),
  ('七転び八起き', 'Nana korobi ya oki'),
  ('一期一会', 'Ichigo ichie'),
];

const _kw = {
  // Italian and English stems, so a note in either language works on any phone.
  'needs': [
    'spes',
    'supermerc',
    'affitt',
    'bollett',
    'farmac',
    'treno',
    'benzin',
    'medic',
    'bus',
    'riso',
    'verdur',
    'grocer',
    'rent',
    'bill',
    'pharma',
    'train',
    'fuel',
    'doctor',
    'vegetab',
  ],
  'wants': [
    'cena',
    'ristor',
    'bar',
    'caff',
    'vestit',
    'regal',
    'fiori',
    'aperitiv',
    'pizza',
    'dinner',
    'restaurant',
    'coffee',
    'cloth',
    'gift',
    'flower',
    'drink',
  ],
  'culture': ['libr', 'cinema', 'muse', 'concert', 'teatr', 'corso', 'mostra', 'quadern', 'book', 'movie', 'theat', 'course', 'exhibit', 'notebook'],
  'unexpected': ['ripara', 'multa', 'dentist', 'guast', 'veterin', 'rott', 'repair', 'broke', 'fix'],
};

/// Pillar guessed from the note: a word that starts like one of the pillar's stems ("spesa" → spes), or null.
String? suggest(String t) {
  final words = t.toLowerCase().split(RegExp(r'[^\p{L}]+', unicode: true));
  for (final e in _kw.entries) {
    if (words.any((w) => e.value.any(w.startsWith))) return e.key;
  }
  return null;
}

/// "21:30" → (21, 30)
(int, int) hm(String t) {
  final [h, m] = t.split(':').map(int.parse).toList();
  return (h, m);
}

class Entry {
  Entry(this.date, this.note, this.amt, this.p);
  final DateTime date;
  final String note, p;
  final double amt;
  Pillar get pillar => pillars[p]!;
  Map<String, Object> toJson() => {'d': dateKey(date), 'n': note, 'a': amt, 'p': p};
  factory Entry.fromJson(Map j) => Entry(DateTime.parse(j['d']), j['n'], (j['a'] as num).toDouble(), j['p']);
}

class Fixed {
  Fixed(this.id, this.name, this.amt);
  final int id;
  String name;
  double amt;
}

double _nz(double v) => v == 0 ? 1 : v;
double sum(Iterable<Entry> l) => l.fold(0.0, (a, e) => a + e.amt);
int daysBetween(DateTime a, DateTime b) => DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

/// A budgeting month: from the chosen start day up to the day before it, a month later.
class Period {
  const Period(this.start, this.end);
  final DateTime start, end; // end is excluded
  bool has(DateTime d) => !d.isBefore(start) && d.isBefore(end);
  int get days => daysBetween(start, end);
  DateTime get last => DateTime(end.year, end.month, end.day - 1);
}

class Kakebo extends ChangeNotifier {
  static DateTime Function() clock = DateTime.now;
  DateTime get now => clock();

  // Persisted.
  bool onboarded = false, rule = false;
  double income = 2800, save = 300;
  List<Fixed> fixed = [
    for (final (i, amt) in const [850.0, 120.0, 30.0, 25.0, 125.0].indexed) Fixed(i + 1, tr.defaultFixed[i], amt),
  ];
  List<Entry> entries = [];
  Map<String, String> thoughts = {}; // yyyy-mm-dd → text
  Map<String, String> improve = {}; // yyyy-mm → answer to question 4
  Map<String, double> sealed = {}; // yyyy-mm → saved when sealed
  Map<String, bool> flags = {'weekly': true, 'phraseOn': true, 'reminders': true, 'thoughtOn': true};
  String thoughtTime = '21:00', noteTime = '20:00';
  int monthStart = 1; // day the budgeting month begins (1–28), e.g. payday
  Map<String, double>? budgets; // null → split what is available like the design

  // Transient.
  String screen = 'onboarding';

  static const _key = 'kakebo';
  SharedPreferencesAsync? _prefs;

  static Future<Kakebo> load() async {
    final k = Kakebo(), prefs = SharedPreferencesAsync();
    final raw = await prefs.getString(_key);
    if (raw != null) k.read(jsonDecode(raw));
    k._prefs = prefs;
    k.screen = k.onboarded ? 'home' : 'onboarding';
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
    sealed = {for (final e in (j['sealed'] as Map).entries) e.key: (e.value as num).toDouble()};
    flags = {...flags, ...Map<String, bool>.from(j['flags'])};
    thoughtTime = j['thoughtTime'];
    noteTime = j['noteTime'] ?? noteTime;
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
    'sealed': sealed,
    'flags': flags,
    'thoughtTime': thoughtTime,
    'noteTime': noteTime,
    'monthStart': monthStart,
    'budgets': ?budgets,
  };

  // ponytail: whole state rewritten as one JSON blob per change; move to drift/SQLite when history spans years.
  @override
  void notifyListeners() {
    super.notifyListeners();
    _prefs?.setString(_key, jsonEncode(toJson()));
  }

  void update(VoidCallback f) {
    f();
    notifyListeners();
  }

  void go(String s) => update(() => screen = s);

  /// Redraw for a new hour/day (greeting, evening notice, "today") without saving.
  void refresh() => super.notifyListeners();

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
  Season get season => seasonOf(now.month - 1);
  List<Entry> get today => entries.where((e) => dateKey(e.date) == dateKey(now)).toList();
  DateTime get weekStart => DateTime(now.year, now.month, now.day - now.weekday + 1);
  List<Entry> get week => entries.where((e) => !e.date.isBefore(weekStart)).toList();
  static Map<String, double> spentBy(Iterable<Entry> l) => {for (final k in pillars.keys) k: sum(l.where((e) => e.p == k))};

  double get fixedTotal => fixed.fold(0.0, (a, r) => a + r.amt);
  double get available => math.max(0, income - fixedTotal - save);
  double get spent => sum(month);
  double get left => math.max(0, available - spent);
  double get onTrack => math.max(0, income - fixedTotal - spent);
  int get spentPct => math.min(100, (spent / _nz(available) * 100).round());

  /// Flowers on the savings branch: one per tenth of the goal, blooming while spending keeps the month's pace.
  int get bloomed {
    final elapsed = day / dim, pace = spent / _nz(available) / elapsed;
    return (10 * elapsed * (pace <= 1 ? 1 : math.max(0, 2 - pace))).round();
  }

  /// From the evening thought's time until 5 in the morning.
  bool get evening {
    final (h, m) = hm(thoughtTime);
    return now.hour * 60 + now.minute >= h * 60 + m || now.hour < 5;
  }

  /// Monthly budget of a pillar: yours once set, otherwise the design's split of what is available.
  double budget(String k) => budgets?[k] ?? (available * pillars[k]!.share).roundToDouble();
  double get budgeted => pillars.keys.fold(0.0, (a, k) => a + budget(k));
  void setBudget(String k, double v) => update(() => budgets = {for (final p in pillars.keys) p: p == k ? v : budget(p)});
  void autoBudgets() => update(() => budgets = null);
  String? get thoughtToday => thoughts[dateKey(now)];
  bool get isSealed => sealed.containsKey(monthKey(label));
  DateTime get nextMonth => DateTime(label.year, label.month + 1);

  /// The month the setup screen plans: next one once this one is sealed.
  DateTime get planMonth => isSealed ? nextMonth : label;

  String get greeting {
    final h = now.hour;
    return h >= 5 && h < 12
        ? tr.morning
        : h >= 12 && h < 18
        ? tr.afternoon
        : tr.evening;
  }

  void toggleRule() => update(() {
    rule = !rule;
    if (rule) save = (income * .2).roundToDouble();
  });

  void addEntry(double amt, String note, String p) =>
      update(() => entries.insert(0, Entry(DateTime(now.year, now.month, now.day), note.isEmpty ? pillars[p]!.name : note, amt, p)));

  void editEntry(Entry old, double amt, String note, String p) =>
      update(() => entries[entries.indexOf(old)] = Entry(old.date, note.isEmpty ? pillars[p]!.name : note, amt, p));

  /// Removes an expense and returns where it was, for undo.
  int removeEntry(Entry e) {
    final i = entries.indexOf(e);
    update(() => entries.removeAt(i));
    return i;
  }

  void restoreEntry(int i, Entry e) => update(() => entries.insert(i, e));

  /// Full backup (everything the app stores), as a file the user keeps.
  String backup() => const JsonEncoder.withIndent(' ').convert({'app': 'kakebo', 'v': 1, ...toJson()});

  /// Replaces all data with a backup; false (and nothing changed) if the file is not a Kakebo backup.
  bool restore(String text) {
    try {
      final j = jsonDecode(text);
      if (j is! Map || j['app'] != 'kakebo') return false;
      Kakebo().read(j); // validate on a scratch copy first
      update(() {
        read(j);
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

  void seal() => update(() => sealed[monthKey(label)] = onTrack);

  /// Spreadsheet-ready for the phone's region: "1,5" with ";" where the comma is decimal, else "1.5" with ",".
  /// Starts with a BOM so Excel reads the accents.
  String csv() {
    final sep = decimalSep == ',' ? ';' : ',';
    return String.fromCharCode(0xFEFF) +
        [
          tr.csvHeader.join(sep),
          for (final e in entries)
            [dateKey(e.date), '"${e.note.replaceAll('"', '""')}"', e.amt.toString().replaceAll('.', decimalSep), e.pillar.name].join(sep),
        ].join(String.fromCharCodes(const [13, 10]));
  }

  /// Demo data from the design, placed in the current month (`--dart-define=DEMO=true`).
  void seedDemo() {
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
    final shift = day - 24; // keep "today" on the design's busiest day
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

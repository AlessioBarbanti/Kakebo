import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// it-IT currency like the design: "1.234 €", "12,80 €".
String fmt(num n) {
  final r = (n * 100).round() / 100;
  final s = r.abs().toStringAsFixed(n % 1 != 0 ? 2 : 0).split('.');
  final whole = s[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => '.');
  return '${r < 0 ? '-' : ''}$whole${s.length > 1 ? ',${s[1]}' : ''} €';
}

const mesi = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
const giorni = ['Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica'];
const kanjiMesi = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];
String mese(DateTime d) => mesi[d.month - 1].toLowerCase();
String abbr(DateTime d) => mese(d).substring(0, 3);
String dayLabel(DateTime d) => '${giorni[d.weekday - 1]} ${d.day} ${mese(d)}';
String dateKey(DateTime d) => d.toIso8601String().substring(0, 10);
String monthKey(DateTime d) => d.toIso8601String().substring(0, 7);

class Pillar {
  Pillar({
    required this.name,
    required this.flower,
    required this.jp,
    required this.virtue,
    required this.kanji,
    required this.ink,
    required this.soft,
    required this.budget,
    required this.img,
    required this.pos,
  });
  final String name, flower, jp, virtue, kanji, img;
  final Color ink, soft;
  final double budget;
  final Alignment pos;
}

final pillars = {
  'needs': Pillar(
    name: 'Necessità',
    flower: 'Bambù',
    jp: '必要 hitsuyō · bambù',
    virtue: 'Il bambù: si piega ma non si spezza',
    kanji: '竹',
    ink: ok(.56, .08, 155),
    soft: ok(.93, .04, 155),
    budget: 600,
    img: 'assets/art/bamboo.jpg',
    pos: const Alignment(0, -.3),
  ),
  'wants': Pillar(
    name: 'Desideri',
    flower: 'Susino in fiore',
    jp: '欲しい hoshii · susino',
    virtue: 'Il susino: fiorisce quando serve gioia',
    kanji: '梅',
    ink: ok(.6, .1, 10),
    soft: ok(.94, .035, 10),
    budget: 300,
    img: 'assets/art/plum.jpg',
    pos: const Alignment(0, -.76),
  ),
  'culture': Pillar(
    name: 'Cultura',
    flower: 'Orchidea',
    jp: '文化 bunka · orchidea',
    virtue: "L'orchidea: nutre la mente in silenzio",
    kanji: '蘭',
    ink: ok(.58, .08, 295),
    soft: ok(.94, .03, 295),
    budget: 200,
    img: 'assets/art/orchid.jpg',
    pos: Alignment.center,
  ),
  'unexpected': Pillar(
    name: 'Imprevisti',
    flower: 'Crisantemo',
    jp: '予想外 yosōgai · crisantemo',
    virtue: 'Il crisantemo: resiste al freddo inatteso',
    kanji: '菊',
    ink: ok(.62, .1, 80),
    soft: ok(.95, .045, 90),
    budget: 250,
    img: 'assets/art/chrys.jpg',
    pos: Alignment.center,
  ),
};

class Season {
  Season(this.name, this.plantName, this.plant, this.deep, this.ink, this.soft, this.bloom);
  final String name, plantName, plant;
  final Color deep, ink, soft, bloom;
}

final seasons = {
  'winter': Season('Inverno', 'Nandina', '南天', ok(.44, .13, 25), ok(.56, .16, 25), ok(.95, .025, 25), ok(.72, .14, 25)),
  'spring': Season('Primavera', 'Ciliegio', '桜', ok(.47, .08, 15), ok(.68, .09, 15), ok(.955, .025, 15), ok(.89, .05, 15)),
  'summer': Season('Estate', 'Pesce rosso', '金魚', ok(.47, .12, 35), ok(.66, .14, 38), ok(.955, .03, 45), ok(.82, .1, 42)),
  'autumn': Season('Autunno', 'Luna piena', '月', ok(.46, .08, 80), ok(.7, .1, 85), ok(.96, .035, 90), ok(.88, .08, 90)),
};
Season seasonOf(int month0) =>
    seasons[[11, 0, 1].contains(month0)
        ? 'winter'
        : month0 < 5
        ? 'spring'
        : month0 < 8
        ? 'summer'
        : 'autumn']!;

const phrases = [
  ('塵も積もれば山となる', 'Chiri mo tsumoreba yama to naru', 'Anche la polvere, accumulandosi, diventa una montagna.'),
  ('足るを知る', 'Taru o shiru', 'Sapere quando si ha abbastanza.'),
  ('急がば回れ', 'Isogaba maware', 'Se hai fretta, prendi la strada lunga.'),
  ('安物買いの銭失い', 'Yasumono-gai no zeni-ushinai', 'Chi compra ciò che costa poco, perde denaro.'),
  ('石の上にも三年', 'Ishi no ue ni mo san-nen', 'Anche una pietra si scalda, se ci siedi sopra tre anni.'),
  ('七転び八起き', 'Nana korobi ya oki', 'Cadi sette volte, rialzati otto.'),
  ('一期一会', 'Ichigo ichie', 'Ogni incontro accade una volta sola.'),
];

const _kw = {
  'needs': ['spes', 'supermerc', 'affitt', 'bollett', 'farmac', 'treno', 'benzin', 'medic', 'bus', 'riso', 'verdur'],
  'wants': ['cena', 'ristor', 'bar', 'caff', 'vestit', 'regal', 'fiori', 'aperitiv', 'pizza'],
  'culture': ['libr', 'cinema', 'muse', 'concert', 'teatr', 'corso', 'mostra', 'quadern'],
  'unexpected': ['ripara', 'multa', 'dentist', 'guast', 'veterin', 'rott'],
};

/// Pillar guessed from the note's words, or null.
String? suggest(String t) {
  t = t.toLowerCase();
  for (final e in _kw.entries) {
    if (e.value.any(t.contains)) return e.key;
  }
  return null;
}

const thoughtTimes = ['20:00', '20:30', '21:00', '21:30', '22:00'];

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

class Kakebo extends ChangeNotifier {
  static DateTime Function() clock = DateTime.now;
  DateTime get now => clock();

  // Persisted.
  bool onboarded = false, rule = false;
  double income = 2800, save = 300;
  List<Fixed> fixed = [
    Fixed(1, 'Affitto', 850),
    Fixed(2, 'Bollette luce e gas', 120),
    Fixed(3, 'Internet e telefono', 30),
    Fixed(4, 'Abbonamenti', 25),
    Fixed(5, 'Assicurazione', 125),
  ];
  List<Entry> entries = [];
  Map<String, String> thoughts = {}; // yyyy-mm-dd → text
  Map<String, String> improve = {}; // yyyy-mm → answer to question 4
  Map<String, double> sealed = {}; // yyyy-mm → saved when sealed
  Map<String, bool> flags = {'weekly': true, 'phraseOn': true, 'reminders': true, 'thoughtOn': true};
  String thoughtTime = '21:00';

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

  // Current month.
  int get day => now.day;
  int get dim => DateTime(now.year, now.month + 1, 0).day;
  Season get season => seasonOf(now.month - 1);
  List<Entry> inMonth(DateTime m) => entries.where((e) => e.date.year == m.year && e.date.month == m.month).toList();
  List<Entry> get month => inMonth(now);
  List<Entry> get today => month.where((e) => e.date.day == day).toList();
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

  int get thoughtHour => int.parse(thoughtTime.split(':')[0]);
  bool get evening => now.hour >= thoughtHour || now.hour < 5;
  String? get thoughtToday => thoughts[dateKey(now)];
  bool get isSealed => sealed.containsKey(monthKey(now));
  DateTime get nextMonth => DateTime(now.year, now.month + 1);

  /// The month the setup screen plans: next one once this one is sealed.
  DateTime get planMonth => isSealed ? nextMonth : DateTime(now.year, now.month);

  String get greeting {
    final h = now.hour;
    return h >= 5 && h < 12
        ? 'Buongiorno'
        : h >= 12 && h < 18
        ? 'Buon pomeriggio'
        : 'Buonasera';
  }

  void toggleRule() => update(() {
    rule = !rule;
    if (rule) save = (income * .2).roundToDouble();
  });

  void addEntry(double amt, String note, String p) =>
      update(() => entries.insert(0, Entry(DateTime(now.year, now.month, now.day), note.isEmpty ? pillars[p]!.name : note, amt, p)));

  void seal() => update(() => sealed[monthKey(now)] = onTrack);

  String csv() =>
      ['data,nota,importo,pilastro', for (final e in entries) '${dateKey(e.date)},"${e.note.replaceAll('"', '""')}",${e.amt},${e.pillar.name}'].join('\n');

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

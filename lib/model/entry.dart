import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/pillar.dart';

class Entry {
  Entry(this.date, this.note, this.amt, this.p);
  final DateTime date;
  final String note, p;
  final double amt;
  Pillar get pillar => pillars[p]!;
  Map<String, Object> toJson() => {'d': dateKey(date), 'n': note, 'a': amt, 'p': p};
  factory Entry.fromJson(Map j) => Entry(DateTime.parse(j['d']), j['n'], (j['a'] as num).toDouble(), j['p']);
}

double sum(Iterable<Entry> entries) => entries.fold(0.0, (total, entry) => total + entry.amt);

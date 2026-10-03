import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/pillar.dart';

class Entry {
  Entry(this.date, this.note, this.amt, this.p, {this.reflection = '', this.receipt});
  final DateTime date;
  final String note, p;
  final String reflection;
  final String? receipt; // the file name of the receipt's photo it was read from, kept on the phone
  final double amt;
  Pillar get pillar => pillars[p]!;
  Map<String, Object> toJson() => {'d': dateKey(date), 'n': note, 'a': amt, 'p': p, if (reflection.isNotEmpty) 'reflection': reflection, 'receipt': ?receipt};
  factory Entry.fromJson(Map j) =>
      Entry(DateTime.parse(j['d']), j['n'], (j['a'] as num).toDouble(), j['p'], reflection: j['reflection'] as String? ?? '', receipt: j['receipt'] as String?);
}

double sum(Iterable<Entry> entries) => entries.fold(0.0, (total, entry) => total + entry.amt);

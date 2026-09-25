String dateKey(DateTime d) => d.toIso8601String().substring(0, 10);
String monthKey(DateTime d) => d.toIso8601String().substring(0, 7);

int daysBetween(DateTime a, DateTime b) => DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

/// A budgeting month: from the chosen start day up to the day before it, a month later.
class Period {
  const Period(this.start, this.end);
  final DateTime start, end; // end is excluded
  bool has(DateTime d) => !d.isBefore(start) && d.isBefore(end);
  int get days => daysBetween(start, end);
  DateTime get last => DateTime(end.year, end.month, end.day - 1);
}

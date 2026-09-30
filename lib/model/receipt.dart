import 'dart:math' as math;

/// A line of text read from a receipt photo, with its four corners in the photo (top left, top right, bottom right,
/// bottom left, turned with the text when the photo is askew).
class ReceiptLine {
  const ReceiptLine(this.text, this.corners);
  final String text;
  final List<(double, double)> corners;
}

/// The receipt's printed rows, top to bottom. Text recognition reads a label on the left and its figure on the right as
/// separate lines, often far apart in its output; lines at the same height, once the photo's tilt is taken out, are one row.
List<String> rowsOf(List<ReceiptLine> lines) {
  final read = [
    for (final l in lines)
      if (l.corners.length == 4 && l.text.trim().isNotEmpty) l,
  ];
  if (read.isEmpty) return [];
  double median(List<double> v) => (v..sort())[v.length ~/ 2];
  final tilt = median([for (final l in read) math.atan2(l.corners[1].$2 - l.corners[0].$2, l.corners[1].$1 - l.corners[0].$1)]);
  final (sin, cos) = (math.sin(-tilt), math.cos(-tilt));
  final placed = [
    for (final l in read)
      (
        text: l.text.trim(),
        // The centre turned level: x across the receipt, y down it.
        x: [for (final c in l.corners) c.$1 * cos - c.$2 * sin].reduce((a, b) => a + b) / 4,
        y: [for (final c in l.corners) c.$1 * sin + c.$2 * cos].reduce((a, b) => a + b) / 4,
        h: math.sqrt(math.pow(l.corners[3].$1 - l.corners[0].$1, 2) + math.pow(l.corners[3].$2 - l.corners[0].$2, 2)),
      ),
  ]..sort((a, b) => a.y.compareTo(b.y));
  final gap = median([for (final p in placed) p.h]) * .6;
  final rows = <List<({String text, double x, double y, double h})>>[];
  for (final p in placed) {
    if (rows.isNotEmpty && (p.y - rows.last.first.y).abs() < gap) {
      rows.last.add(p);
    } else {
      rows.add([p]);
    }
  }
  return [for (final r in rows) (r..sort((a, b) => a.x.compareTo(b.x))).map((p) => p.text).join(' ')];
}

/// What a Kakebo expense needs from a receipt: its total, its day and the shop, each null when not found. Only what is
/// clearly there: no total is better than a wrong one, since the user checks the figures before adding the expense.
class Receipt {
  const Receipt({this.total, this.date, this.shop});
  final double? total;
  final DateTime? date;
  final String? shop;

  bool get isEmpty => total == null && date == null && shop == null;

  /// Reads the [rows] of a receipt, top to bottom. A date after [today] (a return deadline, say) is not the purchase's.
  factory Receipt.read(List<String> rows, {required DateTime today}) {
    final lines = [for (final r in rows) r.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim()];
    return Receipt(total: _total(lines), date: _date(lines, today), shop: _shop(lines));
  }
}

// Labels of the sum to pay, surest first: the Italian commercial document prints "TOTALE COMPLESSIVO", then the payment.
// Recognition often reads O as 0 inside words.
final _totals = [
  RegExp(r'T[O0]TALE (C[O0]MPLESSIV[O0]|DA PAGARE)|IMP[O0]RT[O0] PAGAT[O0]|GRAND T[O0]TAL|AM[O0]UNT DUE|T[O0]TAL DUE|T[O0]TAL T[O0] PAY'),
  RegExp(r'\bT[O0]TALE? (EUR[O0]?|€)'),
  RegExp(r'\bT[O0]TALE?\b'),
  RegExp(r'PAGAMENT[O0] (ELETTR[O0]NIC[O0]|CARTA|BANC[O0]MAT)|\bCARTA DI CREDIT[O0]|\bBANC[O0]MAT\b'),
];
// Rows with a total's word that are not the sum paid: taxes, a part of it, what was saved, points, pieces, change.
final _notTotal = RegExp(r'SUBT[O0]TAL|\bIVA\b|\bVAT\b|\bTAX|IMP[O0]NIBILE|SC[O0]NT[OI]\b|RISPARMI|\bSAVE|PUNTI|POINTS|PEZZI|ARTIC[O0]LI|ITEMS|RESTO|CHANGE');
// A sum: 3,39 or 1.234,56 (also 3.39 as recognition may read it), never part of a longer number or a date like 30.09.2026.
final _amount = RegExp(r'(?<![\d.,])(\d{1,3}(?:\.\d{3})+,\d{2}|\d{1,5} ?[.,] ?\d{2})(?![\d.,]*\d)');

double? _amountIn(String row) {
  final all = _amount.allMatches(row).toList();
  if (all.isEmpty) return null;
  // The rightmost, where receipts print the figure; a label may carry numbers of its own (IVA 22%).
  final s = all.last.group(1)!.replaceAll(' ', '');
  final v = double.tryParse(s.contains(',') ? s.replaceAll('.', '').replaceAll(',', '.') : s);
  return v != null && v > 0 ? v : null;
}

double? _total(List<String> lines) {
  for (final label in _totals) {
    for (final (i, l) in lines.indexed) {
      if (!label.hasMatch(l) || _notTotal.hasMatch(l)) continue;
      // The figure sits on the label's row, or alone on the next when it was printed large or read apart.
      final next = i + 1 < lines.length && !lines[i + 1].contains(RegExp(r'[A-Z]{2}')) ? _amountIn(lines[i + 1]) : null;
      final v = _amountIn(l) ?? next;
      if (v != null) return v;
    }
  }
  return null;
}

final _dates = RegExp(r'(?<!\d)(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4}|\d{2})(?![\d/\-.]*\d)|(?<!\d)(\d{4})-(\d{2})-(\d{2})(?!\d)');

DateTime? _date(List<String> lines, DateTime today) {
  final end = DateTime(today.year, today.month, today.day);
  for (final l in lines) {
    for (final m in _dates.allMatches(l)) {
      final iso = m.group(4) != null;
      final (d, mo, y) = iso
          ? (int.parse(m.group(6)!), int.parse(m.group(5)!), int.parse(m.group(4)!))
          : (int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
      final year = y < 100 ? 2000 + y : y, date = DateTime(year, mo, d);
      // Day and month as printed (DateTime would roll 31/02 into March), and a day already come.
      if (date.day == d && date.month == mo && !date.isAfter(end) && year > end.year - 10) return date;
    }
  }
  return null;
}

// Header rows that are not the shop's name: the document's title, tax codes, address, contacts, greetings, the till.
final _notShop = RegExp(
  r'DOCUMENT[O0]|C[O0]MMERCIALE|SC[O0]NTRIN[O0]|FISCALE|VENDITA|PRESTAZI[O0]NE|P\.? ?IVA|PARTITA|C\.? ?F\.|C[O0]D\.? ?FISC|'
  r'\b(VIA|VIALE|V\.LE|PIAZZA|P\.ZZA|P\.LE|C[O0]RS[O0]|C\.S[O0]|LARG[O0]|STRADA|L[O0]C\.|FRAZ\.)\b|\b\d{5}\b|'
  r'\bTEL|\bFAX\b|WWW|HTTP|@|\.IT\b|\.C[O0]M\b|BENVENUT|WELC[O0]ME|GRAZIE|THANK|CASSA|[O0]PERAT[O0]RE|DESCRIZI[O0]NE|PREZZ[O0]|\bRT\b',
);
final _legal = RegExp(r'\b(S\.? ?P\.? ?A|S\.? ?R\.? ?L\.? ?S?|S\.? ?N\.? ?C|S\.? ?A\.? ?S)\b\.?');
const _small = {'da', 'di', 'del', 'della', 'dei', 'e', 'il', 'la', 'lo', 'le', 'al', 'alla', 'in', 'of', 'the', 'and'};

String? _shop(List<String> lines) {
  // The name heads the receipt: the first rows only, before the items begin.
  for (final l in lines.take(6)) {
    if (_amount.hasMatch(l)) break;
    final letters = RegExp(r'\p{L}', unicode: true).allMatches(l).length;
    if (letters < 3 || letters * 2 < l.replaceAll(' ', '').length || _notShop.hasMatch(l) || _dates.hasMatch(l)) continue;
    final name = l.replaceAll(_legal, '').replaceAll(RegExp(r'[\s.,\-]+$'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.length < 3) continue;
    final shop = [
      for (final (i, w) in name.toLowerCase().split(' ').indexed)
        i > 0 && _small.contains(w) ? w : w.replaceFirstMapped(RegExp(r'\p{L}', unicode: true), (m) => m[0]!.toUpperCase()),
    ].join(' ');
    return shop.length > 40 ? shop.substring(0, 40).trim() : shop;
  }
  return null;
}

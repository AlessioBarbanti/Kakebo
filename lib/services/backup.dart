import 'dart:convert';

import 'package:kakebo/model/entry.dart';
import 'package:kakebo/model/period.dart';

class Backup {
  static String encode(Map<String, Object> data) => const JsonEncoder.withIndent(' ').convert({'app': 'kakebo', 'v': 1, ...data});

  static Map<String, dynamic>? decode(String text) {
    final data = jsonDecode(text);
    return data is Map<String, dynamic> && data['app'] == 'kakebo' ? data : null;
  }

  /// BOM, CRLF and regional separators keep exported CSV readable in Excel.
  static String csv(Iterable<Entry> entries, {required List<String> headers, required String decimalSep, required String Function(String) pillarName}) {
    final sep = decimalSep == ',' ? ';' : ',';
    return String.fromCharCode(0xFEFF) +
        [
          headers.join(sep),
          for (final e in entries)
            [dateKey(e.date), '"${e.note.replaceAll('"', '""')}"', e.amt.toString().replaceAll('.', decimalSep), pillarName(e.p)].join(sep),
        ].join(String.fromCharCodes(const [13, 10]));
  }
}

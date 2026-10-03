import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/model/receipt.dart';

void main() {
  final today = DateTime(2026, 9, 30, 21);
  Receipt read(String text) => Receipt.read(text.trim().split('\n'), today: today);

  test('an Italian commercial document: the total, not the cash handed over, the change or the VAT', () {
    final r = read('''
ESSELUNGA S.P.A.
VIA GIAMBELLINO 12
20146 MILANO
P.IVA 01255720169
DOCUMENTO COMMERCIALE
di vendita o prestazione
DESCRIZIONE IVA Prezzo(€)
LATTE INTERO 4% 1,29
PANE COMUNE 4% 2,10
BISCOTTI 10% 2,49
SUBTOTALE 5,88
SCONTO FIDATY -0,50
TOTALE COMPLESSIVO 5,38
DI CUI IVA 0,31
Pagamento contante 10,00
Resto 4,62
Importo pagato 5,38
28-09-2026 18:42
DOCUMENTO N. 0412-0087
RT 99MEY012345
''');
    expect((r.total, r.date, r.shop), (5.38, DateTime(2026, 9, 28), 'Esselunga'));
  });

  test('a café paid by card, with a two-digit year and the owner under the name', () {
    final r = read('''
BAR DA MARIO SNC
di Rossi Mario & C.
Piazza Duomo 3 - Parma
DOCUMENTO COMMERCIALE
CAPPUCCINO 1,60
BRIOCHE 1,40
PAGAMENTO ELETTRONICO 3,00
29/09/26 08:15
''');
    expect((r.total, r.date, r.shop), (3.0, DateTime(2026, 9, 29), 'Bar da Mario'));
  });

  test('the surest label wins, wherever it is printed', () {
    expect(read('TOTALE 12,00\nTOTALE COMPLESSIVO 11,50').total, 11.5);
    expect(read('PAGAMENTO ELETTRONICO 20,00\nTOTALE EURO 18,20').total, 18.2);
    expect(read('TOTALE PEZZI 3\nTOTALE 7,45').total, 7.45);
    expect(read('TOTALE SCONTI 2,00\nTOTALE 9,90').total, 9.9);
  });

  test('what recognition gets wrong: 0 for O, a dot for the comma, spaces, thousands, the figure on its own row', () {
    expect(read('T0TALE C0MPLESSIV0 12,90').total, 12.9);
    expect(read('TOTALE COMPLESSIVO 12.90').total, 12.9);
    expect(read('TOTALE COMPLESSIVO 12 ,90 €').total, 12.9);
    expect(read('TOTALE COMPLESSIVO 1.234,56').total, 1234.56);
    expect(read('TOTALE COMPLESSIVO\n23,40\nDI CUI IVA 4,22').total, 23.4);
    expect(read('Total 12.50').total, 12.5);
  });

  test('no total rather than a guess; no date from a document number, a time or a return deadline', () {
    final r = read('''
DOCUMENTO COMMERCIALE
di vendita o prestazione
LATTE 1,29
PANE 2,10
Reso entro il 28/10/2026
DOCUMENTO N. 0412-0087 ore 12:34
''');
    expect(r.total, isNull);
    expect(r.date, isNull);
    expect(r.shop, isNull, reason: 'a receipt with only a logo on top: its items are not the shop');
    expect(read('Reso entro il 28/10/2026\n30.09.2026').date, DateTime(2026, 9, 30));
    expect(read('31/02/2026\n2026-09-01').date, DateTime(2026, 9, 1));
    expect(read('').isEmpty, isTrue);
  });

  test("rows come back together from the lines recognition reads, however the photo is tilted", () {
    // Lines laid out as printed (x, y, width), 20 px high, then the whole photo turned by the angle.
    List<ReceiptLine> photo(double degrees) {
      final a = degrees * math.pi / 180;
      (double, double) turn(double x, double y) => (x * math.cos(a) - y * math.sin(a), x * math.sin(a) + y * math.cos(a));
      ReceiptLine line(String text, double x, double y, double w) => ReceiptLine(text, [turn(x, y), turn(x + w, y), turn(x + w, y + 20), turn(x, y + 20)]);
      // In recognition's own order: the labels block first, then the figures block.
      return [
        line('BAR CENTRALE', 200, 0, 300),
        line('CAFFE', 20, 60, 100),
        line('TOTALE COMPLESSIVO', 20, 90, 300),
        line('DI CUI IVA', 20, 120, 150),
        line('1,20', 600, 60, 60),
        line('1,20', 600, 90, 60),
        line('0,22', 600, 120, 60),
      ];
    }

    for (final degrees in [0.0, 4.0, -6.0]) {
      expect(rowsOf(photo(degrees)), ['BAR CENTRALE', 'CAFFE 1,20', 'TOTALE COMPLESSIVO 1,20', 'DI CUI IVA 0,22'], reason: '$degrees°');
    }
    expect(rowsOf([]), isEmpty);
  });
}

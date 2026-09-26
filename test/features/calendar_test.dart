import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/features/calendar/calendar.dart';
import 'package:kakebo/model/entry.dart';

void main() {
  test('a day is shaded by wants, culture and the unexpected against their daily share, never by needs', () {
    Entry e(double amt, String p) => Entry(DateTime(2026, 9, 15), '', amt, p);
    expect(dayShade([e(70, 'needs')], 25), 0); // the weekly shop is not a heavy day
    expect(dayShade([e(70, 'needs'), e(12.5, 'wants')], 25), .25); // half the share
    expect(dayShade([e(25, 'culture')], 25), .5); // the share itself
    expect(dayShade([e(60, 'unexpected')], 25), 1); // twice the share or more is the deepest
    expect(dayShade([e(5, 'wants')], 0), 1); // no share left: any such spending shows in full
  });
}

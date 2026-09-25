import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/model/pillar_suggestion.dart';

void main() {
  test('pillar suggestion matches word starts in Italian and English', () {
    expect(suggest('Cena da Mario'), 'wants');
    expect(suggest('Regalo per i parenti'), 'wants'); // "parenti" is not "rent"
    expect(suggest('Weekly groceries'), 'needs');
    expect(suggest('Ciotola in ceramica'), isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/shared/theme/color.dart';

void main() {
  test('oklch → sRGB', () {
    final red = ok(.628, .2577, 29.23); // CSS reference for #ff0000
    expect((red.r * 255).round(), 255);
    expect((red.g * 255).round(), 0);
    expect((red.b * 255).round(), 0);
    expect((ok(1, 0, 0).g * 255).round(), 255);
  });
}

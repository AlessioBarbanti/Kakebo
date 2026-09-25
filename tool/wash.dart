// Bakes the ink-plum wash behind every screen, so the app draws one plain image instead of
// three live effects (mask, grayscale/contrast, opacity) on every animation frame:
//   dart run tool/wash.dart
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

const w = 640, h = 920; // 2× the 320×460 box it fills
const opacity = .22;

void main() {
  final src = img.decodeJpg(File('assets/src/ink_plum.jpg').readAsBytesSync())!;
  // BoxFit.cover, aligned like CSS background-position 40% 25%.
  final s = max(w / src.width, h / src.height);
  final cover = img.copyResize(src, width: (src.width * s).round(), height: (src.height * s).round(), interpolation: img.Interpolation.cubic);
  final ox = ((cover.width - w) * .4).round(), oy = ((cover.height - h) * .25).round();

  final out = img.Image(width: w, height: h, numChannels: 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = cover.getPixel(x + ox, y + oy);
      final lum = (.2126 * p.r + .7152 * p.g + .0722 * p.b) / 255;
      final v = ((lum - .5) * 1.25 + .5).clamp(0.0, 1.0); // grayscale(1) contrast(1.25)
      // Radial fade centred at 65% 35%: solid to 35% of the radius, gone by 75%.
      final d = sqrt(pow(x - .65 * w, 2) + pow(y - .35 * h, 2)) / (.69 * w);
      final m = d <= .35
          ? 1.0
          : d >= .75
          ? 0.0
          : 1 - (d - .35) / .4;
      out.setPixelRgba(x, y, v * 255, v * 255, v * 255, opacity * m * 255);
    }
  }
  File('assets/art/ink_plum_wash.png').writeAsBytesSync(img.encodePng(out));
  stdout.writeln('assets/art/ink_plum_wash.png');
}

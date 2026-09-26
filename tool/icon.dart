// Turns the painted icon (assets/icon/source.png: ink on paper) into Android icon layers, in negative: the ensō in paper
// colour on Kakebo green, so it stands out among the icons around it.
//   dart run tool/icon.dart && dart run flutter_launcher_icons
// Writes assets/icon/{foreground,monochrome,icon}.png and the white status-bar icon for notifications.
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

// Artwork radius / half canvas; the canvas is the whole 108 dp layer (adaptive_icon_foreground_inset: 0 in pubspec.yaml).
// Android shows the central 72 dp and guarantees a 66 dp circle (.61) in every mask shape; .56 keeps the flower inside it
// while the ensō fills about four fifths of the visible circle, as large as the icons around it.
const safe = .56;
const grain = .12; // paper-texture alpha below this is treated as paper
const bloom = 1.5; // the blossom against the painted one: larger, to hold its own beside the fuller negative stroke
const green = (0x2d, 0x57, 0x42); // Kakebo green (tokens.dart), the icon's background: adaptive_icon_background in pubspec.yaml

void main() {
  final src = img.decodePng(File('assets/icon/source.png').readAsBytesSync())!;
  final paper = _paper(src);
  final ink = _inkOnly(src, paper);

  // Center the drawing and shrink it into the safe circle.
  final (cx, cy, r) = _bounds(ink);
  final scale = safe * 512 / r;
  final fg = img.Image(width: 1024, height: 1024, numChannels: 4);
  final art = img.copyResize(ink, width: (ink.width * scale).round(), height: (ink.height * scale).round(), interpolation: img.Interpolation.average);
  img.compositeImage(fg, art, dstX: (512 - cx * scale).round(), dstY: (512 - cy * scale).round());
  final negative = _negative(fg, paper);
  _save('assets/icon/foreground.png', negative);
  _save('assets/icon/monochrome.png', _silhouette(negative, 0));
  final (gr, gg, gb) = green;
  _save('assets/icon/icon.png', img.compositeImage(img.fill(img.Image(width: 1024, height: 1024), color: img.ColorRgb8(gr, gg, gb)), negative));

  // Status-bar icon: white silhouette filling 24 dp with 2 dp padding, one file per density.
  const densities = {'mdpi': 24, 'hdpi': 36, 'xhdpi': 48, 'xxhdpi': 72, 'xxxhdpi': 96};
  final tight = _silhouette(ink, 255);
  for (final MapEntry(key: d, value: px) in densities.entries) {
    final inner = px * 20 ~/ 24, s = inner / (2 * r);
    final small = img.copyResize(tight, width: (tight.width * s).round(), height: (tight.height * s).round(), interpolation: img.Interpolation.average);
    final out = img.Image(width: px, height: px, numChannels: 4);
    img.compositeImage(out, small, dstX: (px / 2 - cx * s).round(), dstY: (px / 2 - cy * s).round());
    _save('android/app/src/main/res/drawable-$d/ic_stat_kakebo.png', out);
  }
}

/// The ensō in paper colour, to sit on green. The blossom's thin wash would mix with the green into grey, so the pink patch
/// turns opaque pale pink with ochre stamens; the stroke grows a little so it still reads at 48 dp.
img.Image _negative(img.Image fg, img.ColorRgb8 paper) {
  img.Image channel(num Function(img.Pixel p) f) {
    final out = img.Image(width: fg.width, height: fg.height, numChannels: 1);
    for (final p in fg) {
      out.setPixelR(p.x, p.y, f(p));
    }
    return out;
  }

  // The blossom: strongly pink pixels pooled over a neighbourhood, so the stroke's reddish fringe stays out, then widened to
  // take in its outline and stamens.
  final pooled = img.gaussianBlur(channel((p) => p.r > p.g + 40 && p.a > 60 ? 255 : 0), radius: 12);
  final blossom = img.gaussianBlur(channel((p) => pooled.getPixel(p.x, p.y).r > 40 ? 255 : 0), radius: 5);
  // Inside that patch, reddish ink is the flower; the green-black ink under it stays with the stroke.
  bool isFlower(img.Pixel p) => p.a > 0 && p.r >= p.g - 5 && blossom.getPixel(p.x, p.y).r > 20;
  // Soft dilation of the stroke alone: its blurred alpha, amplified, under the original, so the dry-brush texture stays.
  final grown = img.gaussianBlur(channel((p) => isFlower(p) ? 0 : p.a), radius: 4);
  final out = img.Image(width: fg.width, height: fg.height, numChannels: 4);
  // The flower on its own layer, transparent pink around it so resizing leaves no dark fringe.
  final flower = img.fill(
    img.Image(width: fg.width, height: fg.height, numChannels: 4),
    color: img.ColorRgba8(243, 198, 204, 0),
  );
  var (sx, sy, n) = (0.0, 0.0, 0);
  for (final p in fg) {
    if (isFlower(p)) {
      final stamen = p.r > p.b + 40 && p.g > p.b + 25 && p.g > p.r - 60, shade = .72 + .28 * (p.r + p.g + p.b) / 765;
      final (r, g, b) = stamen ? (217.0, 168.0, 74.0) : (243 * shade, 198 * shade, 204 * shade);
      flower.setPixelRgba(p.x, p.y, r, g, b, min(255, p.a * 3));
      (sx, sy, n) = (sx + p.x, sy + p.y, n + 1);
    } else {
      out.setPixelRgba(p.x, p.y, paper.r, paper.g, paper.b, max(p.a, min(255, grown.getPixel(p.x, p.y).r * 1.8)));
    }
  }
  // Larger by [bloom] around its own centre, pulled toward the middle only as far as it takes to stay inside the 66 dp
  // circle every mask shape shows (.61 of the half canvas), with a few pixels to spare.
  final cx = sx / n, cy = sy / n, mid = fg.width / 2;
  var (reach, x0, y0, x1, y1) = (0.0, fg.width, fg.height, 0, 0);
  for (final p in flower) {
    if (p.a > 0) {
      reach = max(reach, sqrt(pow(p.x - cx, 2) + pow(p.y - cy, 2)));
      (x0, y0, x1, y1) = (min(x0, p.x), min(y0, p.y), max(x1, p.x), max(y1, p.y));
    }
  }
  final d0 = sqrt(pow(cx - mid, 2) + pow(cy - mid, 2)), d = min(d0, .61 * mid - 8 - reach * bloom);
  // Only the flower's box is resized (with a transparent rim), so it lands at positive coordinates: compositeImage
  // mishandles a layer placed off the canvas's top left.
  const rim = 4;
  (x0, y0, x1, y1) = (x0 - rim, y0 - rim, x1 + rim, y1 + rim);
  final box = img.copyCrop(flower, x: x0, y: y0, width: x1 - x0 + 1, height: y1 - y0 + 1);
  final big = img.copyResize(box, width: (box.width * bloom).round(), height: (box.height * bloom).round(), interpolation: img.Interpolation.cubic);
  final (nx, ny) = (mid + (cx - mid) * d / d0, mid + (cy - mid) * d / d0);
  img.compositeImage(out, big, dstX: (nx - (cx - x0) * bloom).round(), dstY: (ny - (cy - y0) * bloom).round());
  return out;
}

/// Median of the border pixels.
img.ColorRgb8 _paper(img.Image im) {
  final rs = <num>[], gs = <num>[], bs = <num>[];
  for (final p in im) {
    if (p.x < 12 || p.y < 12 || p.x >= im.width - 12 || p.y >= im.height - 12) {
      rs.add(p.r);
      gs.add(p.g);
      bs.add(p.b);
    }
  }
  num med(List<num> l) => (l..sort())[l.length ~/ 2];
  return img.ColorRgb8(med(rs).toInt(), med(gs).toInt(), med(bs).toInt());
}

/// "Color to alpha" against the paper: each pixel becomes the ink that, laid on paper, gives the same color.
img.Image _inkOnly(img.Image im, img.ColorRgb8 paper) {
  final out = img.Image(width: im.width, height: im.height, numChannels: 4);
  final k = [paper.r / 255, paper.g / 255, paper.b / 255];
  for (final p in im) {
    final c = [p.r / 255, p.g / 255, p.b / 255];
    var a = 0.0;
    // Only darker than paper counts as ink: lighter specks are paper fibre.
    for (var i = 0; i < 3; i++) {
      if (c[i] < k[i]) a = max(a, (k[i] - c[i]) / k[i]);
    }
    final kept = ((a - grain) / (1 - grain)).clamp(0.0, 1.0);
    // Fully transparent pixels keep the paper color so resizing leaves no dark fringe.
    final f = [for (var i = 0; i < 3; i++) a == 0 ? k[i] : (k[i] + (c[i] - k[i]) / a).clamp(0.0, 1.0)];
    out.setPixelRgba(p.x, p.y, f[0] * 255, f[1] * 255, f[2] * 255, kept * 255);
  }
  return out;
}

/// Center of the drawing's bounding box and its farthest visible pixel from it.
(double, double, double) _bounds(img.Image ink) {
  var (x0, y0, x1, y1) = (ink.width, ink.height, 0, 0);
  for (final p in ink) {
    if (p.a > 25) (x0, y0, x1, y1) = (min(x0, p.x), min(y0, p.y), max(x1, p.x), max(y1, p.y));
  }
  final cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
  var r = 0.0;
  for (final p in ink) {
    if (p.a > 25) r = max(r, sqrt(pow(p.x - cx, 2) + pow(p.y - cy, 2)));
  }
  return (cx, cy, r);
}

/// Same shape in one flat color, with dry-brush translucency pushed to solid.
img.Image _silhouette(img.Image im, int v) {
  final out = img.Image(width: im.width, height: im.height, numChannels: 4);
  for (final p in im) {
    out.setPixelRgba(p.x, p.y, v, v, v, min(255, p.a * 1.6));
  }
  return out;
}

void _save(String path, img.Image im) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(im));
  stdout.writeln(path);
}

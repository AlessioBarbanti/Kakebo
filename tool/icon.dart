// Turns the painted icon (assets/icon/source.png: ink on paper) into Android icon layers:
//   dart run tool/icon.dart && dart run flutter_launcher_icons
// Writes assets/icon/{foreground,monochrome,icon}.png and the white status-bar icon for notifications.
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

// Artwork radius / half canvas. Android shows the central 72 of 108 dp and guarantees a 66 dp circle (.61) in every
// mask shape; .50 fills about three quarters of the visible circle and leaves the ensō room to breathe.
const safe = .50;
const grain = .12; // paper-texture alpha below this is treated as paper

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
  _save('assets/icon/foreground.png', fg);
  _save('assets/icon/monochrome.png', _silhouette(fg, 0));
  _save('assets/icon/icon.png', img.compositeImage(img.fill(img.Image(width: 1024, height: 1024), color: paper), fg));

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
  stdout.writeln('paper #${[paper.r, paper.g, paper.b].map((v) => v.toInt().toRadixString(16).padLeft(2, '0')).join()}  (adaptive_icon_background)');
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

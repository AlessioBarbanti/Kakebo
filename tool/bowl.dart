// Synthesizes the two singing-bowl tones played while breathing:
//   dart run tool/bowl.dart
// Tweak the constants below and re-run; the app plays assets/sounds/*.wav.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const rate = 22050; // highest partial stays well under 11 kHz
const seconds = 5.5; // 4 s breath phase + a tail that fades under the next note
const peak = .3; // "leggero": well below full scale
const attack = .8; // slow swell, like a rubbed bowl rather than a struck one
const release = 1.0;

// Bowls ring with inharmonic partials: (frequency ratio, amplitude, decay in seconds).
const partials = [(1.0, 1.0, 3.0), (2.76, .45, 2.0), (5.40, .2, 1.3), (8.93, .08, .9)];
const shimmer = 1.0035; // each partial doubled with this detune → the slow "wah" beating

void main() {
  bowl('assets/sounds/inspira.wav', 440.0); // A4: breathing in
  bowl('assets/sounds/espira.wav', 293.66); // D4, a fifth lower: breathing out
}

void bowl(String path, double f0) {
  final n = (rate * seconds).round(), wave = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / rate;
    var v = 0.0;
    for (final (r, a, d) in partials) {
      final f = f0 * r;
      v += a * exp(-t / d) * (sin(2 * pi * f * t) + sin(2 * pi * f * shimmer * t)) / 2;
    }
    final swell = t < attack ? (1 - cos(pi * t / attack)) / 2 : 1.0;
    final fade = t > seconds - release ? (1 + cos(pi * (t - seconds + release) / release)) / 2 : 1.0;
    wave[i] = v * swell * fade;
  }
  final top = wave.fold(0.0, (m, v) => max(m, v.abs()));
  final pcm = Int16List.fromList([for (final v in wave) (v / top * peak * 32767).round()]);
  assert(pcm.first == 0 && pcm.last.abs() < 2, 'tone must start and end silent, or it clicks');

  final data = pcm.buffer.asUint8List();
  final header = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + data.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, rate, Endian.little)
    ..setUint32(28, rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, data.length, Endian.little);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync([...header.buffer.asUint8List(), ...data]);
  stdout.writeln('$path  ${f0}Hz  ${seconds}s  ${(data.length + 44) ~/ 1024} KB');
}

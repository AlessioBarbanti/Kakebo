import 'package:flutter/painting.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/theme/color.dart';

/// One of the four pillars; its words come in the app's language.
class _PillarStyle {
  _PillarStyle({required this.kanji, required this.ink, required this.soft, required this.img, required this.art, required this.pos});
  final String kanji, img, art; // img: the intro's print; art: the sprig used as the pillar's accent
  final Color ink, soft;
  final Alignment pos;
}

final _styles = {
  'needs': _PillarStyle(
    kanji: '竹',
    ink: ok(.56, .08, 155),
    soft: ok(.93, .04, 155),
    img: 'assets/art/bamboo.jpg',
    art: 'assets/art/sprig_bamboo.webp',
    pos: const Alignment(0, -.3),
  ),
  'wants': _PillarStyle(
    kanji: '梅',
    ink: ok(.6, .1, 10),
    soft: ok(.94, .035, 10),
    img: 'assets/art/plum.jpg',
    art: 'assets/art/sprig_plum.webp',
    pos: const Alignment(0, -.76),
  ),
  'culture': _PillarStyle(
    kanji: '蘭',
    ink: ok(.58, .08, 295),
    soft: ok(.94, .03, 295),
    img: 'assets/art/orchid.jpg',
    art: 'assets/art/sprig_orchid.webp',
    pos: Alignment.center,
  ),
  'unexpected': _PillarStyle(
    kanji: '菊',
    ink: ok(.62, .1, 80),
    soft: ok(.95, .045, 90),
    img: 'assets/art/chrys.jpg',
    art: 'assets/art/sprig_chrys.webp',
    pos: Alignment.center,
  ),
};

extension PillarPresentation on Pillar {
  _PillarStyle get _style => _styles[key]!;
  String get name => tr.pillars[key]!.name;
  String get virtue => tr.pillars[key]!.virtue;
  String get kanji => _style.kanji;
  String get img => _style.img;
  String get art => _style.art;
  Color get ink => _style.ink;
  Color get soft => _style.soft;
  Alignment get pos => _style.pos;
}

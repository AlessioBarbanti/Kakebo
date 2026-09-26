import 'package:flutter/painting.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/shared/theme/color.dart';

/// One of the four pillars; its words come in the app's language.
class _PillarStyle {
  _PillarStyle({required this.kanji, required this.ink, required this.soft, required this.art});
  final String kanji, art; // art: the sprig used as the pillar's accent
  final Color ink, soft;
}

final _styles = {
  'needs': _PillarStyle(kanji: '竹', ink: ok(.56, .08, 155), soft: ok(.93, .04, 155), art: 'assets/art/sprig_bamboo.webp'),
  'wants': _PillarStyle(kanji: '梅', ink: ok(.6, .1, 10), soft: ok(.94, .035, 10), art: 'assets/art/sprig_plum.webp'),
  'culture': _PillarStyle(kanji: '蘭', ink: ok(.58, .08, 295), soft: ok(.94, .03, 295), art: 'assets/art/sprig_orchid.webp'),
  'unexpected': _PillarStyle(kanji: '菊', ink: ok(.62, .1, 80), soft: ok(.95, .045, 90), art: 'assets/art/sprig_chrys.webp'),
};

extension PillarPresentation on Pillar {
  _PillarStyle get _style => _styles[key]!;
  String get name => tr.pillars[key]!.name;
  String get virtue => tr.pillars[key]!.virtue;
  String get kanji => _style.kanji;
  String get art => _style.art;
  Color get ink => _style.ink;
  Color get soft => _style.soft;
}

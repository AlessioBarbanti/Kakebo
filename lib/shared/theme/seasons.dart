import 'package:flutter/painting.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/state/kakebo.dart';

class Season {
  Season(this.key, this.plant, this.deep, this.ink, this.soft, this.bloom);
  final String key, plant;
  final Color deep, ink, soft, bloom;
  String get name => tr.seasons[key]!.$1;
  String get plantName => tr.seasons[key]!.$2;
}

final seasons = {
  'winter': Season('winter', '南天', ok(.44, .13, 25), ok(.56, .16, 25), ok(.95, .025, 25), ok(.72, .14, 25)),
  'spring': Season('spring', '桜', ok(.47, .08, 15), ok(.68, .09, 15), ok(.955, .025, 15), ok(.89, .05, 15)),
  'summer': Season('summer', '金魚', ok(.47, .12, 35), ok(.66, .14, 38), ok(.955, .03, 45), ok(.82, .1, 42)),
  'autumn': Season('autumn', '月', ok(.46, .08, 80), ok(.7, .1, 85), ok(.96, .035, 90), ok(.88, .08, 90)),
};
Season seasonOf(int month0) =>
    seasons[[11, 0, 1].contains(month0)
        ? 'winter'
        : month0 < 5
        ? 'spring'
        : month0 < 8
        ? 'summer'
        : 'autumn']!;

/// Japanese proverbs (text, romaji); their meaning is tr.proverbs[i].
const phrases = [
  ('塵も積もれば山となる', 'Chiri mo tsumoreba yama to naru'),
  ('足るを知る', 'Taru o shiru'),
  ('急がば回れ', 'Isogaba maware'),
  ('安物買いの銭失い', 'Yasumono-gai no zeni-ushinai'),
  ('石の上にも三年', 'Ishi no ue ni mo san-nen'),
  ('七転び八起き', 'Nana korobi ya oki'),
  ('一期一会', 'Ichigo ichie'),
];

const kanjiMesi = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

extension KakeboPresentation on Kakebo {
  Season get season => seasonOf(now.month - 1);
  String get greeting {
    final h = now.hour;
    return h >= 5 && h < 12
        ? tr.morning
        : h >= 12 && h < 18
        ? tr.afternoon
        : tr.evening;
  }
}

import 'package:flutter/painting.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/period.dart';
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

/// Sayings of the day (original, romaji). Meaning and source are tr.phraseMeanings[i]: a source for quotations,
/// none for traditional Japanese sayings. Chosen to encourage, never to judge how anyone spends.
const phrases = [
  ('塵も積もれば山となる', 'Chiri mo tsumoreba yama to naru'),
  ('足るを知る', 'Taru o shiru'),
  ('急がば回れ', 'Isogaba maware'),
  ('日日是好日', 'Nichinichi kore kôjitsu'),
  ('石の上にも三年', 'Ishi no ue ni mo san-nen'),
  ('残り物には福がある', 'Nokorimono ni wa fuku ga aru'),
  ('七転び八起き', 'Nana korobi ya oki'),
  ('花は盛りに、月は隈なきをのみ見るものかは', 'Hana wa sakari ni, tsuki wa kumanaki o nomi miru mono ka wa'),
  ('備えあれば憂いなし', 'Sonae areba urei nashi'),
  ('千里の道も一歩から', 'Senri no michi mo ippo kara'),
  ('一期一会', 'Ichigo ichie'),
  ('笑う門には福来る', 'Warau kado ni wa fuku kitaru'),
  ('過ぎたるは猶及ばざるが如し', 'Sugitaru wa nao oyobazaru ga gotoshi'),
  ('明日は明日の風が吹く', 'Ashita wa ashita no kaze ga fuku'),
  ('晴耕雨読', 'Seikô udoku'),
  ('案ずるより産むが易し', 'Anzuru yori umu ga yasushi'),
  ('温故知新', 'Onko chishin'),
  ('雨降って地固まる', 'Ame futte ji katamaru'),
  ('転ばぬ先の杖', 'Korobanu saki no tsue'),
  ('初心忘るべからず', 'Shoshin wasuru bekarazu'),
  ('住めば都', 'Sumeba miyako'),
  ('猿も木から落ちる', 'Saru mo ki kara ochiru'),
  ('ゆく河の流れは絶えずして、しかももとの水にあらず', 'Yuku kawa no nagare wa taezu shite, shikamo moto no mizu ni arazu'),
  ('待てば海路の日和あり', 'Mateba kairo no hiyori ari'),
  ('人間万事塞翁が馬', 'Ningen banji Saiô ga uma'),
  ('雨垂れ石を穿つ', 'Amadare ishi o ugatsu'),
  ('上善は水の如し', 'Jôzen wa mizu no gotoshi'),
  ('起きて半畳寝て一畳', 'Okite hanjô nete ichijô'),
  ('人事を尽くして天命を待つ', 'Jinji o tsukushite tenmei o matsu'),
  ('捨てる神あれば拾う神あり', 'Suteru kami areba hirou kami ari'),
];

const kanjiMesi = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

extension KakeboPresentation on Kakebo {
  Season get season => seasonOf(now.month - 1);

  /// One saying after another, a new one each day; the order runs on across months and years.
  int get phraseIndex => daysBetween(DateTime(2026), now) % phrases.length;
  String get greeting {
    final h = now.hour;
    return h >= 5 && h < 12
        ? tr.morning
        : h >= 12 && h < 18
        ? tr.afternoon
        : tr.evening;
  }
}

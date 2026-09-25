import 'dart:async';

import 'package:flutter/material.dart';

import 'kakebo.dart';
import 'ui.dart';

typedef _Item = ({String kanji, String name, String jp, Color ink, Color soft});

class _Step {
  const _Step(this.kanji, this.title, this.body, this.cta, this.credit, this.art, this.fallback);
  final String kanji, title, body, cta, credit, fallback;
  final (String, Alignment)? art;
}

const _q4 = ['Quanto denaro hai?', 'Quanto vorresti risparmiare?', 'Quanto stai spendendo?', 'Come puoi migliorare?'];
const _q4jp = ['いくらあるか', 'いくら貯めたいか', 'いくら使っているか', 'どう改善できるか'];

const _steps = [
  _Step(
    '家計簿',
    'Un registro per la casa',
    'Nato in Giappone nel 1904: annoti ogni spesa, ti fermi un momento, osservi dove vanno i soldi.',
    'Avanti',
    'Utagawa Hiroshige · Giardino di susini a Kameido, 1857',
    ('assets/art/plum.jpg', Alignment(0, -.64)),
    '梅',
  ),
  _Step(
    '四君子',
    'Quattro pilastri, quattro gentiluomini',
    'Ogni spesa va in uno di quattro pilastri, ognuno con la sua pianta.',
    'Avanti',
    'Zheng Xie, Bambù e rocce · Hiroshige, Susini a Kameido · Zheng Xie, Orchidee · Hokusai, Crisantemi e ape',
    null,
    '四',
  ),
  _Step(
    '四問',
    'Quattro domande',
    'A inizio e fine mese rispondi sempre alle stesse quattro. Scorri per iniziare.',
    'Inizia il mio mese',
    'Katsushika Hokusai · Crisantemi e ape, c. 1832',
    ('assets/art/chrys.jpg', Alignment.center),
    '菊',
  ),
];

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int step = 0;
  double drag = 0;
  double? op;
  bool dragging = false;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _move(double d, double? o, bool g) => setState(() {
    drag = d;
    op = o;
    dragging = g;
  });

  void finish() => app.update(() {
    app.onboarded = true;
    app.screen = 'monthStart';
  });

  void goStep(int n) {
    if (n < 0 || n > 2 || n == step) return;
    final dir = n > step ? 1 : -1;
    _t?.cancel();
    _move(-dir * 220.0, 0, false);
    _t = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      step = n;
      _move(dir * 90.0, 0, true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _move(0, 1, false);
      });
    });
  }

  void next() => step < 2 ? goStep(step + 1) : finish();

  @override
  Widget build(BuildContext context) {
    final ob = _steps[step], pad = MediaQuery.paddingOf(context);
    final art = ob.art != null ? [ob.art!] : [for (final p in pillars.values) (p.img, p.pos)];
    final fallback = [
      (pillars['wants']!.soft, pillars['wants']!.ink),
      (ok(.94, .03, 150), pillars['needs']!.ink),
      (pillars['unexpected']!.soft, pillars['unexpected']!.ink),
    ][step];
    final items = <_Item>[
      if (step == 1)
        for (final p in pillars.values) (kanji: p.kanji, name: p.name, jp: p.virtue, ink: p.ink, soft: p.soft),
      if (step == 2)
        for (var i = 0; i < 4; i++) (kanji: '${i + 1}', name: _q4[i], jp: _q4jp[i], ink: ink, soft: ok(.94, .03, 150)),
    ];
    final out = op == 0;
    final dur = Duration(
      milliseconds: dragging
          ? 0
          : out
          ? 260
          : 700,
    );
    final curve = out ? const Cubic(.4, 0, 1, 1) : const Cubic(.16, 1, .3, 1);

    return GestureDetector(
      onHorizontalDragUpdate: (d) => _move(drag + d.delta.dx, null, true),
      onHorizontalDragEnd: (_) {
        if (drag < -60) return next();
        if (drag > 60 && step > 0) return goStep(step - 1);
        _move(0, null, false);
      },
      child: ColoredBox(
        color: bg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: fallback.$1,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: pad.top + 40),
              child: Opacity(
                opacity: .35,
                child: Text(ob.fallback, style: serif(180, h: 1, c: fallback.$2)),
              ),
            ),
            AnimatedContainer(
              duration: dur,
              curve: curve,
              transform: Matrix4.translationValues(drag * .2, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (img, pos) in art)
                    Expanded(
                      child: Image.asset(img, fit: BoxFit.cover, alignment: pos, errorBuilder: (_, _, _) => const SizedBox()),
                    ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [bg, bg.withValues(alpha: .96), bg.withValues(alpha: .5), bg.withValues(alpha: 0)],
                  stops: const [0, .52, .72, 1],
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: pad.top + 8,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: ok(.985, .008, 140, .92), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    ob.credit,
                    textAlign: TextAlign.right,
                    style: sans(12, h: 1.4, c: ok(.3, .03, 160)),
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 120, 24, 36 + pad.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          opacity: op ?? (1 - drag.abs() / 260).clamp(.1, 1),
                          duration: dur,
                          child: AnimatedContainer(
                            duration: dur,
                            curve: curve,
                            transform: Matrix4.translationValues(drag * .5, 0, 0),
                            child: _content(ob, items),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(_Step ob, List<_Item> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('家計簿 · KAKEBO', style: serif(13, ls: 1.82, c: ok(.45, .08, 10))),
          TapText('Salta', finish, style: sans(14, c: ok(.38, .04, 160))),
        ],
      ),
      const SizedBox(height: 20),
      Text(ob.kanji, style: serif(44, h: 1, c: green)),
      const SizedBox(height: 16),
      Text(ob.title, style: serif(28, h: 1.25)),
      const SizedBox(height: 10),
      Text(ob.body, style: sans(15, h: 1.65, c: ok(.36, .03, 160))),
      const SizedBox(height: 24),
      Column(
        spacing: 8,
        children: [
          for (final it in items)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: it.soft, borderRadius: BorderRadius.circular(18)),
              child: Row(
                spacing: 14,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      it.kanji,
                      textAlign: TextAlign.center,
                      style: serif(22, c: it.ink),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(it.name, style: sans(15, w: FontWeight.w700)),
                        Text(it.jp, style: sans(13, c: ok(.38, .03, 160))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => goStep(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == step ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(color: i == step ? green : ok(.85, .03, 150), borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ),
            ],
          ),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                if (step > 0)
                  TapText(
                    'Indietro',
                    () => goStep(step - 1),
                    style: sans(15, c: ok(.38, .04, 160)),
                    pad: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                Btn(ob.cta, next),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

class MonthStart extends StatelessWidget {
  const MonthStart({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = app.planMonth, fixed = app.fixedTotal, income = app.income, avail = app.available;
    final sub = ok(.42, .03, 160);
    Widget field(String label, String hint, double value, ValueChanged<double> set, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(label, style: sans(13, w: FontWeight.w700)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 6,
            children: [
              Expanded(
                child: NumField(value, set, style: serif(28, w: FontWeight.w700)),
              ),
              Text('€', style: serif(24)),
            ],
          ),
          Text(hint, style: sans(12, h: 1.4, c: sub)),
        ],
      ),
    );

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 40 + MediaQuery.paddingOf(context).bottom),
        child: Reveal(
          children: [
            Align(alignment: Alignment.centerLeft, child: TapText('← Torna al registro', () => app.go('home'))),
            Padding(padding: const EdgeInsets.only(top: 24), child: kicker('${mesi[pm.month - 1].toUpperCase()} ${pm.year}')),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Prima di iniziare, scrivi cosa entra e cosa deve uscire.', style: serif(26, h: 1.3)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Column(
                spacing: 12,
                children: [
                  field('Entrate del mese', 'Stipendio e altre entrate', income, (v) => app.update(() => app.income = v), ok(.93, .04, 155)),
                  field(
                    'Obiettivo di risparmio',
                    'Da mettere da parte subito, prima di spendere',
                    app.save,
                    (v) => app.update(() {
                      app.save = v;
                      app.rule = false;
                    }),
                    ok(.94, .035, 10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: ok(.99, .006, 140, .8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ok(.9, .025, 150)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              Text('Punto di partenza: 50 / 30 / 20', style: sans(13, w: FontWeight.w700)),
                              Text(
                                'Metà ai bisogni, un terzo al resto, un quinto al risparmio. Poi il kakebo ti chiede di guardare ogni voce.',
                                style: sans(12, h: 1.45, c: sub),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: app.toggleRule,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: app.rule ? ok(.93, .04, 155) : green, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              app.rule ? 'Applicato' : 'Applica',
                              style: sans(14, w: FontWeight.w700, c: app.rule ? ink : onGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (app.rule)
                      Column(
                        children: [
                          for (final (pct, label, note, v) in [
                            ('50%', 'Necessità', fixed > income * .5 ? 'Le spese fisse superano già la metà' : 'Di cui ${fmt(fixed)} già in spese fisse', .5),
                            ('30%', 'Desideri, cultura, imprevisti', 'Da dividere tra i tre pilastri', .3),
                            ('20%', 'Risparmio', 'Diventa il tuo obiettivo del mese', .2),
                          ])
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: ok(.93, .02, 150))),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    width: 38,
                                    child: Text(pct, style: serif(15, w: FontWeight.w700)),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 1,
                                      children: [
                                        Text(label, style: sans(14)),
                                        Text(note, style: sans(12, c: sub)),
                                      ],
                                    ),
                                  ),
                                  Text(fmt((income * v).round()), style: serif(16)),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(color: ok(.95, .025, 150), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text('Spese fisse ricorrenti', style: sans(13, w: FontWeight.w700)),
                              Text('Si ripetono ogni mese, modificabili quando vuoi', style: sans(12, c: sub)),
                            ],
                          ),
                          Text(fmt(fixed), style: serif(24, w: FontWeight.w700)),
                        ],
                      ),
                    ),
                    for (final r in app.fixed) _FixedRow(r, key: ValueKey(r.id)),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: TapText(
                        '+ Aggiungi spesa fissa',
                        () => app.update(() => app.fixed.add(Fixed(DateTime.now().millisecondsSinceEpoch, 'Nuova voce', 0))),
                        style: sans(14, w: FontWeight.w700, c: ok(.4, .06, 160)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: CustomPaint(
                foregroundPainter: Dashed(ok(.78, .05, 150), 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: BoxDecoration(color: ok(.99, .006, 140, .7), borderRadius: BorderRadius.circular(20)),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text('Da spendere con consapevolezza', style: sans(14, w: FontWeight.w700)),
                          Text('circa ${fmt((avail * 7 / app.dim).round())} a settimana', style: sans(13, c: ok(.45, .03, 160))),
                        ],
                      ),
                      Text(fmt(avail), style: serif(32, w: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Align(alignment: Alignment.centerRight, child: Btn('Inizia ${mese(pm)}', () => app.go('home'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedRow extends StatelessWidget {
  const _FixedRow(this.r, {super.key});
  final Fixed r;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: card)),
    ),
    child: Row(
      spacing: 8,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: r.name,
            onChanged: (v) => app.update(() => r.name = v),
            style: sans(15),
            decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6)),
          ),
        ),
        SizedBox(
          width: 80,
          child: NumField(r.amt, (v) => app.update(() => r.amt = v), style: serif(16), align: TextAlign.right, fill: card),
        ),
        Text('€', style: serif(15)),
        Semantics(
          button: true,
          label: 'Rimuovi ${r.name}',
          child: InkResponse(
            onTap: () => app.update(() => app.fixed.remove(r)),
            radius: 22,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: Text('×', style: sans(20, c: ok(.38, .04, 160))),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

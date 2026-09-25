import 'package:flutter/material.dart';

import 'kakebo.dart';
import 'ui.dart';

String _short(DateTime d) => '${giorni[d.weekday - 1].substring(0, 3)} ${d.day} ${abbr(d)}';

/// Diary history, newest first: evening thoughts, Sunday recaps, sealed months.
List<(String, String, String, Color)> _timeline() {
  final items = <(DateTime, String, String, String, Color)>[];
  final today = dateKey(app.now);
  app.thoughts.forEach((k, v) {
    final d = DateTime.parse(k);
    items.add((d, 'Pensiero della sera', k == today ? 'Oggi' : _short(d), v, ok(.72, .06, 295)));
  });
  if (app.flags['weekly']!) {
    final first = DateTime(app.now.year, app.now.month), budget = app.available * 7 / app.dim;
    for (var mon = DateTime(first.year, first.month, 2 - first.weekday); ; mon = DateTime(mon.year, mon.month, mon.day + 7)) {
      final sun = DateTime(mon.year, mon.month, mon.day + 6);
      if (!sun.isBefore(DateTime(app.now.year, app.now.month, app.day))) break;
      final list = app.entries.where((e) => !e.date.isBefore(mon) && !e.date.isAfter(sun)).toList(), total = sum(list);
      final by = Kakebo.spentBy(list).entries.reduce((a, b) => b.value > a.value ? b : a);
      final quiet = List.generate(7, (i) => DateTime(mon.year, mon.month, mon.day + i)).where((d) => !list.any((e) => e.date == d)).length;
      final span = mon.month == sun.month ? '${mon.day}–${sun.day} ${abbr(sun)}' : '${mon.day} ${abbr(mon)}–${sun.day} ${abbr(sun)}';
      items.add((
        sun,
        'La settimana · $span',
        fmt(total),
        total == 0
            ? 'Una settimana senza spese.'
            : '${total <= budget ? 'Nel ritmo del mese' : 'Sopra il ritmo del mese'}. Il pilastro più pieno: ${pillars[by.key]!.name}.${quiet >= 2 ? ' $quiet giorni senza spese.' : ''}',
        app.season.ink,
      ));
    }
  }
  app.sealed.forEach((mk, saved) {
    final m = DateTime.parse('$mk-01'), next = DateTime(m.year, m.month + 1), goal = app.improve[mk] ?? '';
    items.add((
      DateTime(m.year, m.month + 1, 0),
      'Le quattro domande · ${mese(m)}',
      'Sigillato · ${fmt(saved)} risparmiati',
      goal.trim().isEmpty ? 'Mese chiuso con il sigillo.' : 'Proposito per ${mese(next)}: ${goal.trim()}',
      sealRed,
    ));
  });
  items.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, kind, meta, text, dot) in items.take(20)) (kind, meta, text, dot)];
}

class Journal extends StatelessWidget {
  const Journal({super.key});

  @override
  Widget build(BuildContext context) {
    final t = app.thoughtToday, month = mese(app.now);
    Widget diary(String title, String when, String status, Color statusFg, String preview, Color color, String to) => GestureDetector(
      onTap: () => app.go(to),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: 10,
              children: [
                Flexible(child: Text(title, style: serif(20))),
                Text(
                  status,
                  style: sans(13, w: FontWeight.w700, c: statusFg),
                ),
              ],
            ),
            Text(when, style: sans(13, c: ok(.38, .03, 160))),
            Text(
              preview,
              style: serif(16, w: FontWeight.w500, h: 1.55, c: ok(.3, .03, 160)),
            ),
          ],
        ),
      ),
    );

    return Reveal(
      spacing: 14,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              heading('DIARIO', 'Due momenti'),
              Text('Uno per la sera, uno per il mese. Ogni domenica il diario raccoglie da solo la settimana.', style: sans(14, h: 1.55, c: muted)),
            ],
          ),
        ),
        diary(
          'Pensiero della sera',
          'Ogni giorno alle ${app.thoughtTime}',
          t != null ? 'Scritto' : 'Da scrivere',
          t != null ? ok(.4, .08, 155) : ok(.38, .05, 295),
          t != null
              ? '“$t”'
              : app.evening
              ? 'È sera: puoi scriverlo ora.'
              : 'Si apre stasera alle ${app.thoughtTime}.',
          ok(.955, .02, 295),
          'thought',
        ),
        diary(
          'Il mese',
          'Le quattro domande · dal ${app.dim} $month',
          app.isSealed ? 'Sigillato' : 'Aperto',
          ok(.48, .15, 28),
          app.isSealed ? '${mesi[app.now.month - 1]} è chiuso con il sigillo.' : 'Quanto hai, quanto vuoi risparmiare, quanto spendi, come migliorare.',
          ok(.95, .025, 28),
          'review',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                child: Text('Cronologia', style: serif(18)),
              ),
              for (final (kind, meta, text, color) in _timeline())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14,
                      children: [
                        SizedBox(
                          width: 12,
                          child: Column(
                            children: [
                              Padding(padding: const EdgeInsets.only(top: 5), child: dot(10, color)),
                              Expanded(
                                child: Container(width: 2, margin: const EdgeInsets.only(top: 4), color: ok(.9, .02, 150)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 4,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      kind,
                                      style: sans(12, w: FontWeight.w700, c: muted),
                                    ),
                                    Text(meta, style: sans(12, c: muted)),
                                  ],
                                ),
                                Text(text, style: sans(15, h: 1.55)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class Review extends StatelessWidget {
  const Review({super.key});

  @override
  Widget build(BuildContext context) {
    final s = app.season, mk = monthKey(app.now), month = mese(app.now), next = mese(app.nextMonth), sealed = app.isSealed;
    final questions = [
      ('Quanto denaro hai?', fmt(app.income - app.fixedTotal), 'Entrate meno spese fisse'),
      ('Quanto vorresti risparmiare?', fmt(app.save), 'Il tuo obiettivo per $month'),
      ('Quanto stai spendendo?', fmt(app.spent), 'Nei quattro pilastri'),
    ];
    final dim = ok(.34, .04, 160);

    return Reveal(
      spacing: 24,
      children: [
        Align(alignment: Alignment.centerLeft, child: TapText('← Diario', () => app.go('journal'))),
        heading('FINE MESE', 'Le quattro domande'),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: s.soft, borderRadius: BorderRadius.circular(28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text('${month.toUpperCase()}, FINORA', style: sans(12, ls: 1.68, c: ok(.38, .04, 160))),
                      Text(fmt(app.onTrack), style: serif(44, w: FontWeight.w700)),
                    ],
                  ),
                  Text('verso il risparmio · obiettivo ${fmt(app.save)}', style: sans(14, c: dim)),
                ],
              ),
              const Branch(height: 110),
              Text(
                'Ogni fiore vale ${fmt(app.save / 10)}. Finora ${fmt(app.bloomed * app.save / 10)} su ${fmt(app.save)} messi da parte.',
                style: sans(13, c: dim),
              ),
              if (sealed) Align(alignment: Alignment.centerRight, child: Hanko(app.now)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            for (final (i, (q, value, note)) in questions.indexed)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: ok(.95, .025, 150), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      'Domanda ${i + 1}',
                      style: sans(12, w: FontWeight.w700, c: ok(.4, .04, 160)),
                    ),
                    Text(q, style: serif(19, h: 1.35)),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(value, style: serif(28, w: FontWeight.w700)),
                    ),
                    Text(note, style: sans(13, c: ok(.42, .03, 160))),
                  ],
                ),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ok(.88, .04, 150), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                'Domanda 4',
                style: sans(12, w: FontWeight.w700, c: ok(.4, .04, 160)),
              ),
              Text('Come puoi migliorare?', style: serif(19, h: 1.35)),
              TextFormField(
                initialValue: app.improve[mk] ?? '',
                onChanged: (v) => app.update(() => app.improve[mk] = v),
                minLines: 4,
                maxLines: null,
                style: sans(15, h: 1.6),
                decoration: softInput('Un piccolo proposito per $next', ok(.96, .02, 150), 14, const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Btn(
            sealed ? 'Pianifica $next →' : 'Chiudi $month con il sigillo',
            sealed ? () => app.go('monthStart') : app.seal,
            color: sealed ? green : sealRed,
            pad: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          ),
        ),
      ],
    );
  }
}

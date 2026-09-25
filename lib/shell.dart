import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calendar.dart';
import 'home.dart';
import 'journal.dart';
import 'kakebo.dart';
import 'ledger.dart';
import 'ui.dart';

const _nav = [('home', 'Oggi'), ('ledger', 'Registro'), ('journal', 'Diario'), ('calendar', 'Calendario')];
final _tabs = [for (final (k, _) in _nav) k];

/// In-app layout: greeting, sticky tabs, swipeable content.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final _scroll = ScrollController();
  double drag = 0;
  double? op;
  bool dragging = false;
  Timer? _t;

  String get navScreen => app.screen == 'review' ? 'journal' : app.screen;

  @override
  void dispose() {
    _t?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _move(double d, double? o, bool g) => setState(() {
    drag = d;
    op = o;
    dragging = g;
  });

  void goTab(String k, [int? dir]) {
    if (app.screen == k) return _move(0, null, false);
    final d = dir ?? (_tabs.indexOf(k) > _tabs.indexOf(navScreen) ? 1 : -1);
    _t?.cancel();
    _move(-d * 120.0, 0, false);
    _t = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      _move(d * 40.0, 0, true);
      app.go(k);
      if (_scroll.hasClients) _scroll.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _move(0, 1, false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabs.indexOf(navScreen), out = op == 0;
    final content = switch (app.screen) {
      'ledger' => const Ledger(),
      'journal' => const Journal(),
      'review' => const Review(),
      'calendar' => const Calendar(),
      'settings' => const Settings(),
      _ => const Home(),
    };

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(child: _header()),
          PinnedHeaderSliver(child: _navBar()),
          SliverToBoxAdapter(
            child: GestureDetector(
              onHorizontalDragUpdate: idx < 0 ? null : (d) => _move(drag + d.delta.dx, null, true),
              onHorizontalDragEnd: idx < 0
                  ? null
                  : (_) {
                      if (drag < -70 && idx < _tabs.length - 1) return goTab(_tabs[idx + 1], 1);
                      if (drag > 70 && idx > 0) return goTab(_tabs[idx - 1], -1);
                      _move(0, null, false);
                    },
              child: AnimatedOpacity(
                opacity: op ?? math.max(.1, 1 - drag.abs() / 280),
                duration: Duration(
                  milliseconds: dragging
                      ? 0
                      : out
                      ? 420
                      : 500,
                ),
                curve: out ? Curves.easeIn : Curves.easeOut,
                child: AnimatedContainer(
                  duration: Duration(
                    milliseconds: dragging
                        ? 0
                        : out
                        ? 420
                        : 1000,
                  ),
                  curve: out ? const Cubic(.4, 0, .6, 1) : const Cubic(.16, 1, .3, 1),
                  transform: Matrix4.translationValues(drag * .6, 0, 0),
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 110 + MediaQuery.paddingOf(context).bottom),
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final s = app.season,
        fs = s.plant.length > 2
            ? 9.0
            : s.plant.length > 1
            ? 12.0
            : 16.0;
    final bar = Container(
      height: 2,
      decoration: BoxDecoration(color: ok(.35, .03, 160), borderRadius: BorderRadius.circular(1)),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(app.greeting, style: serif(34, h: 1.1)),
                Row(
                  spacing: 8,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: s.soft),
                      child: Text(
                        s.plant,
                        style: serif(fs, h: 1, c: s.ink, ls: -.06 * fs),
                      ),
                    ),
                    Text('${s.plantName} · ${s.name}', style: sans(13, c: s.deep)),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Impostazioni',
            child: Material(
              color: app.screen == 'settings' ? ok(.93, .025, 150) : Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => app.go(app.screen == 'settings' ? 'home' : 'settings'),
                child: SizedBox.square(
                  dimension: 44,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        SizedBox(width: 18, child: bar),
                        SizedBox(width: 12, child: bar),
                        SizedBox(width: 18, child: bar),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: bg.withValues(alpha: .85),
      border: Border(bottom: BorderSide(color: line)),
    ),
    child: Row(
      children: [
        for (final (k, label) in _nav)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => goTab(k),
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      label,
                      style: sans(14, w: navScreen == k ? FontWeight.w700 : FontWeight.w500, c: navScreen == k ? ink : ok(.42, .03, 160)),
                    ),
                    Container(
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(color: navScreen == k ? app.season.ink : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = ok(.45, .03, 160);
    Widget row(String label, String note, {String value = '', String? flag, VoidCallback? tap}) => InkWell(
      onTap: flag != null ? () => app.update(() => app.flags[flag] = !app.flags[flag]!) : tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: ok(.94, .02, 150))),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(label, style: sans(15)),
                  Text(note, style: sans(13, c: sub)),
                ],
              ),
            ),
            if (value.isNotEmpty) Text(value, style: sans(14, c: ok(.42, .04, 160))),
            if (flag != null) Toggle(app.flags[flag]!),
          ],
        ),
      ),
    );
    Widget group(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(title, style: sans(12, ls: 1.44, c: ok(.42, .04, 160))),
        ),
        DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: shadow),
          child: Material(
            color: card,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: Column(children: rows),
          ),
        ),
      ],
    );

    return Reveal(
      spacing: 24,
      children: [
        heading('IMPOSTAZIONI', 'Impostazioni'),
        group('REGISTRO', [
          row('Valuta', 'Mostrata su ogni spesa', value: 'Euro €'),
          row('Inizio del mese', 'Quando si azzerano i budget', value: 'Il 1°'),
          row('Entrate e spese fisse', 'Entrate, spese ricorrenti e risparmio', value: '${fmt(app.fixedTotal)} fisse ›', tap: () => app.go('monthStart')),
        ]),
        group('RITMO', [
          row('Riepilogo della domenica', 'La settimana raccolta nel diario, niente da scrivere', flag: 'weekly'),
          row('Frase del giorno', 'Un proverbio giapponese in fondo a Oggi', flag: 'phraseOn'),
          // ponytail: in-app only for now; system notifications need flutter_local_notifications + exact-alarm permission.
          row('Nota serale', 'Un invito a scrivere le spese del giorno', flag: 'reminders'),
        ]),
        group('LA SERA', [
          row('Notifica del pensiero', 'Cosa ti ha reso felice oggi?', flag: 'thoughtOn'),
          row(
            'Orario',
            'Tocca per cambiare',
            value: app.thoughtTime,
            tap: () => app.update(() => app.thoughtTime = thoughtTimes[(thoughtTimes.indexOf(app.thoughtTime) + 1) % thoughtTimes.length]),
          ),
          row('Scrivi il pensiero di oggi', 'Una schermata senza distrazioni', value: '›', tap: () => app.go('thought')),
        ]),
        group('ALTRO', [
          row(
            'Esporta registro',
            'CSV per i tuoi archivi',
            value: '›',
            tap: () async {
              await Clipboard.setData(ClipboardData(text: app.csv()));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro copiato negli appunti in formato CSV')));
            },
          ),
          row("Rivedi l'introduzione", 'I pilastri e le domande', value: '›', tap: () => app.go('onboarding')),
        ]),
      ],
    );
  }
}

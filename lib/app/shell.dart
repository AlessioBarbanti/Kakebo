import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/calendar/calendar.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/features/expenses/ledger.dart';
import 'package:kakebo/features/home/home.dart';
import 'package:kakebo/features/journal/journal.dart';
import 'package:kakebo/features/journal/review.dart';
import 'package:kakebo/features/settings/settings.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/shared/animations/swipe.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/seasons.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/state/kakebo.dart';

const _tabs = ['home', 'ledger', 'journal', 'calendar']; // labels: tr.tabs

/// In-app layout: greeting, sticky tabs, swipeable content, and the add button always in reach.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  Kakebo get app => AppScope.read(context);
  final _scroll = ScrollController(), _headerKey = GlobalKey();
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
    // Carry on from where the finger left the content, never back toward the centre (a tap starts from rest).
    _move(drag - d * (drag == 0 ? 120.0 : 160.0), 0, false);
    _t = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      _move(d * 40.0, 0, true);
      app.go(k);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // The new tab opens at its top; the greeting stays hidden if it was scrolled away (it returns on scroll up).
        // Measured after the switch: only Home has the tall greeting.
        if (_scroll.hasClients) {
          _scroll.jumpTo(math.min(_scroll.offset, _headerKey.currentContext?.size?.height ?? 0));
        }
        _move(0, 1, false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final idx = _tabs.indexOf(navScreen), out = op == 0;
    final content = switch (app.screen) {
      'ledger' => const Ledger(),
      'journal' => const Journal(),
      'review' => const Review(),
      'calendar' => const Calendar(),
      'settings' => const Settings(),
      _ => const Home(),
    };

    // The swipe listens on the whole screen, empty space included, not only where content is drawn.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: idx < 0 ? null : (d) => _move(drag + d.delta.dx, null, true),
      onHorizontalDragEnd: idx < 0
          ? null
          : (e) {
              final dir = fling(e, drag, 70);
              if (dir < 0 && idx < _tabs.length - 1) {
                return goTab(_tabs[idx + 1], 1);
              }
              if (dir > 0 && idx > 0) return goTab(_tabs[idx - 1], -1);
              _move(0, null, false);
            },
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: !_tabs.contains(app.screen),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  if (app.screen != 'settings')
                    SliverToBoxAdapter(
                      child: KeyedSubtree(key: _headerKey, child: _header()),
                    ),
                  if (app.screen != 'settings') PinnedHeaderSliver(child: _navBar()),
                  SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      opacity: op ?? math.max(.1, 1 - drag.abs() / 280),
                      duration: Duration(
                        milliseconds: dragging
                            ? 0
                            : out
                            ? 260
                            : 500,
                      ),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: Duration(
                          milliseconds: dragging
                              ? 0
                              : out
                              ? 260
                              : 1000,
                        ),
                        curve: out ? Curves.easeOutCubic : const Cubic(.16, 1, .3, 1),
                        transform: Matrix4.translationValues(drag * .6, 0, 0),
                        padding: EdgeInsets.fromLTRB(app.screen == 'calendar' ? 12 : 16, 16, app.screen == 'calendar' ? 12 : 16, 24),
                        // At least a screen tall below the tabs, so even a short tab can keep the greeting scrolled away.
                        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top - 48),
                        child: RepaintBoundary(child: content),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_tabs.contains(app.screen)) // not on the month review, which has its own closing step
            Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => app.screen == 'journal' ? app.go('thought') : openAdd(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: onGreen,
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(app.screen == 'journal' ? Icons.edit_outlined : Icons.add),
                      label: Text(
                        app.screen == 'journal' ? tr.writeThought : tr.addExpense,
                        style: sans(15, w: FontWeight.w700, c: onGreen),
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

  /// Full greeting and season on Home; one compact line on the other screens.
  Widget _header() {
    final home = navScreen == 'home',
        s = app.season,
        fs = s.plant.length > 2
            ? 9.0
            : s.plant.length > 1
            ? 12.0
            : 16.0;
    final phrase = home && app.flags['phraseOn']!;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, home ? 10 : 4, 22, phrase ? 4 : (home ? 16 : 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: home ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(app.greeting, maxLines: 1, style: serif(home ? 34 : 20, h: 1.1)),
                    ),
                    if (home)
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
                          Flexible(
                            child: Text(
                              '${s.plantName} · ${s.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sans(13, c: s.deep),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: tr.settings,
                child: Material(
                  color: app.screen == 'settings' ? ok(.93, .025, 150) : Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => app.go(app.screen == 'settings' ? 'home' : 'settings'),
                    child: SizedBox.square(dimension: 48, child: Icon(Icons.settings_outlined, size: 23, color: ok(.35, .03, 160))),
                  ),
                ),
              ),
            ],
          ),
          if (phrase) const DailyPhrase(),
        ],
      ),
    );
  }

  Widget _navBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: bg,
      border: Border(bottom: BorderSide(color: line)),
    ),
    child: Row(
      children: [
        for (final (k, label) in [for (final (i, k) in _tabs.indexed) (k, tr.tabs[i])])
          Expanded(
            child: Semantics(
              button: true,
              selected: navScreen == k,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => goTab(k),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
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
          ),
      ],
    ),
  );
}

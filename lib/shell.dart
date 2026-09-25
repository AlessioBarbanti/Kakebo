import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'calendar.dart';
import 'home.dart';
import 'journal.dart';
import 'kakebo.dart';
import 'ledger.dart';
import 'notify.dart';
import 'ui.dart';

const _tabs = ['home', 'ledger', 'journal', 'calendar']; // labels: tr.tabs

/// In-app layout: greeting, sticky tabs, swipeable content.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
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
      // The new tab opens at its top; the greeting stays hidden if it was scrolled away (it returns on scroll up).
      if (_scroll.hasClients) _scroll.jumpTo(math.min(_scroll.offset, _headerKey.currentContext?.size?.height ?? 0));
      _move(d * 40.0, 0, true);
      app.go(k);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _move(0, 1, false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    watch(context);
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
              if (dir < 0 && idx < _tabs.length - 1) return goTab(_tabs[idx + 1], 1);
              if (dir > 0 && idx > 0) return goTab(_tabs[idx - 1], -1);
              _move(0, null, false);
            },
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverToBoxAdapter(
              child: KeyedSubtree(key: _headerKey, child: _header()),
            ),
            PinnedHeaderSliver(child: _navBar()),
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
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 110 + MediaQuery.paddingOf(context).bottom),
                  // At least a screen tall below the tabs, so even a short tab can keep the greeting scrolled away.
                  constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top - 48),
                  child: RepaintBoundary(child: content),
                ),
              ),
            ),
          ],
        ),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(app.greeting, maxLines: 1, style: serif(34, h: 1.1)),
                ),
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
            label: tr.settings,
            child: Material(
              color: app.screen == 'settings' ? ok(.93, .025, 150) : Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => app.go(app.screen == 'settings' ? 'home' : 'settings'),
                child: SizedBox.square(dimension: 44, child: Icon(Icons.settings_outlined, size: 23, color: ok(.35, .03, 160))),
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
        for (final (k, label) in [for (final (i, k) in _tabs.indexed) (k, tr.tabs[i])])
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
    watch(context);
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
        heading(tr.settingsKicker, tr.settings),
        group(tr.ledgerGroup, [
          row(
            tr.monthStartLabel,
            tr.monthStartHint,
            value: tr.startDay(app.monthStart),
            tap: () async {
              final d = await _pickDay(context, app.monthStart);
              if (d != null) app.update(() => app.monthStart = d);
            },
          ),
          row(tr.incomeFixed, tr.incomeFixedHint, value: tr.fixedValue(fmt(app.fixedTotal)), tap: () => app.go('monthStart')),
        ]),
        group(tr.rhythm, [
          row(tr.weekly, tr.weeklyHint, flag: 'weekly'),
          row(tr.proverb, tr.proverbHint, flag: 'phraseOn'),
          row(tr.eveningNote, tr.eveningNoteHint, flag: 'reminders'),
          row(
            tr.noteTime,
            tr.tapToChange,
            value: clock(context, app.noteTime),
            tap: () async {
              final t = await _pickTime(context, app.noteTime, tr.noteTimeDialog);
              if (t != null) app.update(() => app.noteTime = t);
            },
          ),
        ]),
        group(tr.evenings, [
          row(tr.thoughtNotice, tr.happyQuestion, flag: 'thoughtOn'),
          row(
            tr.time,
            tr.tapToChange,
            value: clock(context, app.thoughtTime),
            tap: () async {
              final t = await _pickTime(context, app.thoughtTime, tr.thoughtTimeDialog);
              if (t != null) app.update(() => app.thoughtTime = t);
            },
          ),
          if (Reminders.instance?.exact case final exact?)
            row(tr.precise, exact ? tr.preciseOn : tr.preciseOff, value: exact ? tr.active : tr.activate, tap: exact ? null : Reminders.instance!.askExact),
          row(tr.writeToday, tr.writeTodayHint, value: '›', tap: () => app.go('thought')),
        ]),
        group(tr.data, [
          row(
            tr.exportLedger,
            tr.exportHint,
            value: '›',
            tap: () => _saveFile(context, 'kakebo-${tr.ledgerKicker.toLowerCase()}-${dateKey(app.now)}.csv', app.csv(), 'text/csv', tr.ledgerSaved),
          ),
          row(
            tr.backupSave,
            tr.backupHint,
            value: '›',
            tap: () => _saveFile(context, 'kakebo-backup-${dateKey(app.now)}.json', app.backup(), 'application/json', tr.backupSaved),
          ),
          row(tr.restore, tr.restoreHint, value: '›', tap: () => _restore(context)),
          row(
            tr.wipe,
            tr.wipeHint,
            tap: () async {
              if (await _confirm(context, tr.wipeAsk, tr.wipeWarn, tr.erase)) app.reset();
            },
          ),
        ]),
        group(tr.other, [
          row(tr.replayIntro, tr.replayIntroHint, value: '›', tap: () => app.go('onboarding')),
          row(
            tr.licenses,
            tr.licensesHint,
            value: '›',
            tap: () => showLicensePage(context: context, applicationName: 'Kakebo'),
          ),
        ]),
      ],
    );
  }
}

Future<String?> _pickTime(BuildContext context, String current, String title) async {
  final (h, m) = hm(current);
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: h, minute: m),
    helpText: title,
  );
  return t == null ? null : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Day 1–28 (every month has them), e.g. payday.
Future<int?> _pickDay(BuildContext context, int current) => showDialog<int>(
  context: context,
  builder: (c) => AlertDialog(
    title: Text(tr.monthStartDialog),
    content: SizedBox(
      width: 300,
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          for (var d = 1; d <= 28; d++)
            InkResponse(
              onTap: () => Navigator.pop(c, d),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: d == current ? green : null),
                child: Text('$d', style: sans(15, c: d == current ? onGreen : ink)),
              ),
            ),
        ],
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(tr.cancel))],
  ),
);

Future<bool> _confirm(BuildContext context, String title, String body, String yes) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr.cancel)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(yes)),
        ],
      ),
    ) ??
    false;

/// Lets the user pick where to save [text] (Downloads, Drive…) through Android's file dialog.
Future<void> _saveFile(BuildContext context, String name, String text, String mime, String done) async {
  final messenger = ScaffoldMessenger.of(context);
  final saved = await FilePicker.saveFile(fileName: name, bytes: utf8.encode(text), mimeType: mime);
  if (saved != null) messenger.showSnackBar(SnackBar(content: Text(done)));
}

Future<void> _restore(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
  if (file == null || !context.mounted) return;
  if (!await _confirm(context, tr.restoreAsk, tr.restoreWarn, tr.restoreYes)) return;
  final restored = app.restore(utf8.decode(await file.readAsBytes()));
  messenger.showSnackBar(SnackBar(content: Text(restored ? tr.restored : tr.notABackup)));
}

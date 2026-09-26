import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/time.dart';
import 'package:kakebo/services/backup_files.dart';
import 'package:kakebo/services/reminders.dart';
import 'package:kakebo/shared/animations/reveal.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final sub = ok(.45, .03, 160);
    // One node for TalkBack: label, note and the switch's on/off together.
    Widget row(String label, String note, {String value = '', String? flag, VoidCallback? tap}) => MergeSemantics(
      child: InkWell(
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
        Align(alignment: Alignment.centerLeft, child: TapText(tr.backHome, () => app.go('home'))),
        Text(tr.settings, style: serif(26, h: 1.2)),
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
        group(tr.rhythm, [row(tr.weekly, tr.weeklyHint, flag: 'weekly'), row(tr.proverb, tr.proverbHint, flag: 'phraseOn')]),
        group(tr.evenings, [
          row(tr.thoughtNotice, tr.reminderHint, flag: 'thoughtOn'),
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
          row(tr.meditation, tr.meditationHint, flag: 'breathe'),
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
              if (await _confirm(context, tr.wipeAsk, tr.wipeWarn, tr.erase)) {
                app.reset();
              }
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
  final saved = await BackupFiles.save(name, text, mime);
  if (saved) messenger.showSnackBar(SnackBar(content: Text(done)));
}

Future<void> _restore(BuildContext context) async {
  final app = AppScope.read(context);
  final messenger = ScaffoldMessenger.of(context);
  final file = await BackupFiles.pickBackup();
  if (file == null || !context.mounted) return;
  if (!await _confirm(context, tr.restoreAsk, tr.restoreWarn, tr.restoreYes)) {
    return;
  }
  final restored = app.restore(utf8.decode(await file.readAsBytes()));
  messenger.showSnackBar(SnackBar(content: Text(restored ? tr.restored : tr.notABackup)));
}

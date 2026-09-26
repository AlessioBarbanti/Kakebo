import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/model/entry.dart';
import 'package:kakebo/model/period.dart';
import 'package:kakebo/model/pillar.dart';
import 'package:kakebo/model/pillar_suggestion.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/pillars.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/controls.dart';
import 'package:kakebo/shared/widgets/inputs.dart';
import 'package:kakebo/state/kakebo.dart';

/// New expense, or [edit] an existing one (tap on any expense row).
void openAdd(BuildContext context, {Entry? edit}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: card,
  barrierColor: ok(.3, .03, 160, .28),
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  builder: (_) => AppScope(
    notifier: AppScope.read(context),
    child: AddSheet(edit: edit),
  ),
);

class AddSheet extends StatefulWidget {
  const AddSheet({super.key, this.edit});
  final Entry? edit;

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  Kakebo get app => AppScope.read(context);
  late final Entry? e = widget.edit;
  late String amt = e == null ? '' : (e!.amt % 1 == 0 ? e!.amt.toInt().toString() : e!.amt.toStringAsFixed(2)), note = e?.note ?? '';
  late String? pillar = e?.p; // a new expense starts with none: the note may suggest one, the user picks
  late String reflection = e?.reflection ?? '';
  late bool touched = e != null; // an edited expense keeps its pillar
  late DateTime day = e?.date ?? DateTime(app.now.year, app.now.month, app.now.day);

  double get value => double.tryParse(amt) ?? 0;
  bool get ready => value > 0 && pillar != null;

  void press(String k) => setState(() {
    if (k == '⌫') {
      if (amt.isNotEmpty) amt = amt.substring(0, amt.length - 1);
    } else if (k == '.') {
      if (!amt.contains('.')) amt = '${amt.isEmpty ? '0' : amt}.';
    } else if (amt.contains('.') && amt.split('.')[1].length >= 2) {
      return;
    } else if (amt.length < 7) {
      amt = amt == '0' ? k : amt + k;
    }
  });

  void save() {
    if (!ready) return;
    e == null ? app.addEntry(value, note.trim(), pillar!, on: day) : app.editEntry(e!, value, note.trim(), pillar!, reflection: reflection.trim(), on: day);
    Navigator.pop(context);
  }

  /// For an expense written down late: any day of a month still open, so the previous one too until it is sealed (a month
  /// sealed keeps the figures it was sealed with); never a day still to come.
  Future<void> pickDay() async {
    final today = DateTime(app.now.year, app.now.month, app.now.day), previous = app.previous;
    final earliest = app.sealed.containsKey(monthKey(app.labelOf(previous))) ? app.period.start : previous.start;
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: day.isBefore(earliest) ? day : earliest,
      lastDate: day.isAfter(today) ? day : today,
      helpText: tr.expenseDate,
    );
    if (picked != null && mounted) setState(() => day = picked);
  }

  void delete() {
    final app = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context), talkBack = MediaQuery.accessibleNavigationOf(context), old = e!, at = app.removeEntry(old);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        // Flutter keeps a snack bar with an action until tapped; six seconds is time enough to undo.
        // A screen reader user still gets it until they reach it.
        duration: const Duration(seconds: 6),
        persist: talkBack,
        content: Text(tr.expenseDeleted),
        action: SnackBarAction(label: tr.undo, onPressed: () => app.restoreEntry(at, old)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context), today = DateTime(app.now.year, app.now.month, app.now.day);
    final guess = touched ? null : suggest(note);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 30 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(color: ok(.86, .01, 160), borderRadius: BorderRadius.circular(3)),
            ),
          ),
          Row(
            children: [
              Expanded(child: Text(e == null ? tr.newExpense : tr.editExpense, style: serif(20))),
              // Quiet on purpose, in the header's own 48 dp: most expenses are today's, a tap dates one back when forgotten.
              Semantics(
                button: true,
                hint: tr.changeDate,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: pickDay,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          Icon(Icons.edit_calendar_outlined, size: 16, color: muted),
                          Text(
                            day == today
                                ? tr.today
                                : day == DateTime(today.year, today.month, today.day - 1)
                                ? tr.yesterday
                                : shortDay(day),
                            style: sans(14, c: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              TapText(tr.cancel, () => Navigator.pop(context), style: sans(14, c: muted)),
            ],
          ),
          Column(
            spacing: 2,
            children: [
              Text(
                money(amt.isEmpty ? '0' : amt),
                style: serif(46, w: FontWeight.w700, h: 1.1, c: value > 0 ? ink : ok(.7, .02, 160)),
              ),
            ],
          ),
          TextFormField(
            initialValue: note,
            onChanged: (v) => setState(() {
              note = v;
              final g = suggest(v);
              if (!touched && g != null) pillar = g;
            }),
            style: sans(15),
            decoration: softInput(tr.notePlaceholder, ok(.96, .02, 150), 14, const EdgeInsets.symmetric(horizontal: 16, vertical: 13)),
          ),
          Row(
            spacing: 6,
            children: [
              for (final MapEntry(:key, value: p) in pillars.entries)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: pillar == key,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        pillar = key;
                        touched = true;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                        decoration: BoxDecoration(
                          color: pillar == key ? p.soft : card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: pillar == key ? p.ink : line, width: 1.5),
                        ),
                        child: Column(
                          spacing: 2,
                          children: [
                            Text(p.kanji, style: serif(19, c: p.ink)),
                            Text(p.name, style: sans(12, w: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 16,
            child: Text(
              guess != null
                  ? tr.suggested(pillars[guess]!.name)
                  : pillar == null
                  ? tr.choosePillar
                  : '',
              textAlign: TextAlign.center,
              style: sans(12, c: muted),
            ),
          ),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 50, mainAxisSpacing: 6, crossAxisSpacing: 6),
            children: [
              for (final k in ['1', '2', '3', '4', '5', '6', '7', '8', '9', decimalSep, '0', '⌫'])
                Material(
                  color: ok(.955, .018, 150),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => press(k == decimalSep ? '.' : k),
                    // An icon, not the ⌫ character, which the bundled fonts lack.
                    child: Center(
                      child: k == '⌫'
                          ? Icon(Icons.backspace_outlined, size: 22, color: ink, semanticLabel: tr.erase)
                          : Text(k, style: serif(22, w: FontWeight.w500)),
                    ),
                  ),
                ),
            ],
          ),
          if (e != null)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              initiallyExpanded: reflection.isNotEmpty,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(tr.expenseReflection, style: serif(17)),
              subtitle: Text(tr.optionalReflection, style: sans(12, c: muted)),
              children: [
                TextFormField(
                  key: const ValueKey('expenseReflection'),
                  initialValue: reflection,
                  onChanged: (v) => reflection = v,
                  minLines: 2,
                  maxLines: null,
                  style: sans(15, h: 1.5),
                  decoration: softInput(tr.expenseReflectionPrompt, ok(.96, .02, 150), 14, const EdgeInsets.all(16)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          Material(
            color: ready ? green : ok(.75, .03, 160),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: save,
              child: SizedBox(
                height: 52,
                child: Center(
                  child: Text(
                    tr.save,
                    style: sans(16, w: FontWeight.w700, c: onGreen),
                  ),
                ),
              ),
            ),
          ),
          if (e != null)
            Center(
              child: TapText(
                tr.deleteExpense,
                delete,
                style: sans(14, w: FontWeight.w700, c: muted), // vermilion is the seal's alone
              ),
            ),
        ],
      ),
    );
  }
}

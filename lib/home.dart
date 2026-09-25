import 'package:flutter/material.dart';

import 'kakebo.dart';
import 'ui.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    watch(context);
    final s = app.season, by = Kakebo.spentBy(app.month), avail = app.available, today = app.today;
    final rest = app.dim - app.day, perDay = (app.left / (rest < 1 ? 1 : rest)).floor();
    final pi = app.now.day % phrases.length, phrase = (phrases[pi].$1, phrases[pi].$2, tr.proverbs[pi]);
    final notice = app.flags['thoughtOn']! && app.thoughtToday == null && app.evening;

    return Reveal(
      spacing: 40,
      children: [
        if (notice)
          GestureDetector(
            onTap: () => app.go('thought'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ok(.95, .025, 295), borderRadius: BorderRadius.circular(24)),
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(radius: .707, colors: [ok(.99, .01, 295), ok(.88, .05, 295)], stops: const [0, .7]),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(tr.eveningThought, style: sans(12, c: ok(.4, .04, 290))),
                        Text(tr.happyQuestion, style: serif(19, h: 1.3)),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      tr.write,
                      style: sans(14, w: FontWeight.w700, c: onGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(tr.leftFor(monthName(app.label)), style: sans(14, c: muted)),
              Text(fmt(app.left), style: serif(56, w: FontWeight.w700, h: 1.05)),
              Text(rest < 1 ? tr.spendToday : tr.perDay(fmt(perDay), rest), style: sans(14, c: muted)),
              const SizedBox(height: 8),
              Bar([for (final MapEntry(:key, value: p) in pillars.entries) (by[key]! / (avail == 0 ? 1 : avail), p.ink)], height: 6, gap: 2, track: line),
              Text(tr.spentShare(app.spentPct), style: sans(12, c: ok(.42, .03, 160))),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => app.go('ledger'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(22), boxShadow: shadow),
            child: Row(
              children: [
                for (final MapEntry(:key, value: p) in pillars.entries)
                  Expanded(
                    child: Column(
                      spacing: 3,
                      children: [
                        Text(p.kanji, style: serif(22, c: p.ink)),
                        Text(p.name, style: sans(12, c: muted)),
                        Text(fmt(by[key]!.round()), style: serif(15)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                spacing: 8,
                children: [
                  Flexible(child: Text(tr.branchTitle, style: serif(18))),
                  Text(
                    tr.flowers(app.bloomed),
                    style: sans(13, w: FontWeight.w700, c: s.deep),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Branch()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(tr.branchRule(fmt(app.save / 10), fmt(app.bloomed * app.save / 10), fmt(app.save)), style: sans(13, h: 1.5, c: muted)),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.today, style: serif(18)),
                  TapText(
                    tr.addShort,
                    () => openAdd(context),
                    style: sans(14, w: FontWeight.w700, c: ok(.38, .06, 160)),
                  ),
                ],
              ),
            ),
            for (final e in today)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openAdd(context, edit: e),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: line)),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          e.pillar.kanji,
                          textAlign: TextAlign.center,
                          style: serif(17, c: e.pillar.ink),
                        ),
                      ),
                      Expanded(child: Text(e.note, style: sans(15))),
                      Text(fmt(e.amt), style: serif(16)),
                    ],
                  ),
                ),
              ),
            if (today.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: line)),
                ),
                child: Text(app.entries.isEmpty ? tr.emptyLedger : tr.quietToday, style: sans(14, h: 1.55, c: muted)),
              ),
          ],
        ),
        if (app.flags['phraseOn']!)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              spacing: 8,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(width: 24, height: 1, color: ok(.8, .03, 150)),
                ),
                Text(
                  phrase.$1,
                  textAlign: TextAlign.center,
                  style: serif(22, h: 1.3, c: s.deep),
                ),
                Text(
                  phrase.$2,
                  textAlign: TextAlign.center,
                  style: sans(12, ls: .72, c: ok(.42, .03, 160)),
                ),
                Text(
                  phrase.$3,
                  textAlign: TextAlign.center,
                  style: serif(16, w: FontWeight.w500, h: 1.55),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// New expense, or [edit] an existing one (tap on any expense row).
void openAdd(BuildContext context, {Entry? edit}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: card,
  barrierColor: ok(.3, .03, 160, .28),
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  builder: (_) => AddSheet(edit: edit),
);

class AddSheet extends StatefulWidget {
  const AddSheet({super.key, this.edit});
  final Entry? edit;

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  late final Entry? e = widget.edit;
  late String amt = e == null ? '' : (e!.amt % 1 == 0 ? e!.amt.toInt().toString() : e!.amt.toStringAsFixed(2)),
      note = e?.note ?? '',
      pillar = e?.p ?? 'culture';
  late bool touched = e != null; // an edited expense keeps its pillar

  double get value => double.tryParse(amt) ?? 0;

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
    if (value == 0) return;
    e == null ? app.addEntry(value, note.trim(), pillar) : app.editEntry(e!, value, note.trim(), pillar);
    Navigator.pop(context);
  }

  void delete() {
    final messenger = ScaffoldMessenger.of(context), old = e!, at = app.removeEntry(old);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(tr.expenseDeleted),
        action: SnackBarAction(label: tr.undo, onPressed: () => app.restoreEntry(at, old)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    watch(context);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e == null ? tr.newExpense : tr.editExpense, style: serif(20)),
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
              Text(dayLabel(e?.date ?? app.now), style: sans(12, c: ok(.42, .03, 160))),
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
            ],
          ),
          SizedBox(
            height: 16,
            child: Text(
              guess != null ? tr.suggested(pillars[guess]!.name) : '',
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
                    child: Center(
                      child: Text(
                        k,
                        semanticsLabel: k == '⌫' ? tr.erase : null,
                        style: serif(22, w: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Material(
            color: value > 0 ? green : ok(.75, .03, 160),
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
                style: sans(14, w: FontWeight.w700, c: sealRed),
              ),
            ),
        ],
      ),
    );
  }
}

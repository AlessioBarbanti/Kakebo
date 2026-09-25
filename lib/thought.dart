import 'package:flutter/material.dart';

import 'kakebo.dart';
import 'ui.dart';

/// "Cosa ti ha reso felice oggi?" — breathe, write, keep.
class Thought extends StatefulWidget {
  const Thought({super.key});

  @override
  State<Thought> createState() => _ThoughtState();
}

class _ThoughtState extends State<Thought> {
  bool breathed = false, editing = false;
  late String text = app.thoughtToday ?? '';

  @override
  Widget build(BuildContext context) {
    watch(context);
    final pad = MediaQuery.paddingOf(context), violet = ok(.4, .03, 280);
    final saved = app.thoughtToday != null && !editing;
    void home() => app.go('home');

    return Container(
      color: ok(.95, .025, 295, .7),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  radius: .707,
                  colors: [ok(.975, .014, 150, .9), ok(.975, .014, 150, .5), ok(.975, .014, 150, 0)],
                  stops: const [0, .55, .72],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 110, 24, 56 + pad.bottom),
              child: Reveal(
                spacing: 18,
                children: [
                  Text(
                    dayLabel(app.now),
                    textAlign: TextAlign.center,
                    style: sans(13, ls: 2.34, c: ok(.45, .05, 290)),
                  ),
                  if (saved) ...[
                    const Center(
                      child: SizedBox.square(dimension: 130, child: Center(child: Enso())),
                    ),
                    Text(
                      '“${app.thoughtToday}”',
                      textAlign: TextAlign.center,
                      style: serif(24, w: FontWeight.w500, h: 1.6),
                    ),
                    Text(
                      tr.savedGoodnight,
                      textAlign: TextAlign.center,
                      style: sans(15, c: ok(.42, .03, 280)),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        TapText(
                          tr.edit,
                          () => setState(() => editing = breathed = true),
                          style: sans(15, c: violet),
                          pad: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        Btn(tr.backToLedgerShort, home, pad: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                      ],
                    ),
                  ] else if (!breathed) ...[
                    Text(tr.breathFirst, textAlign: TextAlign.center, style: serif(26, h: 1.3)),
                    const Center(child: SizedBox.square(dimension: 200, child: Breath())),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          tr.followCircle,
                          textAlign: TextAlign.center,
                          style: sans(14, h: 1.6, c: violet),
                        ),
                      ),
                    ),
                    Center(child: Btn(tr.ready, () => setState(() => breathed = true), pad: const EdgeInsets.symmetric(horizontal: 28, vertical: 14))),
                  ] else ...[
                    Text(tr.happyQuestion, textAlign: TextAlign.center, style: serif(30, h: 1.25)),
                    Text(
                      tr.smallThing,
                      textAlign: TextAlign.center,
                      style: sans(15, h: 1.6, c: ok(.42, .03, 280)),
                    ),
                    TextFormField(
                      initialValue: text,
                      onChanged: (v) => setState(() => text = v),
                      minLines: 4,
                      maxLines: 6,
                      style: serif(20, w: FontWeight.w500, h: 1.6),
                      decoration: softInput(tr.todayHint, ok(.995, .004, 140, .85), 22, const EdgeInsets.symmetric(horizontal: 22, vertical: 20)),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        TapText(
                          tr.later,
                          home,
                          style: sans(15, c: violet),
                          pad: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        Btn(
                          tr.keepThought,
                          () {
                            if (text.trim().isEmpty) return;
                            app.update(() => app.thoughts[dateKey(app.now)] = text.trim());
                            setState(() => editing = false);
                          },
                          color: text.trim().isEmpty ? ok(.72, .03, 160) : green,
                          pad: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: pad.top + 8,
            right: 16,
            child: TapText(
              tr.close,
              home,
              style: sans(14, c: violet),
              pad: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

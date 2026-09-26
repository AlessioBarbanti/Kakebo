import 'package:flutter/material.dart';

import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';

class NumField extends StatefulWidget {
  const NumField(this.value, this.onChanged, {super.key, required this.style, this.align = TextAlign.start});
  final double value;
  final ValueChanged<double> onChanged;
  final TextStyle style;
  final TextAlign align;

  @override
  State<NumField> createState() => _NumFieldState();
}

// Zero shows as an empty field with a grey 0 in it: a value to type, not one to delete first.
String _num(double v) => v == 0
    ? ''
    : v % 1 == 0
    ? v.toInt().toString()
    : v.toString();
double _parse(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;

class _NumFieldState extends State<NumField> {
  late final _c = TextEditingController(text: _num(widget.value));

  @override
  void didUpdateWidget(NumField old) {
    super.didUpdateWidget(old);
    if (_parse(_c.text) != widget.value) _c.text = _num(widget.value);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textAlign: widget.align,
    style: widget.style,
    onChanged: (v) => widget.onChanged(_parse(v)),
    decoration: boxed(
      hint: '0',
      hintStyle: widget.style.copyWith(color: ok(.72, .02, 160)),
    ),
  );
}

/// The one look of every editable field in a form: white box, thin outline, green when focused.
InputDecoration boxed({String? hint, TextStyle? hintStyle}) => InputDecoration(
  hintText: hint,
  hintStyle: hintStyle,
  isDense: true,
  filled: true,
  fillColor: card,
  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ok(.85, .02, 150)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: green, width: 1.5),
  ),
);

InputDecoration softInput(String hint, Color fill, double radius, EdgeInsets pad) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: fill,
  contentPadding: pad,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
);

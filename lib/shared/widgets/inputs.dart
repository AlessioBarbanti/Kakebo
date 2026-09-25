import 'package:flutter/material.dart';

class NumField extends StatefulWidget {
  const NumField(this.value, this.onChanged, {super.key, required this.style, this.align = TextAlign.start, this.fill});
  final double value;
  final ValueChanged<double> onChanged;
  final TextStyle style;
  final TextAlign align;
  final Color? fill;

  @override
  State<NumField> createState() => _NumFieldState();
}

String _num(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
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
    decoration: InputDecoration(
      isDense: true,
      filled: widget.fill != null,
      fillColor: widget.fill,
      contentPadding: widget.fill != null ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : EdgeInsets.zero,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    ),
  );
}

InputDecoration softInput(String hint, Color fill, double radius, EdgeInsets pad) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: fill,
  contentPadding: pad,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
);

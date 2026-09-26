import 'package:flutter/material.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';
import 'package:kakebo/shared/widgets/inputs.dart';

/// An optional, automatically saved reflection with no score or completion state.
class ReflectionField extends StatelessWidget {
  const ReflectionField({super.key, required this.title, required this.value, required this.onChanged});

  final String title, value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 10,
    children: [
      Text(title, style: serif(19, h: 1.4)),
      TextFormField(
        initialValue: value,
        onChanged: onChanged,
        minLines: 2,
        maxLines: null,
        style: sans(15, h: 1.6),
        decoration: softInput(tr.reflectionPlaceholder, ok(.96, .02, 150), 14, const EdgeInsets.all(16)),
      ),
    ],
  );
}

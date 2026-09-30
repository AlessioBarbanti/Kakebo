import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/services/receipt_scanner.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/tokens.dart';

/// The photo of an expense's receipt, small, in a 48 dp target: a tap opens it whole.
class ReceiptThumb extends StatelessWidget {
  const ReceiptThumb(this.name, {super.key});
  final String name;

  @override
  Widget build(BuildContext context) {
    final file = ReceiptPhotos.file(name);
    final missing = Icon(Icons.image_not_supported_outlined, size: 18, color: muted);
    return Semantics(
      button: true,
      label: tr.openReceipt,
      child: InkResponse(
        onTap: () => showReceipt(context, name),
        radius: 24,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Container(
              width: 34,
              height: 44,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: line),
              ),
              child: file == null
                  ? missing
                  // Decoded at the size shown: the photo itself is 2048 px.
                  : Image.file(
                      file,
                      fit: BoxFit.cover,
                      cacheWidth: (34 * MediaQuery.devicePixelRatioOf(context)).round(),
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) => missing,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The receipt's photo on the whole screen, to zoom into with two fingers; Back or × closes it.
Future<void> showReceipt(BuildContext context, String name) {
  final file = ReceiptPhotos.file(name);
  final missing = Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        tr.receiptMissing,
        textAlign: TextAlign.center,
        style: sans(15, c: bg),
      ),
    ),
  );
  return showDialog(
    context: context,
    builder: (c) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // light status bar icons over the dark backdrop
      child: Dialog.fullscreen(
        backgroundColor: ok(.16, .01, 160),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file == null)
              missing
            else
              InteractiveViewer(
                maxScale: 6,
                child: Center(
                  child: Image.file(file, semanticLabel: tr.receiptPhoto, errorBuilder: (_, _, _) => missing),
                ),
              ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(c),
                  tooltip: MaterialLocalizations.of(c).closeButtonTooltip,
                  icon: Icon(Icons.close, color: bg),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kakebo/model/receipt.dart';

/// A receipt photographed with the phone's camera app or picked from its gallery, then read on the phone by ML Kit's text
/// recognition, whose model is inside the app: the photo is sent nowhere, and deleted once read.
class ReceiptScanner {
  /// The receipt's lines of text, or null when no photo was taken or picked. Tests put their own receipt here.
  static Future<List<ReceiptLine>?> Function({required bool camera}) read = _read;

  static Future<List<ReceiptLine>?> _read({required bool camera}) async {
    final photo = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (photo == null) return null;
    final recognizer = TextRecognizer();
    try {
      final text = await recognizer.processImage(InputImage.fromFilePath(photo.path));
      return [
        for (final block in text.blocks)
          for (final line in block.lines) ReceiptLine(line.text, [for (final p in line.cornerPoints) (p.x.toDouble(), p.y.toDouble())]),
      ];
    } finally {
      await recognizer.close();
      // On Android the picker hands over its own copy in the app's cache, the gallery's photo included: never the original.
      if (Platform.isAndroid) {
        try {
          await File(photo.path).delete();
        } on FileSystemException {
          // Already gone: the cache is the system's to clear too.
        }
      }
    }
  }
}

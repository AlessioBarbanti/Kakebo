import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:kakebo/model/receipt.dart';

/// A receipt photographed with the phone's camera app or picked from its gallery, then read on the phone by ML Kit's text
/// recognition, whose model is inside the app: the photo is sent nowhere. It is kept for the expense (see [ReceiptPhotos]).
class ReceiptScanner {
  /// The receipt's lines of text and its photo as kept (a file name), or null when no photo was taken or picked. A photo
  /// recognition cannot read comes back with no lines. Tests put their own receipt here.
  static Future<({List<ReceiptLine> lines, String? photo})?> Function({required bool camera}) read = _read;

  static Future<({List<ReceiptLine> lines, String? photo})?> _read({required bool camera}) async {
    // Small enough to keep one per expense (a few hundred KB), large enough for receipt print to read.
    final picked = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery, maxWidth: 2048, maxHeight: 2048, imageQuality: 85);
    if (picked == null) return null;
    final photo = ReceiptPhotos.dir == null ? null : await ReceiptPhotos.keep(picked.path);
    final recognizer = TextRecognizer();
    try {
      final text = await recognizer.processImage(InputImage.fromFilePath(photo == null ? picked.path : ReceiptPhotos.file(photo)!.path));
      return (
        lines: [
          for (final block in text.blocks)
            for (final line in block.lines) ReceiptLine(line.text, [for (final p in line.cornerPoints) (p.x.toDouble(), p.y.toDouble())]),
        ],
        photo: photo,
      );
    } on Exception {
      return (lines: <ReceiptLine>[], photo: photo);
    } finally {
      await recognizer.close();
    }
  }
}

/// Receipt photos kept for their expenses, in the app's private files: gone with the app's data, and left out of Android's
/// cloud backup (android/app/src/main/res/xml), whose 25 MB would otherwise fill with photos and stop saving the ledger.
/// Nor are they in the backup file, so an expense restored on another phone may point to a photo that is not there.
class ReceiptPhotos {
  /// Where they are; null until [init]. Tests point it at a temporary folder.
  static Directory? dir;

  /// Finds the folder. Should the system not say where, receipts are read but no photo is kept.
  static Future<void> init() async {
    try {
      dir = Directory('${(await getApplicationSupportDirectory()).path}/receipts');
    } on Exception {
      dir = null;
    }
  }

  static File? file(String name) => dir == null ? null : File('${dir!.path}/$name');

  /// Moves a photo into the folder and returns its name there. On Android the picker hands over its own copy in the app's
  /// cache (the gallery's photo too, never the original), so it is removed once copied.
  static Future<String> keep(String path) async {
    final folder = await dir!.create(recursive: true), dot = path.lastIndexOf('.');
    final name = '${DateTime.now().microsecondsSinceEpoch}${dot < 0 ? '.jpg' : path.substring(dot).toLowerCase()}';
    await File(path).copy('${folder.path}/$name');
    if (Platform.isAndroid) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // Already gone: the cache is the system's to clear too.
      }
    }
    return name;
  }

  /// Deletes the photos no expense points to: its expense deleted (at the next launch, so it can still be undone), its
  /// photo removed, or a receipt read and never saved. Photos newer than the call are left alone.
  static Future<void> clean(Set<String> kept) async {
    final folder = dir, started = DateTime.now();
    if (folder == null || !await folder.exists()) return;
    await for (final f in folder.list()) {
      final name = f.uri.pathSegments.last;
      if (f is File && !kept.contains(name) && (await f.lastModified()).isBefore(started)) await f.delete();
    }
  }
}

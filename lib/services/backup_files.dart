import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Platform file dialogs for backups and CSV exports.
class BackupFiles {
  static Future<bool> save(String name, String text, String mime) async =>
      await FilePicker.saveFile(fileName: name, bytes: utf8.encode(text), mimeType: mime) != null;

  static Future<PlatformFile?> pickBackup() => FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
}

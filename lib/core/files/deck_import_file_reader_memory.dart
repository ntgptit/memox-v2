import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> readDeckImportFileContent(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) {
    return null;
  }

  return utf8.decode(bytes);
}

Future<Uint8List?> readDeckImportFileBytes(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) {
    return null;
  }

  return Uint8List.fromList(bytes);
}

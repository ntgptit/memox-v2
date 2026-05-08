import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> readDeckImportFileContent(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) {
    return utf8.decode(bytes);
  }

  final path = file.path;
  if (path == null) {
    return null;
  }

  return File(path).readAsString(encoding: utf8);
}

Future<Uint8List?> readDeckImportFileBytes(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) {
    return Uint8List.fromList(bytes);
  }

  final path = file.path;
  if (path == null) {
    return null;
  }

  return File(path).readAsBytes();
}

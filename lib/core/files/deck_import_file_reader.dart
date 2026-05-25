import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'deck_import_file_reader_memory.dart'
    if (dart.library.io) 'deck_import_file_reader_io.dart'
    as platform;

Future<String?> readDeckImportFileContent(PlatformFile file) async =>
    platform.readDeckImportFileContent(file);

Future<Uint8List?> readDeckImportFileBytes(PlatformFile file) async =>
    platform.readDeckImportFileBytes(file);

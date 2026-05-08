import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/files/deck_import_file_reader.dart';

void main() {
  test('DT1 readContent: decodes UTF-8 bytes', () async {
    const content = 'front,back\nXin chao,Tieng Viet co dau: a e o u';
    final file = PlatformFile(
      name: 'cards.csv',
      size: utf8.encode(content).length,
      bytes: Uint8List.fromList(utf8.encode(content)),
    );

    final decoded = await readDeckImportFileContent(file);

    expect(decoded, content);
  });

  test(
    'DT2 readContent: reads UTF-8 content from a path-backed file',
    () async {
      const content = 'front,back\nPath file,Reads through core boundary';
      final directory = await Directory.systemTemp.createTemp(
        'memox_deck_import_content_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final sourceFile = File('${directory.path}/cards.csv');
      await sourceFile.writeAsString(content, encoding: utf8);
      final file = PlatformFile(
        name: 'cards.csv',
        size: await sourceFile.length(),
        path: sourceFile.path,
      );

      final decoded = await readDeckImportFileContent(file);

      expect(decoded, content);
    },
  );

  test('DT3 readContent: returns null when file has no source', () {
    final file = PlatformFile(name: 'missing.csv', size: 0);

    expect(readDeckImportFileContent(file), completion(isNull));
  });

  test('DT1 readBytes: returns binary bytes', () async {
    final sourceBytes = Uint8List.fromList(<int>[80, 75, 3, 4, 0, 1]);
    final file = PlatformFile(
      name: 'cards.xlsx',
      size: sourceBytes.length,
      bytes: sourceBytes,
    );

    final decoded = await readDeckImportFileBytes(file);

    expect(decoded, sourceBytes);
  });

  test('DT2 readBytes: reads binary bytes from a path-backed file', () async {
    final sourceBytes = Uint8List.fromList(<int>[80, 75, 3, 4, 5, 6]);
    final directory = await Directory.systemTemp.createTemp(
      'memox_deck_import_bytes_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final sourceFile = File('${directory.path}/cards.xlsx');
    await sourceFile.writeAsBytes(sourceBytes);
    final file = PlatformFile(
      name: 'cards.xlsx',
      size: await sourceFile.length(),
      path: sourceFile.path,
    );

    final decoded = await readDeckImportFileBytes(file);

    expect(decoded, sourceBytes);
  });

  test('DT3 readBytes: returns null when file has no source', () {
    final file = PlatformFile(name: 'missing.xlsx', size: 0);

    expect(readDeckImportFileBytes(file), completion(isNull));
  });
}

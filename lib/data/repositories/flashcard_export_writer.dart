import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'repository_support.dart';

/// Plain value type describing a single export row (front/back/note).
///
/// The repository builds these from flashcard entities and hands them to
/// [FlashcardExportWriter] — keeps the writer free of Drift / entity types.
final class FlashcardExportRow {
  const FlashcardExportRow({
    required this.front,
    required this.back,
    required this.note,
  });

  final String front;
  final String back;
  final String? note;
}

/// Writer that emits a flashcard export payload as either CSV bytes or a
/// minimal valid `.xlsx` workbook (zip with inline-string cells).
///
/// XLSX path uses `archive` + `xml` to stay consistent with
/// `FlashcardExcelImportParser` (same toolset, no extra dependency).
final class FlashcardExportWriter {
  const FlashcardExportWriter._();

  static const _excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  static const _csvMimeType = 'text/csv';
  static const _headerFront = 'front';
  static const _headerBack = 'back';
  static const _headerNote = 'note';

  static String get csvMimeType => _csvMimeType;
  static String get excelMimeType => _excelMimeType;

  /// Build CSV text and return as UTF-8 bytes.
  static Uint8List buildCsv(List<FlashcardExportRow> rows) {
    final lines = <String>[
      '$_headerFront,$_headerBack,$_headerNote',
      for (final row in rows)
        [
          escapeCsvCell(row.front),
          escapeCsvCell(row.back),
          escapeCsvCell(row.note),
        ].join(','),
    ];
    return Uint8List.fromList(utf8.encode(lines.join('\n')));
  }

  /// Build a minimal `.xlsx` workbook with one sheet named "Flashcards".
  ///
  /// Row 1 is the header (`front`, `back`, `note`). All cells use the inline
  /// string type (`t="inlineStr"`) so we can skip `sharedStrings.xml` and the
  /// stylesheet — Excel and LibreOffice both open this layout cleanly.
  static Uint8List buildExcel(List<FlashcardExportRow> rows) {
    final archive = Archive();
    archive
      ..addFile(_archiveFile('[Content_Types].xml', _contentTypesXml()))
      ..addFile(_archiveFile('_rels/.rels', _rootRelsXml()))
      ..addFile(_archiveFile('xl/workbook.xml', _workbookXml()))
      ..addFile(_archiveFile('xl/_rels/workbook.xml.rels', _workbookRelsXml()))
      ..addFile(_archiveFile('xl/worksheets/sheet1.xml', _sheetXml(rows)));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static ArchiveFile _archiveFile(String path, String contents) {
    final bytes = utf8.encode(contents);
    return ArchiveFile(path, bytes.length, bytes);
  }

  static String _contentTypesXml() =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" '
      'ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
      '</Types>';

  static String _rootRelsXml() =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="xl/workbook.xml"/>'
      '</Relationships>';

  static String _workbookXml() =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets>'
      '<sheet name="Flashcards" sheetId="1" r:id="rId1"/>'
      '</sheets>'
      '</workbook>';

  static String _workbookRelsXml() =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
      'Target="worksheets/sheet1.xml"/>'
      '</Relationships>';

  static String _sheetXml(List<FlashcardExportRow> rows) {
    final builder = XmlBuilder()
      ..processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'worksheet',
      attributes: {
        'xmlns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main',
      },
      nest: () {
        builder.element(
          'sheetData',
          nest: () {
            _writeRow(
              builder,
              rowIndex: 1,
              cells: [_headerFront, _headerBack, _headerNote],
            );
            for (var i = 0; i < rows.length; i++) {
              final row = rows[i];
              _writeRow(
                builder,
                rowIndex: i + 2,
                cells: [row.front, row.back, row.note ?? ''],
              );
            }
          },
        );
      },
    );
    return builder.buildDocument().toXmlString();
  }

  static void _writeRow(
    XmlBuilder builder, {
    required int rowIndex,
    required List<String> cells,
  }) {
    builder.element(
      'row',
      attributes: {'r': '$rowIndex'},
      nest: () {
        for (var c = 0; c < cells.length; c++) {
          builder.element(
            'c',
            attributes: {'r': '${_columnLetter(c)}$rowIndex', 't': 'inlineStr'},
            nest: () {
              builder.element(
                'is',
                nest: () {
                  builder.element(
                    't',
                    attributes: {'xml:space': 'preserve'},
                    nest: () => builder.text(cells[c]),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  static String _columnLetter(int index) {
    // 0 → A, 25 → Z, 26 → AA. Sufficient for our 3-column export.
    final result = StringBuffer();
    var value = index;
    while (value >= 0) {
      result.write(String.fromCharCode(65 + value % 26));
      value = value ~/ 26 - 1;
    }
    return result.toString().split('').reversed.join();
  }
}

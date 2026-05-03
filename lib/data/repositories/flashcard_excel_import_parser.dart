import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../../core/utils/string_utils.dart';
import '../../domain/value_objects/content_actions.dart';

final class FlashcardExcelImportParser {
  const FlashcardExcelImportParser._();

  static FlashcardImportPreparation parse(
    Uint8List? sourceBytes, {
    required bool hasHeader,
  }) {
    if (sourceBytes == null || sourceBytes.isEmpty) {
      return _issue('Excel file is empty.');
    }

    try {
      final archive = ZipDecoder().decodeBytes(sourceBytes);
      final worksheetPath = _worksheetPath(archive);
      if (worksheetPath == null) {
        return _issue('Excel file must contain at least one worksheet.');
      }

      final worksheetXml = _archiveText(archive, worksheetPath);
      if (worksheetXml == null) {
        return _issue('Excel file must contain at least one worksheet.');
      }

      final sharedStrings = _sharedStrings(archive);
      final rows = _worksheetRows(worksheetXml, sharedStrings);
      if (rows.isEmpty) {
        return _issue('Excel sheet is empty.');
      }

      return _parseRows(rows, hasHeader: hasHeader);
    } on Exception {
      return _issue('Excel file must be a valid .xlsx workbook.');
    }
  }

  static FlashcardImportPreparation _parseRows(
    List<_ExcelRow> rows, {
    required bool hasHeader,
  }) {
    final previewItems = <FlashcardImportPreviewItem>[];
    final issues = <ImportValidationIssue>[];
    final dataRows = hasHeader ? rows.skip(1) : rows;
    for (final row in dataRows) {
      if (row.cells.values.every(StringUtils.isBlank)) {
        continue;
      }

      final front = _cell(row, 0);
      final back = _cell(row, 1);
      if (StringUtils.isBlank(front) || StringUtils.isBlank(back)) {
        issues.add(
          ImportValidationIssue(
            lineNumber: row.rowNumber,
            message: 'front and back are required.',
          ),
        );
        continue;
      }

      previewItems.add(
        FlashcardImportPreviewItem(
          sourceLabel: 'Row ${row.rowNumber}',
          draft: FlashcardDraft(front: front, back: back, note: _cell(row, 2)),
        ),
      );
    }

    return FlashcardImportPreparation(
      format: ImportSourceFormat.excel,
      previewItems: previewItems,
      issues: issues,
    );
  }

  static String _cell(_ExcelRow row, int? index) {
    if (index == null) {
      return '';
    }
    return StringUtils.trimmed(row.cells[index] ?? '');
  }

  static List<_ExcelRow> _worksheetRows(
    String worksheetXml,
    List<String> sharedStrings,
  ) {
    final document = XmlDocument.parse(worksheetXml);
    final sheetData = _firstElement(document, 'sheetData');
    if (sheetData == null) {
      return <_ExcelRow>[];
    }

    final rows = <_ExcelRow>[];
    var fallbackRowNumber = 1;
    for (final rowElement in _childElements(sheetData, 'row')) {
      final rowNumber =
          int.tryParse(rowElement.getAttribute('r') ?? '') ?? fallbackRowNumber;
      fallbackRowNumber = rowNumber + 1;
      final cells = <int, String>{};
      var fallbackColumnIndex = 0;
      for (final cellElement in _childElements(rowElement, 'c')) {
        final columnIndex =
            _columnIndex(cellElement.getAttribute('r')) ?? fallbackColumnIndex;
        fallbackColumnIndex = columnIndex + 1;
        cells[columnIndex] = _cellValue(cellElement, sharedStrings);
      }
      if (cells.values.every(StringUtils.isBlank)) {
        continue;
      }
      rows.add(_ExcelRow(rowNumber: rowNumber, cells: cells));
    }
    return rows;
  }

  static String _cellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t');
    if (type == 'inlineStr') {
      return _textDescendants(cell, 't');
    }

    final rawValue = StringUtils.trimmed(_firstElement(cell, 'v')?.innerText);
    if (type == 's') {
      final index = int.tryParse(rawValue);
      if (index == null || index < 0 || index >= sharedStrings.length) {
        return '';
      }
      return sharedStrings[index];
    }
    if (type == 'b') {
      return rawValue == '1' ? 'TRUE' : 'FALSE';
    }
    return rawValue;
  }

  static List<String> _sharedStrings(Archive archive) {
    final xml = _archiveText(archive, 'xl/sharedStrings.xml');
    if (xml == null) {
      return const <String>[];
    }

    final document = XmlDocument.parse(xml);
    return [
      for (final item in _allElements(document, 'si'))
        _textDescendants(item, 't'),
    ];
  }

  static String? _worksheetPath(Archive archive) {
    final workbookXml = _archiveText(archive, 'xl/workbook.xml');
    if (workbookXml == null) {
      return _archiveText(archive, 'xl/worksheets/sheet1.xml') == null
          ? null
          : 'xl/worksheets/sheet1.xml';
    }

    final workbook = XmlDocument.parse(workbookXml);
    final sheet = _firstElement(workbook, 'sheet');
    final relationId = _attribute(sheet, 'id') ?? _attribute(sheet, 'r:id');
    if (relationId == null) {
      return 'xl/worksheets/sheet1.xml';
    }

    final relsXml = _archiveText(archive, 'xl/_rels/workbook.xml.rels');
    if (relsXml == null) {
      return 'xl/worksheets/sheet1.xml';
    }

    final rels = XmlDocument.parse(relsXml);
    for (final relationship in _allElements(rels, 'Relationship')) {
      if (_attribute(relationship, 'Id') != relationId) {
        continue;
      }
      final target = _attribute(relationship, 'Target');
      if (target == null) {
        break;
      }
      return _normalizeWorkbookTarget(target);
    }
    return 'xl/worksheets/sheet1.xml';
  }

  static String _normalizeWorkbookTarget(String target) {
    if (target.startsWith('/')) {
      return target.substring(1);
    }
    if (target.startsWith('xl/')) {
      return target;
    }
    return 'xl/$target';
  }

  static String? _archiveText(Archive archive, String path) {
    for (final file in archive.files) {
      if (!file.isFile || file.name != path) {
        continue;
      }
      final bytes = file.readBytes();
      if (bytes == null) {
        return null;
      }
      return utf8.decode(bytes);
    }
    return null;
  }

  static int? _columnIndex(String? cellReference) {
    if (cellReference == null || cellReference.isEmpty) {
      return null;
    }

    var column = 0;
    var hasColumn = false;
    for (var index = 0; index < cellReference.length; index++) {
      final unit = cellReference.codeUnitAt(index);
      if (unit < 65 || unit > 90) {
        break;
      }
      hasColumn = true;
      column = (column * 26) + unit - 64;
    }
    if (!hasColumn) {
      return null;
    }
    return column - 1;
  }

  static String? _attribute(XmlElement? element, String name) {
    if (element == null) {
      return null;
    }
    final direct = element.getAttribute(name);
    if (direct != null) {
      return direct;
    }
    for (final attribute in element.attributes) {
      if (attribute.name.local == name) {
        return attribute.value;
      }
    }
    return null;
  }

  static XmlElement? _firstElement(XmlNode node, String localName) {
    for (final element in _allElements(node, localName)) {
      return element;
    }
    return null;
  }

  static Iterable<XmlElement> _allElements(XmlNode node, String localName) {
    return node.descendants.whereType<XmlElement>().where(
      (element) => element.name.local == localName,
    );
  }

  static Iterable<XmlElement> _childElements(
    XmlElement element,
    String localName,
  ) {
    return element.childElements.where(
      (child) => child.name.local == localName,
    );
  }

  static String _textDescendants(XmlElement element, String localName) {
    return _allElements(
      element,
      localName,
    ).map((text) => text.innerText).join();
  }

  static FlashcardImportPreparation _issue(String message) {
    return FlashcardImportPreparation(
      format: ImportSourceFormat.excel,
      previewItems: const <FlashcardImportPreviewItem>[],
      issues: <ImportValidationIssue>[
        ImportValidationIssue(lineNumber: 1, message: message),
      ],
    );
  }
}

final class _ExcelRow {
  const _ExcelRow({required this.rowNumber, required this.cells});

  final int rowNumber;
  final Map<int, String> cells;
}

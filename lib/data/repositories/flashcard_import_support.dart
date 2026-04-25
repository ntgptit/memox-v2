import '../../core/errors/app_exception.dart';
import '../../domain/value_objects/content_actions.dart';

final class FlashcardImportSupport {
  const FlashcardImportSupport._();

  static FlashcardImportPreparation parse({
    required ImportSourceFormat format,
    required String rawContent,
  }) {
    return switch (format) {
      ImportSourceFormat.csv => _parseCsv(rawContent),
      ImportSourceFormat.structuredText => _parseStructuredText(rawContent),
    };
  }

  static FlashcardImportPreparation _parseCsv(String rawContent) {
    final lines = rawContent
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return const FlashcardImportPreparation(
        format: ImportSourceFormat.csv,
        previewItems: <FlashcardImportPreviewItem>[],
        issues: <ImportValidationIssue>[
          ImportValidationIssue(
            lineNumber: 1,
            message: 'CSV content is empty.',
          ),
        ],
      );
    }

    final headerCells = _parseCsvLine(lines.first);
    final headerMap = <String, int>{};
    for (var index = 0; index < headerCells.length; index++) {
      headerMap[headerCells[index].trim().toLowerCase()] = index;
    }

    if (!headerMap.containsKey('front') || !headerMap.containsKey('back')) {
      return const FlashcardImportPreparation(
        format: ImportSourceFormat.csv,
        previewItems: <FlashcardImportPreviewItem>[],
        issues: <ImportValidationIssue>[
          ImportValidationIssue(
            lineNumber: 1,
            message: 'CSV header must include front and back columns.',
          ),
        ],
      );
    }

    final previewItems = <FlashcardImportPreviewItem>[];
    final issues = <ImportValidationIssue>[];
    for (var index = 1; index < lines.length; index++) {
      final lineNumber = index + 1;
      final cells = _parseCsvLine(lines[index]);
      final front = _readCsvCell(cells, headerMap['front']);
      final back = _readCsvCell(cells, headerMap['back']);
      if (front.trim().isEmpty || back.trim().isEmpty) {
        issues.add(
          ImportValidationIssue(
            lineNumber: lineNumber,
            message: 'front and back are required.',
          ),
        );
        continue;
      }
      previewItems.add(
        FlashcardImportPreviewItem(
          sourceLabel: 'Line $lineNumber',
          draft: FlashcardDraft(
            front: front,
            back: back,
            note: _readCsvCell(cells, headerMap['note']),
          ),
        ),
      );
    }

    return FlashcardImportPreparation(
      format: ImportSourceFormat.csv,
      previewItems: previewItems,
      issues: issues,
    );
  }

  static FlashcardImportPreparation _parseStructuredText(String rawContent) {
    final normalized = rawContent
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n\s*\n'));
    final previewItems = <FlashcardImportPreviewItem>[];
    final issues = <ImportValidationIssue>[];
    var consumedLineCount = 0;

    for (final block in blocks) {
      final trimmedBlock = block.trim();
      if (trimmedBlock.isEmpty) {
        consumedLineCount += block.split('\n').length + 1;
        continue;
      }

      final blockLines = block.split('\n');
      final startLineNumber = consumedLineCount + 1;
      consumedLineCount += blockLines.length + 1;

      String? front;
      String? back;
      String? note;
      for (final rawLine in blockLines) {
        final line = rawLine.trim();
        if (line.isEmpty) {
          continue;
        }
        if (line.startsWith('Front:')) {
          front = line.substring('Front:'.length).trim();
          continue;
        }
        if (line.startsWith('Back:')) {
          back = line.substring('Back:'.length).trim();
          continue;
        }
        if (line.startsWith('Note:')) {
          note = line.substring('Note:'.length).trim();
          continue;
        }
      }

      if ((front ?? '').isEmpty || (back ?? '').isEmpty) {
        issues.add(
          ImportValidationIssue(
            lineNumber: startLineNumber,
            message: 'Each block must include Front: and Back: lines.',
          ),
        );
        continue;
      }

      previewItems.add(
        FlashcardImportPreviewItem(
          sourceLabel: 'Block starting at line $startLineNumber',
          draft: FlashcardDraft(front: front!, back: back!, note: note),
        ),
      );
    }

    return FlashcardImportPreparation(
      format: ImportSourceFormat.structuredText,
      previewItems: previewItems,
      issues: issues,
    );
  }

  static List<String> _parseCsvLine(String line) {
    final cells = <String>[];
    final current = StringBuffer();
    var inQuotes = false;
    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        if (inQuotes && index + 1 < line.length && line[index + 1] == '"') {
          current.write('"');
          index += 1;
          continue;
        }
        inQuotes = !inQuotes;
        continue;
      }
      if (char == ',' && !inQuotes) {
        cells.add(current.toString());
        current.clear();
        continue;
      }
      current.write(char);
    }
    cells.add(current.toString());
    return cells;
  }

  static String _readCsvCell(List<String> cells, int? index) {
    if (index == null || index < 0 || index >= cells.length) {
      return '';
    }
    return cells[index].trim();
  }

  static String ensureImportableContent(
    FlashcardImportPreparation preparation,
  ) {
    if (!preparation.canCommit) {
      throw const ValidationException(
        message: 'Import preparation is not ready to commit.',
      );
    }
    return '';
  }
}

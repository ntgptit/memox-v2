import '../../core/errors/app_exception.dart';
import '../../domain/value_objects/content_actions.dart';

final class FlashcardImportSupport {
  const FlashcardImportSupport._();

  static FlashcardImportPreparation parse({
    required ImportSourceFormat format,
    required String rawContent,
    ImportStructuredTextSeparator structuredTextSeparator =
        ImportStructuredTextSeparator.auto,
  }) {
    return switch (format) {
      ImportSourceFormat.csv => _parseCsv(rawContent),
      ImportSourceFormat.structuredText => _parseStructuredText(
        rawContent,
        structuredTextSeparator,
      ),
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

  static FlashcardImportPreparation _parseStructuredText(
    String rawContent,
    ImportStructuredTextSeparator separator,
  ) {
    final normalized = rawContent
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    if (separator == ImportStructuredTextSeparator.auto &&
        !_hasStructuredBlockLabels(normalized)) {
      final detected = _detectLineSeparator(normalized);
      if (detected != null) {
        return _parseSeparatedText(normalized, detected);
      }
    }
    if (separator != ImportStructuredTextSeparator.auto) {
      return _parseSeparatedText(normalized, separator);
    }

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

  static bool _hasStructuredBlockLabels(String normalized) {
    final lines = normalized.split('\n');
    return lines.any((line) {
      final trimmed = line.trim();
      return trimmed.startsWith('Front:') ||
          trimmed.startsWith('Back:') ||
          trimmed.startsWith('Note:');
    });
  }

  static ImportStructuredTextSeparator? _detectLineSeparator(
    String normalized,
  ) {
    final lines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    var bestCount = 0;
    ImportStructuredTextSeparator? bestSeparator;
    for (final separator in _autoDetectSeparators) {
      final count = lines
          .where(
            (line) =>
                _splitSeparatedLine(line, separator, clearOnly: true) != null,
          )
          .length;
      if (count <= bestCount) {
        continue;
      }
      bestCount = count;
      bestSeparator = separator;
    }
    return bestSeparator;
  }

  static const _autoDetectSeparators = <ImportStructuredTextSeparator>[
    ImportStructuredTextSeparator.tab,
    ImportStructuredTextSeparator.slash,
    ImportStructuredTextSeparator.pipe,
    ImportStructuredTextSeparator.semicolon,
    ImportStructuredTextSeparator.colon,
  ];

  static FlashcardImportPreparation _parseSeparatedText(
    String normalized,
    ImportStructuredTextSeparator separator,
  ) {
    final previewItems = <FlashcardImportPreviewItem>[];
    final issues = <ImportValidationIssue>[];
    final lines = normalized.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final lineNumber = index + 1;
      final line = lines[index].trim();
      if (line.isEmpty) {
        continue;
      }

      final split = _splitSeparatedLine(line, separator);
      if (split == null) {
        issues.add(
          ImportValidationIssue(
            lineNumber: lineNumber,
            message: 'Each line must include a separator and both sides.',
          ),
        );
        continue;
      }

      previewItems.add(
        FlashcardImportPreviewItem(
          sourceLabel: 'Line $lineNumber',
          draft: FlashcardDraft(front: split.front, back: split.back),
        ),
      );
    }

    return FlashcardImportPreparation(
      format: ImportSourceFormat.structuredText,
      previewItems: previewItems,
      issues: issues,
    );
  }

  static ({String front, String back})? _splitSeparatedLine(
    String line,
    ImportStructuredTextSeparator separator, {
    bool clearOnly = false,
  }) {
    final separatorIndex = _separatorIndex(
      line,
      separator,
      clearOnly: clearOnly,
    );
    if (separatorIndex == null) {
      return null;
    }
    final front = line.substring(0, separatorIndex).trim();
    final back = line.substring(separatorIndex + 1).trim();
    if (front.isEmpty || back.isEmpty) {
      return null;
    }
    return (front: front, back: back);
  }

  static int? _separatorIndex(
    String line,
    ImportStructuredTextSeparator separator, {
    required bool clearOnly,
  }) {
    return switch (separator) {
      ImportStructuredTextSeparator.auto => null,
      ImportStructuredTextSeparator.tab => _firstIndex(line, '\t'),
      ImportStructuredTextSeparator.colon =>
        clearOnly ? _clearColonIndex(line) : _firstIndex(line, ':'),
      ImportStructuredTextSeparator.slash =>
        clearOnly ? _spacedTokenIndex(line, '/') : _firstIndex(line, '/'),
      ImportStructuredTextSeparator.semicolon =>
        clearOnly ? _spacedTokenIndex(line, ';') : _firstIndex(line, ';'),
      ImportStructuredTextSeparator.pipe =>
        clearOnly ? _spacedTokenIndex(line, '|') : _firstIndex(line, '|'),
    };
  }

  static int? _firstIndex(String line, String token) {
    final index = line.indexOf(token);
    if (index < 0) {
      return null;
    }
    return index;
  }

  static int? _spacedTokenIndex(String line, String token) {
    final index = line.indexOf(' $token ');
    if (index < 0) {
      return null;
    }
    return index + 1;
  }

  static int? _clearColonIndex(String line) {
    final spacedIndex = _spacedTokenIndex(line, ':');
    if (spacedIndex != null) {
      return spacedIndex;
    }
    final index = line.indexOf(': ');
    if (index < 0) {
      return null;
    }
    return index;
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

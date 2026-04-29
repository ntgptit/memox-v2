final class FolderMoveTarget {
  const FolderMoveTarget({
    required this.id,
    required this.name,
    required this.breadcrumb,
    required this.isRoot,
  });

  final String? id;
  final String name;
  final List<String> breadcrumb;
  final bool isRoot;
}

final class DeckMoveTarget {
  const DeckMoveTarget({
    required this.id,
    required this.name,
    required this.breadcrumb,
  });

  final String id;
  final String name;
  final List<String> breadcrumb;
}

final class ExportData {
  const ExportData({
    required this.fileName,
    required this.mimeType,
    required this.content,
  });

  final String fileName;
  final String mimeType;
  final String content;
}

enum ImportSourceFormat { csv, structuredText }

enum ImportStructuredTextSeparator { auto, tab, colon, slash, semicolon, pipe }

enum FlashcardImportDuplicatePolicy { skipExactDuplicates }

enum FlashcardImportDuplicateSource { importFile, deck }

enum FlashcardProgressEditPolicy { keepProgress, resetProgress }

final class FlashcardDraft {
  const FlashcardDraft({required this.front, required this.back, this.note});

  final String front;
  final String back;
  final String? note;
}

final class ImportValidationIssue {
  const ImportValidationIssue({
    required this.lineNumber,
    required this.message,
  });

  final int lineNumber;
  final String message;
}

final class FlashcardImportPreviewItem {
  const FlashcardImportPreviewItem({
    required this.sourceLabel,
    required this.draft,
  });

  final String sourceLabel;
  final FlashcardDraft draft;
}

final class FlashcardImportSkippedDuplicate {
  const FlashcardImportSkippedDuplicate({
    required this.sourceLabel,
    required this.draft,
    required this.source,
  });

  final String sourceLabel;
  final FlashcardDraft draft;
  final FlashcardImportDuplicateSource source;
}

final class FlashcardImportPreparation {
  const FlashcardImportPreparation({
    required this.format,
    required this.previewItems,
    required this.issues,
    this.duplicatePolicy = FlashcardImportDuplicatePolicy.skipExactDuplicates,
    this.skippedDuplicates = const <FlashcardImportSkippedDuplicate>[],
  });

  final ImportSourceFormat format;
  final List<FlashcardImportPreviewItem> previewItems;
  final List<ImportValidationIssue> issues;
  final FlashcardImportDuplicatePolicy duplicatePolicy;
  final List<FlashcardImportSkippedDuplicate> skippedDuplicates;

  bool get hasIssues => issues.isNotEmpty;
  bool get canCommit => previewItems.isNotEmpty && issues.isEmpty;
  int get skippedDuplicateCount => skippedDuplicates.length;
}

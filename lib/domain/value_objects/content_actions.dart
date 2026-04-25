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

final class FlashcardImportPreparation {
  const FlashcardImportPreparation({
    required this.format,
    required this.previewItems,
    required this.issues,
  });

  final ImportSourceFormat format;
  final List<FlashcardImportPreviewItem> previewItems;
  final List<ImportValidationIssue> issues;

  bool get hasIssues => issues.isNotEmpty;
  bool get canCommit => previewItems.isNotEmpty && issues.isEmpty;
}

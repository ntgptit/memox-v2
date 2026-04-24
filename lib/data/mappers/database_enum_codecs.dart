import '../../core/errors/app_exception.dart';
import '../../domain/enums/folder_content_mode.dart';
import '../../domain/enums/study_enums.dart';

abstract final class DatabaseEnumCodecs {
  const DatabaseEnumCodecs._();

  static FolderContentMode folderContentModeFromStorage(String raw) {
    return FolderContentMode.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported folder content mode: $raw',
      ),
    );
  }

  static StudyType studyTypeFromStorage(String raw) {
    return StudyType.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () =>
          throw ValidationException(message: 'Unsupported study type: $raw'),
    );
  }

  static StudyEntryType studyEntryTypeFromStorage(String raw) {
    return StudyEntryType.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported study entry type: $raw',
      ),
    );
  }

  static StudyFlow studyFlowFromStorage(String raw) {
    return StudyFlow.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () =>
          throw ValidationException(message: 'Unsupported study flow: $raw'),
    );
  }

  static StudyMode studyModeFromStorage(String raw) {
    return StudyMode.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () =>
          throw ValidationException(message: 'Unsupported study mode: $raw'),
    );
  }

  static SessionStatus sessionStatusFromStorage(String raw) {
    return SessionStatus.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported session status: $raw',
      ),
    );
  }

  static SessionItemSourcePool sessionItemSourcePoolFromStorage(String raw) {
    return SessionItemSourcePool.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported session item source pool: $raw',
      ),
    );
  }

  static SessionItemStatus sessionItemStatusFromStorage(String raw) {
    return SessionItemStatus.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported session item status: $raw',
      ),
    );
  }

  static RawStudyResult rawStudyResultFromStorage(String raw) {
    return RawStudyResult.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported raw study result: $raw',
      ),
    );
  }

  static AttemptGrade attemptGradeFromStorage(String raw) {
    return AttemptGrade.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () =>
          throw ValidationException(message: 'Unsupported attempt grade: $raw'),
    );
  }

  static ReviewResult reviewResultFromStorage(String raw) {
    return ReviewResult.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () =>
          throw ValidationException(message: 'Unsupported review result: $raw'),
    );
  }
}

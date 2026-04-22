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
      orElse: () => throw ValidationException(
        message: 'Unsupported study type: $raw',
      ),
    );
  }

  static StudyMode studyModeFromStorage(String raw) {
    return StudyMode.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => throw ValidationException(
        message: 'Unsupported study mode: $raw',
      ),
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
}

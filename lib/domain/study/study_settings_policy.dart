import '../enums/study_enums.dart';

abstract final class StudySettingsPolicy {
  const StudySettingsPolicy._();

  static const int newStudyMinBatchSize = 5;
  static const int newStudyMaxBatchSize = 20;
  static const int reviewMinBatchSize = 5;
  static const int reviewMaxBatchSize = 50;

  static int minBatchSize(StudyType studyType) {
    return switch (studyType) {
      StudyType.newStudy => newStudyMinBatchSize,
      StudyType.srsReview => reviewMinBatchSize,
    };
  }

  static int maxBatchSize(StudyType studyType) {
    return switch (studyType) {
      StudyType.newStudy => newStudyMaxBatchSize,
      StudyType.srsReview => reviewMaxBatchSize,
    };
  }

  static int clampBatchSize(int value, StudyType studyType) {
    return value
        .clamp(minBatchSize(studyType), maxBatchSize(studyType))
        .toInt();
  }
}

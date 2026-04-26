import 'package:flutter/widgets.dart';

import '../../../../../domain/enums/study_enums.dart';
import '../../../../../domain/study/entities/study_models.dart';
import 'fill/fill_mode_session_view.dart';
import 'guess/guess_mode_session_view.dart';
import 'match/match_mode_session_view.dart';
import 'recall/recall_mode_session_view.dart';
import 'review/review_mode_session_view.dart';

typedef StudyModeBatchSubmit =
    Future<bool> Function(Map<String, AttemptGrade> itemGrades);

typedef _ModeViewBuilder =
    Widget Function({
      required StudySessionSnapshot snapshot,
      required bool isSubmitting,
      required Future<bool> Function() onReviewSubmit,
      required StudyModeBatchSubmit onBatchSubmit,
    });

final class StudyModeSessionViewFactory {
  const StudyModeSessionViewFactory();

  static final Map<StudyMode, _ModeViewBuilder> _builders =
      <StudyMode, _ModeViewBuilder>{
        StudyMode.review:
            ({
              required snapshot,
              required isSubmitting,
              required onReviewSubmit,
              required onBatchSubmit,
            }) => ReviewModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              onSubmit: onReviewSubmit,
            ),
        StudyMode.match:
            ({
              required snapshot,
              required isSubmitting,
              required onReviewSubmit,
              required onBatchSubmit,
            }) => MatchModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              onSubmit: onBatchSubmit,
            ),
        StudyMode.guess:
            ({
              required snapshot,
              required isSubmitting,
              required onReviewSubmit,
              required onBatchSubmit,
            }) => GuessModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              onSubmit: onBatchSubmit,
            ),
        StudyMode.recall:
            ({
              required snapshot,
              required isSubmitting,
              required onReviewSubmit,
              required onBatchSubmit,
            }) => RecallModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              onSubmit: onBatchSubmit,
            ),
        StudyMode.fill:
            ({
              required snapshot,
              required isSubmitting,
              required onReviewSubmit,
              required onBatchSubmit,
            }) => FillModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              onSubmit: onBatchSubmit,
            ),
      };

  Widget? build({
    required StudySessionSnapshot snapshot,
    required bool isSubmitting,
    required Future<bool> Function() onReviewSubmit,
    required StudyModeBatchSubmit onBatchSubmit,
  }) {
    final mode = snapshot.currentItem?.studyMode;
    if (mode == null || snapshot.session.status != SessionStatus.inProgress) {
      return null;
    }
    final builder = _builders[mode];
    if (builder == null) {
      return null;
    }
    return builder(
      snapshot: snapshot,
      isSubmitting: isSubmitting,
      onReviewSubmit: onReviewSubmit,
      onBatchSubmit: onBatchSubmit,
    );
  }
}

import 'package:flutter/widgets.dart';

import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
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
      required bool canCancel,
      required Future<bool> Function() onReviewSubmit,
      required StudyModeBatchSubmit onBatchSubmit,
      required VoidCallback onCancel,
      required VoidCallback onBack,
      required VoidCallback? onCardActions,
    });

final class StudyModeSessionViewFactory {
  const StudyModeSessionViewFactory();

  static final Map<StudyMode, _ModeViewBuilder> _builders =
      <StudyMode, _ModeViewBuilder>{
        StudyMode.review:
            ({
              required snapshot,
              required isSubmitting,
              required canCancel,
              required onReviewSubmit,
              required onBatchSubmit,
              required onCancel,
              required onBack,
              required onCardActions,
            }) => ReviewModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              canCancel: canCancel,
              onSubmit: onReviewSubmit,
              onCancel: onCancel,
              onBack: onBack,
              onCardActions: onCardActions,
            ),
        StudyMode.match:
            ({
              required snapshot,
              required isSubmitting,
              required canCancel,
              required onReviewSubmit,
              required onBatchSubmit,
              required onCancel,
              required onBack,
              required onCardActions,
            }) => MatchModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              canCancel: canCancel,
              onSubmit: onBatchSubmit,
              onCancel: onCancel,
              onBack: onBack,
              onCardActions: onCardActions,
            ),
        StudyMode.guess:
            ({
              required snapshot,
              required isSubmitting,
              required canCancel,
              required onReviewSubmit,
              required onBatchSubmit,
              required onCancel,
              required onBack,
              required onCardActions,
            }) => GuessModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              canCancel: canCancel,
              onSubmit: onBatchSubmit,
              onCancel: onCancel,
              onBack: onBack,
              onCardActions: onCardActions,
            ),
        StudyMode.recall:
            ({
              required snapshot,
              required isSubmitting,
              required canCancel,
              required onReviewSubmit,
              required onBatchSubmit,
              required onCancel,
              required onBack,
              required onCardActions,
            }) => RecallModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              canCancel: canCancel,
              onSubmit: onBatchSubmit,
              onCancel: onCancel,
              onBack: onBack,
              onCardActions: onCardActions,
            ),
        StudyMode.fill:
            ({
              required snapshot,
              required isSubmitting,
              required canCancel,
              required onReviewSubmit,
              required onBatchSubmit,
              required onCancel,
              required onBack,
              required onCardActions,
            }) => FillModeSessionView(
              snapshot: snapshot,
              isSubmitting: isSubmitting,
              canCancel: canCancel,
              onSubmit: onBatchSubmit,
              onCancel: onCancel,
              onBack: onBack,
              onCardActions: onCardActions,
            ),
      };

  Widget? build({
    required StudySessionSnapshot snapshot,
    required bool isSubmitting,
    required bool canCancel,
    required Future<bool> Function() onReviewSubmit,
    required StudyModeBatchSubmit onBatchSubmit,
    required VoidCallback onCancel,
    required VoidCallback onBack,
    VoidCallback? onCardActions,
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
      canCancel: canCancel,
      onReviewSubmit: onReviewSubmit,
      onBatchSubmit: onBatchSubmit,
      onCancel: onCancel,
      onBack: onBack,
      onCardActions: onCardActions,
    );
  }
}

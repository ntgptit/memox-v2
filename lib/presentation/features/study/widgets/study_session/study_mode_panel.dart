import 'package:flutter/material.dart';

import '../../../../../domain/enums/study_enums.dart';
import '../../../../../domain/study/entities/study_models.dart';
import 'fill/fill_mode_panel.dart';
import 'guess/guess_mode_panel.dart';
import 'match/match_mode_panel.dart';
import 'ready_to_finalize_panel.dart';
import 'recall/recall_mode_panel.dart';
import 'review/review_mode_panel.dart';
import 'study_answer_models.dart';

export 'study_answer_models.dart';

class StudyModePanel extends StatelessWidget {
  const StudyModePanel({
    required this.snapshot,
    required this.answerOptions,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
    this.onMarkCorrect,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final List<StudyFlashcardRef> answerOptions;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<StudyAnswerSubmission> onAnswer;
  final VoidCallback? onContinue;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

  @override
  Widget build(BuildContext context) {
    final item = snapshot.currentItem;
    if (item == null) {
      return const ReadyToFinalizePanel();
    }
    return switch (item.studyMode) {
      StudyMode.review => ReviewModePanel(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
        onMarkCorrect: onMarkCorrect,
      ),
      StudyMode.match => MatchModePanel(
        item: item,
        answerOptions: answerOptions,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
        onMarkCorrect: onMarkCorrect,
      ),
      StudyMode.guess => GuessModePanel(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
        onMarkCorrect: onMarkCorrect,
      ),
      StudyMode.recall => RecallModePanel(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
        onMarkCorrect: onMarkCorrect,
      ),
      StudyMode.fill => FillModePanel(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
        onMarkCorrect: onMarkCorrect,
      ),
    };
  }
}

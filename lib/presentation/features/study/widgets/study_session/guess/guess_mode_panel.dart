import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/widgets/mx_primary_button.dart';
import '../../../../../shared/widgets/mx_secondary_button.dart';
import '../prompt_card.dart';
import '../study_answer_models.dart';

class GuessModePanel extends StatelessWidget {
  const GuessModePanel({
    required this.item,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
    this.onMarkCorrect,
    super.key,
  });

  final StudySessionItem item;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<StudyAnswerSubmission> onAnswer;
  final VoidCallback? onContinue;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PromptCard(
      title: l10n.studyModeGuess,
      front: item.flashcard.front,
      back: item.flashcard.back,
      feedback: feedback,
      isSubmitting: isSubmitting,
      onContinue: onContinue,
      onMarkCorrect: onMarkCorrect,
      actions: [
        MxSecondaryButton(
          label: l10n.studyIncorrectAction,
          leadingIcon: Icons.close_rounded,
          onPressed: isSubmitting
              ? null
              : () => onAnswer(
                  const StudyAnswerSubmission(grade: AttemptGrade.incorrect),
                ),
        ),
        MxPrimaryButton(
          label: l10n.studyCorrectAction,
          leadingIcon: Icons.check_rounded,
          onPressed: isSubmitting
              ? null
              : () => onAnswer(
                  const StudyAnswerSubmission(grade: AttemptGrade.correct),
                ),
        ),
      ],
    );
  }
}

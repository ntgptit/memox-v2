import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/widgets/mx_answer_option_card.dart';
import '../prompt_card.dart';
import '../study_answer_models.dart';

class MatchModePanel extends StatelessWidget {
  const MatchModePanel({
    required this.item,
    required this.answerOptions,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
    this.onMarkCorrect,
    super.key,
  });

  final StudySessionItem item;
  final List<StudyFlashcardRef> answerOptions;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<StudyAnswerSubmission> onAnswer;
  final VoidCallback? onContinue;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PromptCard(
      title: l10n.studyModeMatch,
      front: item.flashcard.front,
      back: l10n.studyChooseMatchingAnswer,
      feedback: feedback,
      isSubmitting: isSubmitting,
      onContinue: onContinue,
      onMarkCorrect: onMarkCorrect,
      actions: [
        for (final option in answerOptions)
          SizedBox(
            width: double.infinity,
            child: MxAnswerOptionCard(
              label: option.back,
              selected: feedback?.selectedOptionId == option.id,
              enabled: !isSubmitting && feedback == null,
              onPressed: isSubmitting || feedback != null
                  ? null
                  : () => onAnswer(
                      StudyAnswerSubmission(
                        grade: option.id == item.flashcard.id
                            ? AttemptGrade.correct
                            : AttemptGrade.incorrect,
                        submittedAnswer: option.back,
                        selectedOptionId: option.id,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

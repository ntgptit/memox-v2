import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../shared/layouts/mx_gap.dart';
import '../../../../shared/layouts/mx_space.dart';
import '../../../../shared/widgets/mx_secondary_button.dart';
import '../../../../shared/widgets/mx_text.dart';
import 'study_answer_models.dart';

class AnswerFeedbackPanel extends StatelessWidget {
  const AnswerFeedbackPanel({
    required this.feedback,
    this.onMarkCorrect,
    super.key,
  });

  final StudyAnswerFeedback feedback;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cardShape = theme.cardTheme.shape;
    final borderRadius =
        cardShape is RoundedRectangleBorder &&
            cardShape.borderRadius is BorderRadius
        ? cardShape.borderRadius as BorderRadius
        : BorderRadius.zero;
    final background = feedback.isCorrect
        ? scheme.primaryContainer
        : scheme.errorContainer;
    final foreground = feedback.isCorrect
        ? scheme.onPrimaryContainer
        : scheme.onErrorContainer;
    final title = feedback.isCorrect
        ? l10n.studyAnswerCorrectTitle
        : l10n.studyAnswerIncorrectTitle;
    final icon = feedback.isCorrect
        ? Icons.check_circle_rounded
        : Icons.info_rounded;

    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(MxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: foreground),
                const MxGap(MxSpace.sm),
                Expanded(
                  child: MxText(
                    title,
                    role: MxTextRole.sectionTitle,
                    color: foreground,
                  ),
                ),
              ],
            ),
            const MxGap(MxSpace.sm),
            if (feedback.submittedAnswer?.isNotEmpty ?? false) ...[
              MxText(
                l10n.studyYourAnswerLabel(feedback.submittedAnswer!),
                role: MxTextRole.contentBody,
                color: foreground,
                softWrap: true,
              ),
              const MxGap(MxSpace.xs),
            ],
            MxText(
              l10n.studyCorrectAnswerLabel(feedback.correctAnswer),
              role: MxTextRole.contentBody,
              color: foreground,
              softWrap: true,
            ),
            if (!feedback.isCorrect && onMarkCorrect != null) ...[
              const MxGap(MxSpace.sm),
              MxSecondaryButton(
                label: l10n.studyMarkCorrectAction,
                leadingIcon: Icons.check_rounded,
                variant: MxSecondaryVariant.text,
                onPressed: () => onMarkCorrect!(feedback.markCorrected()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

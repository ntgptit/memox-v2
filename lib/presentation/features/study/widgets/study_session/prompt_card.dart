import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../shared/layouts/mx_gap.dart';
import '../../../../shared/layouts/mx_space.dart';
import '../../../../shared/widgets/mx_card.dart';
import '../../../../shared/widgets/mx_primary_button.dart';
import '../../../../shared/widgets/mx_text.dart';
import 'answer_feedback_panel.dart';
import 'study_answer_models.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({
    required this.title,
    required this.front,
    required this.back,
    required this.actions,
    required this.isSubmitting,
    this.content,
    this.feedback,
    this.onContinue,
    this.onMarkCorrect,
    super.key,
  });

  final String title;
  final String front;
  final String back;
  final Widget? content;
  final List<Widget> actions;
  final StudyAnswerFeedback? feedback;
  final bool isSubmitting;
  final VoidCallback? onContinue;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(title, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.md),
          MxText(front, role: MxTextRole.pageTitle),
          const MxGap(MxSpace.sm),
          MxText(back, role: MxTextRole.contentBody),
          if (content != null) ...[const MxGap(MxSpace.lg), content!],
          const MxGap(MxSpace.lg),
          if (feedback != null) ...[
            AnswerFeedbackPanel(
              feedback: feedback!,
              onMarkCorrect: isSubmitting ? null : onMarkCorrect,
            ),
            const MxGap(MxSpace.md),
            MxPrimaryButton(
              label: l10n.studyContinueAction,
              trailingIcon: Icons.arrow_forward_rounded,
              isLoading: isSubmitting,
              fullWidth: true,
              onPressed: isSubmitting ? null : onContinue,
            ),
          ],
          if (feedback == null)
            Wrap(
              spacing: MxSpace.sm,
              runSpacing: MxSpace.sm,
              children: actions,
            ),
        ],
      ),
    );
  }
}

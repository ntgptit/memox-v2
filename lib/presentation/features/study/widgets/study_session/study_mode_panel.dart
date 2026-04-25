import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../shared/layouts/mx_gap.dart';
import '../../../../../domain/enums/study_enums.dart';
import '../../../../../domain/study/entities/study_models.dart';
import '../../../../shared/layouts/mx_space.dart';
import '../../../../shared/widgets/mx_card.dart';
import '../../../../shared/widgets/mx_primary_button.dart';
import '../../../../shared/widgets/mx_secondary_button.dart';
import '../../../../shared/widgets/mx_text.dart';
import '../../../../shared/widgets/mx_text_field.dart';

class StudyModePanel extends StatelessWidget {
  const StudyModePanel({
    required this.snapshot,
    required this.answerOptions,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final List<StudyFlashcardRef> answerOptions;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade> onAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final item = snapshot.currentItem;
    if (item == null) {
      return const _ReadyToFinalizePanel();
    }
    return switch (item.studyMode) {
      StudyMode.review => _ReviewMode(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
      ),
      StudyMode.match => _MatchMode(
        item: item,
        answerOptions: answerOptions,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
      ),
      StudyMode.guess => _GuessMode(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
      ),
      StudyMode.recall => _RecallMode(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
      ),
      StudyMode.fill => _FillMode(
        item: item,
        isSubmitting: isSubmitting,
        feedback: feedback,
        onAnswer: onAnswer,
        onContinue: onContinue,
      ),
    };
  }
}

class StudyAnswerFeedback {
  const StudyAnswerFeedback({
    required this.itemId,
    required this.selectedGrade,
    required this.isCorrect,
    required this.correctAnswer,
  });

  final String itemId;
  final AttemptGrade selectedGrade;
  final bool isCorrect;
  final String correctAnswer;
}

class _ReadyToFinalizePanel extends StatelessWidget {
  const _ReadyToFinalizePanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxText(l10n.studyReadyToFinalizeTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.sm),
          MxText(
            l10n.studyReadyToFinalizeMessage,
            role: MxTextRole.contentBody,
          ),
        ],
      ),
    );
  }
}

class _ReviewMode extends StatelessWidget {
  const _ReviewMode({
    required this.item,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
  });

  final StudySessionItem item;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade> onAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeReview,
      front: item.flashcard.front,
      back: item.flashcard.back,
      feedback: feedback,
      isSubmitting: isSubmitting,
      onContinue: onContinue,
      actions: [
        MxSecondaryButton(
          label: l10n.studyForgotAction,
          leadingIcon: Icons.close_rounded,
          onPressed: isSubmitting ? null : () => onAnswer(AttemptGrade.forgot),
        ),
        MxPrimaryButton(
          label: l10n.studyRememberedAction,
          leadingIcon: Icons.check_rounded,
          onPressed: isSubmitting
              ? null
              : () => onAnswer(AttemptGrade.remembered),
        ),
      ],
    );
  }
}

class _MatchMode extends StatelessWidget {
  const _MatchMode({
    required this.item,
    required this.answerOptions,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
  });

  final StudySessionItem item;
  final List<StudyFlashcardRef> answerOptions;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade> onAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeMatch,
      front: item.flashcard.front,
      back: l10n.studyChooseMatchingAnswer,
      feedback: feedback,
      isSubmitting: isSubmitting,
      onContinue: onContinue,
      actions: [
        for (final option in answerOptions)
          MxSecondaryButton(
            label: option.back,
            variant: MxSecondaryVariant.tonal,
            onPressed: isSubmitting
                ? null
                : () => onAnswer(
                    option.id == item.flashcard.id
                        ? AttemptGrade.correct
                        : AttemptGrade.incorrect,
                  ),
          ),
      ],
    );
  }
}

class _GuessMode extends StatelessWidget {
  const _GuessMode({
    required this.item,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
  });

  final StudySessionItem item;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade> onAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeGuess,
      front: item.flashcard.front,
      back: item.flashcard.back,
      feedback: feedback,
      isSubmitting: isSubmitting,
      onContinue: onContinue,
      actions: [
        MxSecondaryButton(
          label: l10n.studyIncorrectAction,
          leadingIcon: Icons.close_rounded,
          onPressed: isSubmitting
              ? null
              : () => onAnswer(AttemptGrade.incorrect),
        ),
        MxPrimaryButton(
          label: l10n.studyCorrectAction,
          leadingIcon: Icons.check_rounded,
          onPressed: isSubmitting ? null : () => onAnswer(AttemptGrade.correct),
        ),
      ],
    );
  }
}

class _RecallMode extends StatelessWidget {
  const _RecallMode({
    required this.item,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
  });

  final StudySessionItem item;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade> onAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeRecall,
      front: item.flashcard.front,
      back: item.flashcard.back,
      feedback: feedback,
      isSubmitting: isSubmitting,
      onContinue: onContinue,
      actions: [
        MxSecondaryButton(
          label: l10n.studyForgotAction,
          leadingIcon: Icons.close_rounded,
          onPressed: isSubmitting ? null : () => onAnswer(AttemptGrade.forgot),
        ),
        MxPrimaryButton(
          label: l10n.studyRememberedAction,
          leadingIcon: Icons.check_rounded,
          onPressed: isSubmitting
              ? null
              : () => onAnswer(AttemptGrade.remembered),
        ),
      ],
    );
  }
}

class _FillMode extends StatefulWidget {
  const _FillMode({
    required this.item,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
  });

  final StudySessionItem item;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade> onAnswer;
  final VoidCallback? onContinue;

  @override
  State<_FillMode> createState() => _FillModeState();
}

class _FillModeState extends State<_FillMode> {
  late final TextEditingController _controller;
  bool _showEmptyError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _FillMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _controller.clear();
      _showEmptyError = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final answer = _controller.text.trim();
    final inputDisabled = widget.isSubmitting || widget.feedback != null;
    return _PromptCard(
      title: l10n.studyModeFill,
      front: widget.item.flashcard.front,
      back: l10n.studyTypeMatchingAnswer,
      feedback: widget.feedback,
      isSubmitting: widget.isSubmitting,
      onContinue: widget.onContinue,
      content: MxTextField(
        label: l10n.studyAnswerLabel,
        controller: _controller,
        enabled: !inputDisabled,
        errorText: _showEmptyError ? l10n.studyEmptyAnswerMessage : null,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {
          _showEmptyError = false;
        }),
        onSubmitted: inputDisabled ? null : (_) => _submit(),
      ),
      actions: [
        MxPrimaryButton(
          label: l10n.studySubmitAnswer,
          leadingIcon: Icons.check_rounded,
          isLoading: widget.isSubmitting,
          onPressed: inputDisabled || answer.isEmpty ? null : _submit,
        ),
      ],
    );
  }

  void _submit() {
    final answer = _controller.text.trim();
    if (answer.isEmpty) {
      setState(() {
        _showEmptyError = true;
      });
      return;
    }
    final expected = widget.item.flashcard.back.trim().toLowerCase();
    final actual = answer.toLowerCase();
    widget.onAnswer(
      actual == expected ? AttemptGrade.correct : AttemptGrade.incorrect,
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.title,
    required this.front,
    required this.back,
    required this.actions,
    required this.isSubmitting,
    this.content,
    this.feedback,
    this.onContinue,
  });

  final String title;
  final String front;
  final String back;
  final Widget? content;
  final List<Widget> actions;
  final StudyAnswerFeedback? feedback;
  final bool isSubmitting;
  final VoidCallback? onContinue;

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
            _AnswerFeedbackPanel(feedback: feedback!),
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

class _AnswerFeedbackPanel extends StatelessWidget {
  const _AnswerFeedbackPanel({required this.feedback});

  final StudyAnswerFeedback feedback;

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
            MxText(
              l10n.studyCorrectAnswerLabel(feedback.correctAnswer),
              role: MxTextRole.contentBody,
              color: foreground,
            ),
          ],
        ),
      ),
    );
  }
}

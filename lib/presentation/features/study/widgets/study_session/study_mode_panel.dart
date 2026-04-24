import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../core/theme/mx_gap.dart';
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
    required this.onAnswer,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final List<StudyFlashcardRef> answerOptions;
  final ValueChanged<AttemptGrade> onAnswer;

  @override
  Widget build(BuildContext context) {
    final item = snapshot.currentItem;
    if (item == null) {
      return const _ReadyToFinalizePanel();
    }
    return switch (item.studyMode) {
      StudyMode.review => _ReviewMode(item: item, onAnswer: onAnswer),
      StudyMode.match => _MatchMode(
        item: item,
        answerOptions: answerOptions,
        onAnswer: onAnswer,
      ),
      StudyMode.guess => _GuessMode(item: item, onAnswer: onAnswer),
      StudyMode.recall => _RecallMode(item: item, onAnswer: onAnswer),
      StudyMode.fill => _FillMode(item: item, onAnswer: onAnswer),
    };
  }
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
  const _ReviewMode({required this.item, required this.onAnswer});

  final StudySessionItem item;
  final ValueChanged<AttemptGrade> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeReview,
      front: item.flashcard.front,
      back: item.flashcard.back,
      actions: [
        MxSecondaryButton(
          label: l10n.studyForgotAction,
          leadingIcon: Icons.close_rounded,
          onPressed: () => onAnswer(AttemptGrade.forgot),
        ),
        MxPrimaryButton(
          label: l10n.studyRememberedAction,
          leadingIcon: Icons.check_rounded,
          onPressed: () => onAnswer(AttemptGrade.remembered),
        ),
      ],
    );
  }
}

class _MatchMode extends StatelessWidget {
  const _MatchMode({
    required this.item,
    required this.answerOptions,
    required this.onAnswer,
  });

  final StudySessionItem item;
  final List<StudyFlashcardRef> answerOptions;
  final ValueChanged<AttemptGrade> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeMatch,
      front: item.flashcard.front,
      back: l10n.studyChooseMatchingAnswer,
      actions: [
        for (final option in answerOptions)
          MxSecondaryButton(
            label: option.back,
            variant: MxSecondaryVariant.tonal,
            onPressed: () => onAnswer(
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
  const _GuessMode({required this.item, required this.onAnswer});

  final StudySessionItem item;
  final ValueChanged<AttemptGrade> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeGuess,
      front: item.flashcard.front,
      back: item.flashcard.back,
      actions: [
        MxSecondaryButton(
          label: l10n.studyIncorrectAction,
          leadingIcon: Icons.close_rounded,
          onPressed: () => onAnswer(AttemptGrade.incorrect),
        ),
        MxPrimaryButton(
          label: l10n.studyCorrectAction,
          leadingIcon: Icons.check_rounded,
          onPressed: () => onAnswer(AttemptGrade.correct),
        ),
      ],
    );
  }
}

class _RecallMode extends StatelessWidget {
  const _RecallMode({required this.item, required this.onAnswer});

  final StudySessionItem item;
  final ValueChanged<AttemptGrade> onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromptCard(
      title: l10n.studyModeRecall,
      front: item.flashcard.front,
      back: item.flashcard.back,
      actions: [
        MxSecondaryButton(
          label: l10n.studyForgotAction,
          leadingIcon: Icons.close_rounded,
          onPressed: () => onAnswer(AttemptGrade.forgot),
        ),
        MxPrimaryButton(
          label: l10n.studyRememberedAction,
          leadingIcon: Icons.check_rounded,
          onPressed: () => onAnswer(AttemptGrade.remembered),
        ),
      ],
    );
  }
}

class _FillMode extends StatefulWidget {
  const _FillMode({required this.item, required this.onAnswer});

  final StudySessionItem item;
  final ValueChanged<AttemptGrade> onAnswer;

  @override
  State<_FillMode> createState() => _FillModeState();
}

class _FillModeState extends State<_FillMode> {
  late final TextEditingController _controller;

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
    return _PromptCard(
      title: l10n.studyModeFill,
      front: widget.item.flashcard.front,
      back: l10n.studyTypeMatchingAnswer,
      content: MxTextField(
        label: l10n.studyAnswerLabel,
        controller: _controller,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        MxPrimaryButton(
          label: l10n.studySubmitAnswer,
          leadingIcon: Icons.check_rounded,
          onPressed: _submit,
        ),
      ],
    );
  }

  void _submit() {
    final expected = widget.item.flashcard.back.trim().toLowerCase();
    final actual = _controller.text.trim().toLowerCase();
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
    this.content,
  });

  final String title;
  final String front;
  final String back;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
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
          Wrap(spacing: MxSpace.sm, runSpacing: MxSpace.sm, children: actions),
        ],
      ),
    );
  }
}

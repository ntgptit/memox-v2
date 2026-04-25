import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_icon_button.dart';
import '../../../../../shared/widgets/mx_text.dart';
import '../study_mode_progress_row.dart';
import '../study_mode_session_scaffold.dart';
import 'guess_motion.dart';
import 'guess_option_models.dart';
import 'guess_option_tile.dart';

class GuessModeSessionView extends StatefulWidget {
  const GuessModeSessionView({
    required this.snapshot,
    required this.answerOptions,
    required this.progress,
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final List<StudyFlashcardRef> answerOptions;
  final double progress;
  final bool isSubmitting;
  final Future<bool> Function(AttemptGrade grade) onSubmit;

  @override
  State<GuessModeSessionView> createState() => _GuessModeSessionViewState();
}

class _GuessModeSessionViewState extends State<GuessModeSessionView> {
  String? _selectedOptionId;
  bool _isResolving = false;
  bool _hasSubmitted = false;

  @override
  void didUpdateWidget(covariant GuessModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot.currentItem?.id != widget.snapshot.currentItem?.id) {
      _resetSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.snapshot.currentItem;
    final progress = widget.progress.clamp(0, 1).toDouble();
    final percent = (progress * 100).round();
    if (item == null) {
      return StudyModeSessionScaffold(
        title: l10n.studyModeGuess,
        child: const SizedBox.shrink(),
      );
    }

    return StudyModeSessionScaffold(
      title: l10n.studyModeGuess,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudyModeProgressRow(
            value: progress,
            label: l10n.commonPercentValue(percent),
          ),
          const MxGap(MxSpace.md),
          Expanded(flex: 2, child: _GuessTargetCard(item: item)),
          const MxGap(MxSpace.md),
          Expanded(
            flex: 5,
            child: _GuessOptionsList(
              options: _options,
              isLocked: _isLocked,
              optionStateFor: _optionState,
              onOptionTap: _handleOptionTap,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isLocked => widget.isSubmitting || _isResolving || _hasSubmitted;

  List<StudyFlashcardRef> get _options {
    final item = widget.snapshot.currentItem;
    if (item == null) {
      return const <StudyFlashcardRef>[];
    }
    final hasCurrent = widget.answerOptions.any(
      (option) => option.id == item.flashcard.id,
    );
    if (hasCurrent) {
      return widget.answerOptions;
    }
    return [item.flashcard, ...widget.answerOptions];
  }

  GuessOptionState _optionState(StudyFlashcardRef option) {
    final selectedOptionId = _selectedOptionId;
    if (selectedOptionId == null) {
      return GuessOptionState.idle;
    }
    final correctOptionId = widget.snapshot.currentItem?.flashcard.id;
    if (option.id == correctOptionId) {
      return GuessOptionState.success;
    }
    if (option.id == selectedOptionId) {
      return GuessOptionState.error;
    }
    return GuessOptionState.idle;
  }

  void _handleOptionTap(StudyFlashcardRef option) {
    if (_isLocked) {
      return;
    }
    final current = widget.snapshot.currentItem;
    if (current == null) {
      return;
    }
    final grade = option.id == current.flashcard.id
        ? AttemptGrade.correct
        : AttemptGrade.incorrect;
    setState(() {
      _selectedOptionId = option.id;
      _isResolving = true;
      _hasSubmitted = true;
    });
    unawaited(_submitAfterFeedback(grade));
  }

  Future<void> _submitAfterFeedback(AttemptGrade grade) async {
    await Future<void>.delayed(guessFeedbackDelay);
    if (!mounted) {
      return;
    }
    final success = await widget.onSubmit(grade);
    if (!mounted || success) {
      return;
    }
    setState(_resetSelection);
  }

  void _resetSelection() {
    _selectedOptionId = null;
    _isResolving = false;
    _hasSubmitted = false;
  }
}

class _GuessOptionsList extends StatelessWidget {
  const _GuessOptionsList({
    required this.options,
    required this.isLocked,
    required this.optionStateFor,
    required this.onOptionTap,
  });

  final List<StudyFlashcardRef> options;
  final bool isLocked;
  final GuessOptionState Function(StudyFlashcardRef option) optionStateFor;
  final ValueChanged<StudyFlashcardRef> onOptionTap;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final gapTotal = MxSpace.sm * (options.length - 1);
        final optionExtent =
            (constraints.maxHeight - gapTotal) / options.length;
        return ListView.builder(
          key: const ValueKey<String>('guess-options-list'),
          padding: EdgeInsets.zero,
          itemCount: _childCount(options.length),
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return const MxGap(MxSpace.sm);
            }
            final option = options[index ~/ 2];
            return SizedBox(
              height: optionExtent,
              child: GuessOptionTile(
                key: ValueKey<String>('guess-option-${option.id}'),
                option: option,
                state: optionStateFor(option),
                enabled: !isLocked,
                onTap: () => onOptionTap(option),
              ),
            );
          },
        );
      },
    );
  }

  int _childCount(int optionCount) => optionCount + optionCount - 1;
}

class _GuessTargetCard extends StatelessWidget {
  const _GuessTargetCard({required this.item});

  final StudySessionItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.all(MxSpace.sm),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MxSpace.lg),
              child: MxText(
                item.flashcard.front,
                role: MxTextRole.guessPrompt,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: MxIconButton(
              tooltip: l10n.studyEditCardTooltip,
              icon: Icons.mode_edit_outline,
              onPressed: null,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: MxIconButton(
              tooltip: l10n.studyCardAudioTooltip,
              icon: Icons.volume_up_outlined,
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }
}

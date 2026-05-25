import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/study_session_round.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

import '../study_mode_session_scaffold.dart';
import '../study_speak_button.dart';
import 'recall_motion.dart';

class RecallModeSessionView extends StatefulWidget {
  const RecallModeSessionView({
    required this.snapshot,
    required this.isSubmitting,
    required this.canCancel,
    required this.onSubmit,
    required this.onCancel,
    required this.onBack,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final bool canCancel;
  final Future<bool> Function(Map<String, AttemptGrade> itemGrades) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onBack;

  @override
  State<RecallModeSessionView> createState() => _RecallModeSessionViewState();
}

enum _RecallAnswerState { hidden, revealed, timedOut }

class _RecallModeSessionViewState extends State<RecallModeSessionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timerController;

  String? _roundKey;
  int _itemIndex = 0;
  Map<String, AttemptGrade> _stagedGrades = const <String, AttemptGrade>{};
  _RecallAnswerState _answerState = _RecallAnswerState.hidden;
  bool _isLocalSubmitting = false;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: recallAnswerTimeoutDuration,
    )..addStatusListener(_handleTimerStatus);
    _resetRound(_roundItems);
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant RecallModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _roundItems;
    final nextRoundKey = modeRoundKey(widget.snapshot, items);
    if (_roundKey != nextRoundKey) {
      _resetRound(items);
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timerController.removeStatusListener(_handleTimerStatus);
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = _currentItem;
    final progress = studyModeProgressFromGrades(
      snapshot: widget.snapshot,
      localGrades: _stagedGrades,
    );

    final totalItems = _roundItems.length;
    final currentOneBased = totalItems == 0
        ? 0
        : (_itemIndex + 1).clamp(0, totalItems);
    return StudyModeSessionScaffold(
      modeLabel: l10n.studyModeRecall,
      accent: MxStudyTopBarAccent.mastery,
      progressValue: progress.value,
      counterLabel: l10n.studyCounterFormat(currentOneBased, totalItems),
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      child: item == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StudyAutoSpeakEffect(
                  triggerKey: 'recall-front:$_itemIndex:${item.id}',
                  text: item.flashcard.front,
                  side: TtsTextSide.front,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _RecallQuestionCard(item: item)),
                      const MxGap(MxSpace.md),
                      Expanded(
                        child: _RecallAnswerCard(
                          answer: item.flashcard.back,
                          isRevealed: _answerState != _RecallAnswerState.hidden,
                        ),
                      ),
                    ],
                  ),
                ),
                const MxGap(MxSpace.lg),
                AnimatedSwitcher(
                  duration: recallRevealTransitionDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: _RecallActionArea(
                    answerState: _answerState,
                    timer: _timerController,
                    isSubmitting: _isBusy,
                    onShowAnswer: _revealAnswer,
                    onForgot: () => _stageAnswer(AttemptGrade.incorrect),
                    onRemembered: () => _stageAnswer(AttemptGrade.correct),
                    onNextAfterTimeout: () =>
                        _stageAnswer(AttemptGrade.incorrect),
                  ),
                ),
              ],
            ),
    );
  }

  bool get _isBusy => widget.isSubmitting || _isLocalSubmitting;

  void _handleTimerStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    if (_answerState != _RecallAnswerState.hidden) return;
    setState(() {
      _answerState = _RecallAnswerState.timedOut;
    });
  }

  void _restartTimer() {
    _timerController.stop();
    _timerController.reset();
    if (_currentItem == null) {
      return;
    }
    unawaited(_timerController.forward());
  }

  void _revealAnswer() {
    if (_isBusy || _answerState != _RecallAnswerState.hidden) {
      return;
    }
    _timerController.stop();
    setState(() {
      _answerState = _RecallAnswerState.revealed;
    });
  }

  Future<void> _stageAnswer(AttemptGrade grade) async {
    if (_isBusy) {
      return;
    }
    final item = _currentItem;
    if (item == null) {
      return;
    }
    final nextGrades = <String, AttemptGrade>{..._stagedGrades, item.id: grade};
    if (!_isLastItem) {
      setState(() {
        _stagedGrades = nextGrades;
        _itemIndex += 1;
        _answerState = _RecallAnswerState.hidden;
      });
      _restartTimer();
      return;
    }
    setState(() {
      _stagedGrades = nextGrades;
      _isLocalSubmitting = true;
    });
    final success = await widget.onSubmit(nextGrades);
    if (!mounted) return;
    if (success) return;
    setState(() {
      _isLocalSubmitting = false;
    });
  }

  List<StudySessionItem> get _roundItems =>
      pendingModeRoundItems(widget.snapshot);

  StudySessionItem? get _currentItem {
    final items = _roundItems;
    if (items.isEmpty) {
      return null;
    }
    return items[_itemIndex.clamp(0, items.length - 1)];
  }

  bool get _isLastItem {
    final items = _roundItems;
    return items.isEmpty || _itemIndex >= items.length - 1;
  }

  void _resetRound(List<StudySessionItem> items) {
    _roundKey = modeRoundKey(widget.snapshot, items);
    _itemIndex = initialModeRoundIndex(snapshot: widget.snapshot, items: items);
    _stagedGrades = const <String, AttemptGrade>{};
    _answerState = _RecallAnswerState.hidden;
    _isLocalSubmitting = false;
  }
}

class _RecallActionArea extends StatelessWidget {
  const _RecallActionArea({
    required this.answerState,
    required this.timer,
    required this.isSubmitting,
    required this.onShowAnswer,
    required this.onForgot,
    required this.onRemembered,
    required this.onNextAfterTimeout,
  });

  final _RecallAnswerState answerState;
  final Animation<double> timer;
  final bool isSubmitting;
  final VoidCallback onShowAnswer;
  final VoidCallback onForgot;
  final VoidCallback onRemembered;
  final VoidCallback onNextAfterTimeout;

  @override
  Widget build(BuildContext context) => switch (answerState) {
    _RecallAnswerState.hidden => _RecallTimerAction(
      key: const ValueKey<String>('recall-hidden-action'),
      timer: timer,
      isSubmitting: isSubmitting,
      onPressed: onShowAnswer,
    ),
    _RecallAnswerState.revealed => _RecallRevealedActions(
      key: const ValueKey<String>('recall-revealed-actions'),
      isSubmitting: isSubmitting,
      onForgot: onForgot,
      onRemembered: onRemembered,
    ),
    _RecallAnswerState.timedOut => _RecallTimedOutAction(
      key: const ValueKey<String>('recall-timeout-action'),
      isSubmitting: isSubmitting,
      onNext: onNextAfterTimeout,
    ),
  };
}

class _RecallTimerAction extends StatelessWidget {
  const _RecallTimerAction({
    required this.timer,
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final Animation<double> timer;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: timer,
      builder: (context, child) {
        final remainingSeconds =
            (recallAnswerTimeoutDuration.inSeconds * (1 - timer.value))
                .ceil()
                .clamp(0, recallAnswerTimeoutDuration.inSeconds)
                .toInt();
        return Center(
          child: MxPrimaryButton(
            label: l10n.studyShowAnswerCountdownAction(remainingSeconds),
            size: MxButtonSize.compact,
            shape: MxPrimaryButtonShape.pill,
            onPressed: isSubmitting ? null : onPressed,
          ),
        );
      },
    );
  }
}

class _RecallQuestionCard extends StatelessWidget {
  const _RecallQuestionCard({required this.item});

  final StudySessionItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey<String>('recall-question-card'),
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.all(MxSpace.sm),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MxSpace.lg),
              child: MxText(
                item.flashcard.front,
                role: MxTextRole.recallFront,
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
            child: StudySpeakButton(
              key: ValueKey<String>('recall-front-speak-${item.flashcard.id}'),
              tooltip: l10n.studyCardAudioTooltip,
              text: item.flashcard.front,
              side: TtsTextSide.front,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecallAnswerCard extends StatelessWidget {
  const _RecallAnswerCard({required this.answer, required this.isRevealed});

  final String answer;
  final bool isRevealed;

  @override
  Widget build(BuildContext context) => MxCard(
    key: const ValueKey<String>('recall-answer-card'),
    variant: MxCardVariant.outlined,
    padding: const EdgeInsets.all(MxSpace.sm),
    child: Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: recallRevealTransitionDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isRevealed
                ? KeyedSubtree(
                    key: ValueKey<String>(
                      'recall-answer-revealed-switch-$answer',
                    ),
                    child: _RecallAnswerContent(
                      key: const ValueKey<String>('recall-answer-revealed'),
                      answer: answer,
                    ),
                  )
                : KeyedSubtree(
                    key: ValueKey<String>(
                      'recall-answer-hidden-switch-$answer',
                    ),
                    child: ImageFiltered(
                      key: const ValueKey<String>('recall-answer-hidden'),
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: _RecallAnswerContent(answer: answer),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

class _RecallAnswerContent extends StatelessWidget {
  const _RecallAnswerContent({required this.answer, super.key});

  final String answer;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: MxText(
        answer,
        role: MxTextRole.recallBack,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ),
  );
}

class _RecallRevealedActions extends StatelessWidget {
  const _RecallRevealedActions({
    required this.isSubmitting,
    required this.onForgot,
    required this.onRemembered,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onForgot;
  final VoidCallback onRemembered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: MxPrimaryButton(
            key: const ValueKey<String>('recall-forgot-action'),
            label: l10n.studyForgotAction,
            size: MxButtonSize.compact,
            shape: MxPrimaryButtonShape.pill,
            tone: MxPrimaryButtonTone.danger,
            fullWidth: true,
            onPressed: isSubmitting ? null : onForgot,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxPrimaryButton(
            key: const ValueKey<String>('recall-remembered-action'),
            label: l10n.studyGotItAction,
            size: MxButtonSize.compact,
            shape: MxPrimaryButtonShape.pill,
            fullWidth: true,
            onPressed: isSubmitting ? null : onRemembered,
          ),
        ),
      ],
    );
  }
}

class _RecallTimedOutAction extends StatelessWidget {
  const _RecallTimedOutAction({
    required this.isSubmitting,
    required this.onNext,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: MxSecondaryButton(
        key: const ValueKey<String>('recall-next-action'),
        label: l10n.studyNextAction,
        trailingIcon: Icons.arrow_forward_rounded,
        size: MxButtonSize.compact,
        variant: MxSecondaryVariant.tonal,
        onPressed: isSubmitting ? null : onNext,
      ),
    );
  }
}

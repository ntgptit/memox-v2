import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../app/router/app_navigation.dart';
import '../../../../../../core/theme/responsive/app_layout.dart';
import '../../../../../../domain/services/tts_service.dart';
import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_content_shell.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_scaffold.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_icon_button.dart';
import '../../../../../shared/widgets/mx_primary_button.dart';
import '../../../../../shared/widgets/mx_secondary_button.dart';
import '../../../../../shared/widgets/mx_text.dart';
import '../study_mode_local_round.dart';
import '../study_mode_progress_row.dart';
import '../study_speak_button.dart';
import 'recall_motion.dart';

class RecallModeSessionView extends StatefulWidget {
  const RecallModeSessionView({
    required this.snapshot,
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final Future<bool> Function(Map<String, AttemptGrade> itemGrades) onSubmit;

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
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = _currentItem;
    final progress = overallStudyProgress(
      snapshot: widget.snapshot,
      localCorrectCount: localCorrectGradeCount(_stagedGrades),
    ).clamp(0, 1).toDouble();
    final percent = (progress * 100).round();

    return MxScaffold(
      title: l10n.studyModeRecall,
      leading: MxIconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onPressed: () => context.popRoute(fallback: context.goLibrary),
      ),
      actions: [
        MxIconButton(
          tooltip: l10n.studyTextSettingsTooltip,
          icon: Icons.text_fields,
          onPressed: null,
        ),
        MxIconButton(
          tooltip: l10n.studyAudioTooltip,
          icon: Icons.volume_up_outlined,
          onPressed: null,
        ),
        MxIconButton(
          tooltip: l10n.studyMoreActionsTooltip,
          icon: Icons.more_vert,
          onPressed: null,
        ),
      ],
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
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
                  StudyModeProgressRow(
                    value: progress,
                    label: l10n.commonPercentValue(percent),
                  ),
                  const MxGap(MxSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _RecallQuestionCard(item: item)),
                        const MxGap(MxSpace.md),
                        Expanded(
                          child: _RecallAnswerCard(
                            answer: item.flashcard.back,
                            isRevealed:
                                _answerState != _RecallAnswerState.hidden,
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
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
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
      ),
    );
  }

  bool get _isBusy => widget.isSubmitting || _isLocalSubmitting;

  void _handleTimerStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed ||
        !mounted ||
        _answerState != _RecallAnswerState.hidden) {
      return;
    }
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
    _timerController.forward();
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
    if (!mounted || success) {
      return;
    }
    setState(() {
      _isLocalSubmitting = false;
    });
  }

  List<StudySessionItem> get _roundItems {
    return pendingModeRoundItems(widget.snapshot);
  }

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
  Widget build(BuildContext context) {
    return switch (answerState) {
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
            size: MxButtonSize.large,
            fullWidth: true,
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
  Widget build(BuildContext context) {
    return MxCard(
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
}

class _RecallAnswerContent extends StatelessWidget {
  const _RecallAnswerContent({required this.answer, super.key});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Center(
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
      children: [
        Expanded(
          child: MxSecondaryButton(
            key: const ValueKey<String>('recall-forgot-action'),
            label: l10n.studyForgotAction,
            leadingIcon: Icons.close_rounded,
            size: MxButtonSize.large,
            tone: MxSecondaryButtonTone.danger,
            fullWidth: true,
            onPressed: isSubmitting ? null : onForgot,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxPrimaryButton(
            key: const ValueKey<String>('recall-remembered-action'),
            label: l10n.studyRememberedAction,
            leadingIcon: Icons.check_rounded,
            size: MxButtonSize.large,
            tone: MxPrimaryButtonTone.success,
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
        size: MxButtonSize.large,
        variant: MxSecondaryVariant.tonal,
        onPressed: isSubmitting ? null : onNext,
      ),
    );
  }
}

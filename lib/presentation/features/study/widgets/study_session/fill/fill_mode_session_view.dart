import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/fill/fill_answer_matcher.dart';
import 'package:memox/domain/study/fill/fill_hint_policy.dart';
import 'package:memox/domain/study/study_session_round.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';

import '../study_mode_session_scaffold.dart';
import 'fill_actions.dart';
import 'fill_answer_cards.dart';
import 'fill_motion.dart';
import 'fill_prompt_card.dart';

class FillModeSessionView extends StatefulWidget {
  const FillModeSessionView({
    required this.snapshot,
    required this.isSubmitting,
    required this.canCancel,
    required this.onSubmit,
    required this.onCancel,
    required this.onBack,
    this.onCardActions,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final bool canCancel;
  final Future<bool> Function(Map<String, AttemptGrade> itemGrades) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final VoidCallback? onCardActions;

  @override
  State<FillModeSessionView> createState() => _FillModeSessionViewState();
}

enum _FillAnswerState { input, incorrect }

class _FillModeSessionViewState extends State<FillModeSessionView> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String? _roundKey;
  int _itemIndex = 0;
  Map<String, AttemptGrade> _stagedGrades = const <String, AttemptGrade>{};
  _FillAnswerState _answerState = _FillAnswerState.input;
  String? _submittedAnswer;
  bool _isLocalSubmitting = false;
  int _hintRevealCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_handleInputChanged);
    _resetRound(_roundItems);
  }

  @override
  void didUpdateWidget(covariant FillModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _roundItems;
    final nextRoundKey = modeRoundKey(widget.snapshot, items);
    if (_roundKey != nextRoundKey) {
      _resetRound(items);
      _focusAnswerInput();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleInputChanged);
    _controller.dispose();
    _focusNode.dispose();
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
    final expectedFront = item?.flashcard.front ?? '';
    final canRevealHint =
        item != null &&
        !_isBusy &&
        FillHintPolicy.canRevealMore(expectedFront, _hintRevealCount);
    return StudyModeSessionScaffold(
      modeLabel: l10n.studyModeFill,
      accent: MxStudyTopBarAccent.mastery,
      progressValue: progress.value,
      counterLabel: l10n.studyCounterFormat(currentOneBased, totalItems),
      resizeToAvoidBottomInset: true,
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      onCardActions: widget.onCardActions,
      child: item == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: FillPromptCard(item: item)),
                      const MxGap(MxSpace.sm),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: fillStateTransitionDuration,
                          switchInCurve: fillStateTransitionCurve,
                          switchOutCurve: fillStateExitCurve,
                          child: _answerState == _FillAnswerState.input
                              ? FillInputCard(
                                  key: const ValueKey<String>(
                                    'fill-input-card',
                                  ),
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  isEnabled: !_isBusy,
                                  canSubmit: _canCheck,
                                  onSubmit: _checkAnswer,
                                )
                              : FillIncorrectCard(
                                  key: const ValueKey<String>(
                                    'fill-result-card',
                                  ),
                                  submittedAnswer: _submittedAnswerForDisplay(
                                    context,
                                  ),
                                  correctAnswer: item.flashcard.front,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const MxGap(MxSpace.md),
                _buildActions(canRevealHint: canRevealHint),
              ],
            ),
    );
  }

  Widget _buildActions({required bool canRevealHint}) => AnimatedSwitcher(
    duration: fillStateTransitionDuration,
    switchInCurve: fillStateTransitionCurve,
    switchOutCurve: fillStateExitCurve,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: child,
      ),
    ),
    child: _answerState == _FillAnswerState.input
        ? FillInputActions(
            key: const ValueKey<String>('fill-input-actions'),
            canCheck: _canCheck,
            isSubmitting: _isBusy,
            canHint: canRevealHint,
            onHelp: _revealHint,
            onCheck: _checkAnswer,
          )
        : FillResultActions(
            key: const ValueKey<String>('fill-result-actions'),
            isSubmitting: _isBusy,
            onMarkCorrect: () => _submit(AttemptGrade.correct),
            onTryAgain: _tryAgain,
          ),
  );

  bool get _isBusy => widget.isSubmitting || _isLocalSubmitting;

  bool get _canCheck => !_isBusy && StringUtils.isNotBlank(_controller.text);

  void _handleInputChanged() {
    if (!mounted) return;
    if (_answerState != _FillAnswerState.input) return;
    setState(() {});
  }

  void _checkAnswer() {
    if (!_canCheck) {
      return;
    }
    final current = _currentItem;
    if (current == null) {
      return;
    }
    final evaluation = FillAnswerMatcher.evaluate(
      _controller.text,
      current.flashcard.front,
    );
    if (evaluation.isExactMatch) {
      _focusNode.unfocus();
      unawaited(_submit(AttemptGrade.correct));
      return;
    }
    _focusNode.unfocus();
    setState(() {
      _submittedAnswer = evaluation.userAnswer;
      _answerState = _FillAnswerState.incorrect;
    });
  }

  void _tryAgain() {
    if (_isBusy) {
      return;
    }
    setState(() {
      _submittedAnswer = null;
      _answerState = _FillAnswerState.input;
      _controller.clear();
    });
    _focusAnswerInput();
  }

  void _revealHint() {
    if (_isBusy) return;
    final item = _currentItem;
    if (item == null) return;
    final expected = item.flashcard.front;
    if (!FillHintPolicy.canRevealMore(expected, _hintRevealCount)) {
      return;
    }
    final nextCount = FillHintPolicy.nextRevealCount(
      expected,
      _hintRevealCount,
    );
    if (nextCount == _hintRevealCount) return;
    final revealed = FillHintPolicy.revealedPrefix(expected, nextCount);
    setState(() {
      _hintRevealCount = nextCount;
      _controller.value = TextEditingValue(
        text: revealed,
        selection: TextSelection.collapsed(offset: revealed.length),
      );
    });
  }

  Future<void> _submit(AttemptGrade grade) async {
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
        _resetInputState();
      });
      _focusAnswerInput();
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
    _resetInputState();
  }

  void _resetInputState() {
    _controller.clear();
    _submittedAnswer = null;
    _answerState = _FillAnswerState.input;
    _isLocalSubmitting = false;
    _hintRevealCount = 0;
  }

  void _focusAnswerInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_answerState != _FillAnswerState.input) return;
      _focusNode.requestFocus();
    });
  }

  String _submittedAnswerForDisplay(BuildContext context) {
    final answer = _submittedAnswer;
    if (answer != null && answer.isNotEmpty) {
      return answer;
    }
    return AppLocalizations.of(context).studyFillNoAnswerLabel;
  }
}

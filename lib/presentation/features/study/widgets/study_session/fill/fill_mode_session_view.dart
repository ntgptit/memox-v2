import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../core/utils/string_utils.dart';
import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../study_mode_local_round.dart';
import '../study_mode_progress_row.dart';
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
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final bool canCancel;
  final Future<bool> Function(Map<String, AttemptGrade> itemGrades) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onBack;

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
    final progress = overallStudyProgress(
      snapshot: widget.snapshot,
      localCorrectCount: localCorrectGradeCount(_stagedGrades),
    ).clamp(0, 1).toDouble();
    final percent = (progress * 100).round();

    return StudyModeSessionScaffold(
      title: l10n.studyModeFill,
      resizeToAvoidBottomInset: true,
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      child: item == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StudyModeProgressRow(
                  value: progress,
                  label: l10n.commonPercentValue(percent),
                ),
                const MxGap(MxSpace.md),
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
                AnimatedSwitcher(
                  duration: fillStateTransitionDuration,
                  switchInCurve: fillStateTransitionCurve,
                  switchOutCurve: fillStateExitCurve,
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
                  child: _answerState == _FillAnswerState.input
                      ? FillInputActions(
                          key: const ValueKey<String>('fill-input-actions'),
                          canCheck: _canCheck,
                          isSubmitting: _isBusy,
                          onHelp: _showHelp,
                          onCheck: _checkAnswer,
                        )
                      : FillResultActions(
                          key: const ValueKey<String>('fill-result-actions'),
                          isSubmitting: _isBusy,
                          onNext: () => _submit(AttemptGrade.incorrect),
                        ),
                ),
              ],
            ),
    );
  }

  bool get _isBusy => widget.isSubmitting || _isLocalSubmitting;

  bool get _canCheck => !_isBusy && StringUtils.isNotBlank(_controller.text);

  void _handleInputChanged() {
    if (!mounted || _answerState != _FillAnswerState.input) {
      return;
    }
    setState(() {});
  }

  void _checkAnswer() {
    if (!_canCheck) {
      return;
    }
    final answer = StringUtils.trimmed(_controller.text);
    final current = _currentItem;
    if (current == null) {
      return;
    }
    if (StringUtils.equalsNormalized(answer, current.flashcard.front)) {
      _focusNode.unfocus();
      _submit(AttemptGrade.correct);
      return;
    }
    _focusNode.unfocus();
    setState(() {
      _submittedAnswer = answer;
      _answerState = _FillAnswerState.incorrect;
    });
  }

  void _showHelp() {
    if (_isBusy) {
      return;
    }
    final item = _currentItem;
    if (item == null) {
      return;
    }
    _focusNode.unfocus();
    setState(() {
      _stagedGrades = <String, AttemptGrade>{
        ..._stagedGrades,
        item.id: AttemptGrade.incorrect,
      };
      _submittedAnswer = null;
      _answerState = _FillAnswerState.incorrect;
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
    _resetInputState();
  }

  void _resetInputState() {
    _controller.clear();
    _submittedAnswer = null;
    _answerState = _FillAnswerState.input;
    _isLocalSubmitting = false;
  }

  void _focusAnswerInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _answerState != _FillAnswerState.input) {
        return;
      }
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

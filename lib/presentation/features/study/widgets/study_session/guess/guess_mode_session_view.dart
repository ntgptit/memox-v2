import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/services/tts_service.dart';
import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_icon_button.dart';
import '../../../../../shared/widgets/mx_text.dart';
import '../study_mode_local_round.dart';
import '../study_mode_progress_row.dart';
import '../study_mode_session_scaffold.dart';
import '../study_speak_button.dart';
import 'guess_motion.dart';
import 'guess_option_models.dart';
import 'guess_option_tile.dart';

const _guessTermFlex = 54;
const _guessOptionsFlex = 71;

class GuessModeSessionView extends StatefulWidget {
  const GuessModeSessionView({
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
  State<GuessModeSessionView> createState() => _GuessModeSessionViewState();
}

class _GuessModeSessionViewState extends State<GuessModeSessionView> {
  String? _roundKey;
  int _itemIndex = 0;
  Map<String, AttemptGrade> _stagedGrades = const <String, AttemptGrade>{};
  String? _selectedOptionId;
  bool _isResolving = false;
  bool _hasSubmitted = false;
  bool _isLocalSubmitting = false;

  @override
  void initState() {
    super.initState();
    _resetRound(_roundItems);
  }

  @override
  void didUpdateWidget(covariant GuessModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _roundItems;
    final nextRoundKey = modeRoundKey(widget.snapshot, items);
    if (_roundKey != nextRoundKey) {
      _resetRound(items);
    }
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
    if (item == null) {
      return StudyModeSessionScaffold(
        title: l10n.studyModeGuess,
        canCancel: widget.canCancel,
        isActionBusy: widget.isSubmitting,
        onCancel: widget.onCancel,
        onBack: widget.onBack,
        child: const SizedBox.shrink(),
      );
    }

    return StudyModeSessionScaffold(
      title: l10n.studyModeGuess,
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudyAutoSpeakEffect(
            triggerKey: 'guess:$_itemIndex:${item.id}',
            text: item.flashcard.front,
            side: TtsTextSide.front,
          ),
          StudyModeProgressRow(
            value: progress,
            label: l10n.commonPercentValue(percent),
          ),
          const MxGap(MxSpace.md),
          Expanded(
            flex: _guessTermFlex,
            child: _GuessTargetCard(item: item),
          ),
          const MxGap(MxSpace.md),
          Expanded(
            flex: _guessOptionsFlex,
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

  bool get _isLocked =>
      widget.isSubmitting ||
      _isResolving ||
      _hasSubmitted ||
      _isLocalSubmitting;

  List<StudyFlashcardRef> get _options {
    final item = _currentItem;
    if (item == null) {
      return const <StudyFlashcardRef>[];
    }
    final distractors = widget.snapshot.sessionFlashcards
        .where((flashcard) => flashcard.id != item.flashcard.id)
        .toList(growable: true);
    distractors.shuffle(
      math.Random(
        _stableSeed(
          '${widget.snapshot.session.id}:${item.id}:${item.studyMode.storageValue}:${item.flashcard.id}',
        ),
      ),
    );
    final optionIds = <String>{
      item.flashcard.id,
      for (final distractor in distractors.take(4)) distractor.id,
    };
    final options = widget.snapshot.sessionFlashcards
        .where((flashcard) => optionIds.contains(flashcard.id))
        .toList(growable: true);
    if (!widget.snapshot.session.settings.shuffleAnswers) {
      return options;
    }
    options.shuffle(
      math.Random(
        _stableSeed(
          '${item.id}:${item.flashcard.id}:${widget.snapshot.session.settings.shuffleAnswers}',
        ),
      ),
    );
    return options;
  }

  GuessOptionState _optionState(StudyFlashcardRef option) {
    final selectedOptionId = _selectedOptionId;
    if (selectedOptionId == null) {
      return GuessOptionState.idle;
    }
    final correctOptionId = _currentItem?.flashcard.id;
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
    final current = _currentItem;
    if (current == null) {
      return;
    }
    final grade = option.id == current.flashcard.id
        ? AttemptGrade.correct
        : AttemptGrade.incorrect;
    setState(() {
      _selectedOptionId = option.id;
      _isResolving = true;
    });
    unawaited(_stageAfterFeedback(current, grade));
  }

  Future<void> _stageAfterFeedback(
    StudySessionItem item,
    AttemptGrade grade,
  ) async {
    await Future<void>.delayed(guessFeedbackDelay);
    if (!mounted) {
      return;
    }
    final nextGrades = <String, AttemptGrade>{..._stagedGrades, item.id: grade};
    if (!_isLastItem) {
      setState(() {
        _stagedGrades = nextGrades;
        _itemIndex += 1;
        _resetSelection();
      });
      return;
    }

    setState(() {
      _stagedGrades = nextGrades;
      _isResolving = false;
      _isLocalSubmitting = true;
      _hasSubmitted = true;
    });
    final success = await widget.onSubmit(nextGrades);
    if (!mounted || success) {
      return;
    }
    setState(() {
      _isLocalSubmitting = false;
      _hasSubmitted = false;
      _resetSelection();
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
    _selectedOptionId = null;
    _isResolving = false;
    _hasSubmitted = false;
    _isLocalSubmitting = false;
  }

  void _resetSelection() {
    _selectedOptionId = null;
    _isResolving = false;
  }
}

int _stableSeed(String raw) {
  var hash = 0;
  for (final codeUnit in raw.codeUnits) {
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  return hash;
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
      key: const ValueKey<String>('guess-target-card'),
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
            child: StudySpeakButton(
              key: ValueKey<String>('guess-front-speak-${item.flashcard.id}'),
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

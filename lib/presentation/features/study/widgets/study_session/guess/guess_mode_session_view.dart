import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/study_session_round.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_progress_indicator.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

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
    final progress = studyModeProgressFromGrades(
      snapshot: widget.snapshot,
      localGrades: _stagedGrades,
    );
    final totalItems = _roundItems.length;
    final currentOneBased = totalItems == 0
        ? 0
        : (_itemIndex + 1).clamp(0, totalItems);
    if (item == null) {
      return StudyModeSessionScaffold(
        modeLabel: l10n.studyModeGuess,
        accent: MxStudyTopBarAccent.primary,
        progressValue: progress.value,
        counterLabel: l10n.studyCounterFormat(currentOneBased, totalItems),
        canCancel: widget.canCancel,
        isActionBusy: widget.isSubmitting,
        onCancel: widget.onCancel,
        onBack: widget.onBack,
        onCardActions: widget.onCardActions,
        child: const SizedBox.shrink(),
      );
    }

    return StudyModeSessionScaffold(
      modeLabel: l10n.studyModeGuess,
      accent: MxStudyTopBarAccent.primary,
      progressValue: progress.value,
      counterLabel: l10n.studyCounterFormat(currentOneBased, totalItems),
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      onCardActions: widget.onCardActions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudyAutoSpeakEffect(
            triggerKey: 'guess:$_itemIndex:${item.id}',
            text: item.flashcard.front,
            side: TtsTextSide.front,
          ),
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
          _GuessAutoAdvanceFooter(isVisible: _isResolving),
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
    if (!mounted) return;
    if (success) return;
    setState(() {
      _isLocalSubmitting = false;
      _hasSubmitted = false;
      _resetSelection();
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
            final optionIndex = index ~/ 2;
            return SizedBox(
              height: optionExtent,
              child: GuessOptionTile(
                key: ValueKey<String>('guess-option-${option.id}'),
                option: option,
                state: optionStateFor(option),
                enabled: !isLocked,
                letter: _letterFor(optionIndex),
                onTap: () => onOptionTap(option),
              ),
            );
          },
        );
      },
    );
  }

  int _childCount(int optionCount) => optionCount + optionCount - 1;

  String _letterFor(int index) {
    const codeA = 65;
    return String.fromCharCode(codeA + index);
  }
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
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.xl,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: MxText(
              StringUtils.uppercased(l10n.studyGuessPromptLabel),
              role: MxTextRole.overline,
            ),
          ),
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

class _GuessAutoAdvanceFooter extends StatelessWidget {
  const _GuessAutoAdvanceFooter({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final seconds = (guessFeedbackDelay.inMilliseconds / 1000).toStringAsFixed(
      1,
    );
    return Padding(
      padding: const EdgeInsets.only(top: MxSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: MxText(
              l10n.studyGuessAutoAdvanceLabel(seconds),
              role: MxTextRole.overline,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const MxGap(MxSpace.xs),
          TweenAnimationBuilder<double>(
            key: const ValueKey<String>('guess-auto-advance-progress'),
            tween: Tween<double>(begin: 0, end: 1),
            duration: guessFeedbackDelay,
            curve: Curves.linear,
            builder: (context, value, _) =>
                MxLinearProgress(value: value, size: MxProgressSize.small),
          ),
        ],
      ),
    );
  }
}

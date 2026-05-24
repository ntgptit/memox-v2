import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/study_session_round.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

import '../study_mode_session_scaffold.dart';
import 'match_batching.dart';
import 'match_board.dart';
import 'match_motion.dart';
import 'match_seed.dart';
import 'match_tile_models.dart';

class MatchModeSessionView extends StatefulWidget {
  const MatchModeSessionView({
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
  State<MatchModeSessionView> createState() => _MatchModeSessionViewState();
}

class _MatchModeSessionViewState extends State<MatchModeSessionView> {
  String? _boardKey;
  List<String> _rightOrderItemIds = const <String>[];
  Set<String> _matchedItemIds = <String>{};
  Set<String> _successItemIds = <String>{};
  Set<String> _failedItemIds = <String>{};
  String? _selectedLeftItemId;
  String? _selectedRightItemId;
  String? _errorLeftItemId;
  String? _errorRightItemId;
  int _visibleBatchStartIndex = 0;
  bool _isResolving = false;
  bool _hasSubmitted = false;
  DateTime? _boardStartedAt;
  Timer? _elapsedTicker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _resetBoard(_roundItems);
    _startElapsedTicker();
  }

  @override
  void didUpdateWidget(covariant MatchModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _roundItems;
    final nextBoardKey = _computeBoardKey(items);
    if (_boardKey != nextBoardKey) {
      _resetBoard(items);
      _startElapsedTicker();
    }
  }

  @override
  void dispose() {
    _elapsedTicker?.cancel();
    super.dispose();
  }

  void _startElapsedTicker() {
    _elapsedTicker?.cancel();
    _boardStartedAt = DateTime.now();
    _elapsed = Duration.zero;
    _elapsedTicker = Timer.periodic(matchTimerTickDuration, (_) {
      if (!mounted) {
        return;
      }
      final startedAt = _boardStartedAt;
      if (startedAt == null) {
        return;
      }
      setState(() {
        _elapsed = DateTime.now().difference(startedAt);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roundItems = _roundItems;
    final visibleItems = visibleMatchBatch(roundItems, _visibleBatchStartIndex);
    final progress = studyModeProgress(
      snapshot: widget.snapshot,
      localCorrectCount: _localCorrectMatchCount,
    );
    final totalPairs = roundItems.length;
    final pairsMatched = _matchedItemIds.length;
    final pairsLeftInBatch = visibleItems
        .where((item) => !_matchedItemIds.contains(item.id))
        .length;
    final totalBoards = totalPairs == 0
        ? 1
        : ((totalPairs + matchVisiblePairLimit - 1) ~/ matchVisiblePairLimit);
    final boardNumber =
        (_visibleBatchStartIndex ~/ matchVisiblePairLimit) + 1;
    final mistakes = _failedItemIds.length;

    return StudyModeSessionScaffold(
      modeLabel: l10n.studyModeMatch,
      accent: MxStudyTopBarAccent.primary,
      progressValue: progress.value,
      counterLabel: l10n.studyCounterFormat(pairsMatched, totalPairs),
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MatchBoardStatusHeader(
            boardNumber: boardNumber,
            totalBoards: totalBoards,
            pairsLeft: pairsLeftInBatch,
          ),
          const MxGap(MxSpace.sm),
          Expanded(
            child: MatchBoard(
              leftItems: visibleItems,
              rightItems: _rightItems(visibleItems),
              isLocked: widget.isSubmitting || _isResolving || _hasSubmitted,
              tileStateFor: _tileStateFor,
              onTileTap: _handleTileTap,
            ),
          ),
          const MxGap(MxSpace.sm),
          _MatchFooter(elapsed: _elapsed, mistakes: mistakes),
        ],
      ),
    );
  }

  List<StudySessionItem> get _roundItems {
    final items = widget.snapshot.currentRoundItems
        .where((item) => item.status == SessionItemStatus.pending)
        .toList(growable: true);
    if (items.isEmpty) {
      final currentItem = widget.snapshot.currentItem;
      if (currentItem == null) {
        return const <StudySessionItem>[];
      }
      items.add(currentItem);
    }
    items.sort(
      (left, right) => left.queuePosition.compareTo(right.queuePosition),
    );
    return items;
  }

  double get _localCorrectMatchCount => _matchedItemIds
        .where((itemId) => !_failedItemIds.contains(itemId))
        .length
        .toDouble();

  List<StudySessionItem> _rightItems(List<StudySessionItem> roundItems) {
    final itemById = <String, StudySessionItem>{
      for (final item in roundItems) item.id: item,
    };
    return [
      for (final itemId in _rightOrderItemIds)
        if (itemById[itemId] != null) itemById[itemId]!,
    ];
  }

  void _resetBoard(List<StudySessionItem> roundItems) {
    _boardKey = _computeBoardKey(roundItems);
    _rightOrderItemIds = _buildRightOrder(roundItems);
    _matchedItemIds = <String>{};
    _successItemIds = <String>{};
    _failedItemIds = <String>{};
    _selectedLeftItemId = null;
    _selectedRightItemId = null;
    _errorLeftItemId = null;
    _errorRightItemId = null;
    _visibleBatchStartIndex = 0;
    _isResolving = false;
    _hasSubmitted = false;
  }

  String _computeBoardKey(List<StudySessionItem> items) {
    final currentItem = widget.snapshot.currentItem;
    return [
      widget.snapshot.session.id,
      currentItem?.modeOrder,
      currentItem?.roundIndex,
      for (final item in items) item.id,
    ].join(':');
  }

  List<String> _buildRightOrder(List<StudySessionItem> items) {
    final ids = items.map((item) => item.id).toList(growable: true);
    if (!widget.snapshot.session.settings.shuffleAnswers || ids.length < 2) {
      return ids;
    }
    ids.shuffle(
      math.Random(
        stableMatchSeed(
          'match:${widget.snapshot.session.id}:${widget.snapshot.currentItem?.modeOrder}:${widget.snapshot.currentItem?.roundIndex}:${ids.join(',')}',
        ),
      ),
    );
    return ids;
  }

  MatchTileState _tileStateFor(MatchTileSide side, StudySessionItem item) {
    if (side == MatchTileSide.left && _errorLeftItemId == item.id) {
      return MatchTileState.error;
    }
    if (side == MatchTileSide.right && _errorRightItemId == item.id) {
      return MatchTileState.error;
    }
    if (_successItemIds.contains(item.id)) {
      return MatchTileState.success;
    }
    if (_matchedItemIds.contains(item.id)) {
      return MatchTileState.matched;
    }
    if (side == MatchTileSide.left && _selectedLeftItemId == item.id) {
      return MatchTileState.selected;
    }
    if (side == MatchTileSide.right && _selectedRightItemId == item.id) {
      return MatchTileState.selected;
    }
    return MatchTileState.idle;
  }

  void _handleTileTap(MatchTileSide side, StudySessionItem item) {
    if (widget.isSubmitting ||
        _isResolving ||
        _hasSubmitted ||
        _matchedItemIds.contains(item.id)) {
      return;
    }

    if (side == MatchTileSide.left) {
      final selectedRightItemId = _selectedRightItemId;
      setState(() {
        _selectedLeftItemId = item.id;
      });
      if (selectedRightItemId != null) {
        unawaited(_resolveSelection(item.id, selectedRightItemId));
      }
      return;
    }

    final selectedLeftItemId = _selectedLeftItemId;
    setState(() {
      _selectedRightItemId = item.id;
    });
    if (selectedLeftItemId != null) {
      unawaited(_resolveSelection(selectedLeftItemId, item.id));
    }
  }

  Future<void> _resolveSelection(String leftItemId, String rightItemId) async {
    if (leftItemId == rightItemId) {
      setState(() {
        _selectedLeftItemId = null;
        _selectedRightItemId = null;
        _matchedItemIds = <String>{..._matchedItemIds, leftItemId};
        _successItemIds = <String>{..._successItemIds, leftItemId};
      });
      unawaited(_settleMatchedPair(leftItemId));
      return;
    }

    setState(() {
      _failedItemIds = <String>{..._failedItemIds, leftItemId};
      _errorLeftItemId = leftItemId;
      _errorRightItemId = rightItemId;
      _isResolving = true;
    });
    await Future<void>.delayed(matchResolveDelay);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLeftItemId = null;
      _selectedRightItemId = null;
      _errorLeftItemId = null;
      _errorRightItemId = null;
      _isResolving = false;
    });
  }

  void _advanceBatchOrSubmitIfComplete() {
    final roundItems = _roundItems;
    if (_hasSubmitted ||
        roundItems.isEmpty ||
        _successItemIds.isNotEmpty ||
        _matchedItemIds.length != roundItems.length) {
      _advanceVisibleBatchIfComplete(roundItems);
      return;
    }
    _hasSubmitted = true;
    final itemGrades = <String, AttemptGrade>{
      for (final item in roundItems)
        item.id: _failedItemIds.contains(item.id)
            ? AttemptGrade.incorrect
            : AttemptGrade.correct,
    };
    unawaited(_submitAfterAnimation(itemGrades));
  }

  Future<void> _settleMatchedPair(String itemId) async {
    await Future<void>.delayed(matchSuccessHoldDuration);
    if (!mounted) return;
    if (!_successItemIds.contains(itemId)) return;
    setState(() {
      _successItemIds = <String>{..._successItemIds}..remove(itemId);
    });
    await Future<void>.delayed(matchFadeDuration);
    if (!mounted) {
      return;
    }
    _advanceBatchOrSubmitIfComplete();
  }

  void _advanceVisibleBatchIfComplete(List<StudySessionItem> roundItems) {
    final visibleItems = visibleMatchBatch(roundItems, _visibleBatchStartIndex);
    if (_successItemIds.isNotEmpty) {
      return;
    }
    if (!isVisibleMatchBatchComplete(
      visibleItems: visibleItems,
      matchedItemIds: _matchedItemIds,
    )) {
      return;
    }
    setState(() {
      _visibleBatchStartIndex = nextVisibleMatchBatchStart(
        items: _roundItems,
        matchedItemIds: _matchedItemIds,
      );
    });
  }

  Future<void> _submitAfterAnimation(
    Map<String, AttemptGrade> itemGrades,
  ) async {
    if (!mounted) {
      return;
    }
    await widget.onSubmit(itemGrades);
  }
}

class _MatchBoardStatusHeader extends StatelessWidget {
  const _MatchBoardStatusHeader({
    required this.boardNumber,
    required this.totalBoards,
    required this.pairsLeft,
  });

  final int boardNumber;
  final int totalBoards;
  final int pairsLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: MxText(
        l10n.studyMatchBoardStatus(boardNumber, totalBoards, pairsLeft),
        role: MxTextRole.overline,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _MatchFooter extends StatelessWidget {
  const _MatchFooter({required this.elapsed, required this.mistakes});

  final Duration elapsed;
  final int mistakes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final timerLabel = '$minutes:$seconds';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: scheme.onSurfaceVariant,
            ),
            const MxGap(MxSpace.xs),
            MxText(
              timerLabel,
              role: MxTextRole.studyProgress,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
        MxText(
          l10n.studyMatchMistakesLabel(mistakes),
          role: MxTextRole.studyProgress,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

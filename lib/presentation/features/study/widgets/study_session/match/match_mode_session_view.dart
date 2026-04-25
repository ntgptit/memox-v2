import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../study_mode_progress_row.dart';
import '../study_mode_session_scaffold.dart';
import 'match_board.dart';
import 'match_motion.dart';
import 'match_seed.dart';
import 'match_tile_models.dart';

class MatchModeSessionView extends StatefulWidget {
  const MatchModeSessionView({
    required this.snapshot,
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final Future<bool> Function(Map<String, AttemptGrade> itemGrades) onSubmit;

  @override
  State<MatchModeSessionView> createState() => _MatchModeSessionViewState();
}

class _MatchModeSessionViewState extends State<MatchModeSessionView> {
  String? _boardKey;
  List<String> _rightOrderItemIds = const <String>[];
  Set<String> _matchedItemIds = <String>{};
  Set<String> _failedItemIds = <String>{};
  String? _selectedLeftItemId;
  String? _selectedRightItemId;
  String? _errorLeftItemId;
  String? _errorRightItemId;
  bool _isResolving = false;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _resetBoard(_roundItems);
  }

  @override
  void didUpdateWidget(covariant MatchModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _roundItems;
    final nextBoardKey = _computeBoardKey(items);
    if (_boardKey != nextBoardKey) {
      _resetBoard(items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roundItems = _roundItems;
    final progress = _matchProgress(roundItems.length);
    final percent = (progress * 100).round();

    return StudyModeSessionScaffold(
      title: l10n.studyModeMatch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudyModeProgressRow(
            value: progress,
            label: l10n.commonPercentValue(percent),
          ),
          const MxGap(MxSpace.md),
          Expanded(
            child: MatchBoard(
              leftItems: roundItems,
              rightItems: _rightItems(roundItems),
              isLocked: widget.isSubmitting || _isResolving || _hasSubmitted,
              tileStateFor: _tileStateFor,
              onTileTap: _handleTileTap,
            ),
          ),
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
    _failedItemIds = <String>{};
    _selectedLeftItemId = null;
    _selectedRightItemId = null;
    _errorLeftItemId = null;
    _errorRightItemId = null;
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

  double _matchProgress(int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }
    return _matchedItemIds.length / itemCount;
  }

  MatchTileState _tileStateFor(MatchTileSide side, StudySessionItem item) {
    if (side == MatchTileSide.left && _errorLeftItemId == item.id) {
      return MatchTileState.error;
    }
    if (side == MatchTileSide.right && _errorRightItemId == item.id) {
      return MatchTileState.error;
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
      });
      _submitIfComplete();
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

  void _submitIfComplete() {
    final roundItems = _roundItems;
    if (_hasSubmitted ||
        roundItems.isEmpty ||
        _matchedItemIds.length != roundItems.length) {
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

  Future<void> _submitAfterAnimation(
    Map<String, AttemptGrade> itemGrades,
  ) async {
    await Future<void>.delayed(matchResolveDelay);
    if (!mounted) {
      return;
    }
    await widget.onSubmit(itemGrades);
  }
}

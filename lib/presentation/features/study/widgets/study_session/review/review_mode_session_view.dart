import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_text.dart';
import '../study_mode_progress_row.dart';
import '../study_mode_session_scaffold.dart';
import 'review_mode_card.dart';
import 'review_page_scroll_behavior.dart';

const _reviewPointerScrollThreshold = 20.0;
const _reviewPageTurnDuration = Duration(milliseconds: 250);

class ReviewModeSessionView extends StatefulWidget {
  const ReviewModeSessionView({
    required this.snapshot,
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final Future<bool> Function() onSubmit;

  @override
  State<ReviewModeSessionView> createState() => _ReviewModeSessionViewState();
}

class _ReviewModeSessionViewState extends State<ReviewModeSessionView> {
  late PageController _pageController;
  late int _pageIndex;
  Timer? _autoSubmitTimer;
  bool _hasSubmitted = false;
  bool _isPagingFromPointerSignal = false;

  @override
  void initState() {
    super.initState();
    _pageIndex = _initialPageIndex(widget.snapshot);
    _pageController = PageController(initialPage: _pageIndex);
    _scheduleAutoSubmitIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ReviewModeSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldResetPages(oldWidget.snapshot, widget.snapshot)) {
      _autoSubmitTimer?.cancel();
      _hasSubmitted = false;
      _pageController.dispose();
      _pageIndex = _initialPageIndex(widget.snapshot);
      _pageController = PageController(initialPage: _pageIndex);
    }
    _scheduleAutoSubmitIfNeeded();
  }

  @override
  void dispose() {
    _autoSubmitTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = _reviewCards;
    final progress = _reviewProgress(cards.length);
    final percent = (progress * 100).round();

    return StudyModeSessionScaffold(
      title: l10n.studyModeReview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudyModeProgressRow(
            value: progress,
            label: l10n.studyReviewProgressPercent(percent),
          ),
          const MxGap(MxSpace.md),
          Expanded(
            child: Listener(
              onPointerSignal: _handlePointerSignal,
              child: ScrollConfiguration(
                behavior: const ReviewPageScrollBehavior(),
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ReviewModeCard(
                            tooltip: l10n.studyReviewEditCardTooltip,
                            actionIcon: Icons.mode_edit_outline,
                            text: card.front,
                            role: MxTextRole.reviewFront,
                          ),
                        ),
                        const MxGap(MxSpace.md),
                        Expanded(
                          flex: 1,
                          child: ReviewModeCard(
                            tooltip: l10n.studyReviewCardAudioTooltip,
                            actionIcon: Icons.volume_up_outlined,
                            text: card.back,
                            role: MxTextRole.reviewBack,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }
    final scrollDelta = _primaryScrollDelta(event);
    if (scrollDelta.abs() < _reviewPointerScrollThreshold) {
      return;
    }
    if (scrollDelta > 0) {
      unawaited(_turnPage(_pageIndex + 1));
      return;
    }
    unawaited(_turnPage(_pageIndex - 1));
  }

  double _primaryScrollDelta(PointerScrollEvent event) {
    final delta = event.scrollDelta;
    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx;
    }
    return delta.dy;
  }

  Future<void> _turnPage(int targetIndex) async {
    if (_isPagingFromPointerSignal ||
        targetIndex < 0 ||
        targetIndex >= _reviewCards.length ||
        !_pageController.hasClients) {
      return;
    }
    _isPagingFromPointerSignal = true;
    try {
      await _pageController.animateToPage(
        targetIndex,
        duration: _reviewPageTurnDuration,
        curve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) {
        _isPagingFromPointerSignal = false;
      }
    }
  }

  List<StudyFlashcardRef> get _reviewCards {
    final cards = widget.snapshot.sessionFlashcards;
    if (cards.isNotEmpty) {
      return cards;
    }
    final current = widget.snapshot.currentItem?.flashcard;
    return current == null ? const <StudyFlashcardRef>[] : [current];
  }

  bool get _isAtLastPage => _pageIndex == _reviewCards.length - 1;

  int _initialPageIndex(StudySessionSnapshot snapshot) {
    final cards = snapshot.sessionFlashcards;
    final currentCardId = snapshot.currentItem?.flashcard.id;
    if (cards.isEmpty || currentCardId == null) {
      return 0;
    }
    final index = cards.indexWhere((card) => card.id == currentCardId);
    return index < 0 ? 0 : index;
  }

  bool _shouldResetPages(
    StudySessionSnapshot oldSnapshot,
    StudySessionSnapshot newSnapshot,
  ) {
    return oldSnapshot.session.id != newSnapshot.session.id ||
        oldSnapshot.currentItem?.id != newSnapshot.currentItem?.id ||
        oldSnapshot.sessionFlashcards.length !=
            newSnapshot.sessionFlashcards.length;
  }

  double _reviewProgress(int cardCount) {
    final lastPage = cardCount - 1;
    if (lastPage <= 0) {
      return 0;
    }
    return _pageIndex / lastPage;
  }

  void _handlePageChanged(int index) {
    setState(() {
      _pageIndex = index;
    });
    _scheduleAutoSubmitIfNeeded();
  }

  void _scheduleAutoSubmitIfNeeded() {
    if (!_isAtLastPage || widget.isSubmitting || _hasSubmitted) {
      _autoSubmitTimer?.cancel();
      _autoSubmitTimer = null;
      return;
    }
    if (_autoSubmitTimer != null) {
      return;
    }
    _autoSubmitTimer = Timer(const Duration(seconds: 2), _submitBatch);
  }

  Future<void> _submitBatch() async {
    if (!mounted || widget.isSubmitting || _hasSubmitted) {
      return;
    }
    _hasSubmitted = true;
    _autoSubmitTimer?.cancel();
    _autoSubmitTimer = null;
    await widget.onSubmit();
  }
}

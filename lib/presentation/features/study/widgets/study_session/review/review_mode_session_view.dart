import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/motion/mx_motion.dart';
import 'package:memox/presentation/shared/widgets/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

import '../study_mode_session_scaffold.dart';
import '../study_speak_button.dart';
import 'review_page_scroll_behavior.dart';

const _reviewPointerScrollThreshold = 20.0;
const _reviewPageTurnDuration = MxDurations.pageTurn;

class ReviewModeSessionView extends StatefulWidget {
  const ReviewModeSessionView({
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
  final Future<bool> Function() onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onBack;

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
    final totalCards = cards.length;
    final currentOneBased = totalCards == 0 ? 0 : _pageIndex + 1;
    final progressValue = totalCards <= 1 ? 1.0 : currentOneBased / totalCards;

    return StudyModeSessionScaffold(
      modeLabel: l10n.studyModeReview,
      accent: MxStudyTopBarAccent.primary,
      progressValue: progressValue,
      counterLabel: l10n.studyCounterFormat(currentOneBased, totalCards),
      canCancel: widget.canCancel,
      isActionBusy: widget.isSubmitting,
      onCancel: widget.onCancel,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Listener(
              onPointerSignal: _handlePointerSignal,
              child: Stack(
                children: [
                  ScrollConfiguration(
                    behavior: const ReviewPageScrollBehavior(),
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      onPageChanged: _handlePageChanged,
                      itemBuilder: (context, index) =>
                          _ReviewSplitCard(card: cards[index]),
                    ),
                  ),
                  if (cards.isNotEmpty)
                    StudyAutoSpeakEffect(
                      triggerKey: 'review:$_pageIndex:${cards[_pageIndex].id}',
                      text: cards[_pageIndex].front,
                      side: TtsTextSide.front,
                    ),
                ],
              ),
            ),
          ),
          const MxGap(MxSpace.md),
          _ReviewBottomBar(
            isAtLast: _isAtLastPage,
            isBusy: widget.isSubmitting,
            onNext: _isAtLastPage ? null : _advancePage,
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

  Future<void> _advancePage() async {
    await _turnPage(_pageIndex + 1);
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
  ) =>
      oldSnapshot.session.id != newSnapshot.session.id ||
      oldSnapshot.currentItem?.id != newSnapshot.currentItem?.id ||
      oldSnapshot.sessionFlashcards.length !=
          newSnapshot.sessionFlashcards.length;

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
    _autoSubmitTimer = Timer(MxDurations.reviewAutoSubmit, _submitBatch);
  }

  Future<void> _submitBatch() async {
    if (!mounted) return;
    if (widget.isSubmitting || _hasSubmitted) return;
    _hasSubmitted = true;
    _autoSubmitTimer?.cancel();
    _autoSubmitTimer = null;
    await widget.onSubmit();
  }
}

/// Single split card: term up top, divider, meaning bottom.
class _ReviewSplitCard extends StatelessWidget {
  const _ReviewSplitCard({required this.card});

  final StudyFlashcardRef card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ReviewSplitFace(
              overline: StringUtils.uppercased(l10n.studyModeReview),
              text: card.front,
              role: MxTextRole.reviewFront,
              trailing: StudySpeakButton(
                key: ValueKey<String>('review-front-speak-${card.id}'),
                text: card.front,
                side: TtsTextSide.front,
                tooltip: l10n.studyReviewCardAudioTooltip,
              ),
              editTooltip: l10n.studyReviewEditCardTooltip,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: MxSpace.xs),
            child: MxDivider(),
          ),
          Expanded(
            child: _ReviewSplitFace(
              overline: StringUtils.uppercased(l10n.studyReviewMeaningLabel),
              text: card.back,
              role: MxTextRole.reviewBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSplitFace extends StatelessWidget {
  const _ReviewSplitFace({
    required this.overline,
    required this.text,
    required this.role,
    this.trailing,
    this.editTooltip,
  });

  final String overline;
  final String text;
  final MxTextRole role;
  final Widget? trailing;
  final String? editTooltip;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Align(
        alignment: Alignment.topLeft,
        child: MxText(overline, role: MxTextRole.overline),
      ),
      if (editTooltip != null)
        Align(
          alignment: Alignment.topRight,
          child: MxIconButton(
            tooltip: editTooltip,
            icon: Icons.mode_edit_outline,
            onPressed: null,
          ),
        ),
      if (trailing != null)
        Align(alignment: Alignment.bottomRight, child: trailing),
      Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MxSpace.lg),
          child: Center(
            child: SingleChildScrollView(
              child: MxText(
                text,
                role: role,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _ReviewBottomBar extends StatelessWidget {
  const _ReviewBottomBar({
    required this.isAtLast,
    required this.isBusy,
    required this.onNext,
  });

  final bool isAtLast;
  final bool isBusy;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
              const MxGap(MxSpace.xs),
              Flexible(
                child: MxText(
                  l10n.studyReviewSwipeHint,
                  role: MxTextRole.overline,
                  color: scheme.onSurfaceVariant,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const MxGap(MxSpace.sm),
        MxPrimaryButton(
          label: l10n.studyNextAction,
          trailingIcon: Icons.arrow_forward_rounded,
          size: MxButtonSize.compact,
          shape: MxPrimaryButtonShape.pill,
          isLoading: isBusy,
          onPressed: isAtLast || isBusy ? null : onNext,
        ),
      ],
    );
  }
}

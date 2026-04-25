import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_error_state.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/study_session_notifier.dart';
import '../study_labels.dart';
import '../widgets/study_session/study_mode_panel.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  StudyAnswerFeedback? _feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionState = ref.watch(studySessionStateProvider(widget.sessionId));
    final actionState = ref.watch(
      studySessionActionControllerProvider(widget.sessionId),
    );
    final canCancel =
        sessionState.whenOrNull(
          data: (snapshot) =>
              snapshot.session.status != SessionStatus.completed &&
              snapshot.session.status != SessionStatus.cancelled,
        ) ??
        false;

    ref.listen<AsyncValue<void>>(
      studySessionActionControllerProvider(widget.sessionId),
      (_, next) {
        if (next.hasError) {
          MxSnackbar.error(context, studyErrorMessage(next.error));
        }
      },
    );
    ref.listen<AsyncValue<StudySessionSnapshot>>(
      studySessionStateProvider(widget.sessionId),
      (_, next) => _clearFeedbackForNextItem(
        next.whenOrNull(data: (snapshot) => snapshot.currentItem?.id),
      ),
    );

    return sessionState.when(
      loading: () => _buildStandardScaffold(
        context: context,
        canCancel: canCancel,
        actionState: actionState,
        child: const _StudySessionLoadingView(),
      ),
      error: (error, stackTrace) => _buildStandardScaffold(
        context: context,
        canCancel: canCancel,
        actionState: actionState,
        child: MxErrorState(
          title: l10n.sharedErrorTitle,
          message: studyErrorMessage(error),
          onRetry: () =>
              ref.invalidate(studySessionStateProvider(widget.sessionId)),
        ),
      ),
      data: (snapshot) {
        if (snapshot.session.status == SessionStatus.completed ||
            snapshot.session.status == SessionStatus.cancelled) {
          return _buildStandardScaffold(
            context: context,
            canCancel: false,
            actionState: actionState,
            child: _SessionTerminalView(sessionId: widget.sessionId),
          );
        }

        final currentItem = snapshot.currentItem;
        if (currentItem != null &&
            currentItem.studyMode == StudyMode.review &&
            snapshot.session.status == SessionStatus.inProgress) {
          return _ReviewModeSessionView(
            snapshot: snapshot,
            isSubmitting: actionState.isLoading,
            onSubmit: () => ref
                .read(
                  studySessionActionControllerProvider(
                    widget.sessionId,
                  ).notifier,
                )
                .answerCurrentReviewModeAsRemembered(),
          );
        }

        final currentItemId = snapshot.currentItem?.id;
        final feedback = _feedback?.itemId == currentItemId ? _feedback : null;
        return _buildStandardScaffold(
          context: context,
          canCancel: canCancel,
          actionState: actionState,
          child: ListView(
            children: [
              MxText(
                studyProgressLabel(l10n, snapshot),
                role: MxTextRole.pageGreeting,
              ),
              const MxGap(MxSpace.sm),
              MxLinearProgress(value: _sessionProgress(snapshot)),
              const MxGap(MxSpace.md),
              StudyModePanel(
                snapshot: snapshot,
                answerOptions: studyAnswerOptions(snapshot),
                isSubmitting: actionState.isLoading,
                feedback: feedback,
                onAnswer: (submission) => _recordFeedback(snapshot, submission),
                onContinue: feedback == null
                    ? null
                    : () => _continueAfterFeedback(feedback),
                onMarkCorrect: _markFeedbackCorrect,
              ),
              const MxGap(MxSpace.xl),
              if (snapshot.canFinalize)
                MxPrimaryButton(
                  label: l10n.studyFinalizeAction,
                  leadingIcon: Icons.done_all_rounded,
                  isLoading: actionState.isLoading,
                  fullWidth: true,
                  onPressed: () async {
                    final success = await ref
                        .read(
                          studySessionActionControllerProvider(
                            widget.sessionId,
                          ).notifier,
                        )
                        .finalizeSession();
                    if (!context.mounted || !success) {
                      return;
                    }
                    context.goStudyResult(widget.sessionId);
                  },
                ),
              if (!snapshot.canFinalize && feedback == null)
                MxSecondaryButton(
                  label: l10n.studySkipAction,
                  leadingIcon: Icons.skip_next_rounded,
                  isLoading: actionState.isLoading,
                  fullWidth: true,
                  onPressed: () => ref
                      .read(
                        studySessionActionControllerProvider(
                          widget.sessionId,
                        ).notifier,
                      )
                      .skip(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandardScaffold({
    required BuildContext context,
    required bool canCancel,
    required AsyncValue<void> actionState,
    required Widget child,
  }) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      title: l10n.studySessionTitle,
      actions: [
        if (canCancel)
          MxIconButton(
            tooltip: l10n.studyCancelAction,
            onPressed: actionState.isLoading
                ? null
                : () => _confirmCancel(context),
            icon: Icons.close_rounded,
          ),
      ],
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: child,
      ),
    );
  }

  double _sessionProgress(StudySessionSnapshot snapshot) {
    final completed = snapshot.summary.completedAttempts;
    final total = completed + snapshot.summary.remainingCount;
    if (total <= 0) {
      return 0;
    }
    return completed / total;
  }

  void _recordFeedback(
    StudySessionSnapshot snapshot,
    StudyAnswerSubmission submission,
  ) {
    final item = snapshot.currentItem;
    if (item == null || _feedback != null) {
      return;
    }
    setState(() {
      _feedback = StudyAnswerFeedback(
        itemId: item.id,
        selectedGrade: submission.grade,
        isCorrect:
            submission.grade == AttemptGrade.correct ||
            submission.grade == AttemptGrade.remembered,
        correctAnswer: item.flashcard.back,
        submittedAnswer: submission.submittedAnswer,
        selectedOptionId: submission.selectedOptionId,
      );
    });
  }

  void _markFeedbackCorrect(StudyAnswerFeedback feedback) {
    if (_feedback?.itemId != feedback.itemId) {
      return;
    }
    setState(() {
      _feedback = feedback;
    });
  }

  Future<void> _continueAfterFeedback(StudyAnswerFeedback feedback) async {
    final success = await ref
        .read(studySessionActionControllerProvider(widget.sessionId).notifier)
        .answer(feedback.selectedGrade);
    if (!mounted || !success) {
      return;
    }
    setState(() {
      _feedback = null;
    });
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.studyCancelConfirmTitle,
      message: l10n.studyCancelConfirmMessage,
      confirmLabel: l10n.studyCancelConfirmAction,
      icon: Icons.close_rounded,
      tone: MxConfirmationTone.danger,
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    await _cancel(context);
  }

  Future<void> _cancel(BuildContext context) async {
    final success = await ref
        .read(studySessionActionControllerProvider(widget.sessionId).notifier)
        .cancel();
    if (!context.mounted || !success) {
      return;
    }
    context.goStudyResult(widget.sessionId);
  }

  void _clearFeedbackForNextItem(String? currentItemId) {
    final feedback = _feedback;
    if (feedback == null || feedback.itemId == currentItemId) {
      return;
    }
    setState(() {
      _feedback = null;
    });
  }
}

class _StudySessionLoadingView extends StatelessWidget {
  const _StudySessionLoadingView();

  @override
  Widget build(BuildContext context) {
    return const MxLoadingState();
  }
}

class _ReviewModeSessionView extends StatefulWidget {
  const _ReviewModeSessionView({
    required this.snapshot,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final Future<bool> Function() onSubmit;

  @override
  State<_ReviewModeSessionView> createState() => _ReviewModeSessionViewState();
}

class _ReviewModeSessionViewState extends State<_ReviewModeSessionView> {
  late PageController _pageController;
  late int _pageIndex;
  Timer? _autoSubmitTimer;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _pageIndex = _initialPageIndex(widget.snapshot);
    _pageController = PageController(initialPage: _pageIndex);
    _scheduleAutoSubmitIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _ReviewModeSessionView oldWidget) {
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

    return MxScaffold(
      title: l10n.studyModeReview,
      leading: MxIconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onPressed: () => context.popRoute(fallback: context.goLibrary),
      ),
      actions: [
        MxIconButton(
          tooltip: l10n.studyReviewTextSettingsTooltip,
          icon: Icons.text_fields,
          onPressed: null,
        ),
        MxIconButton(
          tooltip: l10n.studyReviewAudioTooltip,
          icon: Icons.volume_up_outlined,
          onPressed: null,
        ),
        MxIconButton(
          tooltip: l10n.studyReviewMoreActionsTooltip,
          icon: Icons.more_vert,
          onPressed: null,
        ),
      ],
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: MxLinearProgress(value: progress)),
                const MxGap(MxSpace.sm),
                MxText(
                  l10n.studyReviewProgressPercent(percent),
                  role: MxTextRole.badge,
                ),
              ],
            ),
            const MxGap(MxSpace.md),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: cards.length,
                onPageChanged: _handlePageChanged,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _ReviewModeCard(
                          tooltip: l10n.studyReviewEditCardTooltip,
                          actionIcon: Icons.mode_edit_outline,
                          text: card.front,
                          role: MxTextRole.pageTitle,
                        ),
                      ),
                      const MxGap(MxSpace.md),
                      Expanded(
                        flex: 1,
                        child: _ReviewModeCard(
                          tooltip: l10n.studyReviewCardAudioTooltip,
                          actionIcon: Icons.volume_up_outlined,
                          text: card.back,
                          role: MxTextRole.displayLarge,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

class _ReviewModeCard extends StatelessWidget {
  const _ReviewModeCard({
    required this.tooltip,
    required this.actionIcon,
    required this.text,
    required this.role,
  });

  final String tooltip;
  final IconData actionIcon;
  final String text;
  final MxTextRole role;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      variant: MxCardVariant.outlined,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: MxIconButton(
              tooltip: tooltip,
              icon: actionIcon,
              onPressed: null,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: MxSpace.xxl),
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
      ),
    );
  }
}

class _SessionTerminalView extends StatelessWidget {
  const _SessionTerminalView({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxText(l10n.studySessionEnded, role: MxTextRole.stateTitle),
          const MxGap(MxSpace.lg),
          MxPrimaryButton(
            label: l10n.studyViewResultAction,
            onPressed: () => context.goStudyResult(sessionId),
          ),
        ],
      ),
    );
  }
}

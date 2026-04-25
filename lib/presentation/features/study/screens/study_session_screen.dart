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
        child: sessionState.when(
          loading: () => const _StudySessionLoadingView(),
          error: (error, stackTrace) => MxErrorState(
            title: l10n.sharedErrorTitle,
            message: studyErrorMessage(error),
            onRetry: () =>
                ref.invalidate(studySessionStateProvider(widget.sessionId)),
          ),
          data: (snapshot) {
            if (snapshot.session.status == SessionStatus.completed ||
                snapshot.session.status == SessionStatus.cancelled) {
              return _SessionTerminalView(sessionId: widget.sessionId);
            }
            final currentItemId = snapshot.currentItem?.id;
            final feedback = _feedback?.itemId == currentItemId
                ? _feedback
                : null;
            return ListView(
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
                  onAnswer: (submission) =>
                      _recordFeedback(snapshot, submission),
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
            );
          },
        ),
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

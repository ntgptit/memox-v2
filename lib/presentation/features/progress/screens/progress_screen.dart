import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_badge.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/progress_session_notifier.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final queryState = ref.watch(progressOverviewProvider);

    return MxScaffold(
      title: l10n.progressTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<ProgressOverviewState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          onRetry: () => ref.invalidate(progressOverviewProvider),
          dataBuilder: (context, state) => _ProgressContent(state: state),
        ),
      ),
    );
  }
}

class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({required this.state});

  final ProgressOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(progressSessionActionControllerProvider);
    final sessions = state.sessions;
    return ListView.builder(
      key: const ValueKey('progress_session_list'),
      itemCount: sessions.isEmpty ? 4 : sessions.length + 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _ProgressHeader();
        }
        if (index == 1) {
          return _LearningOverview(state: state);
        }
        if (index == 2) {
          return const _ActiveSessionsHeader();
        }
        if (index == 3) {
          if (sessions.isEmpty) {
            return const _ActiveSessionsEmptyState();
          }
          return _SessionRecoveryOverview(state: state);
        }
        final session = sessions[index - 4];
        return Column(
          children: [
            _StudySessionCard(
              snapshot: session,
              isActionLoading: actionState.isLoading,
            ),
            const MxGap(MxSpace.lg),
          ],
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.progressOverviewHeading, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.sm),
        MxText(l10n.progressOverviewSubtitle, role: MxTextRole.contentBody),
        const MxGap(MxSpace.lg),
      ],
    );
  }
}

class _LearningOverview extends StatelessWidget {
  const _LearningOverview({required this.state});

  final ProgressOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviewMetric = _MetricCard(
      key: const ValueKey('progress_metric_review'),
      label: l10n.progressReviewDueCount,
      value: '${state.reviewCount}',
      icon: Icons.event_available_outlined,
    );
    final newMetric = _MetricCard(
      key: const ValueKey('progress_metric_new_cards'),
      label: l10n.dashboardNewCardsLabel,
      value: '${state.newCardCount}',
      icon: Icons.add_card_outlined,
    );
    final masteryMetric = _MetricCard(
      key: const ValueKey('progress_metric_mastery'),
      label: l10n.dashboardMasteryLabel,
      value: '${state.masteryPercent}%',
      icon: Icons.trending_up_rounded,
    );
    final activeMetric = _MetricCard(
      key: const ValueKey('progress_metric_active'),
      label: l10n.progressActiveSessionsCount,
      value: '${state.activeSessionCount}',
      icon: Icons.play_circle_outline,
    );

    return _MetricCardGroup(
      first: reviewMetric,
      second: newMetric,
      third: masteryMetric,
      fourth: activeMetric,
    );
  }
}

class _ActiveSessionsHeader extends StatelessWidget {
  const _ActiveSessionsHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(
          l10n.progressActiveSessionsHeading,
          role: MxTextRole.sectionTitle,
        ),
        const MxGap(MxSpace.xs),
        MxText(
          l10n.progressActiveSessionsSubtitle,
          role: MxTextRole.contentBody,
        ),
        const MxGap(MxSpace.lg),
      ],
    );
  }
}

class _ActiveSessionsEmptyState extends StatelessWidget {
  const _ActiveSessionsEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.insights_outlined,
      title: l10n.progressEmptyTitle,
      message: l10n.progressEmptyMessage,
      actionLabel: l10n.dashboardOpenLibraryAction,
      actionLeadingIcon: Icons.folder_open_outlined,
      onAction: () => context.goLibrary(),
    );
  }
}

class _SessionRecoveryOverview extends StatelessWidget {
  const _SessionRecoveryOverview({required this.state});

  final ProgressOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeMetric = _MetricCard(
      key: const ValueKey('progress_metric_session_active'),
      label: l10n.progressActiveSessionsCount,
      value: '${state.activeSessionCount}',
      icon: Icons.play_circle_outline,
    );
    final readyMetric = _MetricCard(
      key: const ValueKey('progress_metric_ready'),
      label: l10n.progressReadySessionsCount,
      value: '${state.readySessionCount}',
      icon: Icons.flag_outlined,
    );
    final failedMetric = _MetricCard(
      key: const ValueKey('progress_metric_failed'),
      label: l10n.progressFailedSessionsCount,
      value: '${state.failedSessionCount}',
      icon: Icons.error_outline,
    );

    return _MetricCardGroup(
      first: activeMetric,
      second: readyMetric,
      third: failedMetric,
    );
  }
}

class _MetricCardGroup extends StatelessWidget {
  const _MetricCardGroup({
    required this.first,
    required this.second,
    required this.third,
    this.fourth,
  });

  final Widget first;
  final Widget second;
  final Widget third;
  final Widget? fourth;

  @override
  Widget build(BuildContext context) {
    final shouldUseMetricRow = context.gridColumns() > 1;
    if (shouldUseMetricRow) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const MxGap(MxSpace.md),
              Expanded(child: second),
              const MxGap(MxSpace.md),
              Expanded(child: third),
              if (fourth != null) ...[
                const MxGap(MxSpace.md),
                Expanded(child: fourth!),
              ],
            ],
          ),
          const MxGap(MxSpace.lg),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        first,
        const MxGap(MxSpace.md),
        second,
        const MxGap(MxSpace.md),
        third,
        if (fourth != null) ...[const MxGap(MxSpace.md), fourth!],
        const MxGap(MxSpace.lg),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const MxGap(MxSpace.sm),
          MxText(value, role: MxTextRole.pageTitle),
          const MxGap(MxSpace.xs),
          MxText(label, role: MxTextRole.tileMeta),
        ],
      ),
    );
  }
}

class _StudySessionCard extends ConsumerWidget {
  const _StudySessionCard({
    required this.snapshot,
    required this.isActionLoading,
  });

  final StudySessionSnapshot snapshot;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = snapshot.session;
    final progress = _sessionProgress(snapshot);
    final startedAt = DateTime.fromMillisecondsSinceEpoch(
      session.startedAt,
      isUtc: true,
    ).toLocal();
    final materialL10n = MaterialLocalizations.of(context);
    final currentCard = snapshot.currentItem?.flashcard.front;

    return MxCard(
      key: ValueKey('progress_session_${session.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MxText(
                      _sessionTitle(l10n, session),
                      role: MxTextRole.sectionTitle,
                    ),
                    const MxGap(MxSpace.xs),
                    MxText(
                      _sessionSubtitle(l10n, snapshot),
                      role: MxTextRole.contentBody,
                    ),
                  ],
                ),
              ),
              const MxGap(MxSpace.md),
              MxBadge(
                label: _statusLabel(l10n, session.status),
                tone: _statusTone(session.status),
              ),
            ],
          ),
          const MxGap(MxSpace.md),
          MxLinearProgress(value: progress),
          const MxGap(MxSpace.sm),
          MxText(
            l10n.progressSessionCardProgress(
              _completedStudySteps(snapshot),
              _totalStudySteps(snapshot),
              snapshot.summary.remainingCount,
            ),
            role: MxTextRole.contentBody,
          ),
          if (currentCard != null) ...[
            const MxGap(MxSpace.sm),
            MxText(
              l10n.progressSessionCurrentCard(currentCard),
              role: MxTextRole.tileMeta,
            ),
          ],
          const MxGap(MxSpace.sm),
          MxText(
            l10n.progressSessionStartedAt(
              materialL10n.formatShortDate(startedAt),
              materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(startedAt)),
            ),
            role: MxTextRole.tileMeta,
          ),
          const MxGap(MxSpace.lg),
          _SessionActions(snapshot: snapshot, isActionLoading: isActionLoading),
        ],
      ),
    );
  }
}

class _SessionActions extends ConsumerWidget {
  const _SessionActions({
    required this.snapshot,
    required this.isActionLoading,
  });

  final StudySessionSnapshot snapshot;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = snapshot.session.status;
    final canRetryFinalize = status == SessionStatus.failedToFinalize;
    final canFinalize =
        status == SessionStatus.readyToFinalize || snapshot.canFinalize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _primaryAction(
          context: context,
          ref: ref,
          l10n: l10n,
          canRetryFinalize: canRetryFinalize,
          canFinalize: canFinalize,
        ),
        if (canFinalize || canRetryFinalize) ...[
          const MxGap(MxSpace.sm),
          MxSecondaryButton(
            label: l10n.studyResumeAction,
            leadingIcon: Icons.play_arrow_rounded,
            onPressed: isActionLoading
                ? null
                : () => context.goStudySession(snapshot.session.id),
            fullWidth: true,
          ),
        ],
        const MxGap(MxSpace.sm),
        MxSecondaryButton(
          label: l10n.studyCancelAction,
          leadingIcon: Icons.close_rounded,
          variant: MxSecondaryVariant.text,
          onPressed: isActionLoading
              ? null
              : () => _confirmCancel(context, ref),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _primaryAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required bool canRetryFinalize,
    required bool canFinalize,
  }) {
    if (canRetryFinalize) {
      return MxPrimaryButton(
        label: l10n.studyRetryFinalizeAction,
        leadingIcon: Icons.refresh,
        isLoading: isActionLoading,
        onPressed: isActionLoading ? null : () => _retryFinalize(context, ref),
      );
    }
    if (canFinalize) {
      return MxPrimaryButton(
        label: l10n.studyFinalizeAction,
        leadingIcon: Icons.flag_outlined,
        isLoading: isActionLoading,
        onPressed: isActionLoading ? null : () => _finalize(context, ref),
      );
    }
    return MxPrimaryButton(
      label: l10n.studyResumeAction,
      leadingIcon: Icons.play_arrow_rounded,
      isLoading: isActionLoading,
      onPressed: isActionLoading
          ? null
          : () => context.goStudySession(snapshot.session.id),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.progressCancelConfirmTitle,
      message: l10n.progressCancelConfirmMessage,
      confirmLabel: l10n.studyCancelAction,
      icon: Icons.close_rounded,
      tone: MxConfirmationTone.danger,
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    final success = await ref
        .read(progressSessionActionControllerProvider.notifier)
        .cancel(snapshot.session.id);
    if (!context.mounted) {
      return;
    }
    if (!success) {
      MxSnackbar.error(context, l10n.progressSessionActionFailed);
      return;
    }
    MxSnackbar.success(context, l10n.progressSessionCancelledMessage);
  }

  Future<void> _finalize(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final success = await ref
        .read(progressSessionActionControllerProvider.notifier)
        .finalize(snapshot);
    if (!context.mounted) {
      return;
    }
    if (!success) {
      MxSnackbar.error(context, l10n.progressSessionActionFailed);
      return;
    }
    MxSnackbar.success(context, l10n.progressSessionFinalizedMessage);
  }

  Future<void> _retryFinalize(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final success = await ref
        .read(progressSessionActionControllerProvider.notifier)
        .retryFinalize(snapshot);
    if (!context.mounted) {
      return;
    }
    if (!success) {
      MxSnackbar.error(context, l10n.progressSessionActionFailed);
      return;
    }
    MxSnackbar.success(context, l10n.progressSessionRetryFinalizeMessage);
  }
}

double _sessionProgress(StudySessionSnapshot snapshot) {
  final total = _totalStudySteps(snapshot);
  if (total == 0) {
    return 0;
  }
  return (_completedStudySteps(snapshot) / total).clamp(0, 1).toDouble();
}

int _totalStudySteps(StudySessionSnapshot snapshot) {
  final totalCards = max(
    snapshot.summary.totalCards,
    snapshot.sessionFlashcards.length,
  );
  return totalCards * snapshot.summary.totalModeCount;
}

int _completedStudySteps(StudySessionSnapshot snapshot) {
  final total = _totalStudySteps(snapshot);
  return snapshot.summary.completedAttempts.clamp(0, total).toInt();
}

String _sessionTitle(AppLocalizations l10n, StudySession session) {
  return l10n.progressSessionTitle(
    _studyTypeLabel(l10n, session.studyType),
    _entryTypeLabel(l10n, session.entryType),
  );
}

String _sessionSubtitle(AppLocalizations l10n, StudySessionSnapshot snapshot) {
  final item = snapshot.currentItem;
  if (item == null) {
    return _statusLabel(l10n, snapshot.session.status);
  }
  return l10n.studyProgressModeRound(
    _studyModeLabel(l10n, item.studyMode),
    item.roundIndex,
  );
}

String _studyTypeLabel(AppLocalizations l10n, StudyType studyType) {
  return switch (studyType) {
    StudyType.newStudy => l10n.studyTypeNew,
    StudyType.srsReview => l10n.studyTypeReview,
  };
}

String _entryTypeLabel(AppLocalizations l10n, StudyEntryType entryType) {
  return switch (entryType) {
    StudyEntryType.deck => l10n.progressEntryDeck,
    StudyEntryType.folder => l10n.progressEntryFolder,
    StudyEntryType.today => l10n.progressEntryToday,
  };
}

String _studyModeLabel(AppLocalizations l10n, StudyMode mode) {
  return switch (mode) {
    StudyMode.review => l10n.studyModeReview,
    StudyMode.match => l10n.studyModeMatch,
    StudyMode.guess => l10n.studyModeGuess,
    StudyMode.recall => l10n.studyModeRecall,
    StudyMode.fill => l10n.studyModeFill,
  };
}

String _statusLabel(AppLocalizations l10n, SessionStatus status) {
  return switch (status) {
    SessionStatus.draft => l10n.studyResultDraft,
    SessionStatus.inProgress => l10n.progressSessionStatusInProgress,
    SessionStatus.readyToFinalize => l10n.progressSessionStatusReady,
    SessionStatus.completed => l10n.studyResultCompleted,
    SessionStatus.failedToFinalize => l10n.progressSessionStatusFailed,
    SessionStatus.cancelled => l10n.studyResultCancelled,
  };
}

MxBadgeTone _statusTone(SessionStatus status) {
  return switch (status) {
    SessionStatus.inProgress => MxBadgeTone.info,
    SessionStatus.readyToFinalize => MxBadgeTone.success,
    SessionStatus.failedToFinalize => MxBadgeTone.error,
    SessionStatus.draft => MxBadgeTone.neutral,
    SessionStatus.completed => MxBadgeTone.success,
    SessionStatus.cancelled => MxBadgeTone.neutral,
  };
}

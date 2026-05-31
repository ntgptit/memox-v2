import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/bottom_sheets/study_scope_picker_sheet.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_error_state.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_progress_ring.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/study_session_notifier.dart';

class StudyResultScreen extends StatelessWidget {
  const StudyResultScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.studyResultTitle,
      bodyInsets: false,
      body: StudyResultSection(sessionId: sessionId),
    );
  }
}

class StudyResultSection extends ConsumerWidget {
  const StudyResultSection({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionState = ref.watch(studySessionStateProvider(sessionId));
    final actionState = ref.watch(
      studySessionActionControllerProvider(sessionId),
    );

    return MxContentShell(
      width: MxContentWidth.reading,
      applyVerticalPadding: true,
      child: MxRetainedAsyncState<StudySessionSnapshot>(
        data: sessionState.value,
        isLoading: sessionState.isLoading,
        error: sessionState.hasError ? sessionState.error : null,
        stackTrace: sessionState.hasError ? sessionState.stackTrace : null,
        skeletonBuilder: (_) => const _StudyResultLoadingView(),
        errorBuilder: (_, error, _) => MxErrorState(
          title: l10n.sharedErrorTitle,
          message: studyErrorMessage(error),
          onRetry: () => ref.invalidate(studySessionStateProvider(sessionId)),
        ),
        dataBuilder: (context, snapshot) =>
            _StudyResultBody(snapshot: snapshot, actionState: actionState),
      ),
    );
  }
}

class _StudyResultBody extends ConsumerWidget {
  const _StudyResultBody({required this.snapshot, required this.actionState});

  final StudySessionSnapshot snapshot;
  final AsyncValue<void> actionState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFailedFinalize =
        snapshot.session.status == SessionStatus.failedToFinalize;
    final hasAnyResult = snapshot.resultBreakdown.totalResultCount > 0;

    return ListView(
      children: [
        MxText(l10n.studyResultHeading, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.sm),
        MxText(
          _statusLabel(l10n, snapshot.session.status),
          role: MxTextRole.contentBody,
        ),
        const MxGap(MxSpace.xl),
        if (isFailedFinalize) ...[
          _FailedFinalizeBanner(),
          const MxGap(MxSpace.lg),
        ],
        if (!hasAnyResult)
          _EmptyResultCard()
        else ...[
          _AccuracyCard(snapshot: snapshot),
          const MxGap(MxSpace.lg),
          _ResultBreakdownCard(snapshot: snapshot),
          const MxGap(MxSpace.lg),
          _BoxChangesCard(snapshot: snapshot),
          const MxGap(MxSpace.lg),
          _StudyResultCardReviewSection(
            items: snapshot.resultCardReviewItems,
          ),
        ],
        const MxGap(MxSpace.xl),
        _ResultActions(
          snapshot: snapshot,
          actionState: actionState,
          showRetry: isFailedFinalize,
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, SessionStatus status) =>
      switch (status) {
        SessionStatus.completed => l10n.studyResultCompleted,
        SessionStatus.cancelled => l10n.studyResultCancelled,
        SessionStatus.failedToFinalize => l10n.studyResultFailedFinalize,
        SessionStatus.readyToFinalize => l10n.studyResultReadyFinalize,
        SessionStatus.inProgress => l10n.studyResultInProgress,
        SessionStatus.draft => l10n.studyResultDraft,
      };
}

class _FailedFinalizeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error),
          const MxGap(MxSpace.md),
          Expanded(
            child: MxText(
              l10n.studyResultFailedFinalizeBanner,
              role: MxTextRole.contentBody,
              color: scheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: MxText(l10n.studyResultEmpty, role: MxTextRole.contentBody),
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({required this.snapshot});

  final StudySessionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = snapshot.resultBreakdown.totalResultCount;
    final passed = snapshot.resultBreakdown.passedCount;
    final accuracy = total == 0 ? 0.0 : passed / total;
    return MxCard(
      child: Row(
        children: [
          MxProgressRing(value: accuracy),
          const MxGap(MxSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxText(
                  l10n.studyResultAccuracyLabel,
                  role: MxTextRole.sectionTitle,
                ),
                const MxGap(MxSpace.xs),
                MxText(
                  '${(accuracy * 100).round()}%',
                  role: MxTextRole.pageTitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBreakdownCard extends StatelessWidget {
  const _ResultBreakdownCard({required this.snapshot});

  final StudySessionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final breakdown = snapshot.resultBreakdown;
    final total = breakdown.totalResultCount;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(
            l10n.studyResultBreakdownTitle,
            role: MxTextRole.sectionTitle,
          ),
          const MxGap(MxSpace.md),
          _ResultBar(
            label: l10n.studyResultPerfect,
            count: breakdown.perfectCount,
            total: total,
          ),
          _ResultBar(
            label: l10n.studyResultPassed,
            count: breakdown.initialPassedCount,
            total: total,
          ),
          _ResultBar(
            label: l10n.studyResultRecovered,
            count: breakdown.recoveredCount,
            total: total,
          ),
          _ResultBar(
            label: l10n.studyResultForgot,
            count: breakdown.forgotCount,
            total: total,
          ),
        ],
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total <= 0 ? 0.0 : count / total;
    final countValue = count.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: MxText(label, role: MxTextRole.contentBody)),
              MxText(countValue, role: MxTextRole.tileTrailing),
            ],
          ),
          const MxGap(MxSpace.xs),
          MxLinearProgress(value: progress),
        ],
      ),
    );
  }
}

class _BoxChangesCard extends StatelessWidget {
  const _BoxChangesCard({required this.snapshot});

  final StudySessionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final box = snapshot.boxChangeBreakdown;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(
            l10n.studyResultBoxChangesTitle,
            role: MxTextRole.sectionTitle,
          ),
          const MxGap(MxSpace.md),
          _MetricRow(
            label: l10n.studyResultBoxAdvanced,
            value: '${box.advancedCount}',
          ),
          _MetricRow(
            label: l10n.studyResultBoxStayed,
            value: '${box.stayedCount}',
          ),
          _MetricRow(
            label: l10n.studyResultBoxReset,
            value: '${box.resetCount}',
          ),
          _MetricRow(
            label: l10n.studyResultBoxReachedMax,
            value: '${box.reachedBox8Count}',
          ),
        ],
      ),
    );
  }
}

class _ResultActions extends ConsumerWidget {
  const _ResultActions({
    required this.snapshot,
    required this.actionState,
    required this.showRetry,
  });

  final StudySessionSnapshot snapshot;
  final AsyncValue<void> actionState;
  final bool showRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entryRefId = snapshot.session.entryRefId;
    final entryType = snapshot.session.entryType.storageValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showRetry) ...[
          MxPrimaryButton(
            label: l10n.studyRetryFinalizeAction,
            leadingIcon: Icons.refresh_rounded,
            isLoading: actionState.isLoading,
            onPressed: () => ref
                .read(
                  studySessionActionControllerProvider(
                    snapshot.session.id,
                  ).notifier,
                )
                .finalizeSession(),
          ),
          const MxGap(MxSpace.sm),
        ],
        MxPrimaryButton(
          label: l10n.studyResultDoneAction,
          leadingIcon: Icons.check_rounded,
          onPressed: () => context.goStudyResultDone(
            entryType: entryType,
            entryRefId: entryRefId,
          ),
        ),
        const MxGap(MxSpace.sm),
        MxSecondaryButton(
          label: l10n.studyResultStudyMoreAction,
          leadingIcon: Icons.school_rounded,
          onPressed: () => showStudyScopePicker(context, ref),
        ),
      ],
    );
  }
}

class _StudyResultLoadingView extends StatelessWidget {
  const _StudyResultLoadingView();

  @override
  Widget build(BuildContext context) => const MxLoadingState();
}

class _StudyResultCardReviewSection extends StatelessWidget {
  const _StudyResultCardReviewSection({required this.items});

  final List<StudyResultCardReviewItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(
            l10n.studyResultCardsToReviewTitle,
            role: MxTextRole.sectionTitle,
          ),
          const MxGap(MxSpace.md),
          ..._buildContent(l10n),
        ],
      ),
    );
  }

  List<Widget> _buildContent(AppLocalizations l10n) {
    if (items.isEmpty) {
      return <Widget>[
        MxText(
          l10n.studyResultCardsToReviewEmpty,
          role: MxTextRole.contentBody,
        ),
      ];
    }
    final children = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      if (index > 0) {
        children.add(const MxGap(MxSpace.md));
      }
      children.add(_StudyResultCardReviewRow(item: items[index]));
    }
    return children;
  }
}

class _StudyResultCardReviewRow extends StatelessWidget {
  const _StudyResultCardReviewRow({required this.item});

  final StudyResultCardReviewItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = item.isForgot
        ? l10n.studyResultForgotLabel
        : l10n.studyResultRecoveredLabel;
    final labelColor = item.isForgot ? scheme.error : scheme.tertiary;
    final oldBox = item.oldBox;
    final newBox = item.newBox;
    final showBoxChange = oldBox != null && newBox != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MxText(item.front, role: MxTextRole.tileTitle),
            ),
            const MxGap(MxSpace.md),
            MxText(label, role: MxTextRole.tileTrailing, color: labelColor),
          ],
        ),
        const MxGap(MxSpace.xs),
        MxText(item.back, role: MxTextRole.contentBody),
        if (showBoxChange) ...[
          const MxGap(MxSpace.xs),
          MxText(
            l10n.studyResultBoxChangedLabel(oldBox, newBox),
            role: MxTextRole.tileMeta,
          ),
        ],
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: MxSpace.xs),
    child: Row(
      children: [
        Expanded(child: MxText(label, role: MxTextRole.contentBody)),
        MxText(value, role: MxTextRole.tileTrailing),
      ],
    ),
  );
}

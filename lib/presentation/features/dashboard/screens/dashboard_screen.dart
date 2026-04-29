import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final queryState = ref.watch(dashboardOverviewProvider);

    return MxScaffold(
      title: l10n.homeTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<DashboardOverviewState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          onRetry: () => ref.invalidate(dashboardOverviewProvider),
          dataBuilder: (context, state) => _DashboardContent(state: state),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      _DashboardActionCard(
        key: const ValueKey('dashboard_today_review_card'),
        icon: Icons.event_available_outlined,
        title: l10n.dashboardTodayReviewTitle,
        message: state.hasReviewCards
            ? l10n.dashboardReviewReadyMessage(state.reviewCount)
            : l10n.dashboardReviewEmptyMessage,
        metrics: [
          _DashboardMetric(
            label: l10n.dashboardOverdueLabel,
            value: '${state.overdueCount}',
          ),
          _DashboardMetric(
            label: l10n.dashboardDueTodayTitle,
            value: '${state.dueTodayCount}',
          ),
        ],
        actionLabel: l10n.dashboardReviewNowAction,
        actionKey: const ValueKey('dashboard_review_now_action'),
        actionIcon: Icons.play_arrow_rounded,
        onAction: state.hasReviewCards ? () => context.goStudyToday() : null,
      ),
      _DashboardActionCard(
        key: const ValueKey('dashboard_new_study_card'),
        icon: Icons.auto_stories_outlined,
        title: l10n.dashboardNewStudyTitle,
        message: state.hasNewCards
            ? l10n.dashboardNewStudyMessage(state.newCardCount)
            : l10n.dashboardNewStudyEmptyMessage,
        metrics: [
          _DashboardMetric(
            label: l10n.dashboardNewCardsLabel,
            value: '${state.newCardCount}',
          ),
        ],
        actionLabel: l10n.dashboardStartNewStudyAction,
        actionKey: const ValueKey('dashboard_start_new_study_action'),
        actionIcon: Icons.school_outlined,
        onAction: state.hasNewCards ? () => context.goLibrary() : null,
      ),
      _DashboardActionCard(
        key: const ValueKey('dashboard_resume_card'),
        icon: Icons.play_circle_outline,
        title: l10n.dashboardResumeTitle,
        message: state.hasActiveSessions
            ? l10n.dashboardResumeMessage(state.activeSessionCount)
            : l10n.dashboardResumeEmptyMessage,
        metrics: [
          _DashboardMetric(
            label: l10n.dashboardActiveSessionsLabel,
            value: '${state.activeSessionCount}',
          ),
        ],
        actionLabel: l10n.dashboardContinueSessionAction,
        actionKey: const ValueKey('dashboard_continue_session_action'),
        actionIcon: Icons.play_arrow_rounded,
        onAction: state.hasActiveSessions
            ? () => _continueSession(context, state)
            : null,
      ),
      _DashboardLibraryHealthCard(state: state),
    ];

    return ListView(
      key: const ValueKey('dashboard_content'),
      children: [
        MxText(l10n.dashboardHeading, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.sm),
        MxText(l10n.dashboardSubtitle, role: MxTextRole.contentBody),
        const MxGap(MxSpace.xl),
        ..._cardLayout(context, cards),
      ],
    );
  }

  List<Widget> _cardLayout(BuildContext context, List<Widget> cards) {
    if (context.gridColumns() <= 1) {
      return [
        for (var index = 0; index < cards.length; index++) ...[
          cards[index],
          if (index != cards.length - 1) const MxGap(MxSpace.lg),
        ],
      ];
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cards[0]),
          const MxGap(MxSpace.lg),
          Expanded(child: cards[1]),
        ],
      ),
      const MxGap(MxSpace.lg),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cards[2]),
          const MxGap(MxSpace.lg),
          Expanded(child: cards[3]),
        ],
      ),
    ];
  }

  void _continueSession(BuildContext context, DashboardOverviewState state) {
    final sessionId = state.resumeSessionId;
    if (sessionId == null) {
      context.goProgress();
      return;
    }
    context.goStudySession(sessionId);
  }
}

class _DashboardMetric {
  const _DashboardMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.metrics,
    required this.actionLabel,
    required this.actionKey,
    required this.actionIcon,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<_DashboardMetric> metrics;
  final String actionLabel;
  final Key actionKey;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxText(title, role: MxTextRole.sectionTitle),
                const MxGap(MxSpace.xs),
                MxText(message, role: MxTextRole.contentBody),
                const MxGap(MxSpace.md),
                _MetricList(metrics: metrics),
                const MxGap(MxSpace.md),
                MxPrimaryButton(
                  key: actionKey,
                  label: actionLabel,
                  leadingIcon: actionIcon,
                  fullWidth: true,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricList extends StatelessWidget {
  const _MetricList({required this.metrics});

  final List<_DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      itemBuilder: (context, index) => _MetricLine(metric: metrics[index]),
      separatorBuilder: (context, index) => const MxGap(MxSpace.xs),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: MxText(metric.label, role: MxTextRole.tileMeta)),
        const MxGap(MxSpace.md),
        MxText(metric.value, role: MxTextRole.sectionTitle),
      ],
    );
  }
}

class _DashboardLibraryHealthCard extends StatelessWidget {
  const _DashboardLibraryHealthCard({required this.state});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.health_and_safety_outlined, color: scheme.primary),
              const MxGap(MxSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MxText(
                      l10n.dashboardLibraryHealthTitle,
                      role: MxTextRole.sectionTitle,
                    ),
                    const MxGap(MxSpace.xs),
                    MxText(
                      l10n.dashboardLibraryHealthSummary(
                        state.folderCount,
                        state.deckCount,
                        state.cardCount,
                      ),
                      role: MxTextRole.contentBody,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const MxGap(MxSpace.md),
          _MetricLine(
            metric: _DashboardMetric(
              label: l10n.dashboardMasteryLabel,
              value: '${state.masteryPercent}%',
            ),
          ),
          const MxGap(MxSpace.md),
          MxLinearProgress(
            value: state.masteryPercent / 100,
            showPercentage: true,
          ),
          const MxGap(MxSpace.md),
          MxSecondaryButton(
            key: const ValueKey('dashboard_open_library_action'),
            label: l10n.dashboardOpenLibraryAction,
            leadingIcon: Icons.folder_open_outlined,
            fullWidth: true,
            onPressed: () => context.goLibrary(),
          ),
        ],
      ),
    );
  }
}

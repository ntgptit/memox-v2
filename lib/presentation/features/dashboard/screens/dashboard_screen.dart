import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_ring.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_study_progress_action.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

const _dashboardChartSize =
    132.0; // guard:raw-size-reviewed fixed dashboard chart diameter
const _dashboardChartStrokeWidth =
    16.0; // guard:raw-size-reviewed dashboard mastery ring thickness
const _dashboardActionInlineMinWidth =
    460.0; // guard:raw-size-reviewed switch point for action button layout
const _dashboardActionButtonWidth =
    152.0; // guard:raw-size-reviewed aligns concise dashboard action CTAs
const _dashboardPercentMax = 100;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryState = ref.watch(dashboardOverviewProvider);

    return MxScaffold(
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
    final actions = [
      _DashboardActionSpec(
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
        isPrimary: false,
        onAction: state.hasReviewCards ? () => context.goStudyToday() : null,
      ),
      _DashboardActionSpec(
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
        isPrimary: true,
        onAction: state.hasNewCards ? () => context.goLibrary() : null,
      ),
      _DashboardActionSpec(
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
        isPrimary: false,
        onAction: state.hasActiveSessions
            ? () => _continueSession(context, state)
            : null,
      ),
    ];

    return ListView(
      key: const ValueKey('dashboard_content'),
      children: [
        const _DashboardGreetingHeader(),
        const MxGap(MxSpace.lg),
        const _DashboardFocusHeader(),
        const MxGap(MxSpace.lg),
        _DashboardLibraryProgressCard(state: state),
        const MxGap(MxSpace.lg),
        _DashboardActionList(actions: actions),
        if (state.deckHighlights.isNotEmpty) ...[
          const MxGap(MxSpace.lg),
          _DashboardDeckHighlightsSection(items: state.deckHighlights),
        ],
      ],
    );
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

class _DashboardGreetingHeader extends StatelessWidget {
  const _DashboardGreetingHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.dashboardGreetingTitle, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.xs),
        MxText(l10n.dashboardGreetingSubtitle, role: MxTextRole.pageGreeting),
      ],
    );
  }
}

class _DashboardFocusHeader extends StatelessWidget {
  const _DashboardFocusHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.dashboardHeading, role: MxTextRole.sectionTitle),
        const MxGap(MxSpace.xs),
        MxText(l10n.dashboardSubtitle, role: MxTextRole.sectionSubtitle),
      ],
    );
  }
}

class _DashboardActionSpec {
  const _DashboardActionSpec({
    required this.icon,
    required this.title,
    required this.message,
    required this.metrics,
    required this.actionLabel,
    required this.actionKey,
    required this.actionIcon,
    required this.isPrimary,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<_DashboardMetric> metrics;
  final String actionLabel;
  final Key actionKey;
  final IconData actionIcon;
  final bool isPrimary;
  final VoidCallback? onAction;
}

class _DashboardMetric {
  const _DashboardMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class _DashboardLibraryProgressCard extends StatelessWidget {
  const _DashboardLibraryProgressCard({required this.state});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final masteryPercent = state.masteryPercent
        .clamp(0, _dashboardPercentMax)
        .toInt();

    return MxCard(
      key: const ValueKey('dashboard_library_progress_card'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DashboardMasteryChart(percent: masteryPercent),
          const MxGap(MxSpace.xl),
          Expanded(
            child: _DashboardLibraryProgressDetails(
              state: state,
              percent: masteryPercent,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMasteryChart extends StatelessWidget {
  const _DashboardMasteryChart({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final progress = percent / _dashboardPercentMax;

    return Semantics(
      container: true,
      label: l10n.dashboardLibraryProgressMessage(percent),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _dashboardChartSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              MxProgressRing(
                value: progress,
                size: _dashboardChartSize,
                strokeWidth: _dashboardChartStrokeWidth,
                showLabel: false,
                trackColor: scheme.surfaceContainerHighest,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MxText(
                    l10n.commonPercentValue(percent),
                    role: MxTextRole.sectionTitle,
                    textAlign: TextAlign.center,
                  ),
                  MxText(
                    l10n.dashboardMasteryLabel,
                    role: MxTextRole.tileMeta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLibraryProgressDetails extends StatelessWidget {
  const _DashboardLibraryProgressDetails({
    required this.state,
    required this.percent,
  });

  final DashboardOverviewState state;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.query_stats_outlined, color: scheme.primary),
            const MxGap(MxSpace.md),
            Expanded(
              child: MxText(
                l10n.dashboardLibraryProgressTitle,
                role: MxTextRole.sectionTitle,
              ),
            ),
          ],
        ),
        const MxGap(MxSpace.xs),
        MxText(
          l10n.dashboardLibraryProgressMessage(percent),
          role: MxTextRole.contentBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const MxGap(MxSpace.xs),
        MxText(
          l10n.dashboardLibraryHealthSummary(
            state.folderCount,
            state.deckCount,
            state.cardCount,
          ),
          role: MxTextRole.tileMeta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const MxGap(MxSpace.md),
        MxSecondaryButton(
          key: const ValueKey('dashboard_open_library_action'),
          label: l10n.dashboardOpenLibraryAction,
          leadingIcon: Icons.folder_open_outlined,
          size: MxButtonSize.small,
          variant: MxSecondaryVariant.text,
          onPressed: () => context.goLibrary(),
        ),
      ],
    );
  }
}

class _DashboardDeckHighlightsSection extends StatelessWidget {
  const _DashboardDeckHighlightsSection({required this.items});

  final List<DashboardDeckHighlightItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visibleItems = items
        .take(dashboardDeckHighlightLimit)
        .toList(growable: false);
    final hasRecentDecks = visibleItems.any((item) => item.hasBeenStudied);

    return MxSection(
      title: hasRecentDecks
          ? l10n.dashboardRecentDecksTitle
          : l10n.dashboardStartDeckTitle,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleItems.length,
        itemBuilder: (context, index) =>
            _DashboardDeckHighlightTile(item: visibleItems[index]),
        separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
      ),
    );
  }
}

class _DashboardDeckHighlightTile extends StatelessWidget {
  const _DashboardDeckHighlightTile({required this.item});

  final DashboardDeckHighlightItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxStudySetTile(
      key: ValueKey('dashboard_deck_${item.id}'),
      title: item.name,
      icon: Icons.style_outlined,
      metaLine: l10n.dashboardDeckStats(item.cardCount),
      onTap: () => context.goFlashcardList(item.id),
      trailing: MxStudyProgressAction(
        key: ValueKey('dashboard_deck_study_${item.id}'),
        masteryPercent: item.masteryPercent,
        badgeCount: item.dueTodayCount,
        tooltip: l10n.studyStartAction,
        onPressed: () =>
            context.goStudyEntry(entryType: 'deck', entryRefId: item.id),
      ),
    );
  }
}

class _DashboardActionList extends StatelessWidget {
  const _DashboardActionList({required this.actions});

  final List<_DashboardActionSpec> actions;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      key: const ValueKey('dashboard_action_list_card'),
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.sm,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) =>
            _DashboardActionRow(action: actions[index]),
        separatorBuilder: (context, index) => const MxDivider(),
      ),
    );
  }
}

class _DashboardActionRow extends StatelessWidget {
  const _DashboardActionRow({required this.action});

  final _DashboardActionSpec action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = action.isPrimary && action.onAction != null
        ? scheme.primary
        : scheme.onSurfaceVariant;
    final button = SizedBox(
      key: action.actionKey,
      width: _dashboardActionButtonWidth,
      child: action.isPrimary
          ? MxPrimaryButton(
              label: action.actionLabel,
              leadingIcon: action.actionIcon,
              size: MxButtonSize.small,
              fullWidth: true,
              onPressed: action.onAction,
            )
          : MxSecondaryButton(
              label: action.actionLabel,
              leadingIcon: action.actionIcon,
              size: MxButtonSize.small,
              variant: MxSecondaryVariant.outlined,
              fullWidth: true,
              onPressed: action.onAction,
            ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpace.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = _DashboardActionDetails(action: action);

          if (constraints.maxWidth < _dashboardActionInlineMinWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(action.icon, color: iconColor),
                    const MxGap(MxSpace.md),
                    Expanded(child: details),
                  ],
                ),
                const MxGap(MxSpace.sm),
                Padding(
                  padding: const EdgeInsets.only(left: MxSpace.xxl),
                  child: button,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(action.icon, color: iconColor),
              const MxGap(MxSpace.md),
              Expanded(child: details),
              const MxGap(MxSpace.md),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _DashboardActionDetails extends StatelessWidget {
  const _DashboardActionDetails({required this.action});

  final _DashboardActionSpec action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(action.title, role: MxTextRole.sectionTitle),
        const MxGap(MxSpace.xs),
        MxText(
          action.message,
          role: MxTextRole.contentBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const MxGap(MxSpace.xs),
        _MetricList(metrics: action.metrics),
      ],
    );
  }
}

class _MetricList extends StatelessWidget {
  const _MetricList({required this.metrics});

  final List<_DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MxSpace.md,
      runSpacing: MxSpace.xs,
      children: [for (final metric in metrics) _MetricLine(metric: metric)],
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return MxText(
      '${metric.label}: ${metric.value}',
      role: MxTextRole.tileMeta,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

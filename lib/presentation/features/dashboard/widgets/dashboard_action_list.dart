import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

const _dashboardActionInlineMinWidth =
    460.0; // guard:raw-size-reviewed switch point for action button layout
const _dashboardActionButtonWidth =
    152.0; // guard:raw-size-reviewed aligns concise dashboard action CTAs

class DashboardActionList extends StatelessWidget {
  const DashboardActionList({required this.state, super.key});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final actions = _actions(context);

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

  List<_DashboardActionSpec> _actions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
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
            ? () => _continueSession(context)
            : null,
      ),
    ];
  }

  void _continueSession(BuildContext context) {
    final sessionId = state.resumeSessionId;
    if (sessionId == null) {
      context.goProgress();
      return;
    }
    context.goStudySession(sessionId);
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

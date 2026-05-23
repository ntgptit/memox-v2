import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_button_size.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_icon_tile.dart';
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

    return Column(
      key: const ValueKey('dashboard_action_list'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const MxGap(MxSpace.md),
          _DashboardActionCard(action: actions[i]),
        ],
      ],
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
        compactStatus: l10n.dashboardReviewCompactStatus(state.reviewCount),
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
        compactStatus: l10n.dashboardNewStudyCompactStatus(state.newCardCount),
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
        compactStatus: l10n.dashboardResumeCompactStatus(
          state.activeSessionCount,
        ),
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
    required this.compactStatus,
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
  final String compactStatus;
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

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({required this.action});

  final _DashboardActionSpec action;

  @override
  Widget build(BuildContext context) {
    final isEnabled = action.onAction != null;
    final showAccent = action.isPrimary && isEnabled;

    return MxCard(
      key: ValueKey('dashboard_action_card_${action.actionKey}'),
      variant: MxCardVariant.outlined,
      accent: showAccent,
      child: _DashboardActionBody(action: action, isEnabled: isEnabled),
    );
  }
}

class _DashboardActionBody extends StatelessWidget {
  const _DashboardActionBody({required this.action, required this.isEnabled});

  final _DashboardActionSpec action;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final details = _DashboardActionDetails(action: action);
        final iconTile = _DashboardActionIcon(
          action: action,
          isEnabled: isEnabled,
        );

        if (constraints.maxWidth < _dashboardActionInlineMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconTile,
                  const MxGap(MxSpace.md),
                  Expanded(child: details),
                ],
              ),
              const MxGap(MxSpace.md),
              _DashboardActionButton(action: action, fullWidth: true),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconTile,
            const MxGap(MxSpace.md),
            Expanded(child: details),
            const MxGap(MxSpace.md),
            _DashboardActionButton(action: action, fullWidth: false),
          ],
        );
      },
    );
  }
}

class _DashboardActionIcon extends StatelessWidget {
  const _DashboardActionIcon({required this.action, required this.isEnabled});

  final _DashboardActionSpec action;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return MxIconTile(icon: action.icon, tone: _tone());
  }

  MxIconTileTone _tone() {
    if (!isEnabled) return MxIconTileTone.disabled;
    if (action.isPrimary) return MxIconTileTone.primary;
    return MxIconTileTone.neutral;
  }
}

class _DashboardActionButton extends StatelessWidget {
  const _DashboardActionButton({
    required this.action,
    required this.fullWidth,
  });

  final _DashboardActionSpec action;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Widget button() {
      return action.isPrimary
          ? MxPrimaryButton(
              label: action.actionLabel,
              leadingIcon: action.actionIcon,
              size: MxButtonSize.small,
              fullWidth: fullWidth,
              onPressed: action.onAction,
            )
          : MxSecondaryButton(
              label: action.actionLabel,
              leadingIcon: action.actionIcon,
              size: MxButtonSize.small,
              variant: MxSecondaryVariant.outlined,
              fullWidth: fullWidth,
              onPressed: action.onAction,
            );
    }

    return SizedBox(
      key: action.actionKey,
      width: fullWidth ? double.infinity : _dashboardActionButtonWidth,
      child: button(),
    );
  }
}

class _DashboardActionDetails extends StatelessWidget {
  const _DashboardActionDetails({required this.action});

  final _DashboardActionSpec action;

  @override
  Widget build(BuildContext context) {
    final showSupportingCopy = context.showsSupportingCopy;
    final statusChildren = showSupportingCopy
        ? <Widget>[
            MxText(
              action.message,
              role: MxTextRole.contentBody,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const MxGap(MxSpace.xs),
            _MetricList(metrics: action.metrics),
          ]
        : <Widget>[
            MxText(
              action.compactStatus,
              role: MxTextRole.tileMeta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(action.title, role: MxTextRole.sectionTitle),
        const MxGap(MxSpace.xs),
        ...statusChildren,
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

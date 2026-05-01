import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/progress_session_notifier.dart';

class LearningOverview extends StatelessWidget {
  const LearningOverview({required this.state, super.key});

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

class SessionRecoveryOverview extends StatelessWidget {
  const SessionRecoveryOverview({required this.state, super.key});

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

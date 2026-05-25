import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_stat_card.dart';
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
      tone: state.reviewCount > 0 ? MxStatTone.streak : MxStatTone.neutral,
    );
    final newMetric = _MetricCard(
      key: const ValueKey('progress_metric_new_cards'),
      label: l10n.dashboardNewCardsLabel,
      value: '${state.newCardCount}',
      icon: Icons.add_card_outlined,
      tone: MxStatTone.primary,
    );
    final masteryMetric = _MetricCard(
      key: const ValueKey('progress_metric_mastery'),
      label: l10n.dashboardMasteryLabel,
      value: '${state.masteryPercent}',
      unit: '%',
      icon: Icons.trending_up_rounded,
      tone: MxStatTone.mastery,
    );
    final activeMetric = _MetricCard(
      key: const ValueKey('progress_metric_active'),
      label: l10n.progressActiveSessionsCount,
      value: '${state.activeSessionCount}',
      icon: Icons.play_circle_outline,
      tone: MxStatTone.success,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricCardGroup(
          first: reviewMetric,
          second: newMetric,
          third: masteryMetric,
          fourth: activeMetric,
        ),
        _LearningSummaryCard(state: state),
        const MxGap(MxSpace.lg),
      ],
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
      tone: MxStatTone.primary,
    );
    final readyMetric = _MetricCard(
      key: const ValueKey('progress_metric_ready'),
      label: l10n.progressReadySessionsCount,
      value: '${state.readySessionCount}',
      icon: Icons.flag_outlined,
      tone: MxStatTone.success,
    );
    final failedMetric = _MetricCard(
      key: const ValueKey('progress_metric_failed'),
      label: l10n.progressFailedSessionsCount,
      value: '${state.failedSessionCount}',
      icon: Icons.error_outline,
      tone: state.failedSessionCount > 0
          ? MxStatTone.streak
          : MxStatTone.neutral,
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
        ],
      );
    }

    // Compact phones: 2-up grid keeps stats glanceable instead of stretching
    // a single column of full-width cards down the screen (web-feel).
    if (fourth != null) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: first),
                const MxGap(MxSpace.md),
                Expanded(child: second),
              ],
            ),
          ),
          const MxGap(MxSpace.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: third),
                const MxGap(MxSpace.md),
                Expanded(child: fourth!),
              ],
            ),
          ),
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
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    this.unit,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final MxStatTone tone;
  final String? unit;

  @override
  Widget build(BuildContext context) => MxStatCard(
    label: label,
    value: value,
    unit: unit,
    icon: icon,
    tone: tone,
  );
}

class _LearningSummaryCard extends StatelessWidget {
  const _LearningSummaryCard({required this.state});

  final ProgressOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviewTotal = state.reviewCount + state.newCardCount;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(
            l10n.dashboardLibraryProgressTitle,
            role: MxTextRole.formLabel,
          ),
          const MxGap(MxSpace.md),
          MxLinearProgress(
            value: state.masteryPercent / 100,
            showPercentage: true,
            size: MxProgressSize.large,
          ),
          const MxGap(MxSpace.md),
          Row(
            children: [
              Expanded(
                child: MxText(
                  l10n.dashboardReviewCompactStatus(reviewTotal),
                  role: MxTextRole.tileMeta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const MxGap(MxSpace.sm),
              MxText(
                '${state.activeSessionCount}',
                role: MxTextRole.tileTrailing,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_ring.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

const _dashboardChartSize =
    132.0; // guard:raw-size-reviewed fixed dashboard chart diameter
const _dashboardChartStrokeWidth =
    16.0; // guard:raw-size-reviewed dashboard mastery ring thickness
const _dashboardPercentMax = 100;

class DashboardLibraryProgressCard extends StatelessWidget {
  const DashboardLibraryProgressCard({required this.state, super.key});

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

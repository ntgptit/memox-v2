import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_stat_card.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

const _dashboardPercentMax = 100;
const _dashboardPlaceholderStreakDays = 0;

class DashboardHomeStatsSection extends StatelessWidget {
  const DashboardHomeStatsSection({required this.state, super.key});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final masteredCount =
        (state.cardCount * state.masteryPercent / _dashboardPercentMax).round();

    return Row(
      children: [
        Expanded(
          child: MxStatCard(
            icon: Icons.local_fire_department_outlined,
            label: AppLocalizations.of(context).sharedStreakLabel,
            value: AppLocalizations.of(
              context,
            ).dashboardStreakDays(_dashboardPlaceholderStreakDays),
            supportingText: AppLocalizations.of(
              context,
            ).dashboardReviewCompactStatus(state.reviewCount),
            tone: MxStatTone.streak,
          ),
        ),
        const MxGap(MxSpace.md),
        Expanded(
          child: MxStatCard(
            label: AppLocalizations.of(context).dashboardMasteryLabel,
            value: AppLocalizations.of(
              context,
            ).dashboardMasteredCards(masteredCount),
            supportingText: AppLocalizations.of(
              context,
            ).dashboardLibraryProgressMessage(state.masteryPercent),
            tone: MxStatTone.mastery,
          ),
        ),
      ],
    );
  }
}

class DashboardEmptyDeckCard extends StatelessWidget {
  const DashboardEmptyDeckCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxText(l10n.dashboardStartDeckTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.sm),
          MxText(
            l10n.dashboardNewStudyEmptyMessage,
            role: MxTextRole.contentBody,
          ),
          const MxGap(MxSpace.md),
          MxSecondaryButton(
            key: const ValueKey('dashboard_empty_deck_library_action'),
            label: l10n.dashboardOpenLibraryAction,
            leadingIcon: Icons.folder_open_outlined,
            variant: MxSecondaryVariant.text,
            onPressed: () => context.goLibrary(),
          ),
        ],
      ),
    );
  }
}

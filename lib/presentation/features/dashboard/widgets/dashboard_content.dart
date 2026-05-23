import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';
import 'dashboard_action_list.dart';
import 'dashboard_header_section.dart';
import 'dashboard_mastery_section.dart';
import 'dashboard_stats_section.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.state, super.key});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('dashboard_content'),
      padding: const EdgeInsets.only(bottom: MxSpace.xxl),
      children: [
        if (context.showsSupportingCopy) ...[
          const DashboardGreetingHeader(),
          const MxGap(MxSpace.lg),
        ],
        MxSectionHeader(title: AppLocalizations.of(context).dashboardHeading),
        const MxGap(MxSpace.lg),
        DashboardActionList(state: state),
        const MxGap(MxSpace.lg),
        DashboardLibraryProgressCard(state: state),
        const MxGap(MxSpace.lg),
        if (state.deckHighlights.isNotEmpty)
          DashboardDeckHighlightsSection(items: state.deckHighlights),
        if (state.deckHighlights.isEmpty) const _DashboardDeckEmptyState(),
      ],
    );
  }
}

class _DashboardDeckEmptyState extends StatelessWidget {
  const _DashboardDeckEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxText(l10n.dashboardStartDeckTitle, role: MxTextRole.sectionTitle),
          if (context.showsSupportingCopy) ...[
            const MxGap(MxSpace.sm),
            MxText(
              l10n.dashboardNewStudyEmptyMessage,
              role: MxTextRole.contentBody,
            ),
          ],
          const MxGap(MxSpace.md),
          MxSecondaryButton(
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

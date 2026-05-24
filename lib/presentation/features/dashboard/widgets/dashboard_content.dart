import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
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
  Widget build(BuildContext context) => ListView(
      key: const ValueKey('dashboard_content'),
      padding: const EdgeInsets.only(bottom: MxSpace.xxl),
      children: [
        const DashboardGreetingHeader(),
        const MxGap(MxSpace.lg),
        DashboardActionList(state: state),
        const MxGap(MxSpace.lg),
        DashboardHomeStatsSection(state: state),
        const MxGap(MxSpace.lg),
        if (state.deckHighlights.isNotEmpty)
          DashboardDeckHighlightsSection(items: state.deckHighlights),
        if (state.deckHighlights.isEmpty) const _DashboardDeckEmptyState(),
      ],
    );
}

class _DashboardDeckEmptyState extends StatelessWidget {
  const _DashboardDeckEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.dashboardPickUpTitle, role: MxTextRole.formLabel),
        const MxGap(MxSpace.sm),
        const DashboardEmptyDeckCard(),
      ],
    );
  }
}

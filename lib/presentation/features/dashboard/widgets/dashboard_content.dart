import 'package:flutter/material.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
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
      children: [
        const DashboardGreetingHeader(),
        const MxGap(MxSpace.lg),
        const DashboardFocusHeader(),
        const MxGap(MxSpace.lg),
        DashboardLibraryProgressCard(state: state),
        const MxGap(MxSpace.lg),
        DashboardActionList(state: state),
        if (state.deckHighlights.isNotEmpty) ...[
          const MxGap(MxSpace.lg),
          DashboardDeckHighlightsSection(items: state.deckHighlights),
        ],
      ],
    );
  }
}

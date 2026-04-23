import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_section.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../viewmodels/deck_detail_viewmodel.dart';

class DeckStatsSection extends StatelessWidget {
  const DeckStatsSection({
    required this.state,
    required this.lastStudiedLabel,
    super.key,
  });

  final DeckDetailState state;
  final String lastStudiedLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxSection(
      title: l10n.commonOverview,
      subtitle: l10n.decksOverviewSubtitle(
        state.cardCount,
        state.dueTodayCount,
        state.masteryPercent,
      ),
      child: MxStudySetTile(
        title: state.name,
        icon: Icons.style_outlined,
        metaLine: lastStudiedLabel,
      ),
    );
  }
}

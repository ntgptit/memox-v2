import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_study_progress_action.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

class DashboardDeckHighlightsSection extends StatelessWidget {
  const DashboardDeckHighlightsSection({required this.items, super.key});

  final List<DashboardDeckHighlightItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visibleItems = items
        .take(dashboardDeckHighlightLimit)
        .toList(growable: false);
    final hasRecentDecks = visibleItems.any((item) => item.hasBeenStudied);

    return MxSection(
      title: hasRecentDecks
          ? l10n.dashboardRecentDecksTitle
          : l10n.dashboardStartDeckTitle,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleItems.length,
        itemBuilder: (context, index) =>
            _DashboardDeckHighlightTile(item: visibleItems[index]),
        separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
      ),
    );
  }
}

class _DashboardDeckHighlightTile extends StatelessWidget {
  const _DashboardDeckHighlightTile({required this.item});

  final DashboardDeckHighlightItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxStudySetTile(
      key: ValueKey('dashboard_deck_${item.id}'),
      title: item.name,
      icon: Icons.style_outlined,
      metaLine: l10n.dashboardDeckStats(item.cardCount),
      onTap: () => context.goFlashcardList(item.id),
      trailing: MxStudyProgressAction(
        key: ValueKey('dashboard_deck_study_${item.id}'),
        masteryPercent: item.masteryPercent,
        badgeCount: item.dueTodayCount,
        tooltip: l10n.studyStartAction,
        onPressed: () =>
            context.goStudyEntry(entryType: 'deck', entryRefId: item.id),
      ),
    );
  }
}

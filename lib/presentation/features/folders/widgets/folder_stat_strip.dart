import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../shared/widgets/mx_chip.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

/// Horizontal stat strip rendered above the search toolbar on folder detail.
///
/// Shows three glance-able chips aggregated from the deck list — total card
/// count, sum of cards due today, and average mastery. Quizlet-mobile-style
/// content density that fills the header area instead of leaving it empty.
class FolderStatStrip extends StatelessWidget {
  const FolderStatStrip({required this.decks, super.key});

  final List<FolderDeckItem> decks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalCards = decks.fold<int>(0, (sum, item) => sum + item.cardCount);
    final dueToday = decks.fold<int>(0, (sum, item) => sum + item.dueToday);
    final masteryAvg = decks.isEmpty
        ? 0
        : (decks.fold<int>(0, (sum, item) => sum + item.masteryPercent) /
                  decks.length)
              .round();

    final cardLabel = l10n.foldersDeckStats(totalCards);
    final dueLabel = l10n.dashboardReviewCompactStatus(dueToday);
    final masteryLabel = _formatMasteryLabel(l10n, masteryAvg);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        MxChip(
          label: cardLabel,
          icon: Icons.style_outlined,
          tone: MxChipTone.neutral,
        ),
        MxChip(
          label: dueLabel,
          icon: Icons.event_available_outlined,
          tone: dueToday > 0 ? MxChipTone.warning : MxChipTone.neutral,
        ),
        MxChip(
          label: masteryLabel,
          icon: Icons.trending_up_rounded,
          tone: masteryAvg >= 67
              ? MxChipTone.success
              : (masteryAvg >= 34 ? MxChipTone.info : MxChipTone.neutral),
        ),
      ],
    );
  }

  String _formatMasteryLabel(AppLocalizations l10n, int percent) {
    final percentToken = '$percent%';
    return '${l10n.dashboardMasteryLabel} $percentToken';
  }
}

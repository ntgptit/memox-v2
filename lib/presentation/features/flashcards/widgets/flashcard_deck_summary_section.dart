import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_progress_ring.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

/// Mastery hero per Design System "03 · Deck detail": a hero progress ring
/// next to an overline + meta line. Renders as a plain row (no card wrap)
/// so the visual hierarchy stays calm.
class FlashcardDeckSummarySection extends StatelessWidget {
  const FlashcardDeckSummarySection({
    required this.state,
    required this.studyEnabled,
    required this.onStartStudy,
    super.key,
  });

  final FlashcardListState state;

  /// Reserved for callers that still want to forward a CTA — currently the
  /// summary itself does not render a button so the Design System overline
  /// stays as the visual anchor.
  // ignore: unused_element
  final bool studyEnabled;

  // ignore: unused_element
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final masteredCount = state.progress.masteredCount;
    final totalCount = state.totalCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MxProgressRing(
          value: state.progress.masteryPercent / 100,
          size: MxProgressRingSize.hero,
        ),
        const MxGap(MxSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MxText(
                StringUtils.upperCaseToEmpty(l10n.deckMasteryLabel),
                role: MxTextRole.overline,
              ),
              const MxGap(MxSpace.xs),
              MxText(
                l10n.deckMasteryProgress(masteredCount, totalCount),
                role: MxTextRole.tileTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

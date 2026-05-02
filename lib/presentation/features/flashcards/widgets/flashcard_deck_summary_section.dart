import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardDeckSummarySection extends StatelessWidget {
  const FlashcardDeckSummarySection({
    required this.state,
    required this.onOpenBreadcrumb,
    super.key,
  });

  final FlashcardListState state;
  final ValueChanged<String> onOpenBreadcrumb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(
          state.deckName,
          role: MxTextRole.pageTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const MxGap(MxSpace.sm),
        MxBreadcrumbBar(
          items: [
            for (var index = 0; index < state.breadcrumb.length; index++)
              MxBreadcrumb(
                label: state.breadcrumb[index].label,
                onTap:
                    index == state.breadcrumb.length - 1 ||
                        state.breadcrumb[index].folderId == null
                    ? null
                    : () => onOpenBreadcrumb(state.breadcrumb[index].folderId!),
              ),
          ],
        ),
        const MxGap(MxSpace.sm),
        MxText(
          l10n.flashcardsDeckSummary(
            state.totalCount,
            state.progress.masteryPercent,
          ),
          role: MxTextRole.contentBody,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';

class FlashcardCardListHeader extends StatelessWidget {
  const FlashcardCardListHeader({required this.sortMode, super.key});

  final ContentSortMode sortMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sortLabel = buildContentSortOptions(
      l10n,
    ).firstWhere((option) => option.value == sortMode).label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: MxSectionHeader(title: l10n.flashcardsCardsSectionTitle),
        ),
        const MxGap(MxSpace.md),
        Icon(
          Icons.sort_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const MxGap(MxSpace.xs),
        MxText(
          sortLabel,
          role: MxTextRole.tileMeta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

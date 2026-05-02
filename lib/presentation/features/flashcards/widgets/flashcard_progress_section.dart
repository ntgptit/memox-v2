import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_progress_ring.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardProgressSection extends StatelessWidget {
  const FlashcardProgressSection({
    required this.progress,
    required this.totalCount,
    super.key,
  });

  final FlashcardDeckProgressState progress;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_ProgressItem>[
      _ProgressItem(
        label: l10n.flashcardsProgressNew,
        count: progress.newCount,
      ),
      _ProgressItem(
        label: l10n.flashcardsProgressLearning,
        count: progress.learningCount,
      ),
      _ProgressItem(
        label: l10n.flashcardsProgressMastered,
        count: progress.masteredCount,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSectionHeader(
          title: l10n.flashcardsProgressTitle,
          subtitle: l10n.flashcardsProgressSubtitle,
        ),
        const MxGap(MxSpace.md),
        for (var index = 0; index < items.length; index++) ...[
          _ProgressTile(
            item: items[index],
            ratio: _ratioFor(items[index].count),
          ),
          if (index != items.length - 1) const MxGap(MxSpace.sm),
        ],
      ],
    );
  }

  double _ratioFor(int count) {
    if (totalCount == 0) {
      return 0;
    }
    return count / totalCount;
  }
}

class _ProgressItem {
  const _ProgressItem({required this.label, required this.count});

  final String label;
  final int count;
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({required this.item, required this.ratio});

  final _ProgressItem item;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countLabel = l10n.flashcardsProgressCountValue(item.count);

    return MxCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              MxProgressRing(value: ratio, showLabel: false),
              MxText(countLabel, role: MxTextRole.studyProgress),
            ],
          ),
          const MxGap(MxSpace.lg),
          Expanded(
            child: MxText(
              item.label,
              role: MxTextRole.tileTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const MxGap(MxSpace.md),
          MxText(countLabel, role: MxTextRole.tileTrailing),
        ],
      ),
    );
  }
}

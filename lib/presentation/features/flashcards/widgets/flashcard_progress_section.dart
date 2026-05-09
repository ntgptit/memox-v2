import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardProgressSection extends StatelessWidget {
  const FlashcardProgressSection({required this.progress, super.key});

  final FlashcardDeckProgressState progress;

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
        MxCard(
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                Expanded(child: _ProgressStat(item: items[index])),
                if (index != items.length - 1) const MxGap(MxSpace.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressItem {
  const _ProgressItem({required this.label, required this.count});

  final String label;
  final int count;
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.item});

  final _ProgressItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countLabel = l10n.flashcardsProgressCountValue(item.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MxText(countLabel, role: MxTextRole.studyProgress),
        const MxGap(MxSpace.xs),
        MxText(
          item.label,
          role: MxTextRole.tileMeta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

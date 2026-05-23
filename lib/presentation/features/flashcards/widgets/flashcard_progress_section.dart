import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/theme/extensions/theme_extensions.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
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
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      _ProgressItem(
        label: l10n.flashcardsProgressLearning,
        count: progress.learningCount,
        color: context.mxColors.warning,
      ),
      _ProgressItem(
        label: l10n.flashcardsProgressMastered,
        count: progress.masteredCount,
        color: context.mxColors.mastery,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSectionHeader(
          title: l10n.flashcardsProgressTitle,
          subtitle: context.showsSupportingCopy
              ? l10n.flashcardsProgressSubtitle
              : null,
        ),
        const MxGap(MxSpace.md),
        MxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MxLinearProgress(
                value: progress.masteryPercent / 100,
                label: l10n.flashcardsProgressMastered,
                showPercentage: true,
                size: MxProgressSize.large,
              ),
              const MxGap(MxSpace.lg),
              for (var index = 0; index < items.length; index++) ...[
                _ProgressStat(item: items[index]),
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
  const _ProgressItem({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.item});

  final _ProgressItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countLabel = l10n.flashcardsProgressCountValue(item.count);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: AppRadius.borderFull,
          ),
          child: const SizedBox.square(dimension: MxSpace.sm),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxText(
            item.label,
            role: MxTextRole.tileMeta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const MxGap(MxSpace.sm),
        MxText(countLabel, role: MxTextRole.tileTrailing),
      ],
    );
  }
}

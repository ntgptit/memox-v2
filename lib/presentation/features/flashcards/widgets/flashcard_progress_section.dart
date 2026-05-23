import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/extensions/theme_extensions.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card_breakdown_list.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardProgressSection extends StatelessWidget {
  const FlashcardProgressSection({required this.progress, super.key});

  final FlashcardDeckProgressState progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final mx = context.mxColors;
    final entries = <MxCardBreakdownEntry>[
      MxCardBreakdownEntry(
        label: l10n.deckBreakdownMastered,
        count: progress.masteredCount,
        color: mx.mastery,
      ),
      MxCardBreakdownEntry(
        label: l10n.deckBreakdownLearning,
        count: progress.learningCount,
        color: mx.warning,
      ),
      MxCardBreakdownEntry(
        label: l10n.deckBreakdownNew,
        count: progress.newCount,
        color: scheme.onSurfaceVariant,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSectionHeader(
          title: l10n.flashcardsProgressTitle,
          style: MxSectionHeaderStyle.overline,
        ),
        const MxGap(MxSpace.md),
        MxCardBreakdownList(entries: entries),
      ],
    );
  }
}

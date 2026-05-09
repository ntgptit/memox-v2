import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';

class FlashcardStudyModesSection extends StatelessWidget {
  const FlashcardStudyModesSection({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modes = <_ModeTileData>[
      _ModeTileData(label: l10n.studyModeReview, icon: Icons.style_outlined),
      _ModeTileData(
        label: l10n.studyModeMatch,
        icon: Icons.compare_arrows_rounded,
      ),
      _ModeTileData(label: l10n.studyModeGuess, icon: Icons.quiz_outlined),
      _ModeTileData(
        label: l10n.studyModeRecall,
        icon: Icons.psychology_alt_outlined,
      ),
      _ModeTileData(label: l10n.studyModeFill, icon: Icons.edit_note_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSectionHeader(
          title: l10n.studyFlowTitle,
          subtitle: l10n.flashcardsStudyModesTitle,
        ),
        const MxGap(MxSpace.md),
        enabled
            ? _StudyModeFlowCard(modes: modes)
            : _StudyUnavailableCard(message: l10n.decksStudyUnavailableNoCards),
      ],
    );
  }
}

class _ModeTileData {
  const _ModeTileData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _StudyModeFlowCard extends StatelessWidget {
  const _StudyModeFlowCard({required this.modes});

  final List<_ModeTileData> modes;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      child: Wrap(
        spacing: MxSpace.sm,
        runSpacing: MxSpace.sm,
        children: [
          for (var index = 0; index < modes.length; index++)
            _StudyModeChip(order: index + 1, data: modes[index]),
        ],
      ),
    );
  }
}

class _StudyModeChip extends StatelessWidget {
  const _StudyModeChip({required this.order, required this.data});

  final int order;
  final _ModeTileData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(MxSpace.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpace.md,
          vertical: MxSpace.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, color: scheme.primary),
            const MxGap(MxSpace.xs),
            MxText(
              '$order. ${data.label}',
              role: MxTextRole.tileMeta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyUnavailableCard extends StatelessWidget {
  const _StudyUnavailableCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      backgroundColor: scheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: scheme.onSurfaceVariant),
          const MxGap(MxSpace.md),
          Expanded(
            child: MxText(
              message,
              role: MxTextRole.contentBody,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

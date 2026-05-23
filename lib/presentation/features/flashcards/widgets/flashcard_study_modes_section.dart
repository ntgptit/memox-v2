import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_list_tile.dart';
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
          subtitle: context.showsSupportingCopy
              ? l10n.flashcardsStudyModesTitle
              : null,
        ),
        const MxGap(MxSpace.md),
        _StudyModeListCard(modes: modes, enabled: enabled),
        if (!enabled) ...[
          const MxGap(MxSpace.sm),
          _StudyUnavailableCard(message: l10n.decksStudyUnavailableNoCards),
        ],
      ],
    );
  }
}

class _ModeTileData {
  const _ModeTileData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _StudyModeListCard extends StatelessWidget {
  const _StudyModeListCard({required this.modes, required this.enabled});

  final List<_ModeTileData> modes;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      padding: const EdgeInsets.symmetric(vertical: MxSpace.xs),
      child: Column(
        children: [
          for (var index = 0; index < modes.length; index++)
            MxListTile(
              title: modes[index].label,
              leadingIcon: modes[index].icon,
              showChevron: enabled,
              enabled: enabled,
            ),
        ],
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

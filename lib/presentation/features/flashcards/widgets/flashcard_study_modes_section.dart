import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';

class FlashcardStudyModesSection extends StatelessWidget {
  const FlashcardStudyModesSection({
    required this.enabled,
    required this.onStartStudy,
    super.key,
  });

  final bool enabled;
  final VoidCallback onStartStudy;

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
        MxSectionHeader(title: l10n.flashcardsStudyModesTitle),
        const MxGap(MxSpace.md),
        for (var index = 0; index < modes.length; index++) ...[
          _StudyModeTile(
            data: modes[index],
            enabled: enabled,
            onTap: onStartStudy,
          ),
          if (index != modes.length - 1) const MxGap(MxSpace.sm),
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

class _StudyModeTile extends StatelessWidget {
  const _StudyModeTile({
    required this.data,
    required this.enabled,
    required this.onTap,
  });

  final _ModeTileData data;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = enabled ? scheme.onSurface : scheme.onSurfaceVariant;

    return MxCard(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          Icon(
            data.icon,
            color: enabled ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const MxGap(MxSpace.md),
          Expanded(
            child: MxText(
              data.label,
              role: MxTextRole.tileTitle,
              color: foreground,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: foreground),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/theme/extensions/theme_extensions.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_mode_mix_card.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';

class FlashcardStudyModesSection extends StatelessWidget {
  const FlashcardStudyModesSection({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modes = <_ModeTileData>[
      _ModeTileData(
        label: l10n.studyModeReview,
        subtitle: l10n.studyModeReviewSubtitle,
        icon: Icons.style_outlined,
        masteryTone: false,
      ),
      _ModeTileData(
        label: l10n.studyModeMatch,
        subtitle: l10n.studyModeMatchSubtitle,
        icon: Icons.compare_arrows_rounded,
        masteryTone: false,
      ),
      _ModeTileData(
        label: l10n.studyModeGuess,
        subtitle: l10n.studyModeGuessSubtitle,
        icon: Icons.quiz_outlined,
        masteryTone: false,
      ),
      _ModeTileData(
        label: l10n.studyModeRecall,
        subtitle: l10n.studyModeRecallSubtitle,
        icon: Icons.psychology_alt_outlined,
        masteryTone: true,
      ),
      _ModeTileData(
        label: l10n.studyModeFill,
        subtitle: l10n.studyModeFillSubtitle,
        icon: Icons.edit_note_rounded,
        masteryTone: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSectionHeader(
          title: l10n.studyFlowTitle,
          style: MxSectionHeaderStyle.overline,
        ),
        const MxGap(MxSpace.md),
        if (enabled) ...[
          MxModeMixCard(
            title: l10n.studyModeMixTitle,
            subtitle: l10n.studyModeMixSubtitle,
            badgeLabel: l10n.studyModeMixBadge,
            modeIcons: const [
              Icons.style_outlined,
              Icons.compare_arrows_rounded,
              Icons.quiz_outlined,
              Icons.psychology_alt_outlined,
              Icons.edit_note_rounded,
            ],
            modesSummary: l10n.studyModeMixSummary,
          ),
          const MxGap(MxSpace.sm),
        ],
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
  const _ModeTileData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.masteryTone,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool masteryTone;
}

class _StudyModeListCard extends StatelessWidget {
  const _StudyModeListCard({required this.modes, required this.enabled});

  final List<_ModeTileData> modes;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn =
            constraints.hasBoundedWidth && context.gridColumns(base: 2) > 1;
        final tiles = [
          for (final mode in modes)
            _StudyModeTile(mode: mode, enabled: enabled),
        ];
        if (!twoColumn) {
          return Column(children: tiles);
        }
        return Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: (constraints.maxWidth - MxSpace.sm) / 2,
                child: tile,
              ),
          ],
        );
      },
    );
  }
}

class _StudyModeTile extends StatelessWidget {
  const _StudyModeTile({required this.mode, required this.enabled});

  final _ModeTileData mode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = mode.masteryTone ? context.mxColors.mastery : scheme.primary;

    return MxCard(
      key: ValueKey('study_mode_${mode.label}'),
      padding: const EdgeInsets.all(MxSpace.md),
      backgroundColor: enabled
          ? scheme.surfaceContainerLowest
          : scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(mode.icon, color: enabled ? accent : scheme.onSurfaceVariant),
          const MxGap(MxSpace.xs),
          MxText(mode.label, role: MxTextRole.tileTitle, enabled: enabled),
          if (mode.subtitle != mode.label) ...[
            const MxGap(MxSpace.xxs),
            MxText(
              mode.subtitle,
              role: MxTextRole.tileMeta,
              enabled: enabled,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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

import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_progress_indicator.dart';
import 'mx_text.dart';

/// Card-form study set surface used inside deck grids and library lists.
///
/// Layout follows the MemoX mobile kit: identity icon tile, title/meta,
/// mastery strip, and a compact trailing percent. The surface stays low
/// chrome so the deck content, not the container, carries the hierarchy.
class MxDeckCard extends StatelessWidget {
  const MxDeckCard({
    required this.title,
    required this.icon,
    this.metaLine,
    this.masteryPercent,
    this.onTap,
    this.onLongPress,
    this.trailing,
    super.key,
  });

  /// guard:raw-size-reviewed progress bar height — slim enough to feel like
  /// a hint, not a primary surface element.
  static const double _progressBarHeight = 6;

  final String title;
  final IconData icon;

  /// Single short meta line, e.g. `168 cards`.
  final String? metaLine;

  /// Mastery percentage in `[0, 100]`; `null` hides the progress bar row.
  final int? masteryPercent;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = _resolveIconPalette(context, Theme.of(context).colorScheme);
    final hasMastery = masteryPercent != null;
    final mastery = (masteryPercent ?? 0).clamp(0, 100);
    final progressValue = mastery / 100;
    final trailingContent =
        trailing ??
        (hasMastery
            ? MxText(
                '$mastery%',
                role: MxTextRole.tileTrailing,
                color: context.mxColors.masteryProgress(progressValue),
              )
            : null);

    return MxCard(
      variant: MxCardVariant.filled,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppIconSizes.xxxl,
            height: AppIconSizes.xxxl,
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: AppRadius.borderLg,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: AppIconSizes.md, color: palette.foreground),
          ),
          const MxGap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MxText(
                        title,
                        role: MxTextRole.tileTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailingContent != null) ...[
                      const MxGap(AppSpacing.sm),
                      trailingContent,
                    ],
                  ],
                ),
                if (metaLine != null) ...[
                  const MxGap(AppSpacing.xxs),
                  MxText(
                    metaLine!,
                    role: MxTextRole.tileMeta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (hasMastery) ...[
                  const MxGap(AppSpacing.sm),
                  MxLinearProgress(
                    value: progressValue,
                    size: MxProgressSize.small,
                    color: context.mxColors.masteryProgress(progressValue),
                    minHeight: _progressBarHeight,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _DeckCardPalette _resolveIconPalette(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final mx = context.mxColors;
    // Shared with [MxStudySetTile] / [MxFolderTile] so a single deck reads
    // with the same identity color across list rows and grid cards.
    final palettes = <_DeckCardPalette>[
      _DeckCardPalette(scheme.primaryContainer, scheme.onPrimaryContainer),
      _DeckCardPalette(scheme.secondaryContainer, scheme.onSecondaryContainer),
      _DeckCardPalette(scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _DeckCardPalette(mx.successContainer, mx.onSuccessContainer),
      _DeckCardPalette(mx.warningContainer, mx.onWarningContainer),
      _DeckCardPalette(mx.infoContainer, mx.onInfoContainer),
    ];
    final seed = title.isEmpty ? 0 : title.hashCode;
    final index = seed.abs() % palettes.length;
    return palettes[index];
  }
}

class _DeckCardPalette {
  const _DeckCardPalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

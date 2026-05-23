import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_progress_indicator.dart';
import 'mx_text.dart';

/// Card-form study set surface used inside 2-col deck grids.
///
/// Layout: tall color block top (palette derived from [title] hash) over a
/// title + meta + progress strip. Designed to read as a "Quizlet-mobile"
/// deck cover — much more visually rich than the row variant
/// ([MxStudySetTile]) and used when a grid layout is more appropriate than
/// a vertical list.
class MxDeckCard extends StatelessWidget {
  const MxDeckCard({
    required this.title,
    required this.icon,
    this.metaLine,
    this.masteryPercent,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  /// guard:raw-size-reviewed cover aspect ratio (16:9) keeps the colored
  /// block readable across compact phone widths (~165-200 dp) without
  /// dwarfing the title row beneath it.
  static const double _coverAspectRatio = 16 / 9;

  /// guard:raw-size-reviewed progress bar height — slim enough to feel like
  /// a hint, not a primary surface element.
  static const double _progressBarHeight = 4;

  final String title;
  final IconData icon;

  /// Single short meta line, e.g. `168 cards`.
  final String? metaLine;

  /// Mastery percentage in `[0, 100]`; `null` hides the progress bar row.
  final int? masteryPercent;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = _resolveIconPalette(context, Theme.of(context).colorScheme);
    final mastery = (masteryPercent ?? 0).clamp(0, 100);
    final progressValue = mastery / 100;

    return MxCard(
      variant: MxCardVariant.filled,
      padding: EdgeInsets.zero,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: _coverAspectRatio,
            child: Container(
              color: palette.background,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: AppIconSizes.xl,
                color: palette.foreground,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MxText(
                  title,
                  role: MxTextRole.tileTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                if (masteryPercent != null) ...[
                  const MxGap(AppSpacing.sm),
                  SizedBox(
                    height: _progressBarHeight,
                    child: MxLinearProgress(
                      value: progressValue,
                      size: MxProgressSize.small,
                    ),
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

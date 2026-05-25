import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_progress_indicator.dart';
import 'mx_text.dart';

/// How [MxDeckCard] renders its trailing slot.
///
/// `chevron` matches the Design System Library row default; `percent` shows
/// the mastery `%` text for surfaces where a numeric readout is preferred.
enum MxDeckCardTrailing { chevron, percent, none }

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
    this.trailingMode = MxDeckCardTrailing.chevron,
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

  /// Custom trailing widget. When provided, overrides [trailingMode].
  final Widget? trailing;

  /// Built-in trailing variant used when [trailing] is null. Defaults to
  /// [MxDeckCardTrailing.chevron] to match the Design System Library row.
  final MxDeckCardTrailing trailingMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = _resolveIconPalette(context, scheme);
    final hasMastery = masteryPercent != null;
    final mastery = (masteryPercent ?? 0).clamp(0, 100);
    final progressValue = mastery / 100;
    final trailingContent =
        trailing ??
        _buildDefaultTrailing(
          context,
          hasMastery: hasMastery,
          mastery: mastery,
          progressValue: progressValue,
        );

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

  Widget? _buildDefaultTrailing(
    BuildContext context, {
    required bool hasMastery,
    required int mastery,
    required double progressValue,
  }) {
    final scheme = Theme.of(context).colorScheme;
    switch (trailingMode) {
      case MxDeckCardTrailing.none:
        return null;
      case MxDeckCardTrailing.percent:
        if (!hasMastery) return null;
        return MxText(
          '$mastery%',
          role: MxTextRole.tileTrailing,
          color: context.mxColors.masteryProgress(progressValue),
        );
      case MxDeckCardTrailing.chevron:
        return Icon(
          Icons.chevron_right_rounded,
          size: AppIconSizes.md,
          color: scheme.onSurfaceVariant,
        );
    }
  }

  _DeckCardPalette _resolveIconPalette(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final mx = context.mxColors;
    // Brand-color tint pattern from Design System "02 · Library" — see
    // [MxFolderTile._resolveIconPalette] for the rationale. Keeping the same
    // brand-color list here ensures a deck reads with the same identity tone
    // whether rendered as a folder row or a deck card.
    final brandColors = <Color>[
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      mx.success,
      mx.warning,
      mx.info,
    ];
    final seed = title.isEmpty ? 0 : title.hashCode;
    final brand = brandColors[seed.abs() % brandColors.length];
    return _DeckCardPalette(
      brand.withValues(alpha: AppOpacity.disabledSurface),
      brand,
    );
  }
}

class _DeckCardPalette {
  const _DeckCardPalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

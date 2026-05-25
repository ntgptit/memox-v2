import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_progress_indicator.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

/// How [MxFolderTile] renders its trailing slot.
enum MxFolderTileTrailing { chevron, none }

/// Library list row used by **both** folder and deck listings.
///
/// Mirrors the Design System "02 · Library" pattern: a single shape that the
/// whole library reads as one family of cards. Layout: tonal icon tile +
/// title + single meta line + inline 6px mastery bar (when known) + chevron.
class MxFolderTile extends StatelessWidget {
  const MxFolderTile({
    required this.name,
    required this.icon,
    this.caption,
    this.masteryPercent,
    this.tileColor,
    this.iconColor,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.trailingMode = MxFolderTileTrailing.chevron,
    super.key,
  });

  /// guard:raw-size-reviewed Inline progress bar height per Design System.
  static const double _progressBarHeight = 6;

  final String name;
  final IconData icon;

  /// Single-line secondary line, e.g. `5 decks · 128 items`.
  final String? caption;

  /// Mastery in `[0, 100]`. `null` hides the inline progress bar.
  final int? masteryPercent;

  /// Tonal container color. Defaults to a hash-derived identity color.
  final Color? tileColor;

  /// Icon color. Defaults to the identity palette foreground.
  final Color? iconColor;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Custom trailing override. When provided, [trailingMode] is ignored.
  final Widget? trailing;

  /// Built-in trailing variant when [trailing] is null. Defaults to chevron
  /// to match the Design System Library row.
  final MxFolderTileTrailing trailingMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = _resolveIconPalette(context, scheme);
    final hasMastery = masteryPercent != null;
    final mastery = (masteryPercent ?? 0).clamp(0, 100);
    final progressValue = mastery / 100;

    final row = LayoutBuilder(
      builder: (context, constraints) {
        final showLeading = AppLayout.showsFolderTileLeading(
          hasBoundedWidth: constraints.hasBoundedWidth,
          maxWidth: constraints.maxWidth,
        );
        final showTrailing = AppLayout.showsFolderTileTrailing(
          hasBoundedWidth: constraints.hasBoundedWidth,
          maxWidth: constraints.maxWidth,
        );
        final iconTileSize = AppLayout.listTileIconSize(context);
        final contentGap = context.isCompactMobile
            ? AppSpacing.md
            : AppSpacing.lg;
        final trailingWidget = trailing ?? _buildDefaultTrailing(context);
        // Library rows mirror MxDeckCard — share the same card padding so
        // folder tiles and deck cards read as one family. Mastery bar gets
        // extra bottom inset so the indigo fill does not touch the edge.
        final basePadding = AppLayout.cardPadding(context);
        final tilePadding = hasMastery
            ? basePadding.copyWith(bottom: basePadding.bottom + AppSpacing.xs)
            : basePadding;

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: tilePadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showLeading) ...[
                  Container(
                    width: iconTileSize,
                    height: iconTileSize,
                    decoration: BoxDecoration(
                      color: tileColor ?? palette.background,
                      borderRadius: AppRadius.borderLg,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: AppIconSizes.md,
                      color: iconColor ?? palette.foreground,
                    ),
                  ),
                  SizedBox(width: contentGap),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MxText(
                        name,
                        role: MxTextRole.tileTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      if (caption != null) ...[
                        const MxGap(AppSpacing.xxs),
                        MxText(
                          caption!,
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
                          color: context.mxColors.masteryProgress(
                            progressValue,
                          ),
                          minHeight: _progressBarHeight,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingWidget != null && showTrailing) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailingWidget,
                ],
              ],
            ),
          ),
        );
      },
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: scheme.outlineVariant.withValues(
            alpha: AppOpacity.ghostBorder,
          ),
        ),
      ),
      child: MxTappable(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        onTap: onTap,
        onLongPress: onLongPress,
        backgroundColor: scheme.surfaceContainerLowest,
        overlayBaseColor: scheme.primary,
        child: row,
      ),
    );
  }

  Widget? _buildDefaultTrailing(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (trailingMode) {
      case MxFolderTileTrailing.none:
        return null;
      case MxFolderTileTrailing.chevron:
        return Icon(
          Icons.chevron_right_rounded,
          size: AppIconSizes.md,
          color: scheme.onSurfaceVariant,
        );
    }
  }

  _IconTilePalette _resolveIconPalette(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final mx = context.mxColors;
    // Brand-color tint pattern from Design System "02 · Library": each tile
    // shows a 12% alpha wash of the brand color with the full color as the
    // icon fill. This reads as a vibrant identity chip even on dark navy
    // backgrounds, where the M3 *Container tokens collapse to muted tones.
    final brandColors = <Color>[
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      mx.success,
      mx.warning,
      mx.info,
    ];
    final seed = name.isEmpty ? 0 : name.hashCode;
    final brand = brandColors[seed.abs() % brandColors.length];
    return _IconTilePalette(
      brand.withValues(alpha: AppOpacity.disabledSurface),
      brand,
    );
  }
}

class _IconTilePalette {
  const _IconTilePalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

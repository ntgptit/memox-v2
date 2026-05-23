import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_progress_ring.dart';
import 'mx_text.dart';
import 'mx_tappable.dart';

/// Calm, low-chrome folder row for library listings.
///
/// Mirrors [MxStudySetTile] geometry so folder rows and deck rows feel like
/// the same family: identical leading tile size, padding, identity palette,
/// and trailing slot. Layout: tonal icon tile (color picked from the folder
/// name hash) + title + optional single caption + optional trailing widget.
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
    super.key,
  });

  final String name;
  final IconData icon;

  /// Single-line secondary line, e.g. `5 decks · 128 items`.
  final String? caption;

  /// Mastery in `[0, 100]`. `null` hides the trailing ring.
  final int? masteryPercent;

  /// Tonal container color. Defaults to a hash-derived identity color.
  final Color? tileColor;

  /// Icon color. Defaults to the identity palette foreground.
  final Color? iconColor;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = _resolveIconPalette(context, scheme);

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

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: AppLayout.listTilePadding(context),
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
                    ],
                  ),
                ),
                if (masteryPercent != null && showTrailing) ...[
                  const SizedBox(width: AppSpacing.md),
                  MxProgressRing(value: masteryPercent! / 100),
                ],
                if (trailing != null && showTrailing) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
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

  _IconTilePalette _resolveIconPalette(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final mx = context.mxColors;
    // Same identity ramp as [MxStudySetTile] — folder + deck rows that
    // belong together pick from one shared palette so the Library reads as
    // a single family of cards.
    final palettes = <_IconTilePalette>[
      _IconTilePalette(scheme.primaryContainer, scheme.onPrimaryContainer),
      _IconTilePalette(scheme.secondaryContainer, scheme.onSecondaryContainer),
      _IconTilePalette(scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _IconTilePalette(mx.successContainer, mx.onSuccessContainer),
      _IconTilePalette(mx.warningContainer, mx.onWarningContainer),
      _IconTilePalette(mx.infoContainer, mx.onInfoContainer),
    ];
    final seed = name.isEmpty ? 0 : name.hashCode;
    final index = seed.abs() % palettes.length;
    return palettes[index];
  }
}

class _IconTilePalette {
  const _IconTilePalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

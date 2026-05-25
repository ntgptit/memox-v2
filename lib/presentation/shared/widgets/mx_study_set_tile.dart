import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_avatar.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

/// List tile for a study set / folder / class entry in library listings.
/// Layout: colored icon tile on the left, title + meta rows on the right.
/// Matches the "Vitamin_Book2_..." rows in the library screen.
class MxStudySetTile extends StatelessWidget {
  const MxStudySetTile({
    required this.title,
    required this.icon,
    this.metaLine,
    this.ownerInitials,
    this.ownerLabel,
    this.ownerBadge,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.iconBackground,
    this.iconColor,
    super.key,
  });

  static const double _contentGap = AppSpacing.lg;

  final String title;
  final IconData icon;

  /// Single-line meta row, e.g. `Học phần · 55 thuật ngữ · Tác giả: bạn`.
  final String? metaLine;

  final String? ownerInitials;
  final String? ownerLabel;
  final String? ownerBadge;

  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Color? iconBackground;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = _resolveIconPalette(context, scheme);

    final tile = LayoutBuilder(
      builder: (context, constraints) {
        final iconTileSize = AppLayout.studySetTileIconSize(context);
        final contentGap = context.isCompactMobile
            ? AppSpacing.md
            : _contentGap;
        final stackTrailing =
            trailing != null &&
            AppLayout.stacksStudySetTileTrailing(
              hasBoundedWidth: constraints.hasBoundedWidth,
              maxWidth: constraints.maxWidth,
            );

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: AppLayout.listTilePadding(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconTileSize,
                  height: iconTileSize,
                  decoration: BoxDecoration(
                    color: iconBackground ?? palette.background,
                    borderRadius: AppRadius.borderLg,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: AppIconSizes.md,
                    color: iconColor ?? palette.foreground,
                  ),
                ),
                MxGap(contentGap),
                Expanded(child: _buildTextColumn(stackTrailing: stackTrailing)),
                if (trailing != null && !stackTrailing) ...[
                  const MxGap(AppSpacing.sm),
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
        child: tile,
      ),
    );
  }

  _IconTilePalette _resolveIconPalette(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final mx = context.mxColors;
    // Brand-color tint pattern shared with [MxDeckCard] / [MxFolderTile] so
    // every Library row feels like one family of cards.
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
    return _IconTilePalette(
      brand.withValues(alpha: AppOpacity.disabledSurface),
      brand,
    );
  }

  Widget _buildTextColumn({required bool stackTrailing}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
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
      if (ownerLabel != null) ...[
        const MxGap(AppSpacing.sm),
        Row(
          children: [
            MxAvatar(
              initials: ownerInitials,
              size: MxAvatarSize.sm,
              badgeLabel: ownerBadge,
            ),
            if (ownerBadge == null) ...[
              const MxGap(AppSpacing.sm),
              Expanded(
                child: MxText(
                  ownerLabel!,
                  role: MxTextRole.tileMeta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
      if (trailing != null && stackTrailing) ...[
        const MxGap(AppSpacing.sm),
        Align(alignment: Alignment.centerRight, child: trailing),
      ],
    ],
  );
}

class _IconTilePalette {
  const _IconTilePalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

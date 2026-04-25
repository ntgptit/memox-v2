import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_progress_ring.dart';
import 'mx_text.dart';
import 'mx_tappable.dart';

/// Calm, low-chrome folder row for library listings.
///
/// Layout: rounded-square tonal icon tile, title + caption, optional trailing
/// mastery ring. No card, no shadow, no explicit border — relies on an
/// indented divider between rows for separation.
///
/// Sizing tokens are intentional:
/// - tile 48×48, icon 24 → readable on compact + expanded tiers.
/// - vertical padding `md` (12) + min row height 64 → comfortable tap target
///   and stops the mastery ring from crowding the caption.
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

  /// guard:raw-size-reviewed minimum row height keeps tap target ≥ 48 dp even
  /// when caption is absent; not a theme token because it is row-geometry.
  static const double _minRowHeight = 64;
  final String name;
  final IconData icon;

  /// Single-line secondary line, e.g. `5 decks · 128 items`.
  final String? caption;

  /// Mastery in `[0, 100]`. `null` hides the trailing ring.
  final int? masteryPercent;

  /// Tonal container color. Defaults to `colorScheme.primaryContainer`.
  final Color? tileColor;

  /// Icon color. Defaults to `colorScheme.onPrimaryContainer`.
  final Color? iconColor;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minRowHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppIconSizes.xxxl,
              height: AppIconSizes.xxxl,
              decoration: BoxDecoration(
                color: tileColor ?? scheme.primaryContainer,
                borderRadius: AppRadius.borderMd,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: AppIconSizes.lg,
                color: iconColor ?? scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
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
            if (masteryPercent != null) ...[
              const SizedBox(width: AppSpacing.md),
              MxProgressRing(value: masteryPercent! / 100),
            ],
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );

    if (onTap == null && onLongPress == null) return row;
    return MxTappable(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      onTap: onTap,
      onLongPress: onLongPress,
      child: row,
    );
  }
}

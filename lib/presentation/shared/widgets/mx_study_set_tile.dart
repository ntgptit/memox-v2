import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'mx_avatar.dart';
import '../../../core/theme/mx_gap.dart';
import 'mx_text.dart';
import 'mx_tappable.dart';

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

  final Color? iconBackground;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppIconSizes.xxl, // guard:raw-size-reviewed icon tile token
            height: AppIconSizes.xxl, // guard:raw-size-reviewed icon tile token
            decoration: BoxDecoration(
              color: iconBackground ?? scheme.primaryContainer,
              borderRadius: AppRadius.borderMd,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: AppIconSizes.md,
              color: iconColor ?? scheme.onPrimaryContainer,
            ),
          ),
          const MxGap(_contentGap),
          Expanded(
            child: Column(
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
                        MxText(ownerLabel!, role: MxTextRole.tileMeta),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const MxGap(AppSpacing.sm), trailing!],
        ],
      ),
    );

    if (onTap == null) return tile;
    return MxTappable(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      onTap: onTap,
      child: tile,
    );
  }
}

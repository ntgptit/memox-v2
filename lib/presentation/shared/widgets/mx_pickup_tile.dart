import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_icon_tile.dart';
import 'mx_text.dart';

/// Card-backed row for "pick up where you left off" deck or study entries.
class MxPickupTile extends StatelessWidget {
  const MxPickupTile({
    required this.title,
    required this.subtitle,
    this.leadingIcon = Icons.menu_book_outlined,
    this.leadingTone = MxIconTileTone.neutral,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final MxIconTileTone leadingTone;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MxIconTile(icon: leadingIcon, tone: leadingTone),
            const MxGap(AppSpacing.md),
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
                  const MxGap(AppSpacing.xxs),
                  MxText(
                    subtitle,
                    role: MxTextRole.tileMeta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const MxGap(AppSpacing.sm),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppIconSizes.lg,
                  color: scheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }
}

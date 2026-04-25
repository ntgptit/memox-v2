import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_text.dart';

/// Reusable term / definition row for flashcard and deck content lists.
class MxTermRow extends StatelessWidget {
  const MxTermRow({
    required this.term,
    required this.definition,
    this.caption,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.padding = AppSpacing.card,
    this.termMaxLines = 2,
    this.definitionMaxLines = 3,
    super.key,
  });

  final String term;
  final String definition;
  final String? caption;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final EdgeInsetsGeometry padding;
  final int termMaxLines;
  final int definitionMaxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveTrailing =
        trailing ??
        (selected
            ? Icon(
                Icons.check_circle_rounded,
                size: AppIconSizes.md,
                color: scheme.primary,
              )
            : null);

    return MxCard(
      variant: selected ? MxCardVariant.filled : MxCardVariant.outlined,
      padding: padding,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const MxGap(AppSpacing.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MxText(
                  term,
                  role: MxTextRole.tileTitle,
                  maxLines: termMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                const MxGap(AppSpacing.xxs),
                MxText(
                  definition,
                  role: MxTextRole.contentBody,
                  maxLines: definitionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (caption != null) ...[
                  const MxGap(AppSpacing.sm),
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
          if (effectiveTrailing != null) ...[
            const MxGap(AppSpacing.md),
            effectiveTrailing,
          ],
        ],
      ),
    );
  }
}

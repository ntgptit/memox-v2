import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';
import 'mx_card.dart';

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
    final textTheme = Theme.of(context).textTheme;
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
          if (leading != null) ...[leading!, const MxGap.h(AppSpacing.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  term,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: termMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                const MxGap(AppSpacing.xxs),
                Text(
                  definition,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: definitionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (caption != null) ...[
                  const MxGap(AppSpacing.sm),
                  Text(
                    caption!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (effectiveTrailing != null) ...[
            const MxGap.h(AppSpacing.md),
            effectiveTrailing,
          ],
        ],
      ),
    );
  }
}

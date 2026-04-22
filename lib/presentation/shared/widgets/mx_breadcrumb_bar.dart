import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';

class MxBreadcrumb {
  const MxBreadcrumb({required this.label, this.onTap, this.icon});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
}

/// Horizontal breadcrumb trail (Folder A / Folder B / Deck C).
///
/// The last crumb is rendered as the current page (non-tappable, stronger
/// weight); previous crumbs are tappable text buttons.
class MxBreadcrumbBar extends StatelessWidget {
  const MxBreadcrumbBar({
    required this.items,
    this.maxCrumbs = 4,
    super.key,
  });

  final List<MxBreadcrumb> items;
  final int maxCrumbs;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final effective = _collapse(items, maxCrumbs);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          for (int i = 0; i < effective.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Icon(
                  Icons.chevron_right,
                  size: AppIconSizes.sm,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            _crumb(context, effective[i], isLast: i == effective.length - 1),
          ],
        ],
      ),
    );
  }

  Widget _crumb(BuildContext context, MxBreadcrumb b, {required bool isLast}) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = textTheme.labelLarge;
    final style = isLast
        ? baseStyle?.copyWith(color: scheme.onSurface)
        : baseStyle?.copyWith(color: scheme.onSurfaceVariant);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (b.icon != null) ...[
          Icon(b.icon, size: AppIconSizes.sm, color: style?.color),
          const MxGap.h(AppSpacing.xs),
        ],
        Text(b.label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );

    if (isLast || b.onTap == null) return content;

    return InkWell(
      borderRadius: AppRadius.borderSm,
      onTap: b.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: content,
      ),
    );
  }

  List<MxBreadcrumb> _collapse(List<MxBreadcrumb> all, int max) {
    if (all.length <= max) return all;
    return [
      all.first,
      const MxBreadcrumb(label: '…'),
      ...all.sublist(all.length - (max - 2)),
    ];
  }
}

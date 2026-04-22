import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';

/// Row-level section header: big title on the left, optional action link on
/// the right. Matches patterns like "Thành tựu – Xem tất cả".
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
              ),
              if (subtitle != null) ...[
                const MxGap(AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

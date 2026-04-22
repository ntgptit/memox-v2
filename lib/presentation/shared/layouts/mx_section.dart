import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';

/// Grouping header + optional action + body. Useful on dashboards and
/// settings pages to delineate logical groups.
class MxSection extends StatelessWidget {
  const MxSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.padding = EdgeInsets.zero,
    this.spacing = AppSpacing.md,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium
                          ?.copyWith(color: scheme.onSurface),
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
              ?action,
            ],
          ),
          MxGap(spacing),
          child,
        ],
      ),
    );
  }
}

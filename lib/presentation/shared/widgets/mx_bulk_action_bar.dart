import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';
import 'mx_card.dart';

/// Elevated action bar for selection-mode and other bulk operations.
class MxBulkActionBar extends StatelessWidget {
  const MxBulkActionBar({
    required this.label,
    this.subtitle,
    this.leading,
    this.actions = const [],
    super.key,
  });

  final String label;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      variant: MxCardVariant.elevated,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 520;
          final info = _InfoBlock(
            label: label,
            subtitle: subtitle,
            leading: leading,
          );
          final actionWrap = actions.isEmpty
              ? null
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.end,
                  children: actions,
                );

          if (isStacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                info,
                if (actionWrap != null) ...[
                  const MxGap(AppSpacing.md),
                  actionWrap,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: info),
              if (actionWrap != null) ...[
                const MxGap.h(AppSpacing.md),
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: actionWrap,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.subtitle,
    required this.leading,
  });

  final String label;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const MxGap.h(AppSpacing.md)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
              ),
              if (subtitle != null) ...[
                const MxGap(AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

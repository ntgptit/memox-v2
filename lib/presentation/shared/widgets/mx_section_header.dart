import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_text.dart';

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
    final action = actionLabel != null && onAction != null
        ? TextButton(
            onPressed: onAction,
            child: MxText(
              actionLabel!,
              role: MxTextRole.tileTrailing,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        : null;
    final heading = _SectionHeading(title: title, subtitle: subtitle);
    if (action == null) return heading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackAction = AppLayout.stacksSectionAction(
          hasBoundedWidth: constraints.hasBoundedWidth,
          maxWidth: constraints.maxWidth,
          textScale: MediaQuery.textScalerOf(context).scale(1),
        );

        if (stackAction) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading,
              const MxGap(AppSpacing.xs),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            action,
          ],
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(title, role: MxTextRole.sectionTitle),
        if (subtitle != null) ...[
          const MxGap(AppSpacing.xxs),
          MxText(subtitle!, role: MxTextRole.sectionSubtitle),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../widgets/mx_text.dart';
import 'mx_gap.dart';

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
  Widget build(BuildContext context) => Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = _SectionHeading(title: title, subtitle: subtitle);
              if (action == null) return heading;

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  action!,
                ],
              );
            },
          ),
          MxGap(spacing),
          child,
        ],
      ),
    );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
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

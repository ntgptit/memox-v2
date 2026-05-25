import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/utils/string_utils.dart';
import '../layouts/mx_gap.dart';
import 'mx_text.dart';

/// Visual style of an [MxSectionHeader] title.
///
/// * [title] renders as a regular `sectionTitle` heading.
/// * [overline] renders as an 11/700 uppercase tracked label per Design
///   System "03 · Deck detail" (`STUDY MODES`, `CARD BREAKDOWN`).
enum MxSectionHeaderStyle { title, overline }

/// Row-level section header: big title on the left, optional action link on
/// the right. Matches patterns like "Thành tựu – Xem tất cả".
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
    this.style = MxSectionHeaderStyle.title,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final MxSectionHeaderStyle style;

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
    final heading = _SectionHeading(
      title: title,
      subtitle: subtitle,
      style: style,
    );
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
  const _SectionHeading({
    required this.title,
    required this.style,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final MxSectionHeaderStyle style;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      switch (style) {
        MxSectionHeaderStyle.title => MxText(
          title,
          role: MxTextRole.sectionTitle,
        ),
        MxSectionHeaderStyle.overline => MxText(
          StringUtils.upperCaseToEmpty(title),
          role: MxTextRole.overline,
        ),
      },
      if (subtitle != null) ...[
        const MxGap(AppSpacing.xxs),
        MxText(subtitle!, role: MxTextRole.sectionSubtitle),
      ],
    ],
  );
}

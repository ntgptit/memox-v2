import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MxText(title, role: MxTextRole.sectionTitle),
              if (subtitle != null) ...[
                const MxGap(AppSpacing.xxs),
                MxText(subtitle!, role: MxTextRole.sectionSubtitle),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_text.dart';

enum MxStatTone { neutral, primary, streak, mastery, success }

/// Compact metric card for dashboard counters and progress summaries.
class MxStatCard extends StatelessWidget {
  const MxStatCard({
    required this.label,
    required this.value,
    this.tone = MxStatTone.neutral,
    this.icon,
    this.supportingText,
    this.unit,
    super.key,
  });

  final String label;
  final String value;
  final MxStatTone tone;
  final IconData? icon;
  final String? supportingText;

  /// Optional short unit suffix rendered next to [value] in a smaller, muted
  /// style. Matches the Design System Home/Stats cards (`7 days`, `512 cards`,
  /// `88%`).
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _accentColor(context);

    return MxCard(
      variant: MxCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppIconSizes.sm, color: accent),
                const MxGap(AppSpacing.sm),
              ],
              Expanded(
                child: MxText(
                  label,
                  role: MxTextRole.formLabel,
                  color: accent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const MxGap(AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: MxText(
                  value,
                  role: MxTextRole.pageTitle,
                  color: scheme.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const MxGap(AppSpacing.xs),
                MxText(
                  unit!,
                  role: MxTextRole.tileMeta,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          if (supportingText != null) ...[
            const MxGap(AppSpacing.xxs),
            MxText(
              supportingText!,
              role: MxTextRole.formHelper,
              color: accent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _accentColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mxColors = context.mxColors;

    return switch (tone) {
      MxStatTone.neutral => scheme.onSurfaceVariant,
      MxStatTone.primary => scheme.primary,
      MxStatTone.streak => mxColors.streak,
      MxStatTone.mastery => mxColors.mastery,
      MxStatTone.success => mxColors.success,
    };
  }
}

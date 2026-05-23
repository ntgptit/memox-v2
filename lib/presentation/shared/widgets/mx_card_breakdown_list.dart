import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';

/// A single status row in [MxCardBreakdownList].
class MxCardBreakdownEntry {
  const MxCardBreakdownEntry({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;

  /// Semantic dot color — pass `mxColors.success`, `scheme.primary`, etc.
  /// Never a raw hex.
  final Color color;
}

/// Renders the "Card breakdown" panel from the Design System Deck Detail
/// screen: a vertical list of `[dot]  label  count` rows, separated by ghost
/// dividers.
class MxCardBreakdownList extends StatelessWidget {
  const MxCardBreakdownList({required this.entries, super.key});

  final List<MxCardBreakdownEntry> entries;

  /// guard:raw-size-reviewed Status-dot diameter per Design System spec.
  static const double _dotSize = 10;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dividerColor = scheme.outlineVariant.withValues(
      alpha: AppOpacity.ghostBorder,
    );

    return MxCard(
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: entries[i].color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const MxGap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      entries[i].label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entries[i].count}',
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i < entries.length - 1)
              Divider(height: 1, thickness: 1, color: dividerColor),
          ],
        ],
      ),
    );
  }
}

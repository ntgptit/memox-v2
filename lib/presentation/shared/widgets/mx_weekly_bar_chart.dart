import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';

/// One bar of [MxWeeklyBarChart].
class MxWeeklyBarChartEntry {
  const MxWeeklyBarChartEntry({required this.label, required this.value});

  /// Short axis label (`M`, `T`, …).
  final String label;

  /// Raw value. Bars normalize against `max(values)` so callers can pass
  /// review counts, minutes studied, retention %, etc.
  final num value;
}

/// 7-bar weekly bar chart used on the Stats screen per Design System UI kit.
///
/// Bars share a single `color` so the visualization stays mode-neutral. Pass
/// `Theme.of(context).colorScheme.primary` (default) or `context.mxColors.*`.
class MxWeeklyBarChart extends StatelessWidget {
  const MxWeeklyBarChart({
    required this.entries,
    this.color,
    this.height = _defaultHeight,
    super.key,
  });

  final List<MxWeeklyBarChartEntry> entries;
  final Color? color;

  /// guard:raw-size-reviewed Chart drawing area height per Design System spec.
  final double height;

  /// guard:raw-size-reviewed Default chart height (Design System spec: 120).
  static const double _defaultHeight = 120;

  /// Bar corner radius. `AppRadius.sm` matches the Design System bar chart.
  static const BorderRadius _barBorderRadius = AppRadius.borderSm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final barColor = color ?? scheme.primary;
    final maxValue = entries.fold<double>(
      0,
      (acc, e) => e.value > acc ? e.value.toDouble() : acc,
    );

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            Expanded(
              child: _Bar(
                value: entries[i].value.toDouble(),
                max: maxValue,
                label: entries[i].label,
                color: barColor,
                labelStyle: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                barRadius: _barBorderRadius,
              ),
            ),
            if (i < entries.length - 1) const MxGap(AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.max,
    required this.label,
    required this.color,
    required this.labelStyle,
    required this.barRadius,
  });

  final double value;
  final double max;
  final String label;
  final Color color;
  final TextStyle? labelStyle;
  final BorderRadius barRadius;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: FractionallySizedBox(
            heightFactor: ratio,
            widthFactor: 1,
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: barRadius),
            ),
          ),
        ),
        const MxGap(AppSpacing.xs),
        Text(label, style: labelStyle),
      ],
    );
  }
}

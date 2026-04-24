import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';

enum MxProgressSize { small, medium, large }

/// Determinate or indeterminate circular spinner.
class MxCircularProgress extends StatelessWidget {
  const MxCircularProgress({
    this.value,
    this.size = MxProgressSize.medium,
    this.color,
    super.key,
  });

  final double? value;
  final MxProgressSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      MxProgressSize.small => 16.0,
      MxProgressSize.medium => 24.0,
      MxProgressSize.large => 40.0,
    };
    final stroke = switch (size) {
      MxProgressSize.small => 2.0,
      MxProgressSize.medium => 3.0,
      MxProgressSize.large => 4.0,
    };
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: stroke,
        color: color,
      ),
    );
  }
}

/// Linear progress with optional label + percentage.
class MxLinearProgress extends StatelessWidget {
  const MxLinearProgress({
    required this.value,
    this.label,
    this.showPercentage = false,
    this.color,
    super.key,
  });

  final double value;
  final String? label;
  final bool showPercentage;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pct = (value.clamp(0.0, 1.0) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (showPercentage)
                Text(
                  '$pct%',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
            ],
          ),
          const MxGap(AppSpacing.xs),
        ],
        ClipRRect(
          borderRadius: AppRadius.borderFull,
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            color: color,
            minHeight: 6, // guard:raw-size-reviewed track height
          ),
        ),
      ],
    );
  }
}

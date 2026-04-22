import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/theme_extensions.dart';

/// Compact circular progress ring with optional centered percent label.
///
/// Designed for the "mastery %" indicator at the end of folder / deck rows.
/// When no explicit [color] is supplied, the ring resolves a semantic
/// low / mid / high color from the active theme extension.
class MxProgressRing extends StatelessWidget {
  const MxProgressRing({
    required this.value,
    this.size = _defaultSize,
    this.strokeWidth = _defaultStroke,
    this.showLabel = true,
    this.color,
    this.trackColor,
    super.key,
  });

  static const double _defaultSize = AppIconSizes.xxl; // 40
  static const double _defaultStroke = 3;

  /// Progress in the range `[0.0, 1.0]`.
  final double value;
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;

    final clamped = value.clamp(0.0, 1.0).toDouble();
    final resolvedColor = color ?? mx.masteryProgress(clamped);
    final resolvedTrack = trackColor ?? scheme.outlineVariant;

    final ring = SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        value: clamped,
        strokeWidth: strokeWidth,
        color: resolvedColor,
        backgroundColor: resolvedTrack,
        strokeCap: StrokeCap.round,
      ),
    );

    if (!showLabel) return ring;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring,
          Text(
            '${(clamped * 100).round()}',
            style: textTheme.labelSmall?.copyWith(color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}

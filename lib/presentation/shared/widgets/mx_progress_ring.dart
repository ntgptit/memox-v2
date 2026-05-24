import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';

/// Size scale for [MxProgressRing].
///
/// `compact` (40) for trailing list-row indicators, `hero` (72) for the
/// Deck Detail mastery header per Design System UI kit.
enum MxProgressRingSize { compact, hero }

/// Compact circular progress ring with optional centered percent label.
///
/// Designed for the "mastery %" indicator at the end of folder / deck rows.
/// When no explicit [color] is supplied, the ring resolves a semantic
/// low / mid / high color from the active theme extension.
class MxProgressRing extends StatelessWidget {
  const MxProgressRing({
    required this.value,
    this.size = MxProgressRingSize.compact,
    this.dimension,
    this.strokeWidth,
    this.showLabel = true,
    this.color,
    this.trackColor,
    super.key,
  });

  /// guard:raw-size-reviewed Hero ring size per Design System Deck Detail spec.
  static const double _heroDimension = 72;
  static const double _compactDimension = AppIconSizes.xxl; // 40
  static const double _defaultStroke = 3;

  /// Progress in the range `[0.0, 1.0]`.
  final double value;
  final MxProgressRingSize size;

  /// Explicit dimension override. When null, derived from [size].
  final double? dimension;

  /// Explicit stroke width override. When null, derived from [size].
  final double? strokeWidth;
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
    // Design System: deck mastery ring sits over a `surfaceContainerHigh`
    // track, not the lower-contrast `outlineVariant` used for borders.
    final resolvedTrack = trackColor ?? scheme.surfaceContainerHigh;
    final resolvedDimension = dimension ?? switch (size) {
      MxProgressRingSize.compact => _compactDimension,
      MxProgressRingSize.hero => _heroDimension,
    };
    final resolvedStroke = strokeWidth ?? _defaultStroke;

    final ring = SizedBox.square(
      dimension: resolvedDimension,
      child: CircularProgressIndicator(
        value: clamped,
        strokeWidth: resolvedStroke,
        color: resolvedColor,
        backgroundColor: resolvedTrack,
        strokeCap: StrokeCap.round,
      ),
    );

    if (!showLabel) return ring;

    final labelStyle = switch (size) {
      MxProgressRingSize.compact => textTheme.labelSmall,
      MxProgressRingSize.hero => textTheme.titleSmall,
    };

    return SizedBox.square(
      dimension: resolvedDimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring,
          Text(
            '${(clamped * 100).round()}%',
            style: labelStyle?.copyWith(color: resolvedColor),
          ),
        ],
      ),
    );
  }
}

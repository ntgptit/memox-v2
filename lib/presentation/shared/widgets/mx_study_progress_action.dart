import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/extensions/theme_extensions.dart';
import 'mx_tappable.dart';

/// Compact study action that combines start, mastery progress, and card count.
class MxStudyProgressAction extends StatelessWidget {
  const MxStudyProgressAction({
    required this.masteryPercent,
    required this.cardCount,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  // guard:raw-size-reviewed fixed-size action mirrors an icon button target
  // while leaving enough room for `100%` and a small count badge.
  static const double _pillWidth = 88;
  static const double _pillHeight = 44;
  static const double _stackWidth = 98;
  static const double _stackHeight = 52;
  static const double _strokeWidth = 3;
  static const double _badgeWidthFloor = 22;
  static const double _badgeHeight = 18;

  final int? masteryPercent;
  final int? cardCount;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;
    final safeMasteryPercent = masteryPercent ?? 0;
    final safeCardCount = cardCount ?? 0;
    final clampedPercent = safeMasteryPercent.clamp(0, 100);
    final progress = clampedPercent / 100;
    final progressColor = mx.masteryProgress(progress);
    final badgeLabel = safeCardCount > 99 ? '99+' : '$safeCardCount';

    return SizedBox(
      width: _stackWidth,
      height: _stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: MxTappable(
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderFull,
              ),
              semanticsLabel: tooltip,
              onTap: onPressed,
              child: CustomPaint(
                painter: _PillProgressPainter(
                  value: progress,
                  color: progressColor,
                  trackColor: scheme.outlineVariant,
                  strokeWidth: _strokeWidth,
                ),
                child: SizedBox(
                  width: _pillWidth,
                  height: _pillHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: AppIconSizes.lg,
                        color: progressColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$clampedPercent%',
                        style: textTheme.labelLarge?.copyWith(
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (safeCardCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                constraints: const BoxConstraints(minWidth: _badgeWidthFloor),
                height: _badgeHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mx.warningContainer,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: scheme.surfaceContainerHigh),
                ),
                child: Text(
                  badgeLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: mx.onWarningContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillProgressPainter extends CustomPainter {
  const _PillProgressPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _roundedPillPath(size);
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, trackPaint);

    final clamped = value.clamp(0.0, 1.0).toDouble();
    if (clamped <= 0) {
      return;
    }
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * clamped),
      progressPaint,
    );
  }

  Path _roundedPillPath(Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final radius = rect.height / 2;
    final topLeftArc = Rect.fromCircle(
      center: Offset(rect.left + radius, rect.top + radius),
      radius: radius,
    );
    final topRightArc = Rect.fromCircle(
      center: Offset(rect.right - radius, rect.top + radius),
      radius: radius,
    );

    return Path()
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcTo(topRightArc, -math.pi / 2, math.pi, false)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcTo(topLeftArc, math.pi / 2, math.pi, false)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _PillProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

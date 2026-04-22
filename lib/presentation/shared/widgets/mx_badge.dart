import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/mx_gap.dart';

enum MxBadgeTone { primary, neutral, success, warning, error, info }

/// Compact numeric/status badge. Use [MxBadge.dot] for a simple presence marker.
class MxBadge extends StatelessWidget {
  const MxBadge({
    required this.label,
    this.tone = MxBadgeTone.primary,
    this.icon,
    super.key,
  })  : _isDot = false,
        _count = null;

  const MxBadge.count(
    int count, {
    this.tone = MxBadgeTone.primary,
    super.key,
  })  : label = null,
        icon = null,
        _isDot = false,
        _count = count;

  const MxBadge.dot({
    this.tone = MxBadgeTone.error,
    super.key,
  })  : label = null,
        icon = null,
        _isDot = true,
        _count = null;

  final String? label;
  final int? _count;
  final IconData? icon;
  final MxBadgeTone tone;
  final bool _isDot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;

    final (Color bg, Color fg) = switch (tone) {
      MxBadgeTone.primary => (scheme.primary, scheme.onPrimary),
      MxBadgeTone.neutral => (scheme.surfaceContainerHighest, scheme.onSurface),
      MxBadgeTone.success => (mx.success, mx.onSuccess),
      MxBadgeTone.warning => (mx.warning, mx.onWarning),
      MxBadgeTone.error => (scheme.error, scheme.onError),
      MxBadgeTone.info => (mx.info, mx.onInfo),
    };

    if (_isDot) {
      return Container(
        width: AppSpacing.sm, // 8
        height: AppSpacing.sm, // 8
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    }

    final count = _count;
    final text = count != null
        ? (count > 99 ? '99+' : '$count')
        : (label ?? '');

    return Container(
      constraints: const BoxConstraints(
        minWidth: AppSpacing.xl, // 20
        minHeight: AppSpacing.xl, // 20
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderFull),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSizes.xs, color: fg),
            const MxGap.h(AppSpacing.xs),
          ],
          Text(
            text,
            style: textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

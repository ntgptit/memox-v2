import 'package:flutter/material.dart';

import '../../../core/utils/string_utils.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_tappable.dart';

/// Hero "Mix" call-to-action card seen on Deck Detail in the Design System.
///
/// Renders a gradient primary→accent surface with the shuffle icon, title,
/// supporting copy, an "Adaptive" pill, and a footer strip of mode icons.
class MxModeMixCard extends StatelessWidget {
  const MxModeMixCard({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.modeIcons,
    required this.modesSummary,
    this.icon = Icons.shuffle_rounded,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final List<IconData> modeIcons;
  final String modesSummary;
  final IconData icon;
  final VoidCallback? onTap;

  /// guard:raw-size-reviewed Hero icon tile matches the Design System spec.
  static const double _iconTile = 36;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Use primary as the brand anchor for the gradient; tertiary on dark
    // navy reads as cyan which fights the indigo brand identity.
    final accent = scheme.primary;

    final cardShape = RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: BorderSide(
        color: accent.withValues(alpha: AppOpacity.disabledSurface),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: ShapeDecoration(
          shape: cardShape,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: AppOpacity.hover),
              accent.withValues(alpha: AppOpacity.disabledSurface),
            ],
          ),
        ),
        child: MxTappable(
          shape: cardShape,
          onTap: onTap,
          overlayBaseColor: accent,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: _iconTile,
                      height: _iconTile,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: AppRadius.borderMd,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: AppIconSizes.sm,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const MxGap(AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const MxGap(AppSpacing.sm),
                    _AdaptiveBadge(label: badgeLabel, color: accent),
                  ],
                ),
                const MxGap(AppSpacing.sm),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(
                    alpha: AppOpacity.ghostBorder,
                  ),
                ),
                const MxGap(AppSpacing.sm),
                Row(
                  children: [
                    for (final ic in modeIcons) ...[
                      Icon(
                        ic,
                        size: AppIconSizes.sm,
                        color: scheme.onSurfaceVariant,
                      ),
                      const MxGap(AppSpacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        modesSummary,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaptiveBadge extends StatelessWidget {
  const _AdaptiveBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.chip,
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          StringUtils.upperCaseToEmpty(label),
          style: textTheme.labelSmall?.copyWith(
            color: color,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

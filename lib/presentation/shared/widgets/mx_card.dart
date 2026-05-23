import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_elevation.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import 'mx_tappable.dart';

enum MxCardVariant { filled, elevated, outlined }

/// Themed card container. Picks tonal surface + radius + padding and exposes
/// an optional [onTap] for list-style interactive cards.
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.variant = MxCardVariant.filled,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.clipBehavior,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.accent = false,
    super.key,
  });

  final Widget child;
  final MxCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip? clipBehavior;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  /// When true the card paints a tonal primary-tinted background, an indigo
  /// border, and lifts off the surface with [AppShadows.primaryGlow]. Use for
  /// the single highlighted call-to-action on a screen — not as a generic
  /// emphasis on multiple surfaces.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cardTheme = theme.cardTheme;
    final resolvedBorderRadius = _resolvedBorderRadius(context, cardTheme);
    final resolvedPadding = padding ?? AppLayout.cardPadding(context);
    final resolvedClipBehavior =
        clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias;
    final accentBackground = accent
        ? scheme.primaryContainer.withValues(alpha: AppOpacity.disabledSurface)
        : null;
    final accentBorder = accent
        ? scheme.primary.withValues(alpha: AppOpacity.half)
        : null;
    final cardColor =
        backgroundColor ?? accentBackground ?? _backgroundColor(cardTheme, scheme);
    final resolvedBorderColor = borderColor ?? accentBorder;
    final cardShape = RoundedRectangleBorder(
      borderRadius: resolvedBorderRadius,
      side: variant == MxCardVariant.outlined || resolvedBorderColor != null
          ? BorderSide(color: resolvedBorderColor ?? scheme.outlineVariant)
          : BorderSide.none,
    );

    final content = Card(
      color: cardColor,
      elevation: _elevation(cardTheme),
      shadowColor: cardTheme.shadowColor,
      surfaceTintColor: cardTheme.surfaceTintColor,
      margin: cardTheme.margin ?? EdgeInsets.zero,
      clipBehavior: resolvedClipBehavior,
      shape: cardShape,
      child: Padding(padding: resolvedPadding, child: child),
    );

    final tappable = onTap == null && onLongPress == null
        ? content
        : Card(
            color: cardColor,
            elevation: _elevation(cardTheme),
            shadowColor: cardTheme.shadowColor,
            surfaceTintColor: cardTheme.surfaceTintColor,
            margin: cardTheme.margin ?? EdgeInsets.zero,
            clipBehavior: resolvedClipBehavior,
            shape: cardShape,
            child: MxTappable(
              shape: cardShape,
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(padding: resolvedPadding, child: child),
            ),
          );

    if (!accent) return tappable;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: resolvedBorderRadius,
        boxShadow: AppShadows.primaryGlow(scheme.primary),
      ),
      child: tappable,
    );
  }

  Color _backgroundColor(CardThemeData cardTheme, ColorScheme scheme) {
    return switch (variant) {
      MxCardVariant.filled => cardTheme.color ?? scheme.surfaceContainerLow,
      MxCardVariant.elevated => scheme.surfaceContainerLow,
      MxCardVariant.outlined => scheme.surfaceContainerLow,
    };
  }

  double _elevation(CardThemeData cardTheme) {
    final baseElevation = cardTheme.elevation ?? AppElevation.card;
    return switch (variant) {
      MxCardVariant.filled => baseElevation,
      MxCardVariant.elevated =>
        baseElevation + (AppElevation.cardRaised - AppElevation.card),
      MxCardVariant.outlined => AppElevation.card,
    };
  }

  BorderRadius _resolvedBorderRadius(
    BuildContext context,
    CardThemeData cardTheme,
  ) {
    if (borderRadius != null) return borderRadius!;
    final shape = cardTheme.shape;
    if (shape is RoundedRectangleBorder && shape.borderRadius is BorderRadius) {
      return shape.borderRadius as BorderRadius;
    }
    return AppLayout.cardRadius(context);
  }
}

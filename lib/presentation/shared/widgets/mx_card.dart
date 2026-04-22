import 'package:flutter/material.dart';

import '../../../core/theme/app_elevation.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum MxCardVariant { filled, elevated, outlined }

/// Themed card container. Picks tonal surface + radius + padding and exposes
/// an optional [onTap] for list-style interactive cards.
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.variant = MxCardVariant.filled,
    this.padding = AppSpacing.card,
    this.onTap,
    this.onLongPress,
    this.clipBehavior,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final MxCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip? clipBehavior;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cardTheme = theme.cardTheme;
    final resolvedBorderRadius = _resolvedBorderRadius(cardTheme);
    final resolvedClipBehavior =
        clipBehavior ?? cardTheme.clipBehavior ?? Clip.antiAlias;

    final content = Card(
      color: _backgroundColor(cardTheme, scheme),
      elevation: _elevation(cardTheme),
      shadowColor: cardTheme.shadowColor,
      surfaceTintColor: cardTheme.surfaceTintColor,
      margin: cardTheme.margin ?? EdgeInsets.zero,
      clipBehavior: resolvedClipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: resolvedBorderRadius,
        side: variant == MxCardVariant.outlined
            ? BorderSide(color: scheme.outlineVariant)
            : BorderSide.none,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null && onLongPress == null) return content;

    return Card(
      color: _backgroundColor(cardTheme, scheme),
      elevation: _elevation(cardTheme),
      shadowColor: cardTheme.shadowColor,
      surfaceTintColor: cardTheme.surfaceTintColor,
      margin: cardTheme.margin ?? EdgeInsets.zero,
      clipBehavior: resolvedClipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: resolvedBorderRadius,
        side: variant == MxCardVariant.outlined
            ? BorderSide(color: scheme.outlineVariant)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: resolvedBorderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  Color _backgroundColor(CardThemeData cardTheme, ColorScheme scheme) {
    return switch (variant) {
      MxCardVariant.filled => cardTheme.color ?? scheme.surfaceContainerLow,
      MxCardVariant.elevated => scheme.surfaceContainer,
      MxCardVariant.outlined => scheme.surface,
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

  BorderRadius _resolvedBorderRadius(CardThemeData cardTheme) {
    if (borderRadius != null) return borderRadius!;
    final shape = cardTheme.shape;
    if (shape is RoundedRectangleBorder && shape.borderRadius is BorderRadius) {
      return shape.borderRadius as BorderRadius;
    }
    return AppRadius.card;
  }
}

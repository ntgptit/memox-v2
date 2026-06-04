import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_elevation.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import 'mx_tappable.dart';

enum MxCardVariant { filled, elevated, outlined, heroGradient }

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
    if (variant == MxCardVariant.heroGradient) {
      return _buildHeroGradient(context);
    }

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
        backgroundColor ??
        accentBackground ??
        _backgroundColor(cardTheme, scheme);
    final resolvedBorderColor =
        borderColor ??
        accentBorder ??
        scheme.outlineVariant.withValues(alpha: AppOpacity.ghostBorder);
    final cardShape = RoundedRectangleBorder(
      borderRadius: resolvedBorderRadius,
      side: BorderSide(color: resolvedBorderColor),
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

  Color _backgroundColor(CardThemeData cardTheme, ColorScheme scheme) =>
      switch (variant) {
        MxCardVariant.filled =>
          cardTheme.color ?? scheme.surfaceContainerLowest,
        MxCardVariant.elevated => scheme.surfaceContainerLow,
        MxCardVariant.outlined => scheme.surfaceContainerLowest,
        MxCardVariant.heroGradient => scheme.surfaceContainerLowest,
      };

  double _elevation(CardThemeData cardTheme) {
    final baseElevation = cardTheme.elevation ?? AppElevation.card;
    return switch (variant) {
      MxCardVariant.filled => baseElevation,
      MxCardVariant.elevated =>
        baseElevation + (AppElevation.cardRaised - AppElevation.card),
      MxCardVariant.outlined => AppElevation.card,
      MxCardVariant.heroGradient => AppElevation.card,
    };
  }

  /// Soft hero surface per Design System mobile hero cards: a subtle
  /// primary→secondary gradient wash, a quiet primary-tinted border, and a
  /// light shadow (no heavy primary glow). Used for the single hero card on a
  /// screen — e.g. the Folder Detail / Deck Detail mastery hero.
  Widget _buildHeroGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardTheme = Theme.of(context).cardTheme;
    final resolvedBorderRadius = _resolvedBorderRadius(context, cardTheme);
    final resolvedPadding = padding ?? AppLayout.cardPadding(context);
    final seed = backgroundColor ?? scheme.primary;

    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          seed.withValues(alpha: AppOpacity.heroGradientLow),
          scheme.secondary.withValues(alpha: AppOpacity.heroGradientHigh),
        ],
      ),
      borderRadius: resolvedBorderRadius,
      border: Border.all(
        color: (borderColor ?? scheme.primary).withValues(
          alpha: AppOpacity.ghostBorder,
        ),
      ),
      boxShadow: AppShadows.sm,
    );

    final inner = Padding(padding: resolvedPadding, child: child);
    if (onTap == null && onLongPress == null) {
      return DecoratedBox(decoration: decoration, child: inner);
    }
    return DecoratedBox(
      decoration: decoration,
      child: MxTappable(
        shape: RoundedRectangleBorder(borderRadius: resolvedBorderRadius),
        onTap: onTap,
        onLongPress: onLongPress,
        child: inner,
      ),
    );
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

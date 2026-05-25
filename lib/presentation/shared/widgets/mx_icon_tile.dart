import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';

/// Tonal accent tier for an [MxIconTile].
///
/// Maps to a `(background, foreground)` pair from the active [ColorScheme]
/// so feature widgets choose a *role*, not a raw color.
enum MxIconTileTone { neutral, primary, primarySoft, disabled }

/// Rounded-square icon container used as the leading affordance on
/// dashboard action cards, list rows, and quick-link tiles.
///
/// The size resolves through [AppLayout.listTileIconSize] so compact and
/// regular mobile densities stay aligned with the rest of the catalogue.
class MxIconTile extends StatelessWidget {
  const MxIconTile({
    required this.icon,
    this.tone = MxIconTileTone.neutral,
    this.size,
    super.key,
  });

  final IconData icon;
  final MxIconTileTone tone;

  /// Optional explicit size — defaults to [AppLayout.listTileIconSize] which
  /// is already density-aware. Override only when a parent constrains the
  /// surface to a non-standard scale.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedSize = size ?? AppLayout.listTileIconSize(context);
    final (background, foreground) = _toneColors(context, scheme);

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.borderMd,
        ),
        child: Center(
          child: Icon(icon, size: AppIconSizes.md, color: foreground),
        ),
      ),
    );
  }

  (Color, Color) _toneColors(BuildContext context, ColorScheme scheme) =>
      switch (tone) {
        MxIconTileTone.neutral => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
        MxIconTileTone.primary => (scheme.primary, scheme.onPrimary),
        MxIconTileTone.primarySoft => (
          scheme.primary.withValues(alpha: AppOpacity.disabledSurface),
          scheme.primary,
        ),
        MxIconTileTone.disabled => (
          scheme.surfaceContainerHighest,
          context.mxOnSurfaceDisabled,
        ),
      };
}

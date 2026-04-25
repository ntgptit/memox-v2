import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';

enum MxFabVariant { primary, surface, tonal }

/// Themed floating action button. Features should compose this instead of
/// instantiating a raw [FloatingActionButton] so tooltip, variant, and size
/// stay consistent across the app.
class MxFab extends StatelessWidget {
  const MxFab({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = MxFabVariant.primary,
    this.extendedLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final MxFabVariant variant;

  /// When provided, the FAB renders as an extended FAB with the label on the
  /// right of the icon.
  final String? extendedLabel;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: AppIconSizes.lg);

    if (variant == MxFabVariant.primary) {
      if (extendedLabel != null) {
        return FloatingActionButton.extended(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: iconWidget,
          label: Text(extendedLabel!),
        );
      }

      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        child: iconWidget,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (variant) {
      MxFabVariant.primary => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      MxFabVariant.surface => (scheme.surfaceContainerHigh, scheme.onSurface),
      MxFabVariant.tonal => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };

    if (extendedLabel != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: bg,
        foregroundColor: fg,
        icon: iconWidget,
        label: Text(extendedLabel!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: bg,
      foregroundColor: fg,
      child: iconWidget,
    );
  }
}

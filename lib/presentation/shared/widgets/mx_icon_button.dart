import 'package:flutter/material.dart';

import '../../../core/theme/component_themes/focus_theme.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';

enum MxIconButtonVariant {
  standard,
  toolbar,
  compact,
  filled,
  filledTonal,
  outlined,
}

/// Themed icon button with tooltip-friendly API and four M3 variants.
class MxIconButton extends StatelessWidget {
  const MxIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = MxIconButtonVariant.standard,
    this.size = AppIconSizes.md,
    this.isSelected = false,
    this.selectedIcon,
    super.key,
  });

  const MxIconButton.toolbar({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = AppIconSizes.lg,
    this.isSelected = false,
    this.selectedIcon,
    super.key,
  }) : variant = MxIconButtonVariant.toolbar;

  const MxIconButton.compact({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = AppIconSizes.lg,
    this.isSelected = false,
    this.selectedIcon,
    super.key,
  }) : variant = MxIconButtonVariant.compact;

  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final MxIconButtonVariant variant;
  final double size;
  final bool isSelected;

  static IconButtonThemeData toolbarTheme(BuildContext context) {
    return IconButtonThemeData(style: toolbarStyle(context));
  }

  static ButtonStyle toolbarStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final transparent = scheme.surface.withValues(
      alpha: AppOpacity.transparent,
    );

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
        }
        return scheme.onSurfaceVariant;
      }),
      backgroundColor: WidgetStatePropertyAll(transparent),
      overlayColor: AppFocus.overlayProperty(scheme.onSurface),
      side: const WidgetStatePropertyAll(BorderSide.none),
      minimumSize: const WidgetStatePropertyAll(
        Size.square(kMinInteractiveDimension),
      ),
      fixedSize: const WidgetStatePropertyAll(
        Size.square(kMinInteractiveDimension),
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: const WidgetStatePropertyAll(CircleBorder()),
    );
  }

  static ButtonStyle compactStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final transparent = scheme.surface.withValues(
      alpha: AppOpacity.transparent,
    );

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
        }
        return scheme.onSurfaceVariant;
      }),
      backgroundColor: WidgetStatePropertyAll(transparent),
      overlayColor: AppFocus.overlayProperty(scheme.onSurface),
      side: const WidgetStatePropertyAll(BorderSide.none),
      minimumSize: const WidgetStatePropertyAll(Size.square(AppIconSizes.xl)),
      fixedSize: const WidgetStatePropertyAll(Size.square(AppIconSizes.xl)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: const WidgetStatePropertyAll(CircleBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: size, semanticLabel: tooltip);
    final selectedIconWidget = selectedIcon != null
        ? Icon(selectedIcon, size: size, semanticLabel: tooltip)
        : null;

    return switch (variant) {
      MxIconButtonVariant.standard => IconButton(
        icon: iconWidget,
        selectedIcon: selectedIconWidget,
        isSelected: isSelected,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
      MxIconButtonVariant.toolbar => IconButton(
        icon: iconWidget,
        selectedIcon: selectedIconWidget,
        isSelected: isSelected,
        tooltip: tooltip,
        onPressed: onPressed,
        style: toolbarStyle(context),
      ),
      MxIconButtonVariant.compact => IconButton(
        icon: iconWidget,
        selectedIcon: selectedIconWidget,
        isSelected: isSelected,
        tooltip: tooltip,
        onPressed: onPressed,
        style: compactStyle(context),
      ),
      MxIconButtonVariant.filled => IconButton.filled(
        icon: iconWidget,
        selectedIcon: selectedIconWidget,
        isSelected: isSelected,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
      MxIconButtonVariant.filledTonal => IconButton.filledTonal(
        icon: iconWidget,
        selectedIcon: selectedIconWidget,
        isSelected: isSelected,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
      MxIconButtonVariant.outlined => IconButton.outlined(
        icon: iconWidget,
        selectedIcon: selectedIconWidget,
        isSelected: isSelected,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    };
  }
}

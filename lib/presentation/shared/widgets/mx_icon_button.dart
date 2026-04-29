import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';

enum MxIconButtonVariant { standard, filled, filledTonal, outlined }

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

  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final MxIconButtonVariant variant;
  final double size;
  final bool isSelected;

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

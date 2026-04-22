import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/theme_extensions.dart';

enum MxChipTone { neutral, primary, success, warning, error, info }

/// Filter/selection chip with tonal variants and a compact density.
class MxChip extends StatelessWidget {
  const MxChip({
    required this.label,
    this.icon,
    this.onTap,
    this.onDeleted,
    this.selected = false,
    this.tone = MxChipTone.neutral,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool selected;
  final MxChipTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;

    final (Color bg, Color fg) = switch (tone) {
      MxChipTone.neutral => selected
          ? (scheme.secondaryContainer, scheme.onSecondaryContainer)
          : (scheme.surfaceContainerHighest, scheme.onSurface),
      MxChipTone.primary => (scheme.primaryContainer, scheme.onPrimaryContainer),
      MxChipTone.success => (mx.successContainer, mx.onSuccessContainer),
      MxChipTone.warning => (mx.warningContainer, mx.onWarningContainer),
      MxChipTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      MxChipTone.info => (mx.infoContainer, mx.onInfoContainer),
    };

    final labelStyle = textTheme.labelLarge?.copyWith(color: fg);

    if (onDeleted != null) {
      return InputChip(
        label: Text(label),
        avatar: icon != null ? Icon(icon, size: AppIconSizes.sm) : null,
        selected: selected,
        onPressed: onTap,
        onDeleted: onDeleted,
        backgroundColor: bg,
        selectedColor: bg,
        labelStyle: labelStyle,
        side: BorderSide.none,
        showCheckmark: false,
      );
    }

    if (onTap != null) {
      return FilterChip(
        label: Text(label),
        avatar: icon != null ? Icon(icon, size: AppIconSizes.sm, color: fg) : null,
        selected: selected,
        onSelected: (_) => onTap!.call(),
        backgroundColor: bg,
        selectedColor: bg,
        labelStyle: labelStyle,
        side: BorderSide.none,
        showCheckmark: selected,
        checkmarkColor: fg,
      );
    }

    return Chip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: AppIconSizes.sm, color: fg) : null,
      backgroundColor: bg,
      labelStyle: labelStyle,
      side: BorderSide.none,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';

enum MxChipTone { neutral, primary, success, warning, error, info }

/// Filter/selection chip with tonal variants and a compact density.
class MxChip extends StatelessWidget {
  const MxChip({
    required this.label,
    this.icon,
    this.onTap,
    this.onDeleted,
    this.selected = false,
    this.showCheckmark = false,
    this.tone = MxChipTone.neutral,
    this.count,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool selected;
  final bool showCheckmark;
  final MxChipTone tone;

  /// Optional trailing count rendered inline (e.g. `All 142`). Mirrors the
  /// Design System filter chips on the Cards-management screen.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;

    final (Color bg, Color fg) = switch (tone) {
      MxChipTone.neutral =>
        selected
            ? (scheme.primaryContainer, scheme.onPrimaryContainer)
            : (scheme.surfaceContainerHighest, scheme.onSurface),
      MxChipTone.primary => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      MxChipTone.success => (mx.successContainer, mx.onSuccessContainer),
      MxChipTone.warning => (mx.warningContainer, mx.onWarningContainer),
      MxChipTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      MxChipTone.info => (mx.infoContainer, mx.onInfoContainer),
    };

    final labelStyle = textTheme.labelLarge?.copyWith(color: fg);

    final Widget labelWidget = count == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 6), // guard:raw-size-reviewed count gap
              Text(
                '$count',
                style: textTheme.labelMedium?.copyWith(
                  color: fg.withValues(alpha: selected ? 0.7 : 0.55),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );

    if (onDeleted != null) {
      return InputChip(
        label: labelWidget,
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
        label: labelWidget,
        avatar: icon != null
            ? Icon(icon, size: AppIconSizes.sm, color: fg)
            : null,
        selected: selected,
        onSelected: (_) => onTap!.call(),
        backgroundColor: bg,
        selectedColor: bg,
        labelStyle: labelStyle,
        side: BorderSide.none,
        showCheckmark: showCheckmark,
        checkmarkColor: fg,
      );
    }

    return Chip(
      label: labelWidget,
      avatar: icon != null
          ? Icon(icon, size: AppIconSizes.sm, color: fg)
          : null,
      backgroundColor: bg,
      labelStyle: labelStyle,
      side: BorderSide.none,
    );
  }
}

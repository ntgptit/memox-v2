import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import 'mx_tappable.dart';

/// Full-width answer option surface for quiz and study choices.
class MxAnswerOptionCard extends StatelessWidget {
  const MxAnswerOptionCard({
    required this.label,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
    this.maxLines = 3,
    this.leadingIcon,
    this.semanticsLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool enabled;
  final int maxLines;
  final IconData? leadingIcon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canInteract = enabled && onPressed != null;
    final foregroundColor = _foregroundColor(scheme);
    final backgroundColor = _backgroundColor(scheme);
    final optionIcon = selected ? Icons.check_circle_rounded : leadingIcon;

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
      side: BorderSide(color: _borderColor(scheme)),
    );

    return Semantics(
      selected: selected,
      child: SizedBox(
        width: double.infinity,
        child: MxTappable(
          shape: shape,
          enabled: enabled,
          onTap: canInteract ? onPressed : null,
          semanticsLabel: semanticsLabel,
          backgroundColor: backgroundColor,
          overlayBaseColor: foregroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (optionIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Icon(
                      optionIcon,
                      size: AppIconSizes.md,
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: maxLines,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: textTheme.bodyLarge?.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme scheme) {
    if (selected) {
      return enabled
          ? scheme.primaryContainer
          : scheme.primaryContainer.withValues(alpha: AppOpacity.half);
    }
    if (!enabled) {
      return scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface);
    }
    return scheme.surfaceContainerLow;
  }

  Color _borderColor(ColorScheme scheme) {
    if (selected) {
      return enabled
          ? scheme.primary
          : scheme.primary.withValues(alpha: AppOpacity.half);
    }
    if (!enabled) {
      return scheme.outlineVariant.withValues(alpha: AppOpacity.half);
    }
    return scheme.outlineVariant;
  }

  Color _foregroundColor(ColorScheme scheme) {
    if (selected) {
      return enabled
          ? scheme.onPrimaryContainer
          : scheme.onPrimaryContainer.withValues(alpha: AppOpacity.disabled);
    }
    if (!enabled) {
      return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
    }
    return scheme.onSurface;
  }
}

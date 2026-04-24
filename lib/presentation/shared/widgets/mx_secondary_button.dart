import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import 'mx_primary_button.dart';
import '../../../core/theme/mx_gap.dart';

enum MxSecondaryVariant { tonal, outlined, text }

/// Secondary action button. Supports tonal/outlined/text variants.
class MxSecondaryButton extends StatelessWidget {
  const MxSecondaryButton({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = MxButtonSize.medium,
    this.variant = MxSecondaryVariant.outlined,
    this.isLoading = false,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final MxButtonSize size;
  final MxSecondaryVariant variant;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;

    final spinnerColor = switch (variant) {
      MxSecondaryVariant.tonal => theme.colorScheme.onSecondaryContainer,
      MxSecondaryVariant.outlined => theme.colorScheme.primary,
      MxSecondaryVariant.text => theme.colorScheme.primary,
    };

    final child = isLoading
        ? SizedBox(
            width: 18, // guard:raw-size-reviewed button spinner diameter
            height: 18, // guard:raw-size-reviewed button spinner diameter
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spinnerColor,
            ),
          )
        : _buildLabel();

    final button = switch (variant) {
      MxSecondaryVariant.tonal => FilledButton.tonal(
        onPressed: effectiveOnPressed,
        style: _resolvedStyle(theme),
        child: child,
      ),
      MxSecondaryVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: _resolvedStyle(theme),
        child: child,
      ),
      MxSecondaryVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: _resolvedStyle(theme),
        child: child,
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildLabel() {
    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: AppIconSizes.md),
          const MxGap(AppSpacing.sm),
        ],
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        if (trailingIcon != null) ...[
          const MxGap(AppSpacing.sm),
          Icon(trailingIcon, size: AppIconSizes.md),
        ],
      ],
    );
  }

  ButtonStyle? _resolvedStyle(ThemeData theme) {
    final baseStyle = switch (variant) {
      MxSecondaryVariant.tonal => theme.filledButtonTheme.style,
      MxSecondaryVariant.outlined => theme.outlinedButtonTheme.style,
      MxSecondaryVariant.text => theme.textButtonTheme.style,
    };
    return _mergeButtonStyles(baseStyle, _sizeStyle(size, theme.textTheme));
  }

  ButtonStyle? _sizeStyle(MxButtonSize size, TextTheme textTheme) {
    return switch (size) {
      MxButtonSize.small => ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelMedium),
      ),
      MxButtonSize.medium => null,
      MxButtonSize.large => ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
      ),
    };
  }

  ButtonStyle? _mergeButtonStyles(ButtonStyle? base, ButtonStyle? overrides) {
    if (base == null) return overrides;
    return base.merge(overrides);
  }
}

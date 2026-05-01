import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import 'mx_primary_button.dart';
import '../layouts/mx_gap.dart';

enum MxSecondaryVariant { tonal, outlined, text }

enum MxSecondaryButtonTone { neutral, danger }

/// Secondary action button. Supports tonal/outlined/text variants.
class MxSecondaryButton extends StatelessWidget {
  const MxSecondaryButton({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = MxButtonSize.medium,
    this.variant = MxSecondaryVariant.outlined,
    this.tone = MxSecondaryButtonTone.neutral,
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
  final MxSecondaryButtonTone tone;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mxColors = context.mxColors;
    final effectiveOnPressed = isLoading ? null : onPressed;

    final spinnerColor = switch (tone) {
      MxSecondaryButtonTone.danger => mxColors.ratingAgain,
      MxSecondaryButtonTone.neutral => switch (variant) {
        MxSecondaryVariant.tonal => theme.colorScheme.onSecondaryContainer,
        MxSecondaryVariant.outlined => theme.colorScheme.primary,
        MxSecondaryVariant.text => theme.colorScheme.primary,
      },
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
        style: _resolvedStyle(theme, mxColors),
        child: child,
      ),
      MxSecondaryVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: _resolvedStyle(theme, mxColors),
        child: child,
      ),
      MxSecondaryVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: _resolvedStyle(theme, mxColors),
        child: child,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return IntrinsicWidth(child: button);
  }

  Widget _buildLabel() {
    final labelText = Text(label, overflow: TextOverflow.ellipsis, maxLines: 1);
    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: AppIconSizes.md),
          const MxGap(AppSpacing.sm),
        ],
        Flexible(child: labelText),
        if (trailingIcon != null) ...[
          const MxGap(AppSpacing.sm),
          Icon(trailingIcon, size: AppIconSizes.md),
        ],
      ],
    );
  }

  ButtonStyle? _resolvedStyle(ThemeData theme, MxColorsExtension mxColors) {
    final baseStyle = switch (variant) {
      MxSecondaryVariant.tonal => theme.filledButtonTheme.style,
      MxSecondaryVariant.outlined => theme.outlinedButtonTheme.style,
      MxSecondaryVariant.text => theme.textButtonTheme.style,
    };
    return _mergeButtonStyles(
      _mergeButtonStyles(baseStyle, _sizeStyle(size, theme.textTheme)),
      _toneStyle(theme, mxColors),
    );
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
    if (overrides == null) return base;
    return overrides.merge(base);
  }

  ButtonStyle? _toneStyle(ThemeData theme, MxColorsExtension mxColors) {
    if (tone != MxSecondaryButtonTone.danger) {
      return null;
    }
    final scheme = theme.colorScheme;
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
        }
        return mxColors.ratingAgain;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: scheme.outlineVariant);
        }
        return BorderSide(color: mxColors.ratingAgain);
      }),
    );
  }
}

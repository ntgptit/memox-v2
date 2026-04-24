import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_opacity.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';

enum MxButtonSize { small, medium, large }

enum MxPrimaryButtonTone { primary, danger }

/// Primary CTA button. Renders as an [ElevatedButton] backed by
/// [ColorScheme.primary]. Supports loading and leading/trailing icons.
class MxPrimaryButton extends StatelessWidget {
  const MxPrimaryButton({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = MxButtonSize.medium,
    this.tone = MxPrimaryButtonTone.primary,
    this.isLoading = false,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final MxButtonSize size;
  final MxPrimaryButtonTone tone;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final effectiveOnPressed = isLoading ? null : onPressed;
    final spinnerColor = switch (tone) {
      MxPrimaryButtonTone.primary => theme.colorScheme.onPrimary,
      MxPrimaryButtonTone.danger => theme.colorScheme.onError,
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
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: AppIconSizes.md),
                const MxGap(AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (trailingIcon != null) ...[
                const MxGap(AppSpacing.sm),
                Icon(trailingIcon, size: AppIconSizes.md),
              ],
            ],
          );

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: _resolvedStyle(theme, textTheme),
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle? _resolvedStyle(ThemeData theme, TextTheme textTheme) {
    return _mergeButtonStyles(
      _mergeButtonStyles(
        theme.elevatedButtonTheme.style,
        _sizeStyle(size, textTheme),
      ),
      _toneStyle(theme),
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

  ButtonStyle? _toneStyle(ThemeData theme) {
    if (tone != MxPrimaryButtonTone.danger) return null;
    final scheme = theme.colorScheme;
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface);
        }
        return scheme.error;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
        }
        return scheme.onError;
      }),
    );
  }

  ButtonStyle? _mergeButtonStyles(ButtonStyle? base, ButtonStyle? overrides) {
    if (base == null) return overrides;
    return base.merge(overrides);
  }
}

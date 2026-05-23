import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/extensions/theme_extensions.dart';
import '../layouts/mx_gap.dart';
import 'mx_button_size.dart';

enum MxPrimaryButtonTone { primary, success, danger }

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
    final mxColors = context.mxColors;
    final effectiveOnPressed = isLoading ? null : onPressed;
    final spinnerColor = switch (tone) {
      MxPrimaryButtonTone.primary => theme.colorScheme.onPrimary,
      MxPrimaryButtonTone.success => mxColors.onSuccess,
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
        : _buildLabel();

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: _resolvedStyle(theme, textTheme, mxColors),
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildLabel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canShowIcons = AppLayout.showsButtonIcons(
          hasBoundedWidth: constraints.hasBoundedWidth,
          maxWidth: constraints.maxWidth,
        );
        final labelText = Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
        return Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null && canShowIcons) ...[
              Icon(leadingIcon, size: AppIconSizes.md),
              const MxGap(AppSpacing.sm),
            ],
            Flexible(child: labelText),
            if (trailingIcon != null && canShowIcons) ...[
              const MxGap(AppSpacing.sm),
              Icon(trailingIcon, size: AppIconSizes.md),
            ],
          ],
        );
      },
    );
  }

  ButtonStyle? _resolvedStyle(
    ThemeData theme,
    TextTheme textTheme,
    MxColorsExtension mxColors,
  ) {
    return _mergeButtonStyles(
      _mergeButtonStyles(
        theme.elevatedButtonTheme.style,
        _sizeStyle(size, textTheme),
      ),
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

  ButtonStyle? _toneStyle(ThemeData theme, MxColorsExtension mxColors) {
    final scheme = theme.colorScheme;
    return switch (tone) {
      MxPrimaryButtonTone.primary => null,
      MxPrimaryButtonTone.success => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(
              alpha: AppOpacity.disabledSurface,
            );
          }
          return mxColors.success;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
          }
          return mxColors.onSuccess;
        }),
      ),
      MxPrimaryButtonTone.danger => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(
              alpha: AppOpacity.disabledSurface,
            );
          }
          return scheme.error;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
          }
          return scheme.onError;
        }),
      ),
    };
  }

  ButtonStyle? _mergeButtonStyles(ButtonStyle? base, ButtonStyle? overrides) {
    if (base == null) return overrides;
    if (overrides == null) return base;
    return overrides.merge(base);
  }
}

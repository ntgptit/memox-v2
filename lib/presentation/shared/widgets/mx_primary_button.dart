import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_button_size.dart';

enum MxPrimaryButtonTone { primary, success, danger }

/// Visual silhouette of the button. `rounded` keeps the themed corner radius;
/// `pill` clamps to a [StadiumBorder] for Quizlet-style hero CTAs.
enum MxPrimaryButtonShape { rounded, pill }

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
    this.shape = MxPrimaryButtonShape.rounded,
    this.isLoading = false,
    this.fullWidth = false,
    this.stretchOnCompact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final MxButtonSize size;
  final MxPrimaryButtonTone tone;
  final MxPrimaryButtonShape shape;
  final bool isLoading;
  final bool fullWidth;

  /// Legacy opt-in: when `true` AND [size] is [MxButtonSize.large] AND the host
  /// is compact-mobile, the button forces `fullWidth` so the CTA spans the
  /// gutter.
  ///
  /// Defaults to `false`. Full-width must be an explicit layout decision
  /// (`fullWidth: true`) or come from a semantic [MxActionButton] intent, not
  /// an implicit side effect of size + screen width. See
  /// `docs/ui-ux/action-hierarchy-contract.md`. Prefer leaving this `false`;
  /// semantic action components never set it.
  final bool stretchOnCompact;

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

    final shouldStretch =
        fullWidth ||
        (stretchOnCompact &&
            context.isCompactMobile &&
            size == MxButtonSize.large);

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: _resolvedStyle(context, theme, textTheme, mxColors),
      child: child,
    );

    if (shouldStretch) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildLabel() => LayoutBuilder(
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

  ButtonStyle? _resolvedStyle(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    MxColorsExtension mxColors,
  ) => _mergeButtonStyles(
    _mergeButtonStyles(
      _mergeButtonStyles(
        theme.elevatedButtonTheme.style,
        _sizeStyle(context, size, textTheme),
      ),
      _toneStyle(theme, mxColors),
    ),
    _shapeStyle(),
  );

  ButtonStyle? _shapeStyle() {
    if (shape != MxPrimaryButtonShape.pill) return null;
    return const ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
    );
  }

  ButtonStyle? _sizeStyle(
    BuildContext context,
    MxButtonSize size,
    TextTheme textTheme,
  ) => switch (size) {
    MxButtonSize.xsmall => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppLayout.buttonHorizontalPadding(
            context,
            regular: AppSpacing.md,
          ),
        ),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelSmall),
    ),
    MxButtonSize.small => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppLayout.buttonHorizontalPadding(
            context,
            regular: AppSpacing.lg,
          ),
        ),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelMedium),
    ),
    MxButtonSize.compact => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppLayout.buttonHorizontalPadding(
            context,
            regular: AppSpacing.lg,
          ),
        ),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelMedium),
    ),
    MxButtonSize.medium =>
      context.isCompactMobile
          ? const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(0, 48)),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            )
          : null,
    MxButtonSize.large => ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(0, context.isCompactMobile ? 56 : 52),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppLayout.buttonHorizontalPadding(
            context,
            regular: AppSpacing.xxl,
          ),
        ),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
    ),
  };

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

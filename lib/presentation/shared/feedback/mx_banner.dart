import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/mx_gap.dart';

enum MxBannerTone { info, success, warning, error }

/// Inline banner — a soft colored strip with icon, message, and optional
/// primary/secondary actions. Use inside content, not as a page-level banner.
class MxBanner extends StatelessWidget {
  const MxBanner({
    required this.message,
    this.title,
    this.tone = MxBannerTone.info,
    this.icon,
    this.primaryAction,
    this.primaryActionLabel,
    this.onDismiss,
    super.key,
  });

  final String? title;
  final String message;
  final MxBannerTone tone;
  final IconData? icon;
  final VoidCallback? primaryAction;
  final String? primaryActionLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mx = context.mxColors;
    final localizations = MaterialLocalizations.of(context);

    final (Color bg, Color fg, IconData defaultIcon) = switch (tone) {
      MxBannerTone.info => (
        mx.infoContainer,
        mx.onInfoContainer,
        Icons.info_outline,
      ),
      MxBannerTone.success => (
        mx.successContainer,
        mx.onSuccessContainer,
        Icons.check_circle_outline,
      ),
      MxBannerTone.warning => (
        mx.warningContainer,
        mx.onWarningContainer,
        Icons.warning_amber_outlined,
      ),
      MxBannerTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.error_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.banner),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: fg, size: AppIconSizes.lg),
            const MxGap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: textTheme.titleSmall?.copyWith(color: fg),
                  ),
                  const MxGap(AppSpacing.xxs),
                ],
                Text(message, style: textTheme.bodyMedium?.copyWith(color: fg)),
                if (primaryAction != null) ...[
                  const MxGap(AppSpacing.sm),
                  TextButton(
                    onPressed: primaryAction,
                    style: _mergeButtonStyles(
                      theme.textButtonTheme.style,
                      ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(fg),
                        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                        minimumSize: const WidgetStatePropertyAll(
                          Size(0, AppSpacing.xxxl),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    child: Text(
                      primaryActionLabel ?? localizations.okButtonLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: localizations.closeButtonTooltip,
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              iconSize: AppIconSizes.md,
              color: fg,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.xxxl, // 32
                minHeight: AppSpacing.xxxl, // 32
              ),
            ),
        ],
      ),
    );
  }

  ButtonStyle? _mergeButtonStyles(ButtonStyle? base, ButtonStyle? overrides) {
    if (base == null) return overrides;
    return base.merge(overrides);
  }
}

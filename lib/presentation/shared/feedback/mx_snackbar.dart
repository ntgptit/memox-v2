import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/extensions/theme_extensions.dart';
import '../layouts/mx_gap.dart';
import '../motion/mx_motion.dart';

enum MxSnackbarTone { neutral, success, warning, error }

typedef MxDeferredSnackbar =
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function();

/// Helpers to show themed snackbars with consistent tone + icon.
abstract final class MxSnackbar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    MxSnackbarTone tone = MxSnackbarTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = MxDurations.snackbar,
    IconData? icon,
  }) {
    return _show(
      ScaffoldMessenger.of(context),
      _snackBar(
        context,
        message: message,
        tone: tone,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        icon: icon,
      ),
    );
  }

  static MxDeferredSnackbar deferredSuccess(BuildContext c, String message) {
    final messenger = ScaffoldMessenger.of(c);
    final snackBar = _snackBar(
      c,
      message: message,
      tone: MxSnackbarTone.success,
    );
    return () => _show(messenger, snackBar);
  }

  static void success(BuildContext c, String message) =>
      show(c, message: message, tone: MxSnackbarTone.success);

  static void warning(BuildContext c, String message) =>
      show(c, message: message, tone: MxSnackbarTone.warning);

  static void error(BuildContext c, String message) =>
      show(c, message: message, tone: MxSnackbarTone.error);

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _show(
    ScaffoldMessengerState messenger,
    SnackBar snackBar,
  ) {
    messenger.clearSnackBars();
    return messenger.showSnackBar(snackBar);
  }

  static SnackBar _snackBar(
    BuildContext context, {
    required String message,
    MxSnackbarTone tone = MxSnackbarTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = MxDurations.snackbar,
    IconData? icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;

    final (Color bg, Color fg, IconData defaultIcon) = switch (tone) {
      MxSnackbarTone.neutral => (
        scheme.inverseSurface,
        scheme.onInverseSurface,
        Icons.info_outline,
      ),
      MxSnackbarTone.success => (
        mx.success,
        mx.onSuccess,
        Icons.check_circle_outline,
      ),
      MxSnackbarTone.warning => (
        mx.warning,
        mx.onWarning,
        Icons.warning_amber_outlined,
      ),
      MxSnackbarTone.error => (
        scheme.error,
        scheme.onError,
        Icons.error_outline,
      ),
    };

    return SnackBar(
      backgroundColor: bg,
      duration: duration,
      content: Row(
        children: [
          Icon(icon ?? defaultIcon, color: fg, size: AppIconSizes.md),
          const MxGap(AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: fg,
              onPressed: onAction,
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/app_elevation.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

abstract final class DialogThemeBuilder {
  static DialogThemeData dialog(ColorScheme scheme) {
    return DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: scheme.surfaceTint,
      shadowColor: scheme.shadow,
      elevation: AppElevation.dialog,
      alignment: Alignment.center,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      titleTextStyle: AppTypography.headlineSmall.copyWith(
        color: scheme.onSurface,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    );
  }

  static BottomSheetThemeData bottomSheet(ColorScheme scheme) {
    return BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBackgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: scheme.surfaceTint,
      shadowColor: scheme.shadow,
      modalElevation: AppElevation.bottomSheet,
      elevation: AppElevation.bottomSheet,
      showDragHandle: true,
      dragHandleColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
      dragHandleSize: const Size(32, 4),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      clipBehavior: Clip.antiAlias,
    );
  }

  static SnackBarThemeData snackbar(ColorScheme scheme) {
    return SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      actionTextColor: scheme.inversePrimary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onInverseSurface,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: AppElevation.snackbar,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      showCloseIcon: false,
    );
  }
}

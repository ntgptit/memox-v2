import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// MemoX app bar theme.
///
/// Design language: the app bar is **a row on the page**, not a separate
/// elevated surface. Background blends with the scaffold so the chrome reads
/// as a quiet navigation strip rather than a Material 2-style raised toolbar.
/// On scroll Flutter draws a subtle surface tint (via M3's
/// `scrolledUnderElevation` mechanism) only when content sits under the bar —
/// we opt out of that here too so the page stays flat end-to-end.
abstract final class AppBarThemeBuilder {
  static AppBarTheme build(ColorScheme scheme) {
    return AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint.withValues(
        alpha: AppOpacity.transparent,
      ),
      shadowColor: scheme.shadow,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppSpacing.lg,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: scheme.onSurface,
      ),
      toolbarTextStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onSurface,
      ),
      systemOverlayStyle: null,
    );
  }
}

import '../../../core/theme/tokens/app_spacing.dart';

/// Feature-facing spacing surface for local UI rhythm.
///
/// Use this for micro-spacing inside feature screens and widgets. Page gutter,
/// top padding, and bottom FAB clearance must still come from `AppLayout`
/// through `MxContentShell` or `MxScaffold`.
abstract final class MxSpace {
  static const double xxs = AppSpacing.xxs;
  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double xxl = AppSpacing.xxl;
}

/// Opacity tokens. Use these instead of hardcoding numeric alpha values so
/// half / disabled / hover opacities stay consistent across the app.
///
/// Lives next to the other raw tokens — not feature-facing. Component themes
/// and shared widgets reach for it; features should get opacity effects
/// through semantic colors or variant props, not by applying opacity to a
/// raw color.
abstract final class AppOpacity {
  static const double full = 1.0;

  /// Disabled foreground (text on disabled surfaces).
  static const double disabled = 0.38;

  /// Disabled background.
  static const double disabledSurface = 0.12;

  /// Subtle hover / pressed state.
  static const double hover = 0.08;

  /// Drag handle / scrim.
  static const double handle = 0.4;

  /// Half opacity. Prefer a themed semantic color when possible.
  static const double half = 0.5;

  static const double transparent = 0.0;
}

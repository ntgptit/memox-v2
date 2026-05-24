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

  /// MemoX ghost border opacity for quiet card outlines.
  static const double ghostBorder = 0.15;

  /// Glass chrome opacity for app bars, bottom nav, and sticky chrome.
  static const double surfaceGlass = 0.84;

  /// Selected bottom-nav icon pill opacity on Tokyo Pure Light.
  static const double navigationSelectedPillLight = 0.14;

  /// Selected bottom-nav icon pill opacity on Tokyo Nebula.
  static const double navigationSelectedPillDark = 0.20;

  /// Drag handle / scrim.
  static const double handle = 0.4;

  /// Half opacity. Prefer a themed semantic color when possible.
  static const double half = 0.5;

  static const double transparent = 0.0;
}

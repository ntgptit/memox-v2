/// Shared button size enum used by both primary and secondary buttons.
///
/// Concrete min-heights (set by each button's `_sizeStyle`):
/// `xsmall` 32 · `small` 36 · `compact` 40 · `medium` 48 · `large` 52–56.
///
/// Pick:
/// - `xsmall` / `small`: dense toolbar / inline trigger / sort chip menus.
/// - `compact`: slim hero pill CTAs (study mode, modal footers) where a 48-dp
///   target reads too heavy.
/// - `medium`: default form / dialog primary action.
/// - `large`: page-bottom hero CTA on a screen with one primary action.
enum MxButtonSize { xsmall, small, compact, medium, large }

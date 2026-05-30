import 'package:memox/core/utils/string_utils.dart';

/// Hint reveal policy for Fill mode.
///
/// Spec: `docs/wireframes/17-study-session-fill.md` §Components (Hint button)
/// and §Matching rules (v1) hint-taint rule.
/// - Reveal cap = floor(trimmed expected length / 2).
/// - Each tap reveals one more leading character of the trimmed expected.
/// - Once revealCount > 0 the card is hint-tainted for grading.
abstract final class FillHintPolicy {
  static int maxRevealCount(String? expectedAnswer) {
    final expected = StringUtils.trimmed(expectedAnswer);
    return expected.length ~/ 2;
  }

  static String revealedPrefix(String? expectedAnswer, int revealCount) {
    final expected = StringUtils.trimmed(expectedAnswer);
    if (revealCount <= 0 || expected.isEmpty) {
      return '';
    }
    final clamped = revealCount.clamp(0, maxRevealCount(expected));
    if (clamped <= 0) return '';
    return expected.substring(0, clamped);
  }

  static int nextRevealCount(String? expectedAnswer, int currentRevealCount) {
    final cap = maxRevealCount(expectedAnswer);
    if (cap <= 0) return 0;
    final next = currentRevealCount + 1;
    if (next > cap) return cap;
    return next;
  }

  static bool canRevealMore(String? expectedAnswer, int currentRevealCount) =>
      currentRevealCount < maxRevealCount(expectedAnswer);

  static bool isHintTainted(int revealCount) => revealCount > 0;
}

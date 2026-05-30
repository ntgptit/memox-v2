import 'package:memox/core/utils/string_utils.dart';

/// Strict matcher for Fill-mode answers.
///
/// Spec: `docs/wireframes/17-study-session-fill.md` §Matching rules (v1).
/// - Trim both sides (via `StringUtils.trimmed`).
/// - Strict character match (no case folding, no diacritic stripping,
///   no internal whitespace collapsing).
class FillAnswerMatchResult {
  const FillAnswerMatchResult({
    required this.userAnswer,
    required this.expectedAnswer,
    required this.isExactMatch,
  });

  final String userAnswer;
  final String expectedAnswer;
  final bool isExactMatch;
}

abstract final class FillAnswerMatcher {
  static FillAnswerMatchResult evaluate(
    String? userAnswer,
    String? expectedAnswer,
  ) {
    final user = StringUtils.trimmed(userAnswer);
    final expected = StringUtils.trimmed(expectedAnswer);
    final isMatch = user.isNotEmpty && user == expected;
    return FillAnswerMatchResult(
      userAnswer: user,
      expectedAnswer: expected,
      isExactMatch: isMatch,
    );
  }

  static bool matches(String? userAnswer, String? expectedAnswer) =>
      evaluate(userAnswer, expectedAnswer).isExactMatch;
}

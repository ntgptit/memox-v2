import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/fill/fill_answer_matcher.dart';

void main() {
  group('FillAnswerMatcher', () {
    test('exact match passes', () {
      expect(FillAnswerMatcher.matches('웃기다', '웃기다'), isTrue);
    });

    test('trim-only difference still matches', () {
      expect(FillAnswerMatcher.matches('  웃기다 ', '웃기다'), isTrue);
      expect(FillAnswerMatcher.matches('웃기다', '  웃기다  '), isTrue);
    });

    test('case difference fails (no case folding)', () {
      expect(FillAnswerMatcher.matches('ABC', 'abc'), isFalse);
      expect(FillAnswerMatcher.matches('Hello', 'hello'), isFalse);
    });

    test('diacritic difference fails (no diacritic stripping)', () {
      expect(FillAnswerMatcher.matches('café', 'cafe'), isFalse);
      expect(FillAnswerMatcher.matches('naïve', 'naive'), isFalse);
    });

    test('internal whitespace difference fails (no whitespace collapsing)', () {
      expect(FillAnswerMatcher.matches('a  b', 'a b'), isFalse);
    });

    test('blank input never matches a non-empty expected', () {
      expect(FillAnswerMatcher.matches('', 'abc'), isFalse);
      expect(FillAnswerMatcher.matches('   ', 'abc'), isFalse);
      expect(FillAnswerMatcher.matches(null, 'abc'), isFalse);
    });

    test('blank vs blank does not falsely report exact match', () {
      // Empty input must not be treated as a satisfactory answer even when the
      // expected answer is also empty.
      expect(FillAnswerMatcher.matches('', ''), isFalse);
      expect(FillAnswerMatcher.matches(null, null), isFalse);
    });

    test('evaluate returns trimmed values', () {
      final result = FillAnswerMatcher.evaluate('  웃기다  ', '웃기다');
      expect(result.userAnswer, '웃기다');
      expect(result.expectedAnswer, '웃기다');
      expect(result.isExactMatch, isTrue);
    });
  });
}

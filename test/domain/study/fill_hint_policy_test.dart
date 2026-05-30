import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/fill/fill_hint_policy.dart';

void main() {
  group('FillHintPolicy.maxRevealCount uses floor(len/2)', () {
    test('length 5 → 2', () {
      expect(FillHintPolicy.maxRevealCount('abcde'), 2);
    });
    test('length 4 → 2', () {
      expect(FillHintPolicy.maxRevealCount('abcd'), 2);
    });
    test('length 3 → 1', () {
      expect(FillHintPolicy.maxRevealCount('abc'), 1);
    });
    test('length 2 → 1', () {
      // Floor(2/2) == 1; reveal of a single char on a two-char answer is
      // still valid per wireframe matching rules (max half).
      expect(FillHintPolicy.maxRevealCount('ab'), 1);
    });
    test('length 1 → 0 (no reveal possible)', () {
      expect(FillHintPolicy.maxRevealCount('a'), 0);
    });
    test('trims before computing length', () {
      expect(FillHintPolicy.maxRevealCount('  abcd  '), 2);
    });
    test('empty/null → 0', () {
      expect(FillHintPolicy.maxRevealCount(''), 0);
      expect(FillHintPolicy.maxRevealCount(null), 0);
    });
  });

  group('FillHintPolicy.nextRevealCount', () {
    test('increments by one up to cap', () {
      expect(FillHintPolicy.nextRevealCount('abcde', 0), 1);
      expect(FillHintPolicy.nextRevealCount('abcde', 1), 2);
    });

    test('never exceeds cap', () {
      expect(FillHintPolicy.nextRevealCount('abcde', 2), 2);
      expect(FillHintPolicy.nextRevealCount('abcde', 99), 2);
    });

    test('returns 0 when cap is 0', () {
      expect(FillHintPolicy.nextRevealCount('a', 0), 0);
      expect(FillHintPolicy.nextRevealCount('', 0), 0);
    });
  });

  group('FillHintPolicy.revealedPrefix', () {
    test('uses trimmed expected answer', () {
      expect(FillHintPolicy.revealedPrefix('  웃기다  ', 1), '웃');
      expect(FillHintPolicy.revealedPrefix('  웃기다  ', 0), '');
    });

    test('clamps to max reveal cap', () {
      // length 5, cap 2 → revealing >cap returns prefix of cap length.
      expect(FillHintPolicy.revealedPrefix('abcde', 4), 'ab');
    });

    test('returns empty when expected is empty', () {
      expect(FillHintPolicy.revealedPrefix('', 1), '');
      expect(FillHintPolicy.revealedPrefix(null, 1), '');
    });
  });

  group('FillHintPolicy.canRevealMore', () {
    test('true when below cap', () {
      expect(FillHintPolicy.canRevealMore('abcde', 0), isTrue);
      expect(FillHintPolicy.canRevealMore('abcde', 1), isTrue);
    });
    test('false at cap', () {
      expect(FillHintPolicy.canRevealMore('abcde', 2), isFalse);
    });
    test('false when cap is 0', () {
      expect(FillHintPolicy.canRevealMore('a', 0), isFalse);
    });
  });

  group('FillHintPolicy.isHintTainted', () {
    test('false at zero reveals', () {
      expect(FillHintPolicy.isHintTainted(0), isFalse);
    });
    test('true once any character is revealed', () {
      expect(FillHintPolicy.isHintTainted(1), isTrue);
      expect(FillHintPolicy.isHintTainted(99), isTrue);
    });
  });
}

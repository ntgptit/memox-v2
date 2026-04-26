import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/utils/string_utils.dart';

void main() {
  test('DT1 normalize: trims and lowercases comparison and search values', () {
    expect(StringUtils.normalizedForComparison('  HeLLo  '), 'hello');
    expect(StringUtils.normalizedForSearch('  HeLLo  '), 'hello');
  });

  test('DT2 normalize: treats null empty and whitespace as blank', () {
    expect(StringUtils.isBlank(null), isTrue);
    expect(StringUtils.isBlank(''), isTrue);
    expect(StringUtils.isBlank('   '), isTrue);
    expect(StringUtils.isNotBlank(null), isFalse);
    expect(StringUtils.isNotBlank(''), isFalse);
    expect(StringUtils.isNotBlank('   '), isFalse);
    expect(StringUtils.trimToNull(null), isNull);
    expect(StringUtils.trimToNull(''), isNull);
    expect(StringUtils.trimToNull('   '), isNull);
  });

  test('DT3 normalize: preserves nonblank trimmed optional text', () {
    expect(StringUtils.isNotBlank('  MemoX  '), isTrue);
    expect(StringUtils.trim('  MemoX  '), 'MemoX');
    expect(StringUtils.trimToEmpty('  MemoX  '), 'MemoX');
    expect(StringUtils.trimToNull('  MemoX  '), 'MemoX');
  });

  test('DT4 normalize: collapses repeated whitespace on demand', () {
    expect(
      StringUtils.normalizeSpace('  MemoX   study\tflow  '),
      'MemoX study flow',
    );
    expect(
      StringUtils.normalizedWhitespace('  MemoX   study\tflow  '),
      'MemoX study flow',
    );
  });

  test('DT5 normalize: uppercases through StringUtils', () {
    expect(StringUtils.uppercased('mx'), 'MX');
    expect(StringUtils.upperCase('mx'), 'MX');
    expect(StringUtils.upperCaseToEmpty('mx'), 'MX');
  });

  test('DT6 normalize: handles null transforms without throwing', () {
    expect(StringUtils.trim(null), isNull);
    expect(StringUtils.trimToEmpty(null), '');
    expect(StringUtils.lowerCase(null), isNull);
    expect(StringUtils.lowerCaseToEmpty(null), '');
    expect(StringUtils.upperCase(null), isNull);
    expect(StringUtils.upperCaseToEmpty(null), '');
    expect(StringUtils.normalizeSpace(null), isNull);
    expect(StringUtils.normalizeSpaceToEmpty(null), '');
    expect(StringUtils.normalizedForComparison(null), '');
    expect(StringUtils.normalizedForSearch(null), '');
    expect(StringUtils.uppercased(null), '');
    expect(StringUtils.normalizedWhitespace(null), '');
  });

  test('DT1 match: equalsNormalized ignores case and outer whitespace', () {
    expect(StringUtils.equalsNormalized(' Front ', 'front'), isTrue);
  });

  test('DT2 match: containsNormalized finds normalized query', () {
    expect(
      StringUtils.containsNormalized('MemoX Flashcard Library', ' flashcard '),
      isTrue,
    );
  });

  test('DT3 match: containsNormalized rejects missing query', () {
    expect(
      StringUtils.containsNormalized('MemoX Flashcard Library', 'progress'),
      isFalse,
    );
  });

  test('DT4 match: containsNormalized accepts blank query', () {
    expect(
      StringUtils.containsNormalized('MemoX Flashcard Library', '   '),
      isTrue,
    );
  });

  test('DT5 match: containsNormalized rejects null source', () {
    expect(StringUtils.containsNormalized(null, 'memo'), isFalse);
  });

  test('DT6 match: equalsNormalized accepts both null values', () {
    expect(StringUtils.equalsNormalized(null, null), isTrue);
  });

  test('DT7 match: equalsNormalized does not collapse null into blank', () {
    expect(StringUtils.equalsNormalized(null, ''), isFalse);
  });

  test('DT1 sort: compareNormalized sorts by normalized text', () {
    expect(StringUtils.compareNormalized(' alpha ', 'Beta'), isNegative);
  });

  test('DT2 sort: compareNormalized treats case-only differences as equal', () {
    expect(StringUtils.compareNormalized('Deck', 'deck'), 0);
  });

  test('DT3 sort: compareNormalized treats two null values as equal', () {
    expect(StringUtils.compareNormalized(null, null), 0);
  });

  test('DT4 sort: compareNormalized sorts null before text', () {
    expect(StringUtils.compareNormalized(null, 'alpha'), isNegative);
  });

  test('DT5 sort: compareNormalized sorts text after null', () {
    expect(StringUtils.compareNormalized('alpha', null), isPositive);
  });
}

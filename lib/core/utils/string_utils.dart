abstract final class StringUtils {
  static final RegExp _whitespacePattern = RegExp(r'\s+');

  static String? trim(String? value) => value?.trim();

  static String trimToEmpty(String? value) => trim(value) ?? '';

  static String trimmed(String? value) => trimToEmpty(value);

  static bool isBlank(String? value) => trimToEmpty(value).isEmpty;

  static bool isNotBlank(String? value) => !isBlank(value);

  static String? trimToNull(String? value) {
    final result = trim(value);
    if (result == null || result.isEmpty) {
      return null;
    }
    return result;
  }

  static String? lowerCase(String? value) => value?.toLowerCase();

  static String lowerCaseToEmpty(String? value) => lowerCase(value) ?? '';

  static String? upperCase(String? value) => value?.toUpperCase();

  static String upperCaseToEmpty(String? value) => upperCase(value) ?? '';

  static String normalizedForComparison(String? value) {
    return lowerCaseToEmpty(trimToEmpty(value));
  }

  static String normalizedForSearch(String? value) {
    return normalizedForComparison(value);
  }

  static String uppercased(String? value) {
    return upperCaseToEmpty(value);
  }

  static String? normalizeSpace(String? value) {
    final result = trim(value);
    if (result == null) {
      return null;
    }
    return result.replaceAll(_whitespacePattern, ' ');
  }

  static String normalizeSpaceToEmpty(String? value) {
    return normalizeSpace(value) ?? '';
  }

  static String normalizedWhitespace(String? value) {
    return normalizeSpaceToEmpty(value);
  }

  static bool equalsNormalized(String? left, String? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return normalizedForComparison(left) == normalizedForComparison(right);
  }

  static bool containsNormalized(String? source, String? query) {
    if (source == null) {
      return false;
    }
    final normalizedQuery = normalizedForSearch(query);
    if (normalizedQuery.isEmpty) {
      return true;
    }
    return normalizedForSearch(source).contains(normalizedQuery);
  }

  static int compareNormalized(String? left, String? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return -1;
    }
    if (right == null) {
      return 1;
    }
    return normalizedForComparison(
      left,
    ).compareTo(normalizedForComparison(right));
  }
}

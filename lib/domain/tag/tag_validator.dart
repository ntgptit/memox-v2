import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../core/utils/string_utils.dart';

/// Pure validator + normalizer for tag names.
///
/// Rules (`docs/contracts/usecase-contracts/tag.md` §TagValidator +
/// `docs/business/tags/tag-system.md`):
/// - Strip a single leading `#` (cosmetic prefix the user may type).
/// - Trim surrounding whitespace.
/// - Reject empty → [FailureCodes.tagEmpty].
/// - Reject any comma — reserved as the `entry_ref_id` separator for
///   `entry_type=tag` → [FailureCodes.tagInvalidCharacter].
/// - Reject length > [maxLength] after trim → [FailureCodes.tagTooLong].
/// - On success, return the lowercased trimmed string (storage form is
///   case-insensitive; tags are stored lowercased in V1).
final class TagValidator {
  const TagValidator();

  static const int maxLength = 50;

  Result<String> validate(String input) {
    var value = StringUtils.trimmed(input);
    if (value.startsWith('#')) {
      value = StringUtils.trimmed(value.substring(1));
    }

    if (value.isEmpty) {
      return _failure(FailureCodes.tagEmpty, 'Tag name is required.');
    }
    if (value.contains(',')) {
      return _failure(
        FailureCodes.tagInvalidCharacter,
        'Tags cannot contain commas.',
      );
    }
    if (value.length > maxLength) {
      return _failure(
        FailureCodes.tagTooLong,
        'Tag too long (max $maxLength chars).',
      );
    }

    return Success<String>(StringUtils.lowerCaseToEmpty(value));
  }

  FailureResult<String> _failure(String code, String message) =>
      FailureResult<String>(
        AppFailure(
          type: FailureType.validation,
          message: message,
          code: code,
        ),
      );
}

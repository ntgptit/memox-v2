import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/failures.dart';
import 'package:memox/domain/tag/tag_validator.dart';

void main() {
  const validator = TagValidator();

  group('TagValidator (decision rows TG9, TG10)', () {
    test('rejects empty input', () {
      final result = validator.validate('   ');
      expect(result.failureOrNull?.code, FailureCodes.tagEmpty);
    });

    test('rejects a comma (TG9)', () {
      final result = validator.validate('weak,grammar');
      expect(result.failureOrNull?.code, FailureCodes.tagInvalidCharacter);
    });

    test('rejects names longer than 50 chars (TG10)', () {
      final result = validator.validate('a' * 51);
      expect(result.failureOrNull?.code, FailureCodes.tagTooLong);
    });

    test('accepts a 50-char name', () {
      final result = validator.validate('a' * 50);
      expect(result.valueOrNull, 'a' * 50);
    });

    test('normalizes to lowercase', () {
      expect(validator.validate('Verb').valueOrNull, 'verb');
      expect(validator.validate('  GRAMMAR  ').valueOrNull, 'grammar');
    });

    test('strips a single leading # before validating', () {
      expect(validator.validate('#weak').valueOrNull, 'weak');
      expect(validator.validate('# ').failureOrNull?.code, FailureCodes.tagEmpty);
    });
  });
}

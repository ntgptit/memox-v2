import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/core/errors/error_mapper.dart';
import 'package:memox/core/errors/failures.dart';

void main() {
  group('ErrorMapper.map', () {
    test('maps timeout exceptions to retryable network failures', () {
      final failure = ErrorMapper.map(
        TimeoutException('request timed out'),
      );

      expect(failure.type, FailureType.network);
      expect(failure.code, FailureCodes.requestTimedOut);
      expect(failure.isRetryable, isTrue);
    });

    test('preserves configuration exception metadata', () {
      final failure = ErrorMapper.map(
        const ConfigurationException(
          message: 'Invalid env',
          code: FailureCodes.invalidAppEnvironment,
        ),
      );

      expect(failure.type, FailureType.configuration);
      expect(failure.code, FailureCodes.invalidAppEnvironment);
      expect(failure.severity, FailureSeverity.critical);
    });
  });
}

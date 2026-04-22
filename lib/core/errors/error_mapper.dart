import 'dart:async';

import 'app_exception.dart';
import 'failures.dart';

/// Maps low-level errors into a normalized app failure contract.
final class ErrorMapper {
  const ErrorMapper._();

  static AppFailure map(Object? error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }

    if (error is AppException) {
      return _fromAppException(error);
    }

    if (error is TimeoutException) {
      return AppFailure(
        type: FailureType.network,
        message: 'Request timed out.',
        code: FailureCodes.requestTimedOut,
        cause: error,
        stackTrace: stackTrace,
        technicalDetails: error.message,
        isRetryable: true,
      );
    }

    if (error is FormatException) {
      return AppFailure(
        type: FailureType.validation,
        message: 'Invalid data received.',
        code: FailureCodes.invalidData,
        cause: error,
        stackTrace: stackTrace,
        technicalDetails: error.message,
      );
    }

    if (error is UnsupportedError) {
      return AppFailure(
        type: FailureType.configuration,
        message: 'Unsupported action in the current configuration.',
        code: FailureCodes.unsupportedAction,
        cause: error,
        stackTrace: stackTrace,
        technicalDetails: error.message,
      );
    }

    return AppFailure.unknown(
      cause: error,
      code: FailureCodes.unknown,
      stackTrace: stackTrace,
      technicalDetails: error?.toString(),
    );
  }

  static AppFailure _fromAppException(AppException error) {
    return switch (error.type) {
      AppExceptionType.configuration => AppFailure(
          type: FailureType.configuration,
          message: error.message,
          code: error.code,
          cause: error.cause,
          stackTrace: error.stackTrace,
          technicalDetails: error.technicalDetails,
          severity: FailureSeverity.critical,
        ),
      AppExceptionType.validation => AppFailure(
          type: FailureType.validation,
          message: error.message,
          code: error.code,
          cause: error.cause,
          stackTrace: error.stackTrace,
          technicalDetails: error.technicalDetails,
        ),
      AppExceptionType.network => AppFailure(
          type: FailureType.network,
          message: error.message,
          code: error.code,
          cause: error.cause,
          stackTrace: error.stackTrace,
          technicalDetails: error.technicalDetails,
          isRetryable: true,
        ),
      AppExceptionType.storage => AppFailure(
          type: FailureType.storage,
          message: error.message,
          code: error.code,
          cause: error.cause,
          stackTrace: error.stackTrace,
          technicalDetails: error.technicalDetails,
        ),
      AppExceptionType.notFound => AppFailure(
          type: FailureType.notFound,
          message: error.message,
          code: error.code,
          cause: error.cause,
          stackTrace: error.stackTrace,
          technicalDetails: error.technicalDetails,
        ),
      AppExceptionType.unknown => AppFailure.unknown(
          message: error.message,
          code: error.code,
          cause: error.cause,
          stackTrace: error.stackTrace,
          technicalDetails: error.technicalDetails,
        ),
    };
  }
}

import 'package:flutter/foundation.dart';

abstract final class FailureCodes {
  const FailureCodes._();

  static const String invalidAppEnvironment = 'invalid_app_environment';
  static const String requestTimedOut = 'request_timed_out';
  static const String invalidData = 'invalid_data';
  static const String unsupportedAction = 'unsupported_action';
  static const String unknown = 'unknown';

  // Tag domain (docs/contracts/usecase-contracts/tag.md §TagValidator).
  static const String tagEmpty = 'tag_empty';
  static const String tagInvalidCharacter = 'tag_invalid_character';
  static const String tagTooLong = 'tag_too_long';
  static const String tagNameConflict = 'tag_name_conflict';
}

enum FailureType {
  unknown,
  configuration,
  validation,
  network,
  storage,
  notFound,
}

enum FailureSeverity { recoverable, critical }

@immutable
class AppFailure {
  const AppFailure({
    required this.type,
    required this.message,
    this.code,
    this.cause,
    this.stackTrace,
    this.technicalDetails,
    this.severity = FailureSeverity.recoverable,
    this.isRetryable = false,
  });

  factory AppFailure.unknown({
    String message = 'Something went wrong.',
    String? code,
    Object? cause,
    StackTrace? stackTrace,
    String? technicalDetails,
  }) => AppFailure(
    type: FailureType.unknown,
    message: message,
    code: code,
    cause: cause,
    stackTrace: stackTrace,
    technicalDetails: technicalDetails,
    severity: FailureSeverity.critical,
  );

  final FailureType type;
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? technicalDetails;
  final FailureSeverity severity;
  final bool isRetryable;
}

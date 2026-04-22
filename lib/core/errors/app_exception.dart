import 'package:flutter/foundation.dart';

enum AppExceptionType {
  unknown,
  configuration,
  validation,
  network,
  storage,
  notFound,
}

@immutable
class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
    this.code,
    this.cause,
    this.stackTrace,
  });

  final AppExceptionType type;
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  String get technicalDetails {
    final codeLabel = code == null ? '' : ' [$code]';
    return '${type.name}$codeLabel: $message';
  }

  @override
  String toString() => technicalDetails;
}

class ConfigurationException extends AppException {
  const ConfigurationException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  }) : super(type: AppExceptionType.configuration);
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  }) : super(type: AppExceptionType.validation);
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  }) : super(type: AppExceptionType.network);
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  }) : super(type: AppExceptionType.storage);
}

class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  }) : super(type: AppExceptionType.notFound);
}

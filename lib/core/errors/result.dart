import 'failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess;
  bool get isFailure => !isSuccess;

  T? get valueOrNull;
  AppFailure? get failureOrNull;
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool get isSuccess => true;

  @override
  T get valueOrNull => value;

  @override
  AppFailure? get failureOrNull => null;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final AppFailure failure;

  @override
  bool get isSuccess => false;

  @override
  T? get valueOrNull => null;

  @override
  AppFailure get failureOrNull => failure;
}

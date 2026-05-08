import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';

typedef MxAsyncActionStateSetter = void Function(AsyncValue<void> state);

final class MxAsyncActionRunner {
  const MxAsyncActionRunner({required this.isMounted, required this.setState});

  final bool Function() isMounted;
  final MxAsyncActionStateSetter setState;

  Future<bool> run(
    Future<void> Function() action, {
    FutureOr<void> Function()? onSuccess,
  }) async {
    setState(const AsyncLoading<void>());
    try {
      await action();
      if (!isMounted()) {
        return false;
      }
      await onSuccess?.call();
      if (!isMounted()) {
        return false;
      }
      setState(const AsyncData<void>(null));
      return true;
    } catch (error, stackTrace) {
      if (!isMounted()) {
        return false;
      }
      _setFailure(ErrorMapper.map(error, stackTrace), stackTrace);
      return false;
    }
  }

  Future<bool> runResult<T>(
    Future<Result<T>> Function() action, {
    FutureOr<void> Function(T? value)? onSuccess,
  }) async {
    setState(const AsyncLoading<void>());
    final result = await action();
    if (!isMounted()) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      _setFailure(failure);
      return false;
    }
    await onSuccess?.call(result.valueOrNull);
    if (!isMounted()) {
      return false;
    }
    setState(const AsyncData<void>(null));
    return true;
  }

  Future<T?> runResultValue<T>(
    Future<Result<T>> Function() action, {
    FutureOr<void> Function(T value)? onSuccess,
  }) async {
    setState(const AsyncLoading<void>());
    final result = await action();
    if (!isMounted()) {
      return null;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      _setFailure(failure);
      return null;
    }
    final value = result.valueOrNull;
    if (value == null) {
      setState(const AsyncData<void>(null));
      return null;
    }
    await onSuccess?.call(value);
    if (!isMounted()) {
      return null;
    }
    setState(const AsyncData<void>(null));
    return value;
  }

  void _setFailure(AppFailure failure, [StackTrace? fallbackStackTrace]) {
    setState(
      AsyncError<void>(
        failure,
        failure.stackTrace ?? fallbackStackTrace ?? StackTrace.current,
      ),
    );
  }
}

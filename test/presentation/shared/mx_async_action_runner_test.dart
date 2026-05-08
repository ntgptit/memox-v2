import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/core/errors/failures.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/presentation/shared/viewmodels/mx_async_action_runner.dart';

void main() {
  test('DT1 runResult: emits data and returns true on success', () async {
    final states = <AsyncValue<void>>[];
    String? successValue;
    final runner = MxAsyncActionRunner(
      isMounted: () => true,
      setState: states.add,
    );

    final result = await runner.runResult<String>(
      () async => const Success<String>('deck-001'),
      onSuccess: (value) {
        successValue = value;
      },
    );

    expect(result, isTrue);
    expect(successValue, 'deck-001');
    expect(states.first, const AsyncLoading<void>());
    expect(states.last, const AsyncData<void>(null));
  });

  test('DT2 runResult: emits failure and returns false', () async {
    final states = <AsyncValue<void>>[];
    const failure = AppFailure(
      type: FailureType.validation,
      message: 'Name is required.',
    );
    final runner = MxAsyncActionRunner(
      isMounted: () => true,
      setState: states.add,
    );

    final result = await runner.runResult<void>(
      () async => const FailureResult<void>(failure),
    );

    expect(result, isFalse);
    expect(states.first, const AsyncLoading<void>());
    expect(states.last.hasError, isTrue);
    expect(states.last.error, same(failure));
  });

  test('DT3 runResult: skips success state after disposal', () async {
    final states = <AsyncValue<void>>[];
    var mounted = true;
    final runner = MxAsyncActionRunner(
      isMounted: () => mounted,
      setState: states.add,
    );

    final result = await runner.runResult<void>(() async {
      mounted = false;
      return const Success<void>(null);
    });

    expect(result, isFalse);
    expect(states, const <AsyncValue<void>>[AsyncLoading<void>()]);
  });

  test('DT1 run: maps thrown exceptions to AppFailure', () async {
    final states = <AsyncValue<void>>[];
    final runner = MxAsyncActionRunner(
      isMounted: () => true,
      setState: states.add,
    );

    final result = await runner.run(() async {
      throw const ValidationException(message: 'Answer is required.');
    });

    expect(result, isFalse);
    expect(states.first, const AsyncLoading<void>());
    expect(states.last.hasError, isTrue);
    final failure = states.last.error! as AppFailure;
    expect(failure.type, FailureType.validation);
    expect(failure.message, 'Answer is required.');
  });
}

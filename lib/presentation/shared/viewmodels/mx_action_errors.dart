import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failures.dart';

/// Shared helpers for surfacing [AppFailure] from action-controller
/// `AsyncValue<void>` states.
///
/// Each feature historically declared its own `xxxError` / `xxxErrorMessage`
/// pair with identical bodies. Forward those forwarders to this helper so the
/// failure-extraction and validation-precedence rules live in one place.
abstract final class MxActionErrors {
  const MxActionErrors._();

  /// Pull the [AppFailure] out of an action state, or `null` when the state
  /// is not an error (or the error is not an [AppFailure]).
  static AppFailure? failureOf(AsyncValue<void> actionState) => actionState
      .whenOrNull(error: (error, _) => error is AppFailure ? error : null);

  /// Map an [AppFailure] to a user-facing message. Validation failures take
  /// precedence so the field-specific message reaches the user instead of the
  /// generic failure text. Returns an empty string when [failure] is null.
  static String messageOf(AppFailure? failure) {
    if (failure == null) {
      return '';
    }
    if (failure.cause case final ValidationException cause) {
      return cause.message;
    }
    return failure.message;
  }
}

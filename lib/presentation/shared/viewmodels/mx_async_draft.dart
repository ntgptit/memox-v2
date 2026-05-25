import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helpers for `AsyncValue<T>` states that wrap an editable draft.
///
/// Form notifiers commonly hold `AsyncValue<DraftState>` while loading the
/// initial draft from a use case, then mutate via `state = AsyncData(next)`.
/// These helpers remove the repeated `switch (state) { AsyncData(:final value)
/// => value, _ => null }` pattern.
extension MxAsyncDraft<T> on AsyncValue<T> {
  /// The current value when the AsyncValue is in `AsyncData`, otherwise null.
  /// Use this to read the draft from a notifier without re-deriving the
  /// pattern match at every callsite.
  T? get currentValue => switch (this) {
    AsyncData(:final value) => value,
    _ => null,
  };
}

/// Applies a pure update to the value inside [state] when present. No-op when
/// the AsyncValue is loading or in an error without prior data.
///
/// Typical wiring inside a notifier:
/// ```dart
/// void setFront(String value) =>
///     state = mxPatchDraft(state, (d) => d.copyWith(front: value));
/// ```
AsyncValue<T> mxPatchDraft<T>(
  AsyncValue<T> state,
  T Function(T draft) update,
) => switch (state) {
  AsyncData(:final value) => AsyncData(update(value)),
  _ => state,
};

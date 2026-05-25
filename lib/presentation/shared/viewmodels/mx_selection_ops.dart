/// Pure operations for set-based multi-selection state used by feature
/// notifiers.
///
/// Notifiers hold `Set<TId>` directly (kept compatible with `@riverpod`
/// codegen) and call these helpers to produce the next state. The functions
/// are pure so they can be unit-tested without a Riverpod container.
///
/// Typical wiring:
/// ```dart
/// @riverpod
/// class FlashcardSelection extends _$FlashcardSelection {
///   @override
///   Set<String> build(String deckId) => const <String>{};
///
///   void toggle(String id) => state = MxSelectionOps.toggle(state, id);
///   void setAll(Iterable<String> ids) =>
///       state = MxSelectionOps.setAll(ids);
///   void clear() => state = MxSelectionOps.clear<String>();
/// }
/// ```
abstract final class MxSelectionOps {
  const MxSelectionOps._();

  /// Returns the next selection after toggling [id]. Adds when absent, removes
  /// when present. Always returns a new set so Riverpod detects the change.
  static Set<TId> toggle<TId>(Set<TId> current, TId id) {
    if (current.contains(id)) {
      return {...current}..remove(id);
    }
    return {...current, id};
  }

  /// Replaces the selection with [ids].
  static Set<TId> setAll<TId>(Iterable<TId> ids) => ids.toSet();

  /// Empty selection literal — typed so the notifier doesn't need to repeat
  /// the type annotation at every callsite.
  static Set<TId> clear<TId>() => <TId>{};

  /// Adds [ids] to the current selection, preserving existing entries.
  static Set<TId> addAll<TId>(Set<TId> current, Iterable<TId> ids) =>
      {...current, ...ids};

  /// Removes [ids] from the current selection.
  static Set<TId> removeAll<TId>(Set<TId> current, Iterable<TId> ids) =>
      current.difference(ids.toSet());

  /// Whether every entry in [available] is currently selected. Returns false
  /// when [available] is empty so "select all" toggles read correctly on an
  /// empty pool.
  static bool isAllSelected<TId>(Set<TId> current, Iterable<TId> available) {
    final pool = available.toSet();
    if (pool.isEmpty) {
      return false;
    }
    return current.containsAll(pool);
  }
}

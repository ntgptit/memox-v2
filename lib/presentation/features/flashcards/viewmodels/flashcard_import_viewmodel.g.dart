// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_import_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FlashcardImportDraft)
final flashcardImportDraftProvider = FlashcardImportDraftFamily._();

final class FlashcardImportDraftProvider
    extends $NotifierProvider<FlashcardImportDraft, FlashcardImportDraftState> {
  FlashcardImportDraftProvider._({
    required FlashcardImportDraftFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardImportDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardImportDraftHash();

  @override
  String toString() {
    return r'flashcardImportDraftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardImportDraft create() => FlashcardImportDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlashcardImportDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlashcardImportDraftState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FlashcardImportDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardImportDraftHash() =>
    r'ee65eab5f7468217ab84e3bf0fe96ebee4d47edc';

final class FlashcardImportDraftFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardImportDraft,
          FlashcardImportDraftState,
          FlashcardImportDraftState,
          FlashcardImportDraftState,
          String
        > {
  FlashcardImportDraftFamily._()
    : super(
        retry: null,
        name: r'flashcardImportDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardImportDraftProvider call(String deckId) =>
      FlashcardImportDraftProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardImportDraftProvider';
}

abstract class _$FlashcardImportDraft
    extends $Notifier<FlashcardImportDraftState> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  FlashcardImportDraftState build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<FlashcardImportDraftState, FlashcardImportDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FlashcardImportDraftState, FlashcardImportDraftState>,
              FlashcardImportDraftState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FlashcardImportController)
final flashcardImportControllerProvider = FlashcardImportControllerFamily._();

final class FlashcardImportControllerProvider
    extends $AsyncNotifierProvider<FlashcardImportController, void> {
  FlashcardImportControllerProvider._({
    required FlashcardImportControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardImportControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardImportControllerHash();

  @override
  String toString() {
    return r'flashcardImportControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardImportController create() => FlashcardImportController();

  @override
  bool operator ==(Object other) {
    return other is FlashcardImportControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardImportControllerHash() =>
    r'63f7fa13d41d82067df0bd134055d59dda24e30f';

final class FlashcardImportControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardImportController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  FlashcardImportControllerFamily._()
    : super(
        retry: null,
        name: r'flashcardImportControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardImportControllerProvider call(String deckId) =>
      FlashcardImportControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardImportControllerProvider';
}

abstract class _$FlashcardImportController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  FutureOr<void> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

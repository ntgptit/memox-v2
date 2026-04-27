// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_editor_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FlashcardEditorDraft)
final flashcardEditorDraftProvider = FlashcardEditorDraftFamily._();

final class FlashcardEditorDraftProvider
    extends
        $AsyncNotifierProvider<
          FlashcardEditorDraft,
          FlashcardEditorDraftState
        > {
  FlashcardEditorDraftProvider._({
    required FlashcardEditorDraftFamily super.from,
    required FlashcardEditorArgs super.argument,
  }) : super(
         retry: null,
         name: r'flashcardEditorDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardEditorDraftHash();

  @override
  String toString() {
    return r'flashcardEditorDraftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardEditorDraft create() => FlashcardEditorDraft();

  @override
  bool operator ==(Object other) {
    return other is FlashcardEditorDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardEditorDraftHash() =>
    r'93b1efe08b92e045dd2790383dbf90ad748c50fa';

final class FlashcardEditorDraftFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardEditorDraft,
          AsyncValue<FlashcardEditorDraftState>,
          FlashcardEditorDraftState,
          FutureOr<FlashcardEditorDraftState>,
          FlashcardEditorArgs
        > {
  FlashcardEditorDraftFamily._()
    : super(
        retry: null,
        name: r'flashcardEditorDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardEditorDraftProvider call(FlashcardEditorArgs args) =>
      FlashcardEditorDraftProvider._(argument: args, from: this);

  @override
  String toString() => r'flashcardEditorDraftProvider';
}

abstract class _$FlashcardEditorDraft
    extends $AsyncNotifier<FlashcardEditorDraftState> {
  late final _$args = ref.$arg as FlashcardEditorArgs;
  FlashcardEditorArgs get args => _$args;

  FutureOr<FlashcardEditorDraftState> build(FlashcardEditorArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<FlashcardEditorDraftState>,
              FlashcardEditorDraftState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<FlashcardEditorDraftState>,
                FlashcardEditorDraftState
              >,
              AsyncValue<FlashcardEditorDraftState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FlashcardEditorController)
final flashcardEditorControllerProvider = FlashcardEditorControllerFamily._();

final class FlashcardEditorControllerProvider
    extends $AsyncNotifierProvider<FlashcardEditorController, void> {
  FlashcardEditorControllerProvider._({
    required FlashcardEditorControllerFamily super.from,
    required FlashcardEditorArgs super.argument,
  }) : super(
         retry: null,
         name: r'flashcardEditorControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardEditorControllerHash();

  @override
  String toString() {
    return r'flashcardEditorControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardEditorController create() => FlashcardEditorController();

  @override
  bool operator ==(Object other) {
    return other is FlashcardEditorControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardEditorControllerHash() =>
    r'03e427485581dd53563a95e95993784ec1bd1d6a';

final class FlashcardEditorControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardEditorController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          FlashcardEditorArgs
        > {
  FlashcardEditorControllerFamily._()
    : super(
        retry: null,
        name: r'flashcardEditorControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardEditorControllerProvider call(FlashcardEditorArgs args) =>
      FlashcardEditorControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'flashcardEditorControllerProvider';
}

abstract class _$FlashcardEditorController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as FlashcardEditorArgs;
  FlashcardEditorArgs get args => _$args;

  FutureOr<void> build(FlashcardEditorArgs args);
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_action_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deckActionContext)
final deckActionContextProvider = DeckActionContextFamily._();

final class DeckActionContextProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeckActionContext>,
          DeckActionContext,
          FutureOr<DeckActionContext>
        >
    with
        $FutureModifier<DeckActionContext>,
        $FutureProvider<DeckActionContext> {
  DeckActionContextProvider._({
    required DeckActionContextFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckActionContextProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckActionContextHash();

  @override
  String toString() {
    return r'deckActionContextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DeckActionContext> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeckActionContext> create(Ref ref) {
    final argument = this.argument as String;
    return deckActionContext(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckActionContextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckActionContextHash() => r'950d4117e1b738ec42c7f998cfe0f9988dfae14e';

final class DeckActionContextFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DeckActionContext>, String> {
  DeckActionContextFamily._()
    : super(
        retry: null,
        name: r'deckActionContextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  DeckActionContextProvider call(String deckId) =>
      DeckActionContextProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckActionContextProvider';
}

@ProviderFor(deckMovePicker)
final deckMovePickerProvider = DeckMovePickerFamily._();

final class DeckMovePickerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeckMoveTarget>>,
          List<DeckMoveTarget>,
          FutureOr<List<DeckMoveTarget>>
        >
    with
        $FutureModifier<List<DeckMoveTarget>>,
        $FutureProvider<List<DeckMoveTarget>> {
  DeckMovePickerProvider._({
    required DeckMovePickerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'deckMovePickerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckMovePickerHash();

  @override
  String toString() {
    return r'deckMovePickerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<DeckMoveTarget>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeckMoveTarget>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return deckMovePicker(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckMovePickerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckMovePickerHash() => r'd026ae8ae4c69c53e5edc9ee85aa040f4aadabff';

final class DeckMovePickerFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DeckMoveTarget>>,
          (String, String)
        > {
  DeckMovePickerFamily._()
    : super(
        retry: null,
        name: r'deckMovePickerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeckMovePickerProvider call(String deckId, String excludingFolderId) =>
      DeckMovePickerProvider._(
        argument: (deckId, excludingFolderId),
        from: this,
      );

  @override
  String toString() => r'deckMovePickerProvider';
}

@ProviderFor(DeckActionController)
final deckActionControllerProvider = DeckActionControllerFamily._();

final class DeckActionControllerProvider
    extends $AsyncNotifierProvider<DeckActionController, void> {
  DeckActionControllerProvider._({
    required DeckActionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckActionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckActionControllerHash();

  @override
  String toString() {
    return r'deckActionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeckActionController create() => DeckActionController();

  @override
  bool operator ==(Object other) {
    return other is DeckActionControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckActionControllerHash() =>
    r'0e3dd96018572ed9b48b8ac07a6511f08ed15d73';

final class DeckActionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DeckActionController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  DeckActionControllerFamily._()
    : super(
        retry: null,
        name: r'deckActionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeckActionControllerProvider call(String deckId) =>
      DeckActionControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckActionControllerProvider';
}

abstract class _$DeckActionController extends $AsyncNotifier<void> {
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

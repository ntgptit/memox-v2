// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deckDetailQuery)
final deckDetailQueryProvider = DeckDetailQueryFamily._();

final class DeckDetailQueryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeckDetailState>,
          DeckDetailState,
          FutureOr<DeckDetailState>
        >
    with $FutureModifier<DeckDetailState>, $FutureProvider<DeckDetailState> {
  DeckDetailQueryProvider._({
    required DeckDetailQueryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deckDetailQueryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckDetailQueryHash();

  @override
  String toString() {
    return r'deckDetailQueryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DeckDetailState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeckDetailState> create(Ref ref) {
    final argument = this.argument as String;
    return deckDetailQuery(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckDetailQueryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckDetailQueryHash() => r'82a5eae679729ef4eb44f3b97e3d194a4134ec86';

final class DeckDetailQueryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DeckDetailState>, String> {
  DeckDetailQueryFamily._()
    : super(
        retry: null,
        name: r'deckDetailQueryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  DeckDetailQueryProvider call(String deckId) =>
      DeckDetailQueryProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckDetailQueryProvider';
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
    required String super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DeckMoveTarget>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeckMoveTarget>> create(Ref ref) {
    final argument = this.argument as String;
    return deckMovePicker(ref, argument);
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

String _$deckMovePickerHash() => r'c97c045c6145694a488765571e846ed566111284';

final class DeckMovePickerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DeckMoveTarget>>, String> {
  DeckMovePickerFamily._()
    : super(
        retry: null,
        name: r'deckMovePickerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeckMovePickerProvider call(String deckId) =>
      DeckMovePickerProvider._(argument: deckId, from: this);

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FlashcardToolbarState)
final flashcardToolbarStateProvider = FlashcardToolbarStateFamily._();

final class FlashcardToolbarStateProvider
    extends $NotifierProvider<FlashcardToolbarState, ContentQuery> {
  FlashcardToolbarStateProvider._({
    required FlashcardToolbarStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardToolbarStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardToolbarStateHash();

  @override
  String toString() {
    return r'flashcardToolbarStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardToolbarState create() => FlashcardToolbarState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentQuery>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FlashcardToolbarStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardToolbarStateHash() =>
    r'f18214cacd90d1cc400c78aed2972195fbb8f4a0';

final class FlashcardToolbarStateFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardToolbarState,
          ContentQuery,
          ContentQuery,
          ContentQuery,
          String
        > {
  FlashcardToolbarStateFamily._()
    : super(
        retry: null,
        name: r'flashcardToolbarStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardToolbarStateProvider call(String deckId) =>
      FlashcardToolbarStateProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardToolbarStateProvider';
}

abstract class _$FlashcardToolbarState extends $Notifier<ContentQuery> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  ContentQuery build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ContentQuery, ContentQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContentQuery, ContentQuery>,
              ContentQuery,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(flashcardListQuery)
final flashcardListQueryProvider = FlashcardListQueryFamily._();

final class FlashcardListQueryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FlashcardListState>,
          FlashcardListState,
          FutureOr<FlashcardListState>
        >
    with
        $FutureModifier<FlashcardListState>,
        $FutureProvider<FlashcardListState> {
  FlashcardListQueryProvider._({
    required FlashcardListQueryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardListQueryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardListQueryHash();

  @override
  String toString() {
    return r'flashcardListQueryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FlashcardListState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FlashcardListState> create(Ref ref) {
    final argument = this.argument as String;
    return flashcardListQuery(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FlashcardListQueryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardListQueryHash() =>
    r'2865cf6a437431051000a8e9dd60b8500888dd01';

final class FlashcardListQueryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FlashcardListState>, String> {
  FlashcardListQueryFamily._()
    : super(
        retry: null,
        name: r'flashcardListQueryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FlashcardListQueryProvider call(String deckId) =>
      FlashcardListQueryProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardListQueryProvider';
}

@ProviderFor(FlashcardSelection)
final flashcardSelectionProvider = FlashcardSelectionFamily._();

final class FlashcardSelectionProvider
    extends $NotifierProvider<FlashcardSelection, Set<String>> {
  FlashcardSelectionProvider._({
    required FlashcardSelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardSelectionHash();

  @override
  String toString() {
    return r'flashcardSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardSelection create() => FlashcardSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FlashcardSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardSelectionHash() =>
    r'fb5bc11ebf57021a2ae543a1b36953753a8d3416';

final class FlashcardSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardSelection,
          Set<String>,
          Set<String>,
          Set<String>,
          String
        > {
  FlashcardSelectionFamily._()
    : super(
        retry: null,
        name: r'flashcardSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardSelectionProvider call(String deckId) =>
      FlashcardSelectionProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardSelectionProvider';
}

abstract class _$FlashcardSelection extends $Notifier<Set<String>> {
  late final _$args = ref.$arg as String;
  String get deckId => _$args;

  Set<String> build(String deckId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(flashcardMoveTargets)
final flashcardMoveTargetsProvider = FlashcardMoveTargetsFamily._();

final class FlashcardMoveTargetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeckMoveTarget>>,
          List<DeckMoveTarget>,
          FutureOr<List<DeckMoveTarget>>
        >
    with
        $FutureModifier<List<DeckMoveTarget>>,
        $FutureProvider<List<DeckMoveTarget>> {
  FlashcardMoveTargetsProvider._({
    required FlashcardMoveTargetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardMoveTargetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardMoveTargetsHash();

  @override
  String toString() {
    return r'flashcardMoveTargetsProvider'
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
    return flashcardMoveTargets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FlashcardMoveTargetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardMoveTargetsHash() =>
    r'fd21560eefbb6264320afae2df4cc968d58e96f2';

final class FlashcardMoveTargetsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DeckMoveTarget>>, String> {
  FlashcardMoveTargetsFamily._()
    : super(
        retry: null,
        name: r'flashcardMoveTargetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardMoveTargetsProvider call(String deckId) =>
      FlashcardMoveTargetsProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardMoveTargetsProvider';
}

@ProviderFor(FlashcardActionController)
final flashcardActionControllerProvider = FlashcardActionControllerFamily._();

final class FlashcardActionControllerProvider
    extends $AsyncNotifierProvider<FlashcardActionController, void> {
  FlashcardActionControllerProvider._({
    required FlashcardActionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flashcardActionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardActionControllerHash();

  @override
  String toString() {
    return r'flashcardActionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardActionController create() => FlashcardActionController();

  @override
  bool operator ==(Object other) {
    return other is FlashcardActionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardActionControllerHash() =>
    r'995ab8f3a11b18bd6294842c1d91b41de9f255b9';

final class FlashcardActionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardActionController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  FlashcardActionControllerFamily._()
    : super(
        retry: null,
        name: r'flashcardActionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FlashcardActionControllerProvider call(String deckId) =>
      FlashcardActionControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'flashcardActionControllerProvider';
}

abstract class _$FlashcardActionController extends $AsyncNotifier<void> {
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

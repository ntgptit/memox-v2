// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FolderChildrenToolbarState)
final folderChildrenToolbarStateProvider = FolderChildrenToolbarStateFamily._();

final class FolderChildrenToolbarStateProvider
    extends $NotifierProvider<FolderChildrenToolbarState, ContentQuery> {
  FolderChildrenToolbarStateProvider._({
    required FolderChildrenToolbarStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'folderChildrenToolbarStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderChildrenToolbarStateHash();

  @override
  String toString() {
    return r'folderChildrenToolbarStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FolderChildrenToolbarState create() => FolderChildrenToolbarState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentQuery>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FolderChildrenToolbarStateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderChildrenToolbarStateHash() =>
    r'7f69cb5b55030f26e32462dedd11759aaeb1849d';

final class FolderChildrenToolbarStateFamily extends $Family
    with
        $ClassFamilyOverride<
          FolderChildrenToolbarState,
          ContentQuery,
          ContentQuery,
          ContentQuery,
          String
        > {
  FolderChildrenToolbarStateFamily._()
    : super(
        retry: null,
        name: r'folderChildrenToolbarStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FolderChildrenToolbarStateProvider call(String folderId) =>
      FolderChildrenToolbarStateProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderChildrenToolbarStateProvider';
}

abstract class _$FolderChildrenToolbarState extends $Notifier<ContentQuery> {
  late final _$args = ref.$arg as String;
  String get folderId => _$args;

  ContentQuery build(String folderId);
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

@ProviderFor(folderDetailQuery)
final folderDetailQueryProvider = FolderDetailQueryFamily._();

final class FolderDetailQueryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FolderDetailState>,
          FolderDetailState,
          FutureOr<FolderDetailState>
        >
    with
        $FutureModifier<FolderDetailState>,
        $FutureProvider<FolderDetailState> {
  FolderDetailQueryProvider._({
    required FolderDetailQueryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'folderDetailQueryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderDetailQueryHash();

  @override
  String toString() {
    return r'folderDetailQueryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FolderDetailState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FolderDetailState> create(Ref ref) {
    final argument = this.argument as String;
    return folderDetailQuery(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderDetailQueryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderDetailQueryHash() => r'6833fb68a7b02ff9a7ccc553bdbad769d7384187';

final class FolderDetailQueryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FolderDetailState>, String> {
  FolderDetailQueryFamily._()
    : super(
        retry: null,
        name: r'folderDetailQueryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FolderDetailQueryProvider call(String folderId) =>
      FolderDetailQueryProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderDetailQueryProvider';
}

@ProviderFor(folderMovePicker)
final folderMovePickerProvider = FolderMovePickerFamily._();

final class FolderMovePickerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FolderMoveTarget>>,
          List<FolderMoveTarget>,
          FutureOr<List<FolderMoveTarget>>
        >
    with
        $FutureModifier<List<FolderMoveTarget>>,
        $FutureProvider<List<FolderMoveTarget>> {
  FolderMovePickerProvider._({
    required FolderMovePickerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'folderMovePickerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderMovePickerHash();

  @override
  String toString() {
    return r'folderMovePickerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FolderMoveTarget>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FolderMoveTarget>> create(Ref ref) {
    final argument = this.argument as String;
    return folderMovePicker(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderMovePickerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderMovePickerHash() => r'c4e92b142cc29f1e9a9d0e8181700e5d57b90dc1';

final class FolderMovePickerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FolderMoveTarget>>, String> {
  FolderMovePickerFamily._()
    : super(
        retry: null,
        name: r'folderMovePickerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FolderMovePickerProvider call(String folderId) =>
      FolderMovePickerProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderMovePickerProvider';
}

@ProviderFor(FolderActionController)
final folderActionControllerProvider = FolderActionControllerFamily._();

final class FolderActionControllerProvider
    extends $AsyncNotifierProvider<FolderActionController, void> {
  FolderActionControllerProvider._({
    required FolderActionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'folderActionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderActionControllerHash();

  @override
  String toString() {
    return r'folderActionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FolderActionController create() => FolderActionController();

  @override
  bool operator ==(Object other) {
    return other is FolderActionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderActionControllerHash() =>
    r'8933e96f4172af9e9b0e47ba390bc7a944777e07';

final class FolderActionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FolderActionController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  FolderActionControllerFamily._()
    : super(
        retry: null,
        name: r'folderActionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FolderActionControllerProvider call(String folderId) =>
      FolderActionControllerProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderActionControllerProvider';
}

abstract class _$FolderActionController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get folderId => _$args;

  FutureOr<void> build(String folderId);
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

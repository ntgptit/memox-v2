// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_overview_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LibraryToolbarState)
final libraryToolbarStateProvider = LibraryToolbarStateProvider._();

final class LibraryToolbarStateProvider
    extends $NotifierProvider<LibraryToolbarState, ContentQuery> {
  LibraryToolbarStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryToolbarStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryToolbarStateHash();

  @$internal
  @override
  LibraryToolbarState create() => LibraryToolbarState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentQuery>(value),
    );
  }
}

String _$libraryToolbarStateHash() =>
    r'9357ac62d9fa7bf5e948a882d69288f8513f9f3d';

abstract class _$LibraryToolbarState extends $Notifier<ContentQuery> {
  ContentQuery build();
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
    element.handleCreate(ref, build);
  }
}

@ProviderFor(libraryOverviewQuery)
final libraryOverviewQueryProvider = LibraryOverviewQueryProvider._();

final class LibraryOverviewQueryProvider
    extends
        $FunctionalProvider<
          AsyncValue<LibraryOverviewState>,
          LibraryOverviewState,
          FutureOr<LibraryOverviewState>
        >
    with
        $FutureModifier<LibraryOverviewState>,
        $FutureProvider<LibraryOverviewState> {
  LibraryOverviewQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryOverviewQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryOverviewQueryHash();

  @$internal
  @override
  $FutureProviderElement<LibraryOverviewState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LibraryOverviewState> create(Ref ref) {
    return libraryOverviewQuery(ref);
  }
}

String _$libraryOverviewQueryHash() =>
    r'd1bf435a43f683157fbf354cf9b425600f3341f1';

@ProviderFor(LibraryOverviewActionController)
final libraryOverviewActionControllerProvider =
    LibraryOverviewActionControllerProvider._();

final class LibraryOverviewActionControllerProvider
    extends $AsyncNotifierProvider<LibraryOverviewActionController, void> {
  LibraryOverviewActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryOverviewActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryOverviewActionControllerHash();

  @$internal
  @override
  LibraryOverviewActionController create() => LibraryOverviewActionController();
}

String _$libraryOverviewActionControllerHash() =>
    r'b7e4210a62957a5caf9f9ad5a373e8b93b6b8f5c';

abstract class _$LibraryOverviewActionController extends $AsyncNotifier<void> {
  FutureOr<void> build();
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
    element.handleCreate(ref, build);
  }
}

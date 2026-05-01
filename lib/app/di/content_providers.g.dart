// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clock)
final clockProvider = ClockProvider._();

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'56e0512567a7581285cae49efec2340e7eee25d0';

@ProviderFor(idGenerator)
final idGeneratorProvider = IdGeneratorProvider._();

final class IdGeneratorProvider
    extends $FunctionalProvider<IdGenerator, IdGenerator, IdGenerator>
    with $Provider<IdGenerator> {
  IdGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idGeneratorHash();

  @$internal
  @override
  $ProviderElement<IdGenerator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdGenerator create(Ref ref) {
    return idGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdGenerator>(value),
    );
  }
}

String _$idGeneratorHash() => r'fbcc656c17f64ed37827151fffae03ed1223b583';

@ProviderFor(localTransactionRunner)
final localTransactionRunnerProvider = LocalTransactionRunnerProvider._();

final class LocalTransactionRunnerProvider
    extends
        $FunctionalProvider<
          LocalTransactionRunner,
          LocalTransactionRunner,
          LocalTransactionRunner
        >
    with $Provider<LocalTransactionRunner> {
  LocalTransactionRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localTransactionRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localTransactionRunnerHash();

  @$internal
  @override
  $ProviderElement<LocalTransactionRunner> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalTransactionRunner create(Ref ref) {
    return localTransactionRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalTransactionRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalTransactionRunner>(value),
    );
  }
}

String _$localTransactionRunnerHash() =>
    r'5d1195cc06ff3beaceaa77f004559bc3743d0e56';

@ProviderFor(folderDao)
final folderDaoProvider = FolderDaoProvider._();

final class FolderDaoProvider
    extends $FunctionalProvider<FolderDao, FolderDao, FolderDao>
    with $Provider<FolderDao> {
  FolderDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderDaoHash();

  @$internal
  @override
  $ProviderElement<FolderDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FolderDao create(Ref ref) {
    return folderDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderDao>(value),
    );
  }
}

String _$folderDaoHash() => r'476a2200281546ea4dab18f1c7e2e3817fc79fdc';

@ProviderFor(deckDao)
final deckDaoProvider = DeckDaoProvider._();

final class DeckDaoProvider
    extends $FunctionalProvider<DeckDao, DeckDao, DeckDao>
    with $Provider<DeckDao> {
  DeckDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckDaoHash();

  @$internal
  @override
  $ProviderElement<DeckDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeckDao create(Ref ref) {
    return deckDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeckDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeckDao>(value),
    );
  }
}

String _$deckDaoHash() => r'ef9bead35efbf0c61d04376952046335b6b628a4';

@ProviderFor(flashcardDao)
final flashcardDaoProvider = FlashcardDaoProvider._();

final class FlashcardDaoProvider
    extends $FunctionalProvider<FlashcardDao, FlashcardDao, FlashcardDao>
    with $Provider<FlashcardDao> {
  FlashcardDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashcardDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashcardDaoHash();

  @$internal
  @override
  $ProviderElement<FlashcardDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlashcardDao create(Ref ref) {
    return flashcardDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlashcardDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlashcardDao>(value),
    );
  }
}

String _$flashcardDaoHash() => r'4e7b4816d4db118b18834d400752db222675b068';

@ProviderFor(folderStructureService)
final folderStructureServiceProvider = FolderStructureServiceProvider._();

final class FolderStructureServiceProvider
    extends
        $FunctionalProvider<
          FolderStructureService,
          FolderStructureService,
          FolderStructureService
        >
    with $Provider<FolderStructureService> {
  FolderStructureServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderStructureServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderStructureServiceHash();

  @$internal
  @override
  $ProviderElement<FolderStructureService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FolderStructureService create(Ref ref) {
    return folderStructureService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderStructureService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderStructureService>(value),
    );
  }
}

String _$folderStructureServiceHash() =>
    r'de8a873347af2444bb312dfffd006349a96217f4';

@ProviderFor(folderRepository)
final folderRepositoryProvider = FolderRepositoryProvider._();

final class FolderRepositoryProvider
    extends
        $FunctionalProvider<
          FolderRepository,
          FolderRepository,
          FolderRepository
        >
    with $Provider<FolderRepository> {
  FolderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderRepositoryHash();

  @$internal
  @override
  $ProviderElement<FolderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FolderRepository create(Ref ref) {
    return folderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderRepository>(value),
    );
  }
}

String _$folderRepositoryHash() => r'94d8f70256ce0a7928cf9b84f9a19716f10fe348';

@ProviderFor(deckRepository)
final deckRepositoryProvider = DeckRepositoryProvider._();

final class DeckRepositoryProvider
    extends $FunctionalProvider<DeckRepository, DeckRepository, DeckRepository>
    with $Provider<DeckRepository> {
  DeckRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeckRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeckRepository create(Ref ref) {
    return deckRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeckRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeckRepository>(value),
    );
  }
}

String _$deckRepositoryHash() => r'882b469d71d1bb51d99d7cb772f5a642c7aa9703';

@ProviderFor(flashcardRepository)
final flashcardRepositoryProvider = FlashcardRepositoryProvider._();

final class FlashcardRepositoryProvider
    extends
        $FunctionalProvider<
          FlashcardRepository,
          FlashcardRepository,
          FlashcardRepository
        >
    with $Provider<FlashcardRepository> {
  FlashcardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashcardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashcardRepositoryHash();

  @$internal
  @override
  $ProviderElement<FlashcardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlashcardRepository create(Ref ref) {
    return flashcardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlashcardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlashcardRepository>(value),
    );
  }
}

String _$flashcardRepositoryHash() =>
    r'7eab0304493b8bc654c987aac1f1855a5b36f278';

@ProviderFor(contentDataRevision)
final contentDataRevisionProvider = ContentDataRevisionProvider._();

final class ContentDataRevisionProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  ContentDataRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentDataRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentDataRevisionHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return contentDataRevision(ref);
  }
}

String _$contentDataRevisionHash() =>
    r'a3021994009ec7b42cd2733ba542c441e20bdcaa';

@ProviderFor(watchLibraryOverviewUseCase)
final watchLibraryOverviewUseCaseProvider =
    WatchLibraryOverviewUseCaseProvider._();

final class WatchLibraryOverviewUseCaseProvider
    extends
        $FunctionalProvider<
          WatchLibraryOverviewUseCase,
          WatchLibraryOverviewUseCase,
          WatchLibraryOverviewUseCase
        >
    with $Provider<WatchLibraryOverviewUseCase> {
  WatchLibraryOverviewUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchLibraryOverviewUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchLibraryOverviewUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchLibraryOverviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchLibraryOverviewUseCase create(Ref ref) {
    return watchLibraryOverviewUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchLibraryOverviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchLibraryOverviewUseCase>(value),
    );
  }
}

String _$watchLibraryOverviewUseCaseHash() =>
    r'9c80be985b2e614a0a1486443c4dd58cd283ac5f';

@ProviderFor(watchFolderDetailUseCase)
final watchFolderDetailUseCaseProvider = WatchFolderDetailUseCaseProvider._();

final class WatchFolderDetailUseCaseProvider
    extends
        $FunctionalProvider<
          WatchFolderDetailUseCase,
          WatchFolderDetailUseCase,
          WatchFolderDetailUseCase
        >
    with $Provider<WatchFolderDetailUseCase> {
  WatchFolderDetailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchFolderDetailUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchFolderDetailUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchFolderDetailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchFolderDetailUseCase create(Ref ref) {
    return watchFolderDetailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchFolderDetailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchFolderDetailUseCase>(value),
    );
  }
}

String _$watchFolderDetailUseCaseHash() =>
    r'3dcac9b845b0e88a89d7fb35a095a990c174c938';

@ProviderFor(watchFlashcardListUseCase)
final watchFlashcardListUseCaseProvider = WatchFlashcardListUseCaseProvider._();

final class WatchFlashcardListUseCaseProvider
    extends
        $FunctionalProvider<
          WatchFlashcardListUseCase,
          WatchFlashcardListUseCase,
          WatchFlashcardListUseCase
        >
    with $Provider<WatchFlashcardListUseCase> {
  WatchFlashcardListUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchFlashcardListUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchFlashcardListUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchFlashcardListUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchFlashcardListUseCase create(Ref ref) {
    return watchFlashcardListUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchFlashcardListUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchFlashcardListUseCase>(value),
    );
  }
}

String _$watchFlashcardListUseCaseHash() =>
    r'd893afa8fb73951207a8e24fa680dc3d13877fcb';

@ProviderFor(getDeckActionContextUseCase)
final getDeckActionContextUseCaseProvider =
    GetDeckActionContextUseCaseProvider._();

final class GetDeckActionContextUseCaseProvider
    extends
        $FunctionalProvider<
          GetDeckActionContextUseCase,
          GetDeckActionContextUseCase,
          GetDeckActionContextUseCase
        >
    with $Provider<GetDeckActionContextUseCase> {
  GetDeckActionContextUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDeckActionContextUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDeckActionContextUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDeckActionContextUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDeckActionContextUseCase create(Ref ref) {
    return getDeckActionContextUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDeckActionContextUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDeckActionContextUseCase>(value),
    );
  }
}

String _$getDeckActionContextUseCaseHash() =>
    r'd0a448e75592f5229460be6911bf434c88ae1a5e';

@ProviderFor(getDeckHighlightsUseCase)
final getDeckHighlightsUseCaseProvider = GetDeckHighlightsUseCaseProvider._();

final class GetDeckHighlightsUseCaseProvider
    extends
        $FunctionalProvider<
          GetDeckHighlightsUseCase,
          GetDeckHighlightsUseCase,
          GetDeckHighlightsUseCase
        >
    with $Provider<GetDeckHighlightsUseCase> {
  GetDeckHighlightsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDeckHighlightsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDeckHighlightsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDeckHighlightsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDeckHighlightsUseCase create(Ref ref) {
    return getDeckHighlightsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDeckHighlightsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDeckHighlightsUseCase>(value),
    );
  }
}

String _$getDeckHighlightsUseCaseHash() =>
    r'd6300cbf5fef4d4a1dabf539f75942a57578ac86';

@ProviderFor(createFolderUseCase)
final createFolderUseCaseProvider = CreateFolderUseCaseProvider._();

final class CreateFolderUseCaseProvider
    extends
        $FunctionalProvider<
          CreateFolderUseCase,
          CreateFolderUseCase,
          CreateFolderUseCase
        >
    with $Provider<CreateFolderUseCase> {
  CreateFolderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createFolderUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createFolderUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateFolderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateFolderUseCase create(Ref ref) {
    return createFolderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateFolderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateFolderUseCase>(value),
    );
  }
}

String _$createFolderUseCaseHash() =>
    r'5d2796a61747d82c75566ab12d9959e38308f578';

@ProviderFor(getFolderMoveTargetsUseCase)
final getFolderMoveTargetsUseCaseProvider =
    GetFolderMoveTargetsUseCaseProvider._();

final class GetFolderMoveTargetsUseCaseProvider
    extends
        $FunctionalProvider<
          GetFolderMoveTargetsUseCase,
          GetFolderMoveTargetsUseCase,
          GetFolderMoveTargetsUseCase
        >
    with $Provider<GetFolderMoveTargetsUseCase> {
  GetFolderMoveTargetsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFolderMoveTargetsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getFolderMoveTargetsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFolderMoveTargetsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetFolderMoveTargetsUseCase create(Ref ref) {
    return getFolderMoveTargetsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFolderMoveTargetsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFolderMoveTargetsUseCase>(value),
    );
  }
}

String _$getFolderMoveTargetsUseCaseHash() =>
    r'd35483fea46e4249ae3ddf7a0d2d10f2aca4ab40';

@ProviderFor(updateFolderUseCase)
final updateFolderUseCaseProvider = UpdateFolderUseCaseProvider._();

final class UpdateFolderUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateFolderUseCase,
          UpdateFolderUseCase,
          UpdateFolderUseCase
        >
    with $Provider<UpdateFolderUseCase> {
  UpdateFolderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateFolderUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateFolderUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateFolderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateFolderUseCase create(Ref ref) {
    return updateFolderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateFolderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateFolderUseCase>(value),
    );
  }
}

String _$updateFolderUseCaseHash() =>
    r'c06b4789a34dc8b84ef98aa9ad41c810ecfbf548';

@ProviderFor(deleteFolderUseCase)
final deleteFolderUseCaseProvider = DeleteFolderUseCaseProvider._();

final class DeleteFolderUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteFolderUseCase,
          DeleteFolderUseCase,
          DeleteFolderUseCase
        >
    with $Provider<DeleteFolderUseCase> {
  DeleteFolderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteFolderUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteFolderUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteFolderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteFolderUseCase create(Ref ref) {
    return deleteFolderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteFolderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteFolderUseCase>(value),
    );
  }
}

String _$deleteFolderUseCaseHash() =>
    r'9f8354a813730c1f5be9ee04e38b9f157cf84ab1';

@ProviderFor(moveFolderUseCase)
final moveFolderUseCaseProvider = MoveFolderUseCaseProvider._();

final class MoveFolderUseCaseProvider
    extends
        $FunctionalProvider<
          MoveFolderUseCase,
          MoveFolderUseCase,
          MoveFolderUseCase
        >
    with $Provider<MoveFolderUseCase> {
  MoveFolderUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveFolderUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveFolderUseCaseHash();

  @$internal
  @override
  $ProviderElement<MoveFolderUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MoveFolderUseCase create(Ref ref) {
    return moveFolderUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveFolderUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveFolderUseCase>(value),
    );
  }
}

String _$moveFolderUseCaseHash() => r'8a8a81abeaec61b08cb01dd0c8576cdce4305cb4';

@ProviderFor(reorderFoldersUseCase)
final reorderFoldersUseCaseProvider = ReorderFoldersUseCaseProvider._();

final class ReorderFoldersUseCaseProvider
    extends
        $FunctionalProvider<
          ReorderFoldersUseCase,
          ReorderFoldersUseCase,
          ReorderFoldersUseCase
        >
    with $Provider<ReorderFoldersUseCase> {
  ReorderFoldersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reorderFoldersUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reorderFoldersUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReorderFoldersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReorderFoldersUseCase create(Ref ref) {
    return reorderFoldersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReorderFoldersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReorderFoldersUseCase>(value),
    );
  }
}

String _$reorderFoldersUseCaseHash() =>
    r'19efa95a3d5063a4fd48738008a6a665ff14f4d8';

@ProviderFor(createDeckUseCase)
final createDeckUseCaseProvider = CreateDeckUseCaseProvider._();

final class CreateDeckUseCaseProvider
    extends
        $FunctionalProvider<
          CreateDeckUseCase,
          CreateDeckUseCase,
          CreateDeckUseCase
        >
    with $Provider<CreateDeckUseCase> {
  CreateDeckUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDeckUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDeckUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateDeckUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateDeckUseCase create(Ref ref) {
    return createDeckUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateDeckUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateDeckUseCase>(value),
    );
  }
}

String _$createDeckUseCaseHash() => r'1e8c8a4c7e4944b25ae2af3e79fe135e6ad757c1';

@ProviderFor(getDeckMoveTargetsUseCase)
final getDeckMoveTargetsUseCaseProvider = GetDeckMoveTargetsUseCaseProvider._();

final class GetDeckMoveTargetsUseCaseProvider
    extends
        $FunctionalProvider<
          GetDeckMoveTargetsUseCase,
          GetDeckMoveTargetsUseCase,
          GetDeckMoveTargetsUseCase
        >
    with $Provider<GetDeckMoveTargetsUseCase> {
  GetDeckMoveTargetsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDeckMoveTargetsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDeckMoveTargetsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDeckMoveTargetsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDeckMoveTargetsUseCase create(Ref ref) {
    return getDeckMoveTargetsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDeckMoveTargetsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDeckMoveTargetsUseCase>(value),
    );
  }
}

String _$getDeckMoveTargetsUseCaseHash() =>
    r'8de43400feb9f87815a73222f68802b006fd6d90';

@ProviderFor(updateDeckUseCase)
final updateDeckUseCaseProvider = UpdateDeckUseCaseProvider._();

final class UpdateDeckUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateDeckUseCase,
          UpdateDeckUseCase,
          UpdateDeckUseCase
        >
    with $Provider<UpdateDeckUseCase> {
  UpdateDeckUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDeckUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDeckUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateDeckUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateDeckUseCase create(Ref ref) {
    return updateDeckUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateDeckUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateDeckUseCase>(value),
    );
  }
}

String _$updateDeckUseCaseHash() => r'ebd89fd664849b7e97f2475602582e43d68a474c';

@ProviderFor(deleteDeckUseCase)
final deleteDeckUseCaseProvider = DeleteDeckUseCaseProvider._();

final class DeleteDeckUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteDeckUseCase,
          DeleteDeckUseCase,
          DeleteDeckUseCase
        >
    with $Provider<DeleteDeckUseCase> {
  DeleteDeckUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteDeckUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteDeckUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteDeckUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteDeckUseCase create(Ref ref) {
    return deleteDeckUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteDeckUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteDeckUseCase>(value),
    );
  }
}

String _$deleteDeckUseCaseHash() => r'1cf6c92afd8073d0ffbbc65a5d879f2bf0ec9cc7';

@ProviderFor(moveDeckUseCase)
final moveDeckUseCaseProvider = MoveDeckUseCaseProvider._();

final class MoveDeckUseCaseProvider
    extends
        $FunctionalProvider<MoveDeckUseCase, MoveDeckUseCase, MoveDeckUseCase>
    with $Provider<MoveDeckUseCase> {
  MoveDeckUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveDeckUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveDeckUseCaseHash();

  @$internal
  @override
  $ProviderElement<MoveDeckUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MoveDeckUseCase create(Ref ref) {
    return moveDeckUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveDeckUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveDeckUseCase>(value),
    );
  }
}

String _$moveDeckUseCaseHash() => r'bb7e80b91fc58aaaa56ee2ef10f0953c3f54177e';

@ProviderFor(reorderDecksUseCase)
final reorderDecksUseCaseProvider = ReorderDecksUseCaseProvider._();

final class ReorderDecksUseCaseProvider
    extends
        $FunctionalProvider<
          ReorderDecksUseCase,
          ReorderDecksUseCase,
          ReorderDecksUseCase
        >
    with $Provider<ReorderDecksUseCase> {
  ReorderDecksUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reorderDecksUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reorderDecksUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReorderDecksUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReorderDecksUseCase create(Ref ref) {
    return reorderDecksUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReorderDecksUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReorderDecksUseCase>(value),
    );
  }
}

String _$reorderDecksUseCaseHash() =>
    r'dc2aa9ee32e7860bda1759eeba70510c5e0656c6';

@ProviderFor(duplicateDeckUseCase)
final duplicateDeckUseCaseProvider = DuplicateDeckUseCaseProvider._();

final class DuplicateDeckUseCaseProvider
    extends
        $FunctionalProvider<
          DuplicateDeckUseCase,
          DuplicateDeckUseCase,
          DuplicateDeckUseCase
        >
    with $Provider<DuplicateDeckUseCase> {
  DuplicateDeckUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'duplicateDeckUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$duplicateDeckUseCaseHash();

  @$internal
  @override
  $ProviderElement<DuplicateDeckUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DuplicateDeckUseCase create(Ref ref) {
    return duplicateDeckUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DuplicateDeckUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DuplicateDeckUseCase>(value),
    );
  }
}

String _$duplicateDeckUseCaseHash() =>
    r'3fd7bc44159743d2fa89a1151007decad76c742d';

@ProviderFor(exportDeckUseCase)
final exportDeckUseCaseProvider = ExportDeckUseCaseProvider._();

final class ExportDeckUseCaseProvider
    extends
        $FunctionalProvider<
          ExportDeckUseCase,
          ExportDeckUseCase,
          ExportDeckUseCase
        >
    with $Provider<ExportDeckUseCase> {
  ExportDeckUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportDeckUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportDeckUseCaseHash();

  @$internal
  @override
  $ProviderElement<ExportDeckUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportDeckUseCase create(Ref ref) {
    return exportDeckUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportDeckUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportDeckUseCase>(value),
    );
  }
}

String _$exportDeckUseCaseHash() => r'18b6eeeeec2fa8c43f741fe984e99a031b87eada';

@ProviderFor(createFlashcardUseCase)
final createFlashcardUseCaseProvider = CreateFlashcardUseCaseProvider._();

final class CreateFlashcardUseCaseProvider
    extends
        $FunctionalProvider<
          CreateFlashcardUseCase,
          CreateFlashcardUseCase,
          CreateFlashcardUseCase
        >
    with $Provider<CreateFlashcardUseCase> {
  CreateFlashcardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createFlashcardUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createFlashcardUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateFlashcardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateFlashcardUseCase create(Ref ref) {
    return createFlashcardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateFlashcardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateFlashcardUseCase>(value),
    );
  }
}

String _$createFlashcardUseCaseHash() =>
    r'c55275d75ecd5436c71157bdcd37949893a30c1b';

@ProviderFor(getFlashcardUseCase)
final getFlashcardUseCaseProvider = GetFlashcardUseCaseProvider._();

final class GetFlashcardUseCaseProvider
    extends
        $FunctionalProvider<
          GetFlashcardUseCase,
          GetFlashcardUseCase,
          GetFlashcardUseCase
        >
    with $Provider<GetFlashcardUseCase> {
  GetFlashcardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFlashcardUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getFlashcardUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFlashcardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetFlashcardUseCase create(Ref ref) {
    return getFlashcardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFlashcardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFlashcardUseCase>(value),
    );
  }
}

String _$getFlashcardUseCaseHash() =>
    r'9dacdb71e5aadbd3a88e56101a4d348a70775009';

@ProviderFor(getFlashcardMoveTargetsUseCase)
final getFlashcardMoveTargetsUseCaseProvider =
    GetFlashcardMoveTargetsUseCaseProvider._();

final class GetFlashcardMoveTargetsUseCaseProvider
    extends
        $FunctionalProvider<
          GetFlashcardMoveTargetsUseCase,
          GetFlashcardMoveTargetsUseCase,
          GetFlashcardMoveTargetsUseCase
        >
    with $Provider<GetFlashcardMoveTargetsUseCase> {
  GetFlashcardMoveTargetsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFlashcardMoveTargetsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getFlashcardMoveTargetsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFlashcardMoveTargetsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetFlashcardMoveTargetsUseCase create(Ref ref) {
    return getFlashcardMoveTargetsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFlashcardMoveTargetsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFlashcardMoveTargetsUseCase>(
        value,
      ),
    );
  }
}

String _$getFlashcardMoveTargetsUseCaseHash() =>
    r'fead5e42474d731b7fa07c5be19ce574f5bcad37';

@ProviderFor(updateFlashcardUseCase)
final updateFlashcardUseCaseProvider = UpdateFlashcardUseCaseProvider._();

final class UpdateFlashcardUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateFlashcardUseCase,
          UpdateFlashcardUseCase,
          UpdateFlashcardUseCase
        >
    with $Provider<UpdateFlashcardUseCase> {
  UpdateFlashcardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateFlashcardUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateFlashcardUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateFlashcardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateFlashcardUseCase create(Ref ref) {
    return updateFlashcardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateFlashcardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateFlashcardUseCase>(value),
    );
  }
}

String _$updateFlashcardUseCaseHash() =>
    r'737cb542a34eb5ada79ef01d4aa05b7ce16f4d45';

@ProviderFor(deleteFlashcardsUseCase)
final deleteFlashcardsUseCaseProvider = DeleteFlashcardsUseCaseProvider._();

final class DeleteFlashcardsUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteFlashcardsUseCase,
          DeleteFlashcardsUseCase,
          DeleteFlashcardsUseCase
        >
    with $Provider<DeleteFlashcardsUseCase> {
  DeleteFlashcardsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteFlashcardsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteFlashcardsUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteFlashcardsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteFlashcardsUseCase create(Ref ref) {
    return deleteFlashcardsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteFlashcardsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteFlashcardsUseCase>(value),
    );
  }
}

String _$deleteFlashcardsUseCaseHash() =>
    r'736efca2cb82f9ec078fd3e3c70b9c603ddd1dfb';

@ProviderFor(moveFlashcardsUseCase)
final moveFlashcardsUseCaseProvider = MoveFlashcardsUseCaseProvider._();

final class MoveFlashcardsUseCaseProvider
    extends
        $FunctionalProvider<
          MoveFlashcardsUseCase,
          MoveFlashcardsUseCase,
          MoveFlashcardsUseCase
        >
    with $Provider<MoveFlashcardsUseCase> {
  MoveFlashcardsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveFlashcardsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveFlashcardsUseCaseHash();

  @$internal
  @override
  $ProviderElement<MoveFlashcardsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MoveFlashcardsUseCase create(Ref ref) {
    return moveFlashcardsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveFlashcardsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveFlashcardsUseCase>(value),
    );
  }
}

String _$moveFlashcardsUseCaseHash() =>
    r'24afb79eda97bc5edcc57d078a8370575b16d793';

@ProviderFor(reorderFlashcardsUseCase)
final reorderFlashcardsUseCaseProvider = ReorderFlashcardsUseCaseProvider._();

final class ReorderFlashcardsUseCaseProvider
    extends
        $FunctionalProvider<
          ReorderFlashcardsUseCase,
          ReorderFlashcardsUseCase,
          ReorderFlashcardsUseCase
        >
    with $Provider<ReorderFlashcardsUseCase> {
  ReorderFlashcardsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reorderFlashcardsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reorderFlashcardsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReorderFlashcardsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReorderFlashcardsUseCase create(Ref ref) {
    return reorderFlashcardsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReorderFlashcardsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReorderFlashcardsUseCase>(value),
    );
  }
}

String _$reorderFlashcardsUseCaseHash() =>
    r'70bb0a1d86716816460764468ecc247831755e0e';

@ProviderFor(prepareFlashcardImportUseCase)
final prepareFlashcardImportUseCaseProvider =
    PrepareFlashcardImportUseCaseProvider._();

final class PrepareFlashcardImportUseCaseProvider
    extends
        $FunctionalProvider<
          PrepareFlashcardImportUseCase,
          PrepareFlashcardImportUseCase,
          PrepareFlashcardImportUseCase
        >
    with $Provider<PrepareFlashcardImportUseCase> {
  PrepareFlashcardImportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prepareFlashcardImportUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prepareFlashcardImportUseCaseHash();

  @$internal
  @override
  $ProviderElement<PrepareFlashcardImportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrepareFlashcardImportUseCase create(Ref ref) {
    return prepareFlashcardImportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrepareFlashcardImportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrepareFlashcardImportUseCase>(
        value,
      ),
    );
  }
}

String _$prepareFlashcardImportUseCaseHash() =>
    r'7681f31e58062afe22726a9296b3308f5c5a2f5f';

@ProviderFor(commitFlashcardImportUseCase)
final commitFlashcardImportUseCaseProvider =
    CommitFlashcardImportUseCaseProvider._();

final class CommitFlashcardImportUseCaseProvider
    extends
        $FunctionalProvider<
          CommitFlashcardImportUseCase,
          CommitFlashcardImportUseCase,
          CommitFlashcardImportUseCase
        >
    with $Provider<CommitFlashcardImportUseCase> {
  CommitFlashcardImportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commitFlashcardImportUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commitFlashcardImportUseCaseHash();

  @$internal
  @override
  $ProviderElement<CommitFlashcardImportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommitFlashcardImportUseCase create(Ref ref) {
    return commitFlashcardImportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommitFlashcardImportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommitFlashcardImportUseCase>(value),
    );
  }
}

String _$commitFlashcardImportUseCaseHash() =>
    r'6909a69fcd5176b589da6ef2689d165c139c8d6a';

@ProviderFor(exportFlashcardsUseCase)
final exportFlashcardsUseCaseProvider = ExportFlashcardsUseCaseProvider._();

final class ExportFlashcardsUseCaseProvider
    extends
        $FunctionalProvider<
          ExportFlashcardsUseCase,
          ExportFlashcardsUseCase,
          ExportFlashcardsUseCase
        >
    with $Provider<ExportFlashcardsUseCase> {
  ExportFlashcardsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportFlashcardsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportFlashcardsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ExportFlashcardsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportFlashcardsUseCase create(Ref ref) {
    return exportFlashcardsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportFlashcardsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportFlashcardsUseCase>(value),
    );
  }
}

String _$exportFlashcardsUseCaseHash() =>
    r'ff2374b1fc68a0752e02cf26f9e8c93add100dd3';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/deck_repository_impl.dart';
import '../../../domain/repositories/deck_repository.dart';
import '../../../domain/usecases/content_query_usecases.dart';
import '../../../domain/usecases/deck_usecases.dart';
import 'content_core_providers.dart';
import 'content_data_providers.dart';

part 'deck_providers.g.dart';

@riverpod
DeckRepository deckRepository(Ref ref) => DeckRepositoryImpl(
  deckDao: ref.watch(deckDaoProvider),
  flashcardDao: ref.watch(flashcardDaoProvider),
  folderDao: ref.watch(folderDaoProvider),
  transactionRunner: ref.watch(localTransactionRunnerProvider),
  structureService: ref.watch(folderStructureServiceProvider),
  clock: ref.watch(clockProvider),
  idGenerator: ref.watch(idGeneratorProvider),
);

@riverpod
GetDeckActionContextUseCase getDeckActionContextUseCase(Ref ref) =>
    GetDeckActionContextUseCase(ref.watch(deckRepositoryProvider));

@riverpod
GetDeckHighlightsUseCase getDeckHighlightsUseCase(Ref ref) =>
    GetDeckHighlightsUseCase(ref.watch(deckRepositoryProvider));

@riverpod
CreateDeckUseCase createDeckUseCase(Ref ref) =>
    CreateDeckUseCase(ref.watch(deckRepositoryProvider));

@riverpod
GetDeckMoveTargetsUseCase getDeckMoveTargetsUseCase(Ref ref) =>
    GetDeckMoveTargetsUseCase(ref.watch(deckRepositoryProvider));

@riverpod
ListDeckDestinationsUseCase listDeckDestinationsUseCase(Ref ref) =>
    ListDeckDestinationsUseCase(ref.watch(deckRepositoryProvider));

@riverpod
UpdateDeckUseCase updateDeckUseCase(Ref ref) =>
    UpdateDeckUseCase(ref.watch(deckRepositoryProvider));

@riverpod
DeleteDeckUseCase deleteDeckUseCase(Ref ref) =>
    DeleteDeckUseCase(ref.watch(deckRepositoryProvider));

@riverpod
MoveDeckUseCase moveDeckUseCase(Ref ref) =>
    MoveDeckUseCase(ref.watch(deckRepositoryProvider));

@riverpod
ReorderDecksUseCase reorderDecksUseCase(Ref ref) =>
    ReorderDecksUseCase(ref.watch(deckRepositoryProvider));

@riverpod
DuplicateDeckUseCase duplicateDeckUseCase(Ref ref) =>
    DuplicateDeckUseCase(ref.watch(deckRepositoryProvider));

@riverpod
ExportDeckUseCase exportDeckUseCase(Ref ref) =>
    ExportDeckUseCase(ref.watch(deckRepositoryProvider));

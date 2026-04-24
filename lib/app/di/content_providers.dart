import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../data/datasources/local/daos/deck_dao.dart';
import '../../data/datasources/local/daos/flashcard_dao.dart';
import '../../data/datasources/local/daos/folder_dao.dart';
import '../../data/datasources/local/local_transaction_runner.dart';
import '../../data/repositories/deck_repository_impl.dart';
import '../../data/repositories/flashcard_repository_impl.dart';
import '../../data/repositories/folder_repository_impl.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/services/folder_structure_service.dart';
import '../../domain/usecases/content_query_usecases.dart';
import '../../domain/usecases/deck_usecases.dart';
import '../../domain/usecases/flashcard_usecases.dart';
import '../../domain/usecases/folder_usecases.dart';
import 'providers.dart';

part 'content_providers.g.dart';

@Riverpod(keepAlive: true)
Clock clock(Ref ref) {
  return const SystemClock();
}

@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) {
  return RandomIdGenerator();
}

@Riverpod(keepAlive: true)
LocalTransactionRunner localTransactionRunner(Ref ref) {
  return LocalTransactionRunner(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
FolderDao folderDao(Ref ref) {
  return FolderDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
DeckDao deckDao(Ref ref) {
  return DeckDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
FlashcardDao flashcardDao(Ref ref) {
  return FlashcardDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
FolderStructureService folderStructureService(Ref ref) {
  return const FolderStructureService();
}

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  return FolderRepositoryImpl(
    folderDao: ref.watch(folderDaoProvider),
    deckDao: ref.watch(deckDaoProvider),
    transactionRunner: ref.watch(localTransactionRunnerProvider),
    structureService: ref.watch(folderStructureServiceProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
}

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) {
  return DeckRepositoryImpl(
    deckDao: ref.watch(deckDaoProvider),
    flashcardDao: ref.watch(flashcardDaoProvider),
    folderDao: ref.watch(folderDaoProvider),
    transactionRunner: ref.watch(localTransactionRunnerProvider),
    structureService: ref.watch(folderStructureServiceProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
}

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(Ref ref) {
  return FlashcardRepositoryImpl(
    flashcardDao: ref.watch(flashcardDaoProvider),
    deckDao: ref.watch(deckDaoProvider),
    folderDao: ref.watch(folderDaoProvider),
    transactionRunner: ref.watch(localTransactionRunnerProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<int> contentDataRevision(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  var revision = 0;
  return database
      .customSelect(
        'SELECT 1 AS changed',
        readsFrom: {
          database.folders,
          database.decks,
          database.flashcards,
          database.flashcardProgress,
        },
      )
      .watch()
      .map((_) => revision++);
}

@Riverpod(keepAlive: true)
WatchLibraryOverviewUseCase watchLibraryOverviewUseCase(Ref ref) {
  return WatchLibraryOverviewUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
WatchFolderDetailUseCase watchFolderDetailUseCase(Ref ref) {
  return WatchFolderDetailUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
WatchDeckDetailUseCase watchDeckDetailUseCase(Ref ref) {
  return WatchDeckDetailUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
WatchFlashcardListUseCase watchFlashcardListUseCase(Ref ref) {
  return WatchFlashcardListUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
CreateFolderUseCase createFolderUseCase(Ref ref) {
  return CreateFolderUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetFolderMoveTargetsUseCase getFolderMoveTargetsUseCase(Ref ref) {
  return GetFolderMoveTargetsUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
UpdateFolderUseCase updateFolderUseCase(Ref ref) {
  return UpdateFolderUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
DeleteFolderUseCase deleteFolderUseCase(Ref ref) {
  return DeleteFolderUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
MoveFolderUseCase moveFolderUseCase(Ref ref) {
  return MoveFolderUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
ReorderFoldersUseCase reorderFoldersUseCase(Ref ref) {
  return ReorderFoldersUseCase(ref.watch(folderRepositoryProvider));
}

@Riverpod(keepAlive: true)
CreateDeckUseCase createDeckUseCase(Ref ref) {
  return CreateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDeckMoveTargetsUseCase getDeckMoveTargetsUseCase(Ref ref) {
  return GetDeckMoveTargetsUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
UpdateDeckUseCase updateDeckUseCase(Ref ref) {
  return UpdateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
DeleteDeckUseCase deleteDeckUseCase(Ref ref) {
  return DeleteDeckUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
MoveDeckUseCase moveDeckUseCase(Ref ref) {
  return MoveDeckUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
ReorderDecksUseCase reorderDecksUseCase(Ref ref) {
  return ReorderDecksUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
DuplicateDeckUseCase duplicateDeckUseCase(Ref ref) {
  return DuplicateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
ExportDeckUseCase exportDeckUseCase(Ref ref) {
  return ExportDeckUseCase(ref.watch(deckRepositoryProvider));
}

@Riverpod(keepAlive: true)
CreateFlashcardUseCase createFlashcardUseCase(Ref ref) {
  return CreateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetFlashcardUseCase getFlashcardUseCase(Ref ref) {
  return GetFlashcardUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetFlashcardMoveTargetsUseCase getFlashcardMoveTargetsUseCase(Ref ref) {
  return GetFlashcardMoveTargetsUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
UpdateFlashcardUseCase updateFlashcardUseCase(Ref ref) {
  return UpdateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
DeleteFlashcardsUseCase deleteFlashcardsUseCase(Ref ref) {
  return DeleteFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
MoveFlashcardsUseCase moveFlashcardsUseCase(Ref ref) {
  return MoveFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
ReorderFlashcardsUseCase reorderFlashcardsUseCase(Ref ref) {
  return ReorderFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
PrepareFlashcardImportUseCase prepareFlashcardImportUseCase(Ref ref) {
  return PrepareFlashcardImportUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
CommitFlashcardImportUseCase commitFlashcardImportUseCase(Ref ref) {
  return CommitFlashcardImportUseCase(ref.watch(flashcardRepositoryProvider));
}

@Riverpod(keepAlive: true)
ExportFlashcardsUseCase exportFlashcardsUseCase(Ref ref) {
  return ExportFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

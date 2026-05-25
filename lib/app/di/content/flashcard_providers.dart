import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/flashcard_repository_impl.dart';
import '../../../domain/repositories/flashcard_repository.dart';
import '../../../domain/usecases/content_query_usecases.dart';
import '../../../domain/usecases/flashcard_usecases.dart';
import 'content_core_providers.dart';
import 'content_data_providers.dart';

part 'flashcard_providers.g.dart';

@riverpod
FlashcardRepository flashcardRepository(Ref ref) => FlashcardRepositoryImpl(
  flashcardDao: ref.watch(flashcardDaoProvider),
  deckDao: ref.watch(deckDaoProvider),
  folderDao: ref.watch(folderDaoProvider),
  transactionRunner: ref.watch(localTransactionRunnerProvider),
  clock: ref.watch(clockProvider),
  idGenerator: ref.watch(idGeneratorProvider),
);

@riverpod
WatchFlashcardListUseCase watchFlashcardListUseCase(Ref ref) =>
    WatchFlashcardListUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
CreateFlashcardUseCase createFlashcardUseCase(Ref ref) =>
    CreateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
GetFlashcardUseCase getFlashcardUseCase(Ref ref) =>
    GetFlashcardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
GetFlashcardMoveTargetsUseCase getFlashcardMoveTargetsUseCase(Ref ref) =>
    GetFlashcardMoveTargetsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
UpdateFlashcardUseCase updateFlashcardUseCase(Ref ref) =>
    UpdateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
DeleteFlashcardsUseCase deleteFlashcardsUseCase(Ref ref) =>
    DeleteFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
MoveFlashcardsUseCase moveFlashcardsUseCase(Ref ref) =>
    MoveFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
ReorderFlashcardsUseCase reorderFlashcardsUseCase(Ref ref) =>
    ReorderFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
PrepareFlashcardImportUseCase prepareFlashcardImportUseCase(Ref ref) =>
    PrepareFlashcardImportUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
CommitFlashcardImportUseCase commitFlashcardImportUseCase(Ref ref) =>
    CommitFlashcardImportUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
ExportFlashcardsUseCase exportFlashcardsUseCase(Ref ref) =>
    ExportFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));

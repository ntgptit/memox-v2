import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/flashcard_repository_impl.dart';
import '../../../domain/repositories/flashcard_repository.dart';
import '../../../domain/usecases/content_query_usecases.dart';
import '../../../domain/usecases/flashcard_usecases.dart';
import 'content_core_providers.dart';
import 'content_data_providers.dart';

part 'flashcard_providers.g.dart';

@riverpod
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

@riverpod
WatchFlashcardListUseCase watchFlashcardListUseCase(Ref ref) {
  return WatchFlashcardListUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
CreateFlashcardUseCase createFlashcardUseCase(Ref ref) {
  return CreateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
GetFlashcardUseCase getFlashcardUseCase(Ref ref) {
  return GetFlashcardUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
GetFlashcardMoveTargetsUseCase getFlashcardMoveTargetsUseCase(Ref ref) {
  return GetFlashcardMoveTargetsUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
UpdateFlashcardUseCase updateFlashcardUseCase(Ref ref) {
  return UpdateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
DeleteFlashcardsUseCase deleteFlashcardsUseCase(Ref ref) {
  return DeleteFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
MoveFlashcardsUseCase moveFlashcardsUseCase(Ref ref) {
  return MoveFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
ReorderFlashcardsUseCase reorderFlashcardsUseCase(Ref ref) {
  return ReorderFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
PrepareFlashcardImportUseCase prepareFlashcardImportUseCase(Ref ref) {
  return PrepareFlashcardImportUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
CommitFlashcardImportUseCase commitFlashcardImportUseCase(Ref ref) {
  return CommitFlashcardImportUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
ExportFlashcardsUseCase exportFlashcardsUseCase(Ref ref) {
  return ExportFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

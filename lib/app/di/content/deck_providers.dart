import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/deck_repository_impl.dart';
import '../../../domain/repositories/deck_repository.dart';
import '../../../domain/usecases/content_query_usecases.dart';
import '../../../domain/usecases/deck_usecases.dart';
import 'content_core_providers.dart';
import 'content_data_providers.dart';

part 'deck_providers.g.dart';

@riverpod
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

@riverpod
GetDeckActionContextUseCase getDeckActionContextUseCase(Ref ref) {
  return GetDeckActionContextUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
GetDeckHighlightsUseCase getDeckHighlightsUseCase(Ref ref) {
  return GetDeckHighlightsUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
CreateDeckUseCase createDeckUseCase(Ref ref) {
  return CreateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
GetDeckMoveTargetsUseCase getDeckMoveTargetsUseCase(Ref ref) {
  return GetDeckMoveTargetsUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
ListDeckDestinationsUseCase listDeckDestinationsUseCase(Ref ref) {
  return ListDeckDestinationsUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
UpdateDeckUseCase updateDeckUseCase(Ref ref) {
  return UpdateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
DeleteDeckUseCase deleteDeckUseCase(Ref ref) {
  return DeleteDeckUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
MoveDeckUseCase moveDeckUseCase(Ref ref) {
  return MoveDeckUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
ReorderDecksUseCase reorderDecksUseCase(Ref ref) {
  return ReorderDecksUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
DuplicateDeckUseCase duplicateDeckUseCase(Ref ref) {
  return DuplicateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
ExportDeckUseCase exportDeckUseCase(Ref ref) {
  return ExportDeckUseCase(ref.watch(deckRepositoryProvider));
}

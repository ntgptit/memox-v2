import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/folder_repository.dart';
import '../value_objects/content_queries.dart';
import '../value_objects/content_read_models.dart';

final class WatchLibraryOverviewUseCase {
  const WatchLibraryOverviewUseCase(this._repository);

  final FolderRepository _repository;

  Future<LibraryOverviewReadModel> execute(ContentQuery query) =>
      _repository.getLibraryOverview(query);
}

final class WatchFolderDetailUseCase {
  const WatchFolderDetailUseCase(this._repository);

  final FolderRepository _repository;

  Future<FolderDetailReadModel> execute(String folderId, ContentQuery query) =>
      _repository.getFolderDetail(folderId, query);
}

final class GetDeckActionContextUseCase {
  const GetDeckActionContextUseCase(this._repository);

  final DeckRepository _repository;

  Future<DeckActionContextReadModel> execute(String deckId) =>
      _repository.getDeckActionContext(deckId);
}

final class GetDeckHighlightsUseCase {
  const GetDeckHighlightsUseCase(this._repository);

  final DeckRepository _repository;

  Future<List<DeckHighlightReadModel>> execute({required int limit}) =>
      _repository.getDeckHighlights(limit: limit);
}

final class WatchFlashcardListUseCase {
  const WatchFlashcardListUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<FlashcardListReadModel> execute(String deckId, ContentQuery query) =>
      _repository.getFlashcards(deckId, query);
}

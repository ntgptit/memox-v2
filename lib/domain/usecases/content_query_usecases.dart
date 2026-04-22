import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/folder_repository.dart';
import '../value_objects/content_queries.dart';
import '../value_objects/content_read_models.dart';

final class WatchLibraryOverviewUseCase {
  const WatchLibraryOverviewUseCase(this._repository);

  final FolderRepository _repository;

  Future<LibraryOverviewReadModel> execute(ContentQuery query) {
    return _repository.getLibraryOverview(query);
  }
}

final class WatchFolderDetailUseCase {
  const WatchFolderDetailUseCase(this._repository);

  final FolderRepository _repository;

  Future<FolderDetailReadModel> execute(String folderId, ContentQuery query) {
    return _repository.getFolderDetail(folderId, query);
  }
}

final class WatchDeckDetailUseCase {
  const WatchDeckDetailUseCase(this._repository);

  final DeckRepository _repository;

  Future<DeckDetailReadModel> execute(String deckId) {
    return _repository.getDeckDetail(deckId);
  }
}

final class WatchFlashcardListUseCase {
  const WatchFlashcardListUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<FlashcardListReadModel> execute(String deckId, ContentQuery query) {
    return _repository.getFlashcards(deckId, query);
  }
}

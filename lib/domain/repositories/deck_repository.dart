import '../../core/errors/result.dart';
import '../entities/deck_entity.dart';
import '../value_objects/content_actions.dart';
import '../value_objects/content_queries.dart';
import '../value_objects/content_read_models.dart';

abstract interface class DeckRepository {
  Future<DeckActionContextReadModel> getDeckActionContext(String deckId);

  Future<List<FolderDeckReadModel>> getDecksInFolder(
    String folderId,
    ContentQuery query,
  );

  Future<List<DeckMoveTarget>> getDeckMoveTargets({
    required String deckId,
    String? excludingFolderId,
  });

  Future<Result<DeckEntity>> createDeck({
    required String folderId,
    required String name,
  });

  Future<Result<DeckEntity>> updateDeck({
    required String deckId,
    required String name,
  });

  Future<Result<void>> deleteDeck(String deckId);

  Future<Result<void>> moveDeck({
    required String deckId,
    required String targetFolderId,
  });

  Future<Result<void>> reorderDecks({
    required String folderId,
    required List<String> orderedDeckIds,
  });

  Future<Result<DeckEntity>> duplicateDeck({
    required String deckId,
    required String targetFolderId,
  });

  Future<Result<ExportData>> exportDeck(String deckId);
}

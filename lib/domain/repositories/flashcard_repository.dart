import '../../core/errors/result.dart';
import '../entities/flashcard_entity.dart';
import '../value_objects/content_actions.dart';
import '../value_objects/content_queries.dart';
import '../value_objects/content_read_models.dart';

abstract interface class FlashcardRepository {
  Future<FlashcardEntity> getFlashcard(String flashcardId);

  Future<FlashcardListReadModel> getFlashcards(
    String deckId,
    ContentQuery query,
  );

  Future<List<DeckMoveTarget>> getFlashcardMoveTargets({
    required String deckId,
    required List<String> flashcardIds,
  });

  Future<Result<FlashcardEntity>> createFlashcard({
    required String deckId,
    required FlashcardDraft draft,
  });

  Future<Result<FlashcardEntity>> updateFlashcard({
    required String flashcardId,
    required FlashcardDraft draft,
  });

  Future<Result<void>> deleteFlashcards(List<String> flashcardIds);

  Future<Result<void>> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
  });

  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedFlashcardIds,
  });

  Future<Result<FlashcardImportPreparation>> prepareImport({
    required ImportSourceFormat format,
    required String rawContent,
  });

  Future<Result<int>> commitImport({
    required String deckId,
    required FlashcardImportPreparation preparation,
  });

  Future<Result<ExportData>> exportFlashcards(List<String> flashcardIds);
}

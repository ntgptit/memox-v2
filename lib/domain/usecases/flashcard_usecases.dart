import '../../core/errors/result.dart';
import '../entities/flashcard_entity.dart';
import '../repositories/flashcard_repository.dart';
import '../value_objects/content_actions.dart';

final class CreateFlashcardUseCase {
  const CreateFlashcardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<FlashcardEntity>> execute({
    required String deckId,
    required FlashcardDraft draft,
  }) {
    return _repository.createFlashcard(deckId: deckId, draft: draft);
  }
}

final class GetFlashcardUseCase {
  const GetFlashcardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<FlashcardEntity> execute(String flashcardId) {
    return _repository.getFlashcard(flashcardId);
  }
}

final class GetFlashcardMoveTargetsUseCase {
  const GetFlashcardMoveTargetsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<List<DeckMoveTarget>> execute({
    required String deckId,
    required List<String> flashcardIds,
  }) {
    return _repository.getFlashcardMoveTargets(
      deckId: deckId,
      flashcardIds: flashcardIds,
    );
  }
}

final class UpdateFlashcardUseCase {
  const UpdateFlashcardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<FlashcardEntity>> execute({
    required String flashcardId,
    required FlashcardDraft draft,
  }) {
    return _repository.updateFlashcard(flashcardId: flashcardId, draft: draft);
  }
}

final class DeleteFlashcardsUseCase {
  const DeleteFlashcardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<void>> execute(List<String> flashcardIds) {
    return _repository.deleteFlashcards(flashcardIds);
  }
}

final class MoveFlashcardsUseCase {
  const MoveFlashcardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<void>> execute({
    required List<String> flashcardIds,
    required String targetDeckId,
  }) {
    return _repository.moveFlashcards(
      flashcardIds: flashcardIds,
      targetDeckId: targetDeckId,
    );
  }
}

final class ReorderFlashcardsUseCase {
  const ReorderFlashcardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<void>> execute({
    required String deckId,
    required List<String> orderedFlashcardIds,
  }) {
    return _repository.reorderFlashcards(
      deckId: deckId,
      orderedFlashcardIds: orderedFlashcardIds,
    );
  }
}

final class PrepareFlashcardImportUseCase {
  const PrepareFlashcardImportUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<FlashcardImportPreparation>> execute({
    required ImportSourceFormat format,
    required String rawContent,
  }) {
    return _repository.prepareImport(format: format, rawContent: rawContent);
  }
}

final class CommitFlashcardImportUseCase {
  const CommitFlashcardImportUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<int>> execute({
    required String deckId,
    required FlashcardImportPreparation preparation,
  }) {
    return _repository.commitImport(
      deckId: deckId,
      preparation: preparation,
    );
  }
}

final class ExportFlashcardsUseCase {
  const ExportFlashcardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<ExportData>> execute(List<String> flashcardIds) {
    return _repository.exportFlashcards(flashcardIds);
  }
}

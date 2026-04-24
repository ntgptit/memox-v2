import '../../core/errors/result.dart';
import '../entities/deck_entity.dart';
import '../repositories/deck_repository.dart';
import '../value_objects/content_actions.dart';

final class CreateDeckUseCase {
  const CreateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<DeckEntity>> execute({
    required String folderId,
    required String name,
  }) {
    return _repository.createDeck(folderId: folderId, name: name);
  }
}

final class UpdateDeckUseCase {
  const UpdateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<DeckEntity>> execute({
    required String deckId,
    required String name,
  }) {
    return _repository.updateDeck(deckId: deckId, name: name);
  }
}

final class GetDeckMoveTargetsUseCase {
  const GetDeckMoveTargetsUseCase(this._repository);

  final DeckRepository _repository;

  Future<List<DeckMoveTarget>> execute({
    required String deckId,
    String? excludingFolderId,
  }) {
    return _repository.getDeckMoveTargets(
      deckId: deckId,
      excludingFolderId: excludingFolderId,
    );
  }
}

final class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> execute(String deckId) {
    return _repository.deleteDeck(deckId);
  }
}

final class MoveDeckUseCase {
  const MoveDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> execute({
    required String deckId,
    required String targetFolderId,
  }) {
    return _repository.moveDeck(deckId: deckId, targetFolderId: targetFolderId);
  }
}

final class ReorderDecksUseCase {
  const ReorderDecksUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> execute({
    required String folderId,
    required List<String> orderedDeckIds,
  }) {
    return _repository.reorderDecks(
      folderId: folderId,
      orderedDeckIds: orderedDeckIds,
    );
  }
}

final class DuplicateDeckUseCase {
  const DuplicateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<DeckEntity>> execute({
    required String deckId,
    required String targetFolderId,
  }) {
    return _repository.duplicateDeck(
      deckId: deckId,
      targetFolderId: targetFolderId,
    );
  }
}

final class ExportDeckUseCase {
  const ExportDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<ExportData>> execute(String deckId) {
    return _repository.exportDeck(deckId);
  }
}

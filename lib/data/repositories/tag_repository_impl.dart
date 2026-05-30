import '../../core/errors/result.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/value_objects/tag_read_models.dart';
import '../datasources/local/daos/flashcard_tag_dao.dart';
import '../datasources/local/local_transaction_runner.dart';
import 'repository_support.dart';

/// Drift-backed [TagRepository]. Assumes pre-validated, lowercased input
/// (validation/normalization lives in the domain `TagValidator`).
final class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl({
    required FlashcardTagDao flashcardTagDao,
    required LocalTransactionRunner transactionRunner,
  }) : _dao = flashcardTagDao,
       _transactionRunner = transactionRunner;

  final FlashcardTagDao _dao;
  final LocalTransactionRunner _transactionRunner;

  @override
  Stream<List<TagWithCount>> watchAllWithCount() => _dao
      .watchAllWithCount()
      .map(
        (rows) => rows
            .map(
              (row) =>
                  TagWithCount(tag: row.tag, cardCount: row.cardCount),
            )
            .toList(growable: false),
      );

  @override
  Future<bool> existsCaseInsensitive(String lowerName) =>
      _dao.existsCaseInsensitive(lowerName);

  @override
  Future<Result<void>> addTagToCard({
    required String flashcardId,
    required String tag,
  }) => runRepositoryAction(
    () => _dao.addToCard(flashcardId: flashcardId, tag: tag),
  );

  @override
  Future<Result<void>> removeTagFromCard({
    required String flashcardId,
    required String tag,
  }) => runRepositoryAction(
    () => _dao.removeFromCard(flashcardId: flashcardId, lowerTag: tag),
  );

  @override
  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  }) => runRepositoryAction(
    () => _transactionRunner.write(
      (_) => _dao.rename(lowerOldName: oldName, newName: newName),
    ),
  );

  @override
  Future<Result<TagMergeResult>> merge({
    required String sourceName,
    required String destinationName,
  }) => runRepositoryAction(
    () => _transactionRunner.write((_) async {
      final movedCards = await _dao.countCardsWithTag(sourceName);
      await _dao.attachDestinationToSourceCards(
        lowerSource: sourceName,
        destination: destinationName,
      );
      await _dao.deleteTag(sourceName);
      return TagMergeResult(movedCards: movedCards);
    }),
  );

  @override
  Future<Result<int>> delete(String name) => runRepositoryAction(
    () => _transactionRunner.write((_) async {
      final affected = await _dao.countCardsWithTag(name);
      await _dao.deleteTag(name);
      return affected;
    }),
  );
}

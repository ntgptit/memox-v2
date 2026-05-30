import '../../core/errors/result.dart';
import '../value_objects/tag_read_models.dart';

/// `flashcard_tags` operations. Tags are global by name, case-insensitive,
/// stored lowercased. See `docs/contracts/repository-contracts/tag-repository.md`.
///
/// Queries/streams return raw values (and throw on failure); mutations return
/// [Result] — matching the repository convention used across this project.
/// Validation/normalization is the domain layer's job (TagValidator); the
/// repository assumes pre-validated, lowercased input.
abstract interface class TagRepository {
  /// All distinct tags with their card usage count, sorted by count desc then
  /// name asc. Backs the tag management screen.
  Stream<List<TagWithCount>> watchAllWithCount();

  /// Whether any card is tagged with [lowerName] (case-insensitive match).
  /// Used by rename to detect a collision before mutating.
  Future<bool> existsCaseInsensitive(String lowerName);

  /// Idempotently attach [tag] to a card (dedupe by `(flashcard_id, tag)`).
  Future<Result<void>> addTagToCard({
    required String flashcardId,
    required String tag,
  });

  /// Remove [tag] from a card. Idempotent (no error if absent).
  Future<Result<void>> removeTagFromCard({
    required String flashcardId,
    required String tag,
  });

  /// Rename a tag on every card. Caller must guarantee [newName] does not
  /// already exist (collision is resolved as a merge by the caller).
  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  });

  /// Merge [sourceName] into [destinationName] atomically, deduping per card,
  /// then remove the source tag rows.
  Future<Result<TagMergeResult>> merge({
    required String sourceName,
    required String destinationName,
  });

  /// Remove a tag from all cards. Cards themselves are untouched. Returns the
  /// number of cards that had the tag.
  Future<Result<int>> delete(String name);
}

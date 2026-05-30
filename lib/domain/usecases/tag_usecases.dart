import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../core/utils/string_utils.dart';
import '../repositories/tag_repository.dart';
import '../tag/tag_validator.dart';
import '../value_objects/tag_read_models.dart';

/// Streams all tags with usage count for the tag management screen.
///
/// (Maps the prompt's `ListTagsUseCase` onto the contract name.)
final class WatchAllTagsWithCountUseCase {
  const WatchAllTagsWithCountUseCase(this._repository);

  final TagRepository _repository;

  Stream<List<TagWithCount>> call() => _repository.watchAllWithCount();
}

/// Validates + normalizes a tag, then idempotently attaches it to a card.
///
/// Returns [Result<void>] (contract: `Either<Failure, Unit>`). The use case
/// validates through [TagValidator] and rejects commas, over-length names, and
/// empty input before touching the repository.
final class AddTagToCardUseCase {
  const AddTagToCardUseCase(this._repository, this._validator);

  final TagRepository _repository;
  final TagValidator _validator;

  Future<Result<void>> execute({
    required String flashcardId,
    required String tag,
  }) async {
    final validation = _validator.validate(tag);
    if (validation is FailureResult<String>) {
      return FailureResult<void>(validation.failure);
    }
    final normalized = (validation as Success<String>).value;
    return _repository.addTagToCard(flashcardId: flashcardId, tag: normalized);
  }
}

/// Detaches a tag from a single card. Idempotent.
final class RemoveTagFromCardUseCase {
  const RemoveTagFromCardUseCase(this._repository, this._validator);

  final TagRepository _repository;
  final TagValidator _validator;

  Future<Result<void>> execute({
    required String flashcardId,
    required String tag,
  }) {
    final validation = _validator.validate(tag);
    if (validation is FailureResult<String>) {
      return Future<Result<void>>.value(FailureResult<void>(validation.failure));
    }
    return _repository.removeTagFromCard(
      flashcardId: flashcardId,
      tag: (validation as Success<String>).value,
    );
  }
}

/// Renames a tag across all cards.
///
/// - No-op when the new name equals the current name (case-insensitive).
/// - Returns a [FailureCodes.tagNameConflict] validation failure when the new
///   name already exists, so the UI can offer a merge instead. Never
///   auto-merges (contract §RenameTagUseCase).
final class RenameTagUseCase {
  const RenameTagUseCase(this._repository, this._validator);

  final TagRepository _repository;
  final TagValidator _validator;

  Future<Result<void>> execute({
    required String oldName,
    required String newName,
  }) async {
    final validation = _validator.validate(newName);
    if (validation is FailureResult<String>) {
      return FailureResult<void>(validation.failure);
    }
    final normalizedNew = (validation as Success<String>).value;
    final normalizedOld = StringUtils.normalizedForComparison(oldName);

    if (normalizedNew == normalizedOld) {
      return const Success<void>(null);
    }
    if (await _repository.existsCaseInsensitive(normalizedNew)) {
      return const FailureResult<void>(
        AppFailure(
          type: FailureType.validation,
          message: 'A tag with that name already exists.',
          code: FailureCodes.tagNameConflict,
        ),
      );
    }
    return _repository.rename(oldName: normalizedOld, newName: normalizedNew);
  }
}

/// Merges a source tag into a destination tag (dedupe per card, remove source).
final class MergeTagUseCase {
  const MergeTagUseCase(this._repository, this._validator);

  final TagRepository _repository;
  final TagValidator _validator;

  Future<Result<TagMergeResult>> execute({
    required String sourceName,
    required String destinationName,
  }) async {
    final validation = _validator.validate(destinationName);
    if (validation is FailureResult<String>) {
      return FailureResult<TagMergeResult>(validation.failure);
    }
    final destination = (validation as Success<String>).value;
    final source = StringUtils.normalizedForComparison(sourceName);

    if (source == destination) {
      return const FailureResult<TagMergeResult>(
        AppFailure(
          type: FailureType.validation,
          message: 'Cannot merge a tag into itself.',
          code: FailureCodes.tagInvalidCharacter,
        ),
      );
    }
    return _repository.merge(
      sourceName: source,
      destinationName: destination,
    );
  }
}

/// Deletes a tag from all cards. Cards are not deleted. Returns affected card
/// count.
final class DeleteTagUseCase {
  const DeleteTagUseCase(this._repository);

  final TagRepository _repository;

  Future<Result<int>> execute(String tag) =>
      _repository.delete(StringUtils.normalizedForComparison(tag));
}

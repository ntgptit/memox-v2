import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/failures.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/usecases/tag_usecases.dart';
import 'package:memox/domain/value_objects/tag_read_models.dart';

/// In-memory fake isolating use-case logic (validation, collision, dedupe)
/// from Drift. Records the arguments each method received.
class _FakeTagRepository implements TagRepository {
  bool existsResult = false;

  ({String flashcardId, String tag})? addedToCard;
  ({String oldName, String newName})? renamed;
  ({String source, String destination})? merged;
  String? deleted;

  @override
  Stream<List<TagWithCount>> watchAllWithCount() =>
      const Stream<List<TagWithCount>>.empty();

  @override
  Future<bool> existsCaseInsensitive(String lowerName) async => existsResult;

  @override
  Future<Result<void>> addTagToCard({
    required String flashcardId,
    required String tag,
  }) async {
    addedToCard = (flashcardId: flashcardId, tag: tag);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> removeTagFromCard({
    required String flashcardId,
    required String tag,
  }) async => const Success<void>(null);

  @override
  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  }) async {
    renamed = (oldName: oldName, newName: newName);
    return const Success<void>(null);
  }

  @override
  Future<Result<TagMergeResult>> merge({
    required String sourceName,
    required String destinationName,
  }) async {
    merged = (source: sourceName, destination: destinationName);
    return const Success<TagMergeResult>(TagMergeResult(movedCards: 1));
  }

  @override
  Future<Result<int>> delete(String name) async {
    deleted = name;
    return const Success<int>(1);
  }
}

void main() {
  const validator = TagValidator();
  late _FakeTagRepository repo;

  setUp(() => repo = _FakeTagRepository());

  group('AddTagToCardUseCase', () {
    test('normalizes input and attaches it to the card', () async {
      final useCase = AddTagToCardUseCase(repo, validator);
      final result = await useCase.execute(flashcardId: 'card-1', tag: '#Verb');

      expect(result.valueOrNull, 'verb');
      expect(repo.addedToCard, (flashcardId: 'card-1', tag: 'verb'));
    });

    test('rejects an invalid tag before touching the repository', () async {
      final useCase = AddTagToCardUseCase(repo, validator);
      final result = await useCase.execute(flashcardId: 'card-1', tag: 'a,b');

      expect(result.failureOrNull?.code, FailureCodes.tagInvalidCharacter);
      expect(repo.addedToCard, isNull);
    });
  });

  group('RenameTagUseCase (collision = ConflictFailure)', () {
    test('renames when the new name is free', () async {
      repo.existsResult = false;
      final useCase = RenameTagUseCase(repo, validator);
      final result = await useCase.execute(oldName: 'verb', newName: 'Verbs');

      expect(result.isSuccess, isTrue);
      expect(repo.renamed, (oldName: 'verb', newName: 'verbs'));
    });

    test('returns a conflict failure when the new name exists', () async {
      repo.existsResult = true;
      final useCase = RenameTagUseCase(repo, validator);
      final result = await useCase.execute(oldName: 'verb', newName: 'noun');

      expect(result.failureOrNull?.code, FailureCodes.tagNameConflict);
      expect(repo.renamed, isNull);
    });

    test('is a no-op when renamed to the same name (case-insensitive)', () async {
      final useCase = RenameTagUseCase(repo, validator);
      final result = await useCase.execute(oldName: 'verb', newName: 'VERB');

      expect(result.isSuccess, isTrue);
      expect(repo.renamed, isNull);
    });
  });

  group('MergeTagUseCase', () {
    test('normalizes both sides and delegates to the repository', () async {
      final useCase = MergeTagUseCase(repo, validator);
      final result = await useCase.execute(
        sourceName: 'Verb',
        destinationName: '#Verbs',
      );

      expect(result.valueOrNull, const TagMergeResult(movedCards: 1));
      expect(repo.merged, (source: 'verb', destination: 'verbs'));
    });

    test('rejects merging a tag into itself', () async {
      final useCase = MergeTagUseCase(repo, validator);
      final result = await useCase.execute(
        sourceName: 'verb',
        destinationName: 'VERB',
      );

      expect(result.isFailure, isTrue);
      expect(repo.merged, isNull);
    });
  });

  group('DeleteTagUseCase', () {
    test('deletes by normalized name', () async {
      final useCase = DeleteTagUseCase(repo);
      final result = await useCase.execute('  Verb ');

      expect(result.valueOrNull, 1);
      expect(repo.deleted, 'verb');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/daos/flashcard_tag_dao.dart';
import 'package:memox/data/datasources/local/local_transaction_runner.dart';
import 'package:memox/data/repositories/tag_repository_impl.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/tag_read_models.dart';

import '../../support/content_repository_harness.dart';

/// Tag repository behavior against an in-memory Drift database. Verifies tag
/// rows are mutated correctly while flashcard rows are preserved
/// (docs/contracts/repository-contracts/tag-repository.md, decision rows TG7).
void main() {
  late ContentRepositoryHarness harness;
  late TagRepositoryImpl repo;
  late String deckId;

  setUp(() async {
    harness = ContentRepositoryHarness.create();
    repo = TagRepositoryImpl(
      flashcardTagDao: FlashcardTagDao(harness.database),
      transactionRunner: LocalTransactionRunner(harness.database),
    );

    final folder = await harness.folderRepository.createRootFolder('Root');
    final deck = await harness.deckRepository.createDeck(
      folderId: folder.valueOrNull!.id,
      name: 'Deck',
    );
    deckId = deck.valueOrNull!.id;
  });

  tearDown(() => harness.dispose());

  Future<String> seedCard(String front, List<String> tags) async {
    final result = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: FlashcardDraft(front: front, back: 'back', tags: tags),
    );
    return result.valueOrNull!.id;
  }

  Future<List<String>> tagsOf(String cardId) async {
    final card = await harness.flashcardRepository.getFlashcard(cardId);
    return card.tags;
  }

  test('addToCard is idempotent (no duplicate rows)', () async {
    final cardId = await seedCard('a', const []);

    expect((await repo.addTagToCard(flashcardId: cardId, tag: 'verb')).isSuccess, isTrue);
    expect((await repo.addTagToCard(flashcardId: cardId, tag: 'verb')).isSuccess, isTrue);

    expect(await tagsOf(cardId), ['verb']);
  });

  test('existsCaseInsensitive matches regardless of case', () async {
    await seedCard('a', const ['verb']);
    expect(await repo.existsCaseInsensitive('verb'), isTrue);
    expect(await repo.existsCaseInsensitive('VERB'), isTrue);
    expect(await repo.existsCaseInsensitive('noun'), isFalse);
  });

  test('rename updates all rows and keeps card links', () async {
    final cardId = await seedCard('a', const ['verb']);

    final result = await repo.rename(oldName: 'verb', newName: 'verbs');
    expect(result.isSuccess, isTrue);

    expect(await tagsOf(cardId), ['verbs']);
    // Card itself is preserved.
    expect((await harness.flashcardRepository.getFlashcard(cardId)).front, 'a');
  });

  test('merge moves links from source to target, dedupes, removes source',
      () async {
    final cardA = await seedCard('a', const ['verb']);
    final cardB = await seedCard('b', const ['verb', 'verbs']);

    final result = await repo.merge(sourceName: 'verb', destinationName: 'verbs');
    expect(result.valueOrNull, const TagMergeResult(movedCards: 2));

    expect(await tagsOf(cardA), ['verbs']);
    expect(await tagsOf(cardB), ['verbs']); // deduped, not duplicated
    expect(await repo.existsCaseInsensitive('verb'), isFalse);
  });

  test('delete detaches tag from cards but keeps the cards', () async {
    final cardId = await seedCard('a', const ['verb', 'noun']);

    final result = await repo.delete('verb');
    expect(result.valueOrNull, 1);

    expect(await tagsOf(cardId), ['noun']);
    expect((await harness.flashcardRepository.getFlashcard(cardId)).front, 'a');
  });

  test('watchAllWithCount reports correct usage counts', () async {
    await seedCard('a', const ['verb', 'noun']);
    await seedCard('b', const ['verb']);
    await seedCard('c', const ['noun']);

    final tags = await repo.watchAllWithCount().first;

    expect(tags, contains(const TagWithCount(tag: 'verb', cardCount: 2)));
    expect(tags, contains(const TagWithCount(tag: 'noun', cardCount: 2)));
    // Sorted by count desc then name asc.
    expect(tags.first.cardCount, 2);
  });
}

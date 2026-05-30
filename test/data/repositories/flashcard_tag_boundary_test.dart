import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/failures.dart';
import 'package:memox/domain/value_objects/content_actions.dart';

import '../../support/content_repository_harness.dart';

/// Tests that TagValidator is enforced at the FlashcardRepository boundary
/// (`_normalizeDraft`) so invalid tags are rejected regardless of call path
/// (editor, import, bulk, etc.).
///
/// Decision rows: TG9 (no comma), TG10 (max 50 chars).
void main() {
  late ContentRepositoryHarness harness;
  late String deckId;

  setUp(() async {
    harness = ContentRepositoryHarness.create();
    final folder = await harness.folderRepository.createRootFolder('Root');
    final deck = await harness.deckRepository.createDeck(
      folderId: folder.valueOrNull!.id,
      name: 'Deck',
    );
    deckId = deck.valueOrNull!.id;
  });

  tearDown(() => harness.dispose());

  // ── CreateFlashcard tag validation ────────────────────────────────────────

  test('TG9 CreateFlashcard rejects tag with comma', () async {
    final result = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: const FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['a,b'],
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.type, FailureType.validation);
    expect(result.failureOrNull?.code, FailureCodes.tagInvalidCharacter);
  });

  test('TG10 CreateFlashcard rejects tag longer than 50 chars', () async {
    final result = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['a' * 51],
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.type, FailureType.validation);
    expect(result.failureOrNull?.code, FailureCodes.tagTooLong);
  });

  test('CreateFlashcard strips leading # and lowercases valid tag', () async {
    final result = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: const FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['#Verb', 'GRAMMAR'],
      ),
    );

    expect(result.isSuccess, isTrue);
    final tags = result.valueOrNull!.tags;
    // Stored lowercased, # stripped.
    expect(tags, containsAll(<String>['verb', 'grammar']));
    expect(tags, isNot(contains('#verb')));
    expect(tags, isNot(contains('Verb')));
  });

  test('CreateFlashcard with 50-char tag succeeds (boundary)', () async {
    final result = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['a' * 50],
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.tags, contains('a' * 50));
  });

  // ── UpdateFlashcard tag validation ────────────────────────────────────────

  test('UpdateFlashcard rejects tag with comma', () async {
    final created = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: const FlashcardDraft(front: 'Front', back: 'Back'),
    );
    final cardId = created.valueOrNull!.id;

    final result = await harness.flashcardRepository.updateFlashcard(
      flashcardId: cardId,
      draft: const FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['bad,tag'],
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, FailureCodes.tagInvalidCharacter);
  });

  test('UpdateFlashcard rejects tag longer than 50 chars', () async {
    final created = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: const FlashcardDraft(front: 'Front', back: 'Back'),
    );
    final cardId = created.valueOrNull!.id;

    final result = await harness.flashcardRepository.updateFlashcard(
      flashcardId: cardId,
      draft: FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['b' * 51],
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, FailureCodes.tagTooLong);
  });

  test('UpdateFlashcard lowercases and strips # on valid tags', () async {
    final created = await harness.flashcardRepository.createFlashcard(
      deckId: deckId,
      draft: const FlashcardDraft(front: 'Front', back: 'Back'),
    );
    final cardId = created.valueOrNull!.id;

    final result = await harness.flashcardRepository.updateFlashcard(
      flashcardId: cardId,
      draft: const FlashcardDraft(
        front: 'Front',
        back: 'Back',
        tags: ['#Verb', 'NOUN'],
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.tags, containsAll(<String>['verb', 'noun']));
  });
}

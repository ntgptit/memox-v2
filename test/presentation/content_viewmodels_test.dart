import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_queries.dart';
import 'package:memox/presentation/features/decks/viewmodels/deck_action_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_import_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';

import '../support/content_repository_harness.dart';

void main() {
  group('content viewmodels', () {
    test(
      'DT1 onSearchFilterSort: library overview query refreshes after creating a folder',
      () async {
        final harness = ContentRepositoryHarness.create(ids: ['folder-root']);
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final subscription = container.listen(
          libraryOverviewQueryProvider,
          (_, _) {},
          fireImmediately: true,
        );

        expect(
          (await container.read(libraryOverviewQueryProvider.future)).folders,
          isEmpty,
        );

        final success = await container
            .read(libraryOverviewActionControllerProvider.notifier)
            .createFolder('Japanese N5');

        expect(success, isTrue);
        await _flush(container);

        expect(
          subscription.read().requireValue.folders.map((item) => item.name),
          contains('Japanese N5'),
        );
        expect(
          subscription.read().requireValue.folders.single.icon,
          Icons.folder_outlined,
        );
      },
    );

    test(
      'DT2 onSearchFilterSort: folder detail query refreshes after creating a subfolder',
      () async {
        final harness = ContentRepositoryHarness.create(ids: ['folder-root']);
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Japanese N5',
        )).valueOrNull!;

        final subscription = container.listen(
          folderDetailQueryProvider(root.id),
          (_, _) {},
          fireImmediately: true,
        );

        expect(
          (await container.read(
            folderDetailQueryProvider(root.id).future,
          )).isUnlocked,
          isTrue,
        );

        final success = await container
            .read(folderActionControllerProvider(root.id).notifier)
            .createSubfolder('Vocabulary');

        expect(success, isTrue);
        await _flush(container);

        final state = subscription.read().requireValue;
        expect(state.isSubfolderMode, isTrue);
        expect(
          state.subfolders.map((item) => item.name),
          contains('Vocabulary'),
        );
        expect(state.subfolders.single.icon, Icons.folder_copy_outlined);
      },
    );

    test(
      'DT3 onSearchFilterSort: folder detail query exposes structural subtree counts for subfolders',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: [
            'folder-root',
            'folder-child',
            'folder-grandchild',
            'deck-child',
            'flashcard-001',
            'flashcard-002',
          ],
        );
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(harness.database),
            clockProvider.overrideWithValue(harness.clock),
            idGeneratorProvider.overrideWithValue(harness.idGenerator),
            contentDataRevisionProvider.overrideWith(
              (ref) => Stream<int>.value(0),
            ),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Korean',
        )).valueOrNull!;
        final child = (await harness.folderRepository.createSubfolder(
          parentFolderId: root.id,
          name: 'Topik I',
        )).valueOrNull!;
        final grandchild = (await harness.folderRepository.createSubfolder(
          parentFolderId: child.id,
          name: 'Grammar',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: grandchild.id,
          name: 'Vitamin B1',
        )).valueOrNull!;

        await harness.flashcardRepository.createFlashcard(
          deckId: deck.id,
          draft: const FlashcardDraft(front: 'A', back: 'a'),
        );
        await harness.flashcardRepository.createFlashcard(
          deckId: deck.id,
          draft: const FlashcardDraft(front: 'B', back: 'b'),
        );

        final state = await container.read(
          folderDetailQueryProvider(root.id).future,
        );
        final subfolder = state.subfolders.singleWhere(
          (item) => item.id == child.id,
        );

        expect(state.isSubfolderMode, isTrue);
        expect(subfolder.subfolderCount, 1);
        expect(subfolder.deckCount, 1);
        expect(subfolder.itemCount, 2);
      },
    );

    test(
      'DT4 onSearchFilterSort: folder import targets ignore active folder search',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: ['folder-root', 'deck-import-target'],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Korean',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: root.id,
          name: 'Import target',
        )).valueOrNull!;

        container
            .read(folderChildrenToolbarStateProvider(root.id).notifier)
            .setSearchTerm('not matching');

        final targets = await container
            .read(folderActionControllerProvider(root.id).notifier)
            .loadImportDeckTargets();

        expect(targets.map((item) => item.id), contains(deck.id));
        expect(targets.single.name, 'Import target');
      },
    );

    test(
      'DT1 onInsert: folder action create deck returns id for import routing',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: ['folder-root', 'deck-import-new'],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Korean',
        )).valueOrNull!;

        final deckId = await container
            .read(folderActionControllerProvider(root.id).notifier)
            .createDeck('Imported deck');

        expect(deckId, 'deck-import-new');
        expect(
          container.read(folderActionControllerProvider(root.id)).hasError,
          isFalse,
        );
      },
    );

    test(
      'DT1 onUpdate: deck action controller updates deck without provider error',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: ['folder-root', 'deck-root'],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Japanese N5',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: root.id,
          name: 'Core vocabulary',
        )).valueOrNull!;

        final success = await container
            .read(deckActionControllerProvider(deck.id).notifier)
            .updateDeck('Core vocabulary updated');

        expect(success, isTrue);
        expect(
          container.read(deckActionControllerProvider(deck.id)).hasError,
          isFalse,
        );

        final updated = await harness.deckRepository.getDeckActionContext(
          deck.id,
        );
        expect(updated.deck.name, 'Core vocabulary updated');
      },
    );

    test(
      'DT1 onRefreshRetry: flashcard editor save-and-add-next refreshes the list and clears draft',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: ['folder-root', 'deck-root', 'flashcard-001'],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Japanese N5',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: root.id,
          name: 'Core vocabulary',
        )).valueOrNull!;

        final args = FlashcardEditorArgs(deckId: deck.id);
        final listSubscription = container.listen(
          flashcardListQueryProvider(deck.id),
          (_, _) {},
          fireImmediately: true,
        );

        expect(
          (await container.read(
            flashcardListQueryProvider(deck.id).future,
          )).items,
          isEmpty,
        );
        await container.read(flashcardEditorDraftProvider(args).future);

        final draftNotifier = container.read(
          flashcardEditorDraftProvider(args).notifier,
        );
        draftNotifier.setFront('Hello');
        draftNotifier.setBack('Xin chao');
        draftNotifier.setNote('Basic greeting');

        final success = await container
            .read(flashcardEditorControllerProvider(args).notifier)
            .save(keepCreating: true);

        expect(success, isTrue);
        await _flush(container);

        expect(listSubscription.read().requireValue.items, hasLength(1));
        expect(listSubscription.read().requireValue.items.first.front, 'Hello');

        final clearedDraft = await container.read(
          flashcardEditorDraftProvider(args).future,
        );
        expect(clearedDraft.front, isEmpty);
        expect(clearedDraft.back, isEmpty);
        expect(clearedDraft.note, isEmpty);
      },
    );

    test(
      'DT1 onDelete: flashcard action controller deletes cards without provider error',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: ['folder-root', 'deck-root', 'flashcard-001'],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Japanese N5',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: root.id,
          name: 'Core vocabulary',
        )).valueOrNull!;
        final flashcard = (await harness.flashcardRepository.createFlashcard(
          deckId: deck.id,
          draft: const FlashcardDraft(front: 'Hello', back: 'Xin chao'),
        )).valueOrNull!;

        final success = await container
            .read(flashcardActionControllerProvider(deck.id).notifier)
            .deleteFlashcards([flashcard.id]);

        expect(success, isTrue);
        expect(
          container.read(flashcardActionControllerProvider(deck.id)).hasError,
          isFalse,
        );

        final list = await harness.flashcardRepository.getFlashcards(
          deck.id,
          const ContentQuery(),
        );
        expect(list.items, isEmpty);
      },
    );

    test(
      'DT2 onRefreshRetry: flashcard import preview surfaces issues, commit resets draft, and list refreshes',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: ['folder-root', 'deck-root', 'flashcard-001'],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Japanese N5',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: root.id,
          name: 'Core vocabulary',
        )).valueOrNull!;

        container.listen(
          flashcardListQueryProvider(deck.id),
          (_, _) {},
          fireImmediately: true,
        );
        final draftNotifier = container.read(
          flashcardImportDraftProvider(deck.id).notifier,
        );
        final controller = container.read(
          flashcardImportControllerProvider(deck.id).notifier,
        );

        draftNotifier.setFormat(ImportSourceFormat.csv);
        draftNotifier.setRawContent('front,back\nHello,');
        final invalidPreparation = await controller.preparePreview();

        expect(invalidPreparation, isNotNull);
        expect(invalidPreparation!.issues, hasLength(1));
        expect(invalidPreparation.canCommit, isFalse);

        draftNotifier.setRawContent('front,back\nHello,Xin chao');
        final validPreparation = await controller.preparePreview();

        expect(validPreparation, isNotNull);
        expect(validPreparation!.canCommit, isTrue);

        final count = await controller.commitImport();

        expect(count, 1);
        await _flush(container);
        final refreshedList = await container.read(
          flashcardListQueryProvider(deck.id).future,
        );

        expect(refreshedList.items, hasLength(1));
        expect(refreshedList.items.first.front, 'Hello');

        final resetDraft = container.read(
          flashcardImportDraftProvider(deck.id),
        );
        expect(resetDraft.rawContent, isEmpty);
        expect(resetDraft.preparation, isNull);
      },
    );
  });
}

ProviderContainer _createContainer(ContentRepositoryHarness harness) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(harness.database),
      clockProvider.overrideWithValue(harness.clock),
      idGeneratorProvider.overrideWithValue(harness.idGenerator),
    ],
  );
}

Future<void> _flush(ProviderContainer container) async {
  await Future<void>.delayed(Duration.zero);
  await container.pump();
}

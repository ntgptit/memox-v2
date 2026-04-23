import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_import_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';

import '../support/content_repository_harness.dart';

void main() {
  group('content viewmodels', () {
    test('library overview query refreshes after creating a folder', () async {
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
    });

    test('folder detail query refreshes after creating a subfolder', () async {
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
      expect(state.subfolders.map((item) => item.name), contains('Vocabulary'));
    });

    test(
      'folder detail query exposes subtree deck and card stats for subfolders',
      () async {
        final harness = ContentRepositoryHarness.create(
          ids: [
            'folder-root',
            'folder-child',
            'deck-child',
            'flashcard-001',
            'flashcard-002',
          ],
        );
        final container = _createContainer(harness);
        addTearDown(container.dispose);
        addTearDown(harness.dispose);

        final root = (await harness.folderRepository.createRootFolder(
          'Korean',
        )).valueOrNull!;
        final child = (await harness.folderRepository.createSubfolder(
          parentFolderId: root.id,
          name: 'Topik I',
        )).valueOrNull!;
        final deck = (await harness.deckRepository.createDeck(
          folderId: child.id,
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
        expect(subfolder.deckCount, 1);
        expect(subfolder.itemCount, 2);
      },
    );

    test(
      'flashcard editor save-and-add-next refreshes the list and clears draft',
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
        draftNotifier.setTitle('Greeting');
        draftNotifier.setFront('Hello');
        draftNotifier.setBack('Xin chao');
        draftNotifier.setNote('Basic greeting');

        final success = await container
            .read(flashcardEditorControllerProvider(args).notifier)
            .save(keepCreating: true);

        expect(success, isTrue);
        await _flush(container);

        expect(listSubscription.read().requireValue.items, hasLength(1));
        expect(
          listSubscription.read().requireValue.items.first.title,
          'Greeting',
        );

        final clearedDraft = await container.read(
          flashcardEditorDraftProvider(args).future,
        );
        expect(clearedDraft.title, isEmpty);
        expect(clearedDraft.front, isEmpty);
        expect(clearedDraft.back, isEmpty);
        expect(clearedDraft.note, isEmpty);
      },
    );

    test(
      'flashcard import preview surfaces issues, commit resets draft, and list refreshes',
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

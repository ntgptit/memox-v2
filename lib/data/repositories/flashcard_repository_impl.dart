import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/enums/content_sort_mode.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/value_objects/content_actions.dart';
import '../../domain/value_objects/content_queries.dart';
import '../../domain/value_objects/content_read_models.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/deck_dao.dart';
import '../datasources/local/daos/flashcard_dao.dart';
import '../datasources/local/daos/folder_dao.dart';
import '../datasources/local/local_transaction_runner.dart';
import '../mappers/content_entity_mappers.dart';
import 'flashcard_import_support.dart';
import 'repository_support.dart';

final class FlashcardRepositoryImpl implements FlashcardRepository {
  const FlashcardRepositoryImpl({
    required FlashcardDao flashcardDao,
    required DeckDao deckDao,
    required FolderDao folderDao,
    required LocalTransactionRunner transactionRunner,
    required Clock clock,
    required IdGenerator idGenerator,
  }) : _flashcardDao = flashcardDao,
       _deckDao = deckDao,
       _folderDao = folderDao,
       _transactionRunner = transactionRunner,
       _clock = clock,
       _idGenerator = idGenerator;

  final FlashcardDao _flashcardDao;
  final DeckDao _deckDao;
  final FolderDao _folderDao;
  final LocalTransactionRunner _transactionRunner;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<FlashcardEntity> getFlashcard(String flashcardId) async {
    return (await _requireFlashcard(flashcardId)).toDomain();
  }

  @override
  Future<FlashcardListReadModel> getFlashcards(
    String deckId,
    ContentQuery query,
  ) async {
    final deck = await _requireDeck(deckId);
    final folderBreadcrumb = await _folderDao.getBreadcrumbSegments(
      deck.folderId,
    );
    final flashcards = await _flashcardDao.listFlashcardsInDeck(
      deckId: deckId,
      query: query,
    );
    final lastStudiedMap = await _flashcardDao.getLastStudiedMap(
      flashcards.map((item) => item.id).toList(growable: false),
    );
    final items = flashcards
        .map(
          (flashcard) => FlashcardListItemReadModel(
            flashcard: flashcard.toDomain(),
            lastStudiedAt: lastStudiedMap[flashcard.id],
          ),
        )
        .toList(growable: false);
    _sortFlashcardItems(items, query.sortMode);
    return FlashcardListReadModel(
      deck: deck.toDomain(),
      breadcrumb: [
        ...folderBreadcrumb,
        BreadcrumbSegmentReadModel(label: deck.name),
      ],
      items: items,
    );
  }

  @override
  Future<List<DeckMoveTarget>> getFlashcardMoveTargets({
    required String deckId,
    required List<String> flashcardIds,
  }) async {
    final targets = <DeckMoveTarget>[];
    for (final deck in await _deckDao.listAllDecks()) {
      if (deck.id == deckId) {
        continue;
      }
      final breadcrumb = await _folderDao.getBreadcrumbNames(deck.folderId);
      targets.add(
        DeckMoveTarget(
          id: deck.id,
          name: deck.name,
          breadcrumb: [...breadcrumb, deck.name],
        ),
      );
    }
    return targets;
  }

  @override
  Future<Result<FlashcardEntity>> createFlashcard({
    required String deckId,
    required FlashcardDraft draft,
  }) {
    return runRepositoryAction(() async {
      await _requireDeck(deckId);
      final now = _clock.nowEpochMillis();
      final sortOrder = await _flashcardDao.nextSortOrder(deckId);
      final id = _idGenerator.nextId();
      await _transactionRunner.write((_) {
        return _flashcardDao.insertFlashcard(
          id: id,
          deckId: deckId,
          draft: _normalizeDraft(draft),
          sortOrder: sortOrder,
          createdAt: now,
          updatedAt: now,
        );
      });
      return FlashcardEntity(
        id: id,
        deckId: deckId,
        front: draft.front.trim(),
        back: draft.back.trim(),
        note: draft.note?.trim(),
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<FlashcardEntity>> updateFlashcard({
    required String flashcardId,
    required FlashcardDraft draft,
  }) {
    return runRepositoryAction(() async {
      final flashcard = await _requireFlashcard(flashcardId);
      final normalized = _normalizeDraft(draft);
      final now = _clock.nowEpochMillis();
      await _flashcardDao.updateFlashcard(
        flashcardId: flashcardId,
        draft: normalized,
        updatedAt: now,
      );
      return FlashcardEntity(
        id: flashcard.id,
        deckId: flashcard.deckId,
        front: normalized.front.trim(),
        back: normalized.back.trim(),
        note: normalized.note?.trim(),
        sortOrder: flashcard.sortOrder,
        createdAt: flashcard.createdAt,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<void>> deleteFlashcards(List<String> flashcardIds) {
    return runRepositoryAction(() async {
      if (flashcardIds.isEmpty) {
        return;
      }
      await _transactionRunner.write((_) {
        return _flashcardDao.deleteFlashcards(flashcardIds);
      });
    });
  }

  @override
  Future<Result<void>> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
  }) {
    return runRepositoryAction(() async {
      if (flashcardIds.isEmpty) {
        return;
      }
      await _requireDeck(targetDeckId);
      final nextSortOrder = await _flashcardDao.nextSortOrder(targetDeckId);
      await _transactionRunner.write((_) {
        return _flashcardDao.moveFlashcards(
          flashcardIds: flashcardIds,
          targetDeckId: targetDeckId,
          startingSortOrder: nextSortOrder,
          updatedAt: _clock.nowEpochMillis(),
        );
      });
    });
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedFlashcardIds,
  }) {
    return runRepositoryAction(() async {
      await _flashcardDao.reorderFlashcards(
        deckId: deckId,
        orderedFlashcardIds: orderedFlashcardIds,
        updatedAt: _clock.nowEpochMillis(),
      );
    });
  }

  @override
  Future<Result<FlashcardImportPreparation>> prepareImport({
    required ImportSourceFormat format,
    required String rawContent,
  }) {
    return runRepositoryAction(() async {
      return FlashcardImportSupport.parse(
        format: format,
        rawContent: rawContent,
      );
    });
  }

  @override
  Future<Result<int>> commitImport({
    required String deckId,
    required FlashcardImportPreparation preparation,
  }) {
    return runRepositoryAction(() async {
      if (!preparation.canCommit) {
        throw const ValidationException(
          message: 'Import preparation contains validation issues.',
        );
      }
      await _requireDeck(deckId);
      final now = _clock.nowEpochMillis();
      await _transactionRunner.write((_) async {
        var nextSortOrder = await _flashcardDao.nextSortOrder(deckId);
        for (final item in preparation.previewItems) {
          await _flashcardDao.insertFlashcard(
            id: _idGenerator.nextId(),
            deckId: deckId,
            draft: item.draft,
            sortOrder: nextSortOrder,
            createdAt: now,
            updatedAt: now,
          );
          nextSortOrder += 1;
        }
      });
      return preparation.previewItems.length;
    });
  }

  @override
  Future<Result<ExportData>> exportFlashcards(List<String> flashcardIds) {
    return runRepositoryAction(() async {
      final flashcards = await _flashcardDao.listFlashcardsByIds(flashcardIds);
      final lines = <String>[
        'front,back,note',
        for (final flashcard in flashcards)
          [
            escapeCsvCell(flashcard.front),
            escapeCsvCell(flashcard.back),
            escapeCsvCell(flashcard.note),
          ].join(','),
      ];
      return ExportData(
        fileName: 'flashcards_export.csv',
        mimeType: 'text/csv',
        content: lines.join('\n'),
      );
    });
  }

  Future<Deck> _requireDeck(String deckId) async {
    final deck = await _deckDao.findById(deckId);
    if (deck == null) {
      throw const NotFoundException(message: 'Deck not found.');
    }
    return deck;
  }

  Future<Flashcard> _requireFlashcard(String flashcardId) async {
    final flashcard = await _flashcardDao.findById(flashcardId);
    if (flashcard == null) {
      throw const NotFoundException(message: 'Flashcard not found.');
    }
    return flashcard;
  }

  FlashcardDraft _normalizeDraft(FlashcardDraft draft) {
    final front = draft.front.trim();
    final back = draft.back.trim();
    if (front.isEmpty || back.isEmpty) {
      throw const ValidationException(message: 'front and back are required.');
    }
    return FlashcardDraft(front: front, back: back, note: draft.note?.trim());
  }

  void _sortFlashcardItems(
    List<FlashcardListItemReadModel> items,
    ContentSortMode sortMode,
  ) {
    switch (sortMode) {
      case ContentSortMode.manual:
        items.sort(
          (a, b) => a.flashcard.sortOrder.compareTo(b.flashcard.sortOrder),
        );
      case ContentSortMode.name:
        items.sort(
          (a, b) => a.flashcard.displayName.toLowerCase().compareTo(
            b.flashcard.displayName.toLowerCase(),
          ),
        );
      case ContentSortMode.newest:
        items.sort(
          (a, b) => b.flashcard.createdAt.compareTo(a.flashcard.createdAt),
        );
      case ContentSortMode.lastStudied:
        items.sort((a, b) {
          final left = a.lastStudiedAt;
          final right = b.lastStudiedAt;
          if (left == null && right == null) {
            return a.flashcard.sortOrder.compareTo(b.flashcard.sortOrder);
          }
          if (left == null) {
            return 1;
          }
          if (right == null) {
            return -1;
          }
          return right.compareTo(left);
        });
    }
  }
}

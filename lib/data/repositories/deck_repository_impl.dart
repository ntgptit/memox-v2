import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../domain/entities/deck_entity.dart';
import '../../domain/enums/content_sort_mode.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/services/folder_structure_service.dart';
import '../../domain/value_objects/content_actions.dart';
import '../../domain/value_objects/content_queries.dart';
import '../../domain/value_objects/content_read_models.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/deck_dao.dart';
import '../datasources/local/daos/flashcard_dao.dart';
import '../datasources/local/daos/folder_dao.dart';
import '../datasources/local/local_transaction_runner.dart';
import '../mappers/content_entity_mappers.dart';
import '../mappers/database_enum_codecs.dart';
import 'repository_support.dart';

final class DeckRepositoryImpl implements DeckRepository {
  const DeckRepositoryImpl({
    required DeckDao deckDao,
    required FlashcardDao flashcardDao,
    required FolderDao folderDao,
    required LocalTransactionRunner transactionRunner,
    required FolderStructureService structureService,
    required Clock clock,
    required IdGenerator idGenerator,
  }) : _deckDao = deckDao,
       _flashcardDao = flashcardDao,
       _folderDao = folderDao,
       _transactionRunner = transactionRunner,
       _structureService = structureService,
       _clock = clock,
       _idGenerator = idGenerator;

  final DeckDao _deckDao;
  final FlashcardDao _flashcardDao;
  final FolderDao _folderDao;
  final LocalTransactionRunner _transactionRunner;
  final FolderStructureService _structureService;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<DeckDetailReadModel> getDeckDetail(String deckId) async {
    final deck = await _requireDeck(deckId);
    final folderBreadcrumb = await _folderDao.getBreadcrumbSegments(
      deck.folderId,
    );
    return DeckDetailReadModel(
      deck: deck.toDomain(),
      breadcrumb: [
        ...folderBreadcrumb,
        BreadcrumbSegmentReadModel(label: deck.name),
      ],
      cardCount: await _deckDao.countFlashcardsInDeck(deck.id),
      dueTodayCount: await _deckDao.countDueTodayInDeck(
        deckId: deck.id,
        endOfTodayEpochMillis: endOfTodayEpochMillis(_clock),
      ),
      masteryPercent: computeMasteryPercent(
        await _deckDao.getCurrentBoxesInDeck(deck.id),
      ),
      lastStudiedAt: await _deckDao.getLastStudiedAtInDeck(deck.id),
    );
  }

  @override
  Future<List<FolderDeckReadModel>> getDecksInFolder(
    String folderId,
    ContentQuery query,
  ) async {
    final decks = await _deckDao.listDecksInFolder(
      folderId: folderId,
      query: query,
    );
    final items = <FolderDeckReadModel>[];
    for (final deck in decks) {
      items.add(
        FolderDeckReadModel(
          deck: deck.toDomain(),
          cardCount: await _deckDao.countFlashcardsInDeck(deck.id),
          dueTodayCount: await _deckDao.countDueTodayInDeck(
            deckId: deck.id,
            endOfTodayEpochMillis: endOfTodayEpochMillis(_clock),
          ),
          masteryPercent: computeMasteryPercent(
            await _deckDao.getCurrentBoxesInDeck(deck.id),
          ),
          lastStudiedAt: await _deckDao.getLastStudiedAtInDeck(deck.id),
        ),
      );
    }
    _sortDeckReadModels(items, query.sortMode);
    return items;
  }

  @override
  Future<List<DeckMoveTarget>> getDeckMoveTargets({
    required String deckId,
    String? excludingFolderId,
  }) async {
    final targets = <DeckMoveTarget>[];
    for (final folder in await _folderDao.listAllFolders()) {
      if (folder.id == excludingFolderId) {
        continue;
      }
      try {
        _structureService.validateDeckMove(
          DatabaseEnumCodecs.folderContentModeFromStorage(folder.contentMode),
        );
      } on ValidationException {
        continue;
      }
      targets.add(
        DeckMoveTarget(
          id: folder.id,
          name: folder.name,
          breadcrumb: await _folderDao.getBreadcrumbNames(folder.id),
        ),
      );
    }
    return targets;
  }

  @override
  Future<Result<DeckEntity>> createDeck({
    required String folderId,
    required String name,
  }) {
    return runRepositoryAction(() async {
      final trimmedName = _normalizeName(name);
      final parentFolder = await _requireFolder(folderId);
      final targetMode = _structureService.resolveModeAfterAddingDeck(
        DatabaseEnumCodecs.folderContentModeFromStorage(
          parentFolder.contentMode,
        ),
      );
      final now = _clock.nowEpochMillis();
      final id = _idGenerator.nextId();
      final sortOrder = await _deckDao.nextSortOrder(folderId);
      await _transactionRunner.write((_) async {
        await _folderDao.updateFolderMode(
          folderId: folderId,
          contentMode: targetMode,
          updatedAt: now,
        );
        await _deckDao.insertDeck(
          id: id,
          folderId: folderId,
          name: trimmedName,
          sortOrder: sortOrder,
          createdAt: now,
          updatedAt: now,
        );
      });
      return DeckEntity(
        id: id,
        folderId: folderId,
        name: trimmedName,
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<DeckEntity>> updateDeck({
    required String deckId,
    required String name,
  }) {
    return runRepositoryAction(() async {
      final deck = await _requireDeck(deckId);
      final trimmedName = _normalizeName(name);
      final now = _clock.nowEpochMillis();
      await _deckDao.updateDeckName(
        deckId: deckId,
        name: trimmedName,
        updatedAt: now,
      );
      return DeckEntity(
        id: deck.id,
        folderId: deck.folderId,
        name: trimmedName,
        sortOrder: deck.sortOrder,
        createdAt: deck.createdAt,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<void>> deleteDeck(String deckId) {
    return runRepositoryAction(() async {
      final deck = await _requireDeck(deckId);
      final now = _clock.nowEpochMillis();
      await _transactionRunner.write((_) async {
        await _deckDao.deleteDeck(deckId);
        await _syncFolderMode(deck.folderId, updatedAt: now);
      });
    });
  }

  @override
  Future<Result<void>> moveDeck({
    required String deckId,
    required String targetFolderId,
  }) {
    return runRepositoryAction(() async {
      final deck = await _requireDeck(deckId);
      final targetFolder = await _requireFolder(targetFolderId);
      final targetMode = DatabaseEnumCodecs.folderContentModeFromStorage(
        targetFolder.contentMode,
      );
      _structureService.validateDeckMove(targetMode);
      final now = _clock.nowEpochMillis();
      final targetSortOrder = await _deckDao.nextSortOrder(targetFolderId);
      await _transactionRunner.write((_) async {
        final nextMode = _structureService.resolveModeAfterAddingDeck(
          targetMode,
        );
        await _folderDao.updateFolderMode(
          folderId: targetFolderId,
          contentMode: nextMode,
          updatedAt: now,
        );
        await _deckDao.updateDeckFolder(
          deckId: deckId,
          folderId: targetFolderId,
          sortOrder: targetSortOrder,
          updatedAt: now,
        );
        await _syncFolderMode(deck.folderId, updatedAt: now);
      });
    });
  }

  @override
  Future<Result<void>> reorderDecks({
    required String folderId,
    required List<String> orderedDeckIds,
  }) {
    return runRepositoryAction(() async {
      await _deckDao.reorderDecks(
        folderId: folderId,
        orderedDeckIds: orderedDeckIds,
        updatedAt: _clock.nowEpochMillis(),
      );
    });
  }

  @override
  Future<Result<DeckEntity>> duplicateDeck({
    required String deckId,
    required String targetFolderId,
  }) {
    return runRepositoryAction(() async {
      final sourceDeck = await _requireDeck(deckId);
      final targetFolder = await _requireFolder(targetFolderId);
      final targetMode = DatabaseEnumCodecs.folderContentModeFromStorage(
        targetFolder.contentMode,
      );
      _structureService.validateDeckMove(targetMode);
      final now = _clock.nowEpochMillis();
      final newDeckId = _idGenerator.nextId();
      final newDeckName = '${sourceDeck.name} Copy';
      final sortOrder = await _deckDao.nextSortOrder(targetFolderId);
      final sourceFlashcards = await _deckDao.listDeckFlashcards(deckId);
      await _transactionRunner.write((_) async {
        final nextMode = _structureService.resolveModeAfterAddingDeck(
          targetMode,
        );
        await _folderDao.updateFolderMode(
          folderId: targetFolderId,
          contentMode: nextMode,
          updatedAt: now,
        );
        await _deckDao.insertDeck(
          id: newDeckId,
          folderId: targetFolderId,
          name: newDeckName,
          sortOrder: sortOrder,
          createdAt: now,
          updatedAt: now,
        );
        for (var index = 0; index < sourceFlashcards.length; index++) {
          await _flashcardDao.insertFlashcard(
            id: _idGenerator.nextId(),
            deckId: newDeckId,
            draft: FlashcardDraft(
              title: sourceFlashcards[index].title,
              front: sourceFlashcards[index].front,
              back: sourceFlashcards[index].back,
              note: sourceFlashcards[index].note,
            ),
            sortOrder: index,
            createdAt: now,
            updatedAt: now,
          );
        }
      });
      return DeckEntity(
        id: newDeckId,
        folderId: targetFolderId,
        name: newDeckName,
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<ExportData>> exportDeck(String deckId) {
    return runRepositoryAction(() async {
      final deck = await _requireDeck(deckId);
      final flashcards = await _deckDao.listDeckFlashcards(deckId);
      final lines = <String>[
        'title,front,back,note',
        for (final flashcard in flashcards)
          [
            escapeCsvCell(flashcard.title),
            escapeCsvCell(flashcard.front),
            escapeCsvCell(flashcard.back),
            escapeCsvCell(flashcard.note),
          ].join(','),
      ];
      return ExportData(
        fileName: '${sanitizeFileName(deck.name)}.csv',
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

  Future<Folder> _requireFolder(String folderId) async {
    final folder = await _folderDao.findById(folderId);
    if (folder == null) {
      throw const NotFoundException(message: 'Folder not found.');
    }
    return folder;
  }

  Future<void> _syncFolderMode(
    String folderId, {
    required int updatedAt,
  }) async {
    final resolvedMode = _structureService.resolveModeAfterChildrenChanged(
      hasSubfolders: await _folderDao.hasSubfolders(folderId),
      hasDecks: await _folderDao.hasDecks(folderId),
    );
    await _folderDao.updateFolderMode(
      folderId: folderId,
      contentMode: resolvedMode,
      updatedAt: updatedAt,
    );
  }

  String _normalizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(message: 'The name is required.');
    }
    return trimmed;
  }

  void _sortDeckReadModels(
    List<FolderDeckReadModel> items,
    ContentSortMode sortMode,
  ) {
    switch (sortMode) {
      case ContentSortMode.manual:
        items.sort((a, b) => a.deck.sortOrder.compareTo(b.deck.sortOrder));
      case ContentSortMode.name:
        items.sort(
          (a, b) =>
              a.deck.name.toLowerCase().compareTo(b.deck.name.toLowerCase()),
        );
      case ContentSortMode.newest:
        items.sort((a, b) => b.deck.createdAt.compareTo(a.deck.createdAt));
      case ContentSortMode.lastStudied:
        items.sort((a, b) {
          final left = a.lastStudiedAt;
          final right = b.lastStudiedAt;
          if (left == null && right == null) {
            return a.deck.sortOrder.compareTo(b.deck.sortOrder);
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

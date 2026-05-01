import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/enums/content_sort_mode.dart';
import '../../domain/enums/folder_content_mode.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/services/folder_structure_service.dart';
import '../../domain/value_objects/content_actions.dart';
import '../../domain/value_objects/content_queries.dart';
import '../../domain/value_objects/content_read_models.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/deck_dao.dart';
import '../datasources/local/daos/folder_dao.dart';
import '../datasources/local/local_transaction_runner.dart';
import '../mappers/content_entity_mappers.dart';
import '../mappers/database_enum_codecs.dart';
import 'repository_support.dart';

final class FolderRepositoryImpl implements FolderRepository {
  const FolderRepositoryImpl({
    required FolderDao folderDao,
    required DeckDao deckDao,
    required LocalTransactionRunner transactionRunner,
    required FolderStructureService structureService,
    required Clock clock,
    required IdGenerator idGenerator,
  }) : _folderDao = folderDao,
       _deckDao = deckDao,
       _transactionRunner = transactionRunner,
       _structureService = structureService,
       _clock = clock,
       _idGenerator = idGenerator;

  final FolderDao _folderDao;
  final DeckDao _deckDao;
  final LocalTransactionRunner _transactionRunner;
  final FolderStructureService _structureService;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<LibraryOverviewReadModel> getLibraryOverview(
    ContentQuery query,
  ) async {
    final folders = query.hasSearchTerm
        ? (await _folderDao.listAllFolders())
              .where(
                (folder) => StringUtils.containsNormalized(
                  folder.name,
                  query.normalizedSearchTerm,
                ),
              )
              .toList(growable: false)
        : await _folderDao.listRootFolders(query);
    final folderItems = <LibraryFolderReadModel>[];
    final startOfToday = startOfTodayEpochMillis(_clock);
    final endOfToday = endOfTodayEpochMillis(_clock);
    for (final folder in folders) {
      final subfolderCount = await _folderDao.countSubfoldersInSubtree(
        folder.id,
      );
      final deckCount = await _folderDao.countDecksInSubtree(folder.id);
      final itemCount = await _folderDao.countFlashcardsInSubtree(folder.id);
      final dueCardCount = await _folderDao.countDueCardsInSubtree(
        folderId: folder.id,
        endOfTodayEpochMillis: endOfToday,
      );
      final newCardCount = await _folderDao.countNewFlashcardsInSubtree(
        folder.id,
      );
      final lastStudiedAt = await _folderDao.getLastStudiedAtInSubtree(
        folder.id,
      );
      final masteryPercent = computeMasteryPercent(
        await _folderDao.getCurrentBoxesInSubtree(folder.id),
      );
      folderItems.add(
        LibraryFolderReadModel(
          folder: folder.toDomain(),
          breadcrumb: await _folderDao.getBreadcrumbNames(folder.id),
          subfolderCount: subfolderCount,
          deckCount: deckCount,
          itemCount: itemCount,
          dueCardCount: dueCardCount,
          newCardCount: newCardCount,
          masteryPercent: masteryPercent,
          lastStudiedAt: lastStudiedAt,
        ),
      );
    }
    _sortLibraryFolders(folderItems, query.sortMode);

    return LibraryOverviewReadModel(
      overdueCount: await _folderDao.countOverdue(startOfToday),
      dueTodayCount: await _folderDao.countDueToday(
        startOfTodayEpochMillis: startOfToday,
        endOfTodayEpochMillis: endOfToday,
      ),
      newCardCount: await _folderDao.countNewFlashcards(),
      totalFolderCount: await _folderDao.countAllFolders(),
      folders: folderItems,
    );
  }

  @override
  Future<FolderDetailReadModel> getFolderDetail(
    String folderId,
    ContentQuery query,
  ) async {
    final folder = await _requireFolder(folderId);
    final subfolders = await _folderDao.listSubfolders(
      parentFolderId: folderId,
      query: query,
    );
    final decks = await _deckDao.listDecksInFolder(
      folderId: folderId,
      query: query,
    );
    final deckItems = <FolderDeckReadModel>[];
    for (final deck in decks) {
      deckItems.add(await _buildFolderDeckReadModel(deck));
    }

    final subfolderEntities = subfolders
        .map((item) => item.toDomain())
        .toList(growable: false);
    switch (query.sortMode) {
      case ContentSortMode.lastStudied:
        final lastStudiedMap = <String, int?>{};
        for (final subfolder in subfolders) {
          lastStudiedMap[subfolder.id] = await _folderDao
              .getLastStudiedAtInSubtree(subfolder.id);
        }
        subfolderEntities.sort((FolderEntity a, FolderEntity b) {
          final left = lastStudiedMap[a.id];
          final right = lastStudiedMap[b.id];
          if (left == null && right == null) {
            return a.sortOrder.compareTo(b.sortOrder);
          }
          if (left == null) {
            return 1;
          }
          if (right == null) {
            return -1;
          }
          return right.compareTo(left);
        });
        _sortFolderDeckItems(deckItems, query.sortMode);
      case ContentSortMode.name:
        subfolderEntities.sort(
          (a, b) => StringUtils.compareNormalized(a.name, b.name),
        );
        _sortFolderDeckItems(deckItems, query.sortMode);
      case ContentSortMode.newest:
        subfolderEntities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _sortFolderDeckItems(deckItems, query.sortMode);
      case ContentSortMode.manual:
        subfolderEntities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _sortFolderDeckItems(deckItems, query.sortMode);
    }

    final subfolderItems = <FolderSubfolderReadModel>[];
    for (final subfolder in subfolderEntities) {
      subfolderItems.add(
        FolderSubfolderReadModel(
          folder: subfolder,
          subfolderCount: await _folderDao.countSubfoldersInSubtree(
            subfolder.id,
          ),
          deckCount: await _folderDao.countDecksInSubtree(subfolder.id),
          itemCount: await _folderDao.countFlashcardsInSubtree(subfolder.id),
          dueCardCount: await _folderDao.countDueCardsInSubtree(
            folderId: subfolder.id,
            endOfTodayEpochMillis: endOfTodayEpochMillis(_clock),
          ),
          masteryPercent: computeMasteryPercent(
            await _folderDao.getCurrentBoxesInSubtree(subfolder.id),
          ),
        ),
      );
    }

    return FolderDetailReadModel(
      folder: folder.toDomain(),
      breadcrumb: await _folderDao.getBreadcrumbSegments(folderId),
      subfolders: subfolderItems,
      decks: deckItems,
    );
  }

  @override
  Future<List<FolderMoveTarget>> getFolderMoveTargets(String folderId) async {
    final descendants = await _folderDao.getDescendantIds(folderId);
    final candidates = <FolderMoveTarget>[
      const FolderMoveTarget(
        id: null,
        name: '',
        breadcrumb: <String>[],
        isRoot: true,
      ),
    ];
    for (final folder in await _folderDao.listAllFolders()) {
      if (folder.id == folderId) {
        continue;
      }
      try {
        _structureService.validateFolderMove(
          folderId: folderId,
          targetParentId: folder.id,
          descendantIds: descendants,
          targetParentMode: DatabaseEnumCodecs.folderContentModeFromStorage(
            folder.contentMode,
          ),
        );
      } on ValidationException {
        continue;
      }
      candidates.add(
        FolderMoveTarget(
          id: folder.id,
          name: folder.name,
          breadcrumb: await _folderDao.getBreadcrumbNames(folder.id),
          isRoot: false,
        ),
      );
    }
    return candidates;
  }

  @override
  Future<Result<FolderEntity>> createRootFolder(String name) {
    return runRepositoryAction(() async {
      final trimmedName = _normalizeName(name);
      final now = _clock.nowEpochMillis();
      final id = _idGenerator.nextId();
      final sortOrder = await _folderDao.nextSortOrder(null);
      await _transactionRunner.write((_) {
        return _folderDao.insertFolder(
          id: id,
          parentId: null,
          name: trimmedName,
          contentMode: FolderContentMode.unlocked,
          sortOrder: sortOrder,
          createdAt: now,
          updatedAt: now,
        );
      });
      return FolderEntity(
        id: id,
        parentId: null,
        name: trimmedName,
        contentMode: FolderContentMode.unlocked,
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<FolderEntity>> createSubfolder({
    required String parentFolderId,
    required String name,
  }) {
    return runRepositoryAction(() async {
      final trimmedName = _normalizeName(name);
      final parent = await _requireFolder(parentFolderId);
      final nextMode = _structureService.resolveModeAfterAddingSubfolder(
        DatabaseEnumCodecs.folderContentModeFromStorage(parent.contentMode),
      );
      final now = _clock.nowEpochMillis();
      final id = _idGenerator.nextId();
      final sortOrder = await _folderDao.nextSortOrder(parentFolderId);
      await _transactionRunner.write((_) async {
        await _folderDao.updateFolderMode(
          folderId: parentFolderId,
          contentMode: nextMode,
          updatedAt: now,
        );
        await _folderDao.insertFolder(
          id: id,
          parentId: parentFolderId,
          name: trimmedName,
          contentMode: FolderContentMode.unlocked,
          sortOrder: sortOrder,
          createdAt: now,
          updatedAt: now,
        );
      });
      return FolderEntity(
        id: id,
        parentId: parentFolderId,
        name: trimmedName,
        contentMode: FolderContentMode.unlocked,
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<FolderEntity>> updateFolder({
    required String folderId,
    required String name,
  }) {
    return runRepositoryAction(() async {
      final existing = await _requireFolder(folderId);
      final trimmedName = _normalizeName(name);
      final now = _clock.nowEpochMillis();
      await _folderDao.updateFolderName(
        folderId: folderId,
        name: trimmedName,
        updatedAt: now,
      );
      return FolderEntity(
        id: existing.id,
        parentId: existing.parentId,
        name: trimmedName,
        contentMode: DatabaseEnumCodecs.folderContentModeFromStorage(
          existing.contentMode,
        ),
        sortOrder: existing.sortOrder,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Result<void>> deleteFolder(String folderId) {
    return runRepositoryAction(() async {
      final folder = await _requireFolder(folderId);
      final now = _clock.nowEpochMillis();
      await _transactionRunner.write((_) async {
        await _folderDao.deleteFolder(folderId);
        if (folder.parentId != null) {
          await _syncFolderMode(folder.parentId!, updatedAt: now);
        }
      });
    });
  }

  @override
  Future<Result<void>> moveFolder({
    required String folderId,
    required String? targetParentId,
  }) {
    return runRepositoryAction(() async {
      final folder = await _requireFolder(folderId);
      final descendants = await _folderDao.getDescendantIds(folderId);
      final now = _clock.nowEpochMillis();
      FolderContentMode targetMode = FolderContentMode.unlocked;
      if (targetParentId != null) {
        final targetFolder = await _requireFolder(targetParentId);
        targetMode = DatabaseEnumCodecs.folderContentModeFromStorage(
          targetFolder.contentMode,
        );
      }
      _structureService.validateFolderMove(
        folderId: folderId,
        targetParentId: targetParentId,
        descendantIds: descendants,
        targetParentMode: targetMode,
      );
      final targetSortOrder = await _folderDao.nextSortOrder(targetParentId);
      await _transactionRunner.write((_) async {
        if (targetParentId != null) {
          final nextMode = _structureService.resolveModeAfterAddingSubfolder(
            targetMode,
          );
          await _folderDao.updateFolderMode(
            folderId: targetParentId,
            contentMode: nextMode,
            updatedAt: now,
          );
        }
        await _folderDao.updateFolderParent(
          folderId: folderId,
          parentId: targetParentId,
          sortOrder: targetSortOrder,
          updatedAt: now,
        );
        if (folder.parentId != null) {
          await _syncFolderMode(folder.parentId!, updatedAt: now);
        }
      });
    });
  }

  @override
  Future<Result<void>> reorderFolders({
    required String? parentFolderId,
    required List<String> orderedFolderIds,
  }) {
    return runRepositoryAction(() async {
      final now = _clock.nowEpochMillis();
      await _folderDao.reorderFolders(
        parentFolderId: parentFolderId,
        orderedFolderIds: orderedFolderIds,
        updatedAt: now,
      );
    });
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

  Future<Folder> _requireFolder(String folderId) async {
    final folder = await _folderDao.findById(folderId);
    if (folder == null) {
      throw const NotFoundException(message: 'Folder not found.');
    }
    return folder;
  }

  Future<FolderDeckReadModel> _buildFolderDeckReadModel(Deck deck) async {
    return FolderDeckReadModel(
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
    );
  }

  String _normalizeName(String name) {
    final trimmed = StringUtils.trimmed(name);
    if (trimmed.isEmpty) {
      throw const ValidationException(message: 'The name is required.');
    }
    return trimmed;
  }

  void _sortLibraryFolders(
    List<LibraryFolderReadModel> folders,
    ContentSortMode sortMode,
  ) {
    switch (sortMode) {
      case ContentSortMode.manual:
        folders.sort(
          (a, b) => a.folder.sortOrder.compareTo(b.folder.sortOrder),
        );
      case ContentSortMode.name:
        folders.sort(
          (a, b) => StringUtils.compareNormalized(a.folder.name, b.folder.name),
        );
      case ContentSortMode.newest:
        folders.sort(
          (a, b) => b.folder.createdAt.compareTo(a.folder.createdAt),
        );
      case ContentSortMode.lastStudied:
        folders.sort((a, b) {
          final left = a.lastStudiedAt;
          final right = b.lastStudiedAt;
          if (left == null && right == null) {
            return a.folder.sortOrder.compareTo(b.folder.sortOrder);
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

  void _sortFolderDeckItems(
    List<FolderDeckReadModel> decks,
    ContentSortMode sortMode,
  ) {
    switch (sortMode) {
      case ContentSortMode.manual:
        decks.sort((a, b) => a.deck.sortOrder.compareTo(b.deck.sortOrder));
      case ContentSortMode.name:
        decks.sort(
          (a, b) => StringUtils.compareNormalized(a.deck.name, b.deck.name),
        );
      case ContentSortMode.newest:
        decks.sort((a, b) => b.deck.createdAt.compareTo(a.deck.createdAt));
      case ContentSortMode.lastStudied:
        decks.sort((a, b) {
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/enums/folder_content_mode.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../../domain/value_objects/content_read_models.dart';

part 'folder_detail_viewmodel.g.dart';

enum FolderDetailMode { unlocked, subfolders, decks }

@immutable
class FolderDetailHeader {
  const FolderDetailHeader({
    required this.id,
    required this.name,
    required this.breadcrumb,
  });

  final String id;
  final String name;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
}

@immutable
class FolderSubfolderItem {
  const FolderSubfolderItem({
    required this.id,
    required this.name,
    required this.icon,
    required int deckCount,
    required int itemCount,
    required int? masteryPercent,
  }) : _deckCount = deckCount,
       _itemCount = itemCount,
       _masteryPercent = masteryPercent;

  final String id;
  final String name;
  final IconData icon;
  final int? _masteryPercent;
  final int? _deckCount;
  final int? _itemCount;

  int get deckCount => _deckCount ?? 0;
  int get itemCount => _itemCount ?? 0;
  int get masteryPercent => _masteryPercent ?? 0;
}

@immutable
class FolderDeckItem {
  const FolderDeckItem({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.dueToday,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final String id;
  final String name;
  final int cardCount;
  final int dueToday;
  final int masteryPercent;
  final int? lastStudiedAt;
}

@immutable
class FolderDetailState {
  const FolderDetailState({
    required this.header,
    required this.mode,
    required this.sortMode,
    required this.searchTerm,
    required this.subfolders,
    required this.decks,
  });

  final FolderDetailHeader header;
  final FolderDetailMode mode;
  final ContentSortMode sortMode;
  final String searchTerm;
  final List<FolderSubfolderItem> subfolders;
  final List<FolderDeckItem> decks;

  bool get isUnlocked => mode == FolderDetailMode.unlocked;
  bool get isSubfolderMode => mode == FolderDetailMode.subfolders;
  bool get isDeckMode => mode == FolderDetailMode.decks;
  bool get canManualReorder => sortMode.allowsManualReorder;
}

@riverpod
class FolderChildrenToolbarState extends _$FolderChildrenToolbarState {
  @override
  ContentQuery build(String folderId) => const ContentQuery();

  void setSearchTerm(String value) {
    final next = StringUtils.trimmed(value);
    if (next == state.searchTerm) {
      return;
    }
    state = ContentQuery(searchTerm: next, sortMode: state.sortMode);
  }

  void setSortMode(ContentSortMode sortMode) {
    if (sortMode == state.sortMode) {
      return;
    }
    state = ContentQuery(searchTerm: state.searchTerm, sortMode: sortMode);
  }
}

@Riverpod(keepAlive: true)
Future<FolderDetailState> folderDetailQuery(Ref ref, String folderId) async {
  final query = ref.watch(folderChildrenToolbarStateProvider(folderId));
  final useCase = ref.watch(watchFolderDetailUseCaseProvider);
  ref.watch(contentDataRevisionProvider);

  final data = await useCase.execute(folderId, query);
  return _mapFolderDetailState(data, query);
}

@riverpod
Future<List<FolderMoveTarget>> folderMovePicker(Ref ref, String folderId) {
  return ref.watch(getFolderMoveTargetsUseCaseProvider).execute(folderId);
}

@riverpod
class FolderActionController extends _$FolderActionController {
  @override
  FutureOr<void> build(String folderId) {}

  Future<bool> createSubfolder(String name) async {
    // guard:retry-reviewed
    state = const AsyncLoading<void>();
    final result = await ref
        .read(createFolderUseCaseProvider)
        .createSubfolder(parentFolderId: folderId, name: name);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> createDeck(String name) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(createDeckUseCaseProvider)
        .execute(folderId: folderId, name: name);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> updateFolder(String name) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(updateFolderUseCaseProvider)
        .execute(folderId: folderId, name: name);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> deleteFolder() async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(deleteFolderUseCaseProvider)
        .execute(folderId);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> moveFolder(String? targetParentId) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(moveFolderUseCaseProvider)
        .execute(folderId: folderId, targetParentId: targetParentId);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> reorderSubfolders(List<String> orderedFolderIds) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(reorderFoldersUseCaseProvider)
        .execute(parentFolderId: folderId, orderedFolderIds: orderedFolderIds);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> reorderDecks(List<String> orderedDeckIds) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(reorderDecksUseCaseProvider)
        .execute(folderId: folderId, orderedDeckIds: orderedDeckIds);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }
}

FolderDetailState _mapFolderDetailState(
  FolderDetailReadModel readModel,
  ContentQuery query,
) {
  return FolderDetailState(
    header: FolderDetailHeader(
      id: readModel.folder.id,
      name: readModel.folder.name,
      breadcrumb: readModel.breadcrumb,
    ),
    mode: _toDetailMode(readModel.effectiveContentMode),
    sortMode: query.sortMode,
    searchTerm: query.searchTerm,
    subfolders: readModel.subfolders
        .map(
          (item) => FolderSubfolderItem(
            id: item.folder.id,
            name: item.folder.name,
            icon: Icons.folder_copy_outlined,
            deckCount: item.deckCount,
            itemCount: item.itemCount,
            masteryPercent: item.masteryPercent,
          ),
        )
        .toList(growable: false),
    decks: readModel.decks
        .map(
          (item) => FolderDeckItem(
            id: item.deck.id,
            name: item.deck.name,
            cardCount: item.cardCount,
            dueToday: item.dueTodayCount,
            masteryPercent: item.masteryPercent,
            lastStudiedAt: item.lastStudiedAt,
          ),
        )
        .toList(growable: false),
  );
}

FolderDetailMode _toDetailMode(FolderContentMode mode) {
  return switch (mode) {
    FolderContentMode.unlocked => FolderDetailMode.unlocked,
    FolderContentMode.subfolders => FolderDetailMode.subfolders,
    FolderContentMode.decks => FolderDetailMode.decks,
  };
}

AppFailure? folderActionError(AsyncValue<void> actionState) {
  return actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );
}

String folderActionErrorMessage(AppFailure? failure) {
  if (failure == null) {
    return '';
  }
  if (failure.cause case final ValidationException cause) {
    return cause.message;
  }
  return failure.message;
}

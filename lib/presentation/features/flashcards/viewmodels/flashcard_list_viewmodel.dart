import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../../domain/value_objects/content_read_models.dart';

part 'flashcard_list_viewmodel.g.dart';

@immutable
class FlashcardListItemState {
  const FlashcardListItemState({
    required this.id,
    required this.front,
    required this.back,
    required this.note,
    required this.lastStudiedAt,
  });

  final String id;
  final String front;
  final String back;
  final String? note;
  final int? lastStudiedAt;
}

@immutable
class FlashcardListState {
  const FlashcardListState({
    required this.deckId,
    required this.folderId,
    required this.deckName,
    required this.breadcrumb,
    required this.sortMode,
    required this.searchTerm,
    required this.items,
  });

  final String deckId;
  final String folderId;
  final String deckName;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
  final ContentSortMode sortMode;
  final String searchTerm;
  final List<FlashcardListItemState> items;

  bool get canManualReorder => sortMode.allowsManualReorder;
}

@riverpod
class FlashcardToolbarState extends _$FlashcardToolbarState {
  @override
  ContentQuery build(String deckId) => const ContentQuery();

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
Future<FlashcardListState> flashcardListQuery(Ref ref, String deckId) async {
  final query = ref.watch(flashcardToolbarStateProvider(deckId));
  final useCase = ref.watch(watchFlashcardListUseCaseProvider);
  ref.watch(contentDataRevisionProvider);

  final data = await useCase.execute(deckId, query);
  return FlashcardListState(
    deckId: data.deck.id,
    folderId: data.deck.folderId,
    deckName: data.deck.name,
    breadcrumb: data.breadcrumb,
    sortMode: query.sortMode,
    searchTerm: query.searchTerm,
    items: data.items
        .map(
          (item) => FlashcardListItemState(
            id: item.flashcard.id,
            front: item.flashcard.front,
            back: item.flashcard.back,
            note: item.flashcard.note,
            lastStudiedAt: item.lastStudiedAt,
          ),
        )
        .toList(growable: false),
  );
}

@riverpod
class FlashcardSelection extends _$FlashcardSelection {
  @override
  Set<String> build(String deckId) => <String>{};

  void toggle(String flashcardId) {
    if (state.contains(flashcardId)) {
      state = {...state}..remove(flashcardId);
      return;
    }
    state = {...state, flashcardId};
  }

  void setAll(Iterable<String> flashcardIds) {
    state = flashcardIds.toSet();
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = <String>{};
  }
}

@riverpod
Future<List<DeckMoveTarget>> flashcardMoveTargets(
  Ref ref,
  String deckId,
) async {
  final selectedIds = ref
      .watch(flashcardSelectionProvider(deckId))
      .toList(growable: false);
  return ref
      .watch(getFlashcardMoveTargetsUseCaseProvider)
      .execute(deckId: deckId, flashcardIds: selectedIds);
}

@riverpod
class FlashcardActionController extends _$FlashcardActionController {
  @override
  FutureOr<void> build(String deckId) {}

  Future<List<DeckMoveTarget>> loadMoveTargets(List<String> flashcardIds) {
    return ref
        .read(getFlashcardMoveTargetsUseCaseProvider)
        .execute(deckId: deckId, flashcardIds: flashcardIds);
  }

  Future<bool> deleteFlashcards(List<String> flashcardIds) async {
    // guard:retry-reviewed
    state = const AsyncLoading<void>();
    final result = await ref
        .read(deleteFlashcardsUseCaseProvider)
        .execute(flashcardIds);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    ref.read(flashcardSelectionProvider(deckId).notifier).clear();
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
  }) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(moveFlashcardsUseCaseProvider)
        .execute(flashcardIds: flashcardIds, targetDeckId: targetDeckId);
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    ref.read(flashcardSelectionProvider(deckId).notifier).clear();
    state = const AsyncData<void>(null);
    return true;
  }

  Future<bool> reorderFlashcards(List<String> orderedFlashcardIds) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(reorderFlashcardsUseCaseProvider)
        .execute(deckId: deckId, orderedFlashcardIds: orderedFlashcardIds);
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

  Future<ExportData?> exportFlashcards(List<String> flashcardIds) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(exportFlashcardsUseCaseProvider)
        .execute(flashcardIds);
    if (!ref.mounted) {
      return null;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return null;
    }
    state = const AsyncData<void>(null);
    return result.valueOrNull;
  }
}

AppFailure? flashcardActionError(AsyncValue<void> actionState) {
  return actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );
}

String flashcardActionErrorMessage(AppFailure? failure) {
  if (failure == null) {
    return '';
  }
  if (failure.cause case final ValidationException cause) {
    return cause.message;
  }
  return failure.message;
}

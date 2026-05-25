import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/content/flashcard_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/viewmodels/mx_action_errors.dart';
import '../../../shared/viewmodels/mx_async_action_runner.dart';
import '../../../shared/viewmodels/mx_selection_ops.dart';

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
class FlashcardDeckProgressState {
  const FlashcardDeckProgressState({
    required this.newCount,
    required this.learningCount,
    required this.masteredCount,
    required this.masteryPercent,
  });

  final int newCount;
  final int learningCount;
  final int masteredCount;
  final int masteryPercent;
}

@immutable
class FlashcardListState {
  FlashcardListState({
    required String deckId,
    required String folderId,
    required String deckName,
    required List<BreadcrumbSegmentReadModel> breadcrumb,
    required ContentSortMode sortMode,
    required String searchTerm,
    required this.progress,
    required this.items,
  }) : deckContext = FlashcardListDeckContext(
         deckId: deckId,
         folderId: folderId,
         deckName: deckName,
         breadcrumb: breadcrumb,
       ),
       query = FlashcardListQueryState(
         sortMode: sortMode,
         searchTerm: searchTerm,
       );

  static const int previewLimit = 5;

  final FlashcardListDeckContext deckContext;
  final FlashcardListQueryState query;
  final FlashcardDeckProgressState progress;
  final List<FlashcardListItemState> items;

  String get deckId => deckContext.deckId;
  String get folderId => deckContext.folderId;
  String get deckName => deckContext.deckName;
  List<BreadcrumbSegmentReadModel> get breadcrumb => deckContext.breadcrumb;
  ContentSortMode get sortMode => query.sortMode;
  String get searchTerm => query.searchTerm;
  bool get canManualReorder => sortMode.allowsManualReorder;
  int get totalCount =>
      progress.newCount + progress.learningCount + progress.masteredCount;
  List<FlashcardListItemState> get previewItems =>
      items.take(previewLimit).toList(growable: false);
}

@immutable
class FlashcardListDeckContext {
  const FlashcardListDeckContext({
    required this.deckId,
    required this.folderId,
    required this.deckName,
    required this.breadcrumb,
  });

  final String deckId;
  final String folderId;
  final String deckName;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
}

@immutable
class FlashcardListQueryState {
  const FlashcardListQueryState({
    required this.sortMode,
    required this.searchTerm,
  });

  final ContentSortMode sortMode;
  final String searchTerm;
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
    progress: FlashcardDeckProgressState(
      newCount: data.progress.newCount,
      learningCount: data.progress.learningCount,
      masteredCount: data.progress.masteredCount,
      masteryPercent: data.progress.masteryPercent,
    ),
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
  Set<String> build(String deckId) => const <String>{};

  void toggle(String flashcardId) =>
      state = MxSelectionOps.toggle(state, flashcardId);

  void setAll(Iterable<String> flashcardIds) =>
      state = MxSelectionOps.setAll(flashcardIds);

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = MxSelectionOps.clear<String>();
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

  Future<List<DeckMoveTarget>> loadMoveTargets(List<String> flashcardIds) => ref
      .read(getFlashcardMoveTargetsUseCaseProvider)
      .execute(deckId: deckId, flashcardIds: flashcardIds);

  Future<bool> deleteFlashcards(List<String> flashcardIds) =>
      _actionRunner.runResult(
        () => ref.read(deleteFlashcardsUseCaseProvider).execute(flashcardIds),
        onSuccess: (_) {
          ref.read(flashcardSelectionProvider(deckId).notifier).clear();
        },
      );

  Future<bool> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
  }) async => _actionRunner.runResult(
    () => ref
        .read(moveFlashcardsUseCaseProvider)
        .execute(flashcardIds: flashcardIds, targetDeckId: targetDeckId),
    onSuccess: (_) {
      ref.read(flashcardSelectionProvider(deckId).notifier).clear();
    },
  );

  Future<bool> reorderFlashcards(List<String> orderedFlashcardIds) async =>
      _actionRunner.runResult(
        () => ref
            .read(reorderFlashcardsUseCaseProvider)
            .execute(deckId: deckId, orderedFlashcardIds: orderedFlashcardIds),
      );

  Future<ExportData?> exportFlashcards(
    List<String> flashcardIds, {
    required ExportFormat format,
  }) async => _actionRunner.runResultValue(
    () => ref
        .read(exportFlashcardsUseCaseProvider)
        .execute(flashcardIds, format: format),
  );

  MxAsyncActionRunner get _actionRunner => MxAsyncActionRunner(
    isMounted: () => ref.mounted,
    setState: (nextState) => state = nextState,
  );
}

AppFailure? flashcardActionError(AsyncValue<void> actionState) =>
    MxActionErrors.failureOf(actionState);

String flashcardActionErrorMessage(AppFailure? failure) =>
    MxActionErrors.messageOf(failure);

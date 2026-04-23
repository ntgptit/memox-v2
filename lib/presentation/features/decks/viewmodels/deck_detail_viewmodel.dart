import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/value_objects/content_actions.dart';

part 'deck_detail_viewmodel.g.dart';

@immutable
class DeckDetailState {
  const DeckDetailState({
    required this.id,
    required this.folderId,
    required this.name,
    required this.breadcrumb,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final String id;
  final String folderId;
  final String name;
  final List<String> breadcrumb;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

@Riverpod(keepAlive: true)
Future<DeckDetailState> deckDetailQuery(Ref ref, String deckId) async {
  final useCase = ref.watch(watchDeckDetailUseCaseProvider);
  ref.watch(contentDataRevisionProvider);

  final data = await useCase.execute(deckId);
  return DeckDetailState(
    id: data.deck.id,
    folderId: data.deck.folderId,
    name: data.deck.name,
    breadcrumb: data.breadcrumb,
    cardCount: data.cardCount,
    dueTodayCount: data.dueTodayCount,
    masteryPercent: data.masteryPercent,
    lastStudiedAt: data.lastStudiedAt,
  );
}

@riverpod
Future<List<DeckMoveTarget>> deckMovePicker(Ref ref, String deckId) async {
  final detail = await ref.watch(deckDetailQueryProvider(deckId).future);
  return ref
      .watch(getDeckMoveTargetsUseCaseProvider)
      .execute(deckId: deckId, excludingFolderId: detail.folderId);
}

@riverpod
class DeckActionController extends _$DeckActionController {
  @override
  FutureOr<void> build(String deckId) {}

  Future<bool> updateDeck(String name) async {
    // guard:retry-reviewed
    state = const AsyncLoading<void>();
    final result = await ref
        .read(updateDeckUseCaseProvider)
        .execute(deckId: deckId, name: name);
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

  Future<bool> deleteDeck() async {
    state = const AsyncLoading<void>();
    final result = await ref.read(deleteDeckUseCaseProvider).execute(deckId);
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

  Future<bool> moveDeck(String targetFolderId) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(moveDeckUseCaseProvider)
        .execute(deckId: deckId, targetFolderId: targetFolderId);
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

  Future<String?> duplicateDeck(String targetFolderId) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(duplicateDeckUseCaseProvider)
        .execute(deckId: deckId, targetFolderId: targetFolderId);
    if (!ref.mounted) {
      return null;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return null;
    }
    state = const AsyncData<void>(null);
    return result.valueOrNull?.id;
  }

  Future<ExportData?> exportDeck() async {
    state = const AsyncLoading<void>();
    final result = await ref.read(exportDeckUseCaseProvider).execute(deckId);
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

AppFailure? deckActionError(AsyncValue<void> actionState) {
  return actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );
}

String deckActionErrorMessage(AppFailure? failure) {
  if (failure == null) {
    return '';
  }
  if (failure.cause case final ValidationException cause) {
    return cause.message;
  }
  return failure.message;
}

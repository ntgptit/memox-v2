import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_read_models.dart';

part 'deck_action_viewmodel.g.dart';

@immutable
class DeckActionContext {
  const DeckActionContext({
    required this.deckId,
    required this.deckName,
    required this.folderId,
    required this.breadcrumb,
  });

  final String deckId;
  final String deckName;
  final String folderId;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
}

@Riverpod(keepAlive: true)
Future<DeckActionContext> deckActionContext(Ref ref, String deckId) async {
  final useCase = ref.watch(getDeckActionContextUseCaseProvider);
  ref.watch(contentDataRevisionProvider);

  final data = await useCase.execute(deckId);
  return DeckActionContext(
    deckId: data.deck.id,
    deckName: data.deck.name,
    folderId: data.deck.folderId,
    breadcrumb: data.breadcrumb,
  );
}

@riverpod
Future<List<DeckMoveTarget>> deckMovePicker(
  Ref ref,
  String deckId,
  String excludingFolderId,
) {
  return ref
      .watch(getDeckMoveTargetsUseCaseProvider)
      .execute(deckId: deckId, excludingFolderId: excludingFolderId);
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

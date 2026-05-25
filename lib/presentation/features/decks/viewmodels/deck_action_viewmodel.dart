import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/content/deck_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/viewmodels/mx_action_errors.dart';
import '../../../shared/viewmodels/mx_async_action_runner.dart';

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
) => ref
    .watch(getDeckMoveTargetsUseCaseProvider)
    .execute(deckId: deckId, excludingFolderId: excludingFolderId);

@riverpod
class DeckActionController extends _$DeckActionController {
  @override
  FutureOr<void> build(String deckId) {}

  Future<bool> updateDeck(String name) => _actionRunner.runResult(
    () =>
        ref.read(updateDeckUseCaseProvider).execute(deckId: deckId, name: name),
  );

  Future<bool> deleteDeck() async => _actionRunner.runResult(
    () => ref.read(deleteDeckUseCaseProvider).execute(deckId),
  );

  Future<bool> moveDeck(String targetFolderId) async => _actionRunner.runResult(
    () => ref
        .read(moveDeckUseCaseProvider)
        .execute(deckId: deckId, targetFolderId: targetFolderId),
  );

  Future<String?> duplicateDeck(String targetFolderId) async {
    final deck = await _actionRunner.runResultValue(
      () => ref
          .read(duplicateDeckUseCaseProvider)
          .execute(deckId: deckId, targetFolderId: targetFolderId),
    );
    return deck?.id;
  }

  Future<ExportData?> exportDeck(ExportFormat format) async =>
      _actionRunner.runResultValue(
        () => ref
            .read(exportDeckUseCaseProvider)
            .execute(deckId, format: format),
      );

  MxAsyncActionRunner get _actionRunner => MxAsyncActionRunner(
    isMounted: () => ref.mounted,
    setState: (nextState) => state = nextState,
  );
}

AppFailure? deckActionError(AsyncValue<void> actionState) =>
    MxActionErrors.failureOf(actionState);

String deckActionErrorMessage(AppFailure? failure) =>
    MxActionErrors.messageOf(failure);

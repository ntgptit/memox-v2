import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/value_objects/content_actions.dart';

part 'flashcard_import_viewmodel.g.dart';

@immutable
class FlashcardImportDraftState {
  const FlashcardImportDraftState({
    required this.format,
    required this.rawContent,
    this.preparation,
  });

  final ImportSourceFormat format;
  final String rawContent;
  final FlashcardImportPreparation? preparation;

  FlashcardImportDraftState copyWith({
    ImportSourceFormat? format,
    String? rawContent,
    FlashcardImportPreparation? preparation,
    bool clearPreparation = false,
  }) {
    return FlashcardImportDraftState(
      format: format ?? this.format,
      rawContent: rawContent ?? this.rawContent,
      preparation: clearPreparation ? null : (preparation ?? this.preparation),
    );
  }
}

@riverpod
class FlashcardImportDraft extends _$FlashcardImportDraft {
  @override
  FlashcardImportDraftState build(String deckId) {
    return const FlashcardImportDraftState(
      format: ImportSourceFormat.csv,
      rawContent: '',
    );
  }

  void setFormat(ImportSourceFormat format) {
    if (state.format == format) {
      return;
    }
    state = state.copyWith(format: format, clearPreparation: true);
  }

  void setRawContent(String rawContent) {
    if (state.rawContent == rawContent) {
      return;
    }
    state = state.copyWith(rawContent: rawContent, clearPreparation: true);
  }

  void setPreparation(FlashcardImportPreparation preparation) {
    state = state.copyWith(preparation: preparation);
  }

  void reset() {
    state = const FlashcardImportDraftState(
      format: ImportSourceFormat.csv,
      rawContent: '',
    );
  }
}

@riverpod
class FlashcardImportController extends _$FlashcardImportController {
  @override
  FutureOr<void> build(String deckId) {}

  Future<FlashcardImportPreparation?> preparePreview() async {
    // guard:retry-reviewed
    final draft = ref.read(flashcardImportDraftProvider(deckId));
    state = const AsyncLoading<void>();
    final result = await ref.read(prepareFlashcardImportUseCaseProvider).execute(
      format: draft.format,
      rawContent: draft.rawContent,
    );
    if (!ref.mounted) {
      return null;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return null;
    }
    final preparation = result.valueOrNull!;
    ref.read(flashcardImportDraftProvider(deckId).notifier).setPreparation(
      preparation,
    );
    state = const AsyncData<void>(null);
    return preparation;
  }

  Future<int?> commitImport() async {
    final draft = ref.read(flashcardImportDraftProvider(deckId));
    final preparation = draft.preparation;
    if (preparation == null) {
      return null;
    }

    state = const AsyncLoading<void>();
    final result = await ref.read(commitFlashcardImportUseCaseProvider).execute(
      deckId: deckId,
      preparation: preparation,
    );
    if (!ref.mounted) {
      return null;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return null;
    }
    ref.read(flashcardImportDraftProvider(deckId).notifier).reset();
    state = const AsyncData<void>(null);
    return result.valueOrNull;
  }

  void cancelImport() {
    ref.read(flashcardImportDraftProvider(deckId).notifier).reset();
  }
}

AppFailure? flashcardImportError(AsyncValue<void> actionState) {
  return actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );
}

String flashcardImportErrorMessage(AppFailure? failure) {
  if (failure == null) {
    return '';
  }
  if (failure.cause case final ValidationException cause) {
    return cause.message;
  }
  return failure.message;
}

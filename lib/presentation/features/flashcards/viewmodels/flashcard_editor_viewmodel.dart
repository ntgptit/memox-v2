import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/value_objects/content_actions.dart';

part 'flashcard_editor_viewmodel.g.dart';

@immutable
class FlashcardEditorArgs {
  const FlashcardEditorArgs({required this.deckId, this.flashcardId});

  final String deckId;
  final String? flashcardId;

  bool get isEditing => flashcardId != null;

  @override
  bool operator ==(Object other) {
    return other is FlashcardEditorArgs &&
        other.deckId == deckId &&
        other.flashcardId == flashcardId;
  }

  @override
  int get hashCode => Object.hash(deckId, flashcardId);
}

@immutable
class FlashcardEditorDraftState {
  const FlashcardEditorDraftState({
    required this.deckId,
    required this.flashcardId,
    required this.front,
    required this.back,
    required this.note,
    required this.originalFront,
    required this.originalBack,
    required this.hasLearningProgress,
  });

  final String deckId;
  final String? flashcardId;
  final String front;
  final String back;
  final String note;
  final String originalFront;
  final String originalBack;
  final bool hasLearningProgress;

  bool get isEditing => flashcardId != null;

  bool get hasChangedLearningContent {
    return StringUtils.trimmed(front) != StringUtils.trimmed(originalFront) ||
        StringUtils.trimmed(back) != StringUtils.trimmed(originalBack);
  }

  bool get requiresLearningProgressPolicy {
    return isEditing && hasLearningProgress && hasChangedLearningContent;
  }

  FlashcardDraft toDraft() {
    return FlashcardDraft(front: front, back: back, note: note);
  }

  FlashcardEditorDraftState copyWith({
    String? front,
    String? back,
    String? note,
  }) {
    return FlashcardEditorDraftState(
      deckId: deckId,
      flashcardId: flashcardId,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
      originalFront: originalFront,
      originalBack: originalBack,
      hasLearningProgress: hasLearningProgress,
    );
  }
}

@riverpod
class FlashcardEditorDraft extends _$FlashcardEditorDraft {
  @override
  Future<FlashcardEditorDraftState> build(FlashcardEditorArgs args) async {
    if (!args.isEditing) {
      return FlashcardEditorDraftState(
        deckId: args.deckId,
        flashcardId: null,
        front: '',
        back: '',
        note: '',
        originalFront: '',
        originalBack: '',
        hasLearningProgress: false,
      );
    }

    final flashcard = await ref
        .read(getFlashcardUseCaseProvider)
        .execute(args.flashcardId!);
    return FlashcardEditorDraftState(
      deckId: flashcard.deckId,
      flashcardId: flashcard.id,
      front: flashcard.front,
      back: flashcard.back,
      note: flashcard.note ?? '',
      originalFront: flashcard.front,
      originalBack: flashcard.back,
      hasLearningProgress: flashcard.hasLearningProgress,
    );
  }

  void setFront(String value) {
    final current = _currentDraft(state);
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(front: value));
  }

  void setBack(String value) {
    final current = _currentDraft(state);
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(back: value));
  }

  void setNote(String value) {
    final current = _currentDraft(state);
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(note: value));
  }

  void clearForNext() {
    final current = _currentDraft(state);
    if (current == null) {
      return;
    }
    state = AsyncData(
      FlashcardEditorDraftState(
        deckId: current.deckId,
        flashcardId: null,
        front: '',
        back: '',
        note: '',
        originalFront: '',
        originalBack: '',
        hasLearningProgress: false,
      ),
    );
  }
}

@riverpod
class FlashcardEditorController extends _$FlashcardEditorController {
  @override
  FutureOr<void> build(FlashcardEditorArgs args) {}

  Future<bool> save({
    bool keepCreating = false,
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) async {
    // guard:retry-reviewed
    final draftState = _currentDraft(
      ref.read(flashcardEditorDraftProvider(args)),
    );
    if (draftState == null) {
      return false;
    }

    state = const AsyncLoading<void>();
    if (args.isEditing) {
      final result = await ref
          .read(updateFlashcardUseCaseProvider)
          .execute(
            flashcardId: args.flashcardId!,
            draft: draftState.toDraft(),
            progressPolicy: progressPolicy,
          );
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

    final result = await ref
        .read(createFlashcardUseCaseProvider)
        .execute(deckId: args.deckId, draft: draftState.toDraft());
    if (!ref.mounted) {
      return false;
    }
    final failure = result.failureOrNull;
    if (failure != null) {
      state = AsyncError<void>(failure, StackTrace.current);
      return false;
    }
    if (keepCreating) {
      ref.read(flashcardEditorDraftProvider(args).notifier).clearForNext();
    }
    state = const AsyncData<void>(null);
    return true;
  }
}

AppFailure? flashcardEditorError(AsyncValue<void> actionState) {
  return actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );
}

String flashcardEditorErrorMessage(AppFailure? failure) {
  if (failure == null) {
    return '';
  }
  if (failure.cause case final ValidationException cause) {
    return cause.message;
  }
  return failure.message;
}

FlashcardEditorDraftState? _currentDraft(
  AsyncValue<FlashcardEditorDraftState> state,
) {
  return switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };
}

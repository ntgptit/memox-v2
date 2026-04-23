import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/value_objects/content_actions.dart';

part 'flashcard_editor_viewmodel.g.dart';

@immutable
class FlashcardEditorArgs {
  const FlashcardEditorArgs({
    required this.deckId,
    this.flashcardId,
  });

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
    required this.title,
    required this.front,
    required this.back,
    required this.note,
  });

  final String deckId;
  final String? flashcardId;
  final String title;
  final String front;
  final String back;
  final String note;

  bool get isEditing => flashcardId != null;

  FlashcardDraft toDraft() {
    return FlashcardDraft(
      title: title,
      front: front,
      back: back,
      note: note,
    );
  }

  FlashcardEditorDraftState copyWith({
    String? title,
    String? front,
    String? back,
    String? note,
  }) {
    return FlashcardEditorDraftState(
      deckId: deckId,
      flashcardId: flashcardId,
      title: title ?? this.title,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
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
        title: '',
        front: '',
        back: '',
        note: '',
      );
    }

    final flashcard = await ref
        .read(getFlashcardUseCaseProvider)
        .execute(args.flashcardId!);
    return FlashcardEditorDraftState(
      deckId: flashcard.deckId,
      flashcardId: flashcard.id,
      title: flashcard.title ?? '',
      front: flashcard.front,
      back: flashcard.back,
      note: flashcard.note ?? '',
    );
  }

  void setTitle(String value) {
    final current = _currentDraft(state);
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(title: value));
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
        title: '',
        front: '',
        back: '',
        note: '',
      ),
    );
  }
}

@riverpod
class FlashcardEditorController extends _$FlashcardEditorController {
  @override
  FutureOr<void> build(FlashcardEditorArgs args) {}

  Future<bool> save({bool keepCreating = false}) async {
    // guard:retry-reviewed
    final draftState = _currentDraft(ref.read(flashcardEditorDraftProvider(args)));
    if (draftState == null) {
      return false;
    }

    state = const AsyncLoading<void>();
    if (args.isEditing) {
      final result = await ref.read(updateFlashcardUseCaseProvider).execute(
        flashcardId: args.flashcardId!,
        draft: draftState.toDraft(),
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

    final result = await ref.read(createFlashcardUseCaseProvider).execute(
      deckId: args.deckId,
      draft: draftState.toDraft(),
    );
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

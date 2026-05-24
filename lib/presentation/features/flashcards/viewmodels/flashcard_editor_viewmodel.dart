import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/deck_providers.dart';
import '../../../../app/di/content/flashcard_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/flashcard_starting_status.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/viewmodels/mx_async_action_runner.dart';

part 'flashcard_editor_viewmodel.g.dart';

@immutable
class FlashcardEditorArgs {
  const FlashcardEditorArgs({required this.deckId, this.flashcardId});

  final String deckId;
  final String? flashcardId;

  bool get isEditing => flashcardId != null;

  @override
  bool operator ==(Object other) => other is FlashcardEditorArgs &&
        other.deckId == deckId &&
        other.flashcardId == flashcardId;

  @override
  int get hashCode => Object.hash(deckId, flashcardId);
}

@immutable
class FlashcardEditorDraftState {
  const FlashcardEditorDraftState({
    required this.deckId,
    required this.deckName,
    required this.breadcrumb,
    required this.flashcardId,
    required this.front,
    required this.back,
    required this.note,
    required this.example,
    required this.pronunciation,
    required this.hint,
    required this.tags,
    required this.startingStatus,
    required this.originalFront,
    required this.originalBack,
    required this.hasLearningProgress,
  });

  final String deckId;
  final String deckName;
  final List<String> breadcrumb;
  final String? flashcardId;
  final String front;
  final String back;
  final String note;
  final String example;
  final String pronunciation;
  final String hint;
  final List<String> tags;
  final FlashcardStartingStatus startingStatus;
  final String originalFront;
  final String originalBack;
  final bool hasLearningProgress;

  bool get isEditing => flashcardId != null;

  bool get canSave =>
      StringUtils.trimmed(front).isNotEmpty &&
      StringUtils.trimmed(back).isNotEmpty;

  bool get hasChangedLearningContent => StringUtils.trimmed(front) != StringUtils.trimmed(originalFront) ||
        StringUtils.trimmed(back) != StringUtils.trimmed(originalBack);

  bool get requiresLearningProgressPolicy => isEditing && hasLearningProgress && hasChangedLearningContent;

  FlashcardDraft toDraft() => FlashcardDraft(
      front: front,
      back: back,
      note: note,
      example: example,
      pronunciation: pronunciation,
      hint: hint,
      tags: tags,
      startingStatus: startingStatus,
    );

  FlashcardEditorDraftState copyWith({
    String? deckId,
    String? deckName,
    List<String>? breadcrumb,
    String? front,
    String? back,
    String? note,
    String? example,
    String? pronunciation,
    String? hint,
    List<String>? tags,
    FlashcardStartingStatus? startingStatus,
  }) => FlashcardEditorDraftState(
      deckId: deckId ?? this.deckId,
      deckName: deckName ?? this.deckName,
      breadcrumb: breadcrumb ?? this.breadcrumb,
      flashcardId: flashcardId,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
      example: example ?? this.example,
      pronunciation: pronunciation ?? this.pronunciation,
      hint: hint ?? this.hint,
      tags: tags ?? this.tags,
      startingStatus: startingStatus ?? this.startingStatus,
      originalFront: originalFront,
      originalBack: originalBack,
      hasLearningProgress: hasLearningProgress,
    );
}

@riverpod
class FlashcardEditorDraft extends _$FlashcardEditorDraft {
  @override
  Future<FlashcardEditorDraftState> build(FlashcardEditorArgs args) async {
    final deckContext = await ref
        .read(getDeckActionContextUseCaseProvider)
        .execute(args.deckId);
    final breadcrumb = <String>[
      for (final segment in deckContext.breadcrumb) segment.label,
    ];

    if (!args.isEditing) {
      return FlashcardEditorDraftState(
        deckId: args.deckId,
        deckName: deckContext.deck.name,
        breadcrumb: breadcrumb,
        flashcardId: null,
        front: '',
        back: '',
        note: '',
        example: '',
        pronunciation: '',
        hint: '',
        tags: const <String>[],
        startingStatus: FlashcardStartingStatus.newCard,
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
      deckName: deckContext.deck.name,
      breadcrumb: breadcrumb,
      flashcardId: flashcard.id,
      front: flashcard.front,
      back: flashcard.back,
      note: flashcard.note ?? '',
      example: flashcard.example ?? '',
      pronunciation: flashcard.pronunciation ?? '',
      hint: flashcard.hint ?? '',
      tags: List<String>.unmodifiable(flashcard.tags),
      startingStatus: flashcard.startingStatus,
      originalFront: flashcard.front,
      originalBack: flashcard.back,
      hasLearningProgress: flashcard.hasLearningProgress,
    );
  }

  void setFront(String value) =>
      _patch((draft) => draft.copyWith(front: value));

  void setBack(String value) => _patch((draft) => draft.copyWith(back: value));

  void setNote(String value) => _patch((draft) => draft.copyWith(note: value));

  void setExample(String value) =>
      _patch((draft) => draft.copyWith(example: value));

  void setPronunciation(String value) =>
      _patch((draft) => draft.copyWith(pronunciation: value));

  void setHint(String value) => _patch((draft) => draft.copyWith(hint: value));

  void setStartingStatus(FlashcardStartingStatus value) =>
      _patch((draft) => draft.copyWith(startingStatus: value));

  /// Re-targets the draft to a different deck. Per Design System "05 · Create
  /// card", the deck pill is a picker that lets the author swap destination
  /// before saving.
  void setDestinationDeck({
    required String deckId,
    required String deckName,
    required List<String> breadcrumb,
  }) {
    _patch(
      (draft) => draft.copyWith(
        deckId: deckId,
        deckName: deckName,
        breadcrumb: breadcrumb,
      ),
    );
  }

  void addTag(String tag) {
    final trimmed = StringUtils.trimmed(tag);
    if (trimmed.isEmpty) return;
    _patch((draft) {
      if (draft.tags.contains(trimmed)) return draft;
      return draft.copyWith(tags: <String>[...draft.tags, trimmed]);
    });
  }

  void removeTag(String tag) {
    _patch((draft) {
      if (!draft.tags.contains(tag)) return draft;
      final next = List<String>.from(draft.tags)..remove(tag);
      return draft.copyWith(tags: next);
    });
  }

  void clearForNext() {
    final current = _currentDraft(state);
    if (current == null) {
      return;
    }
    state = AsyncData(
      FlashcardEditorDraftState(
        deckId: current.deckId,
        deckName: current.deckName,
        breadcrumb: current.breadcrumb,
        flashcardId: null,
        front: '',
        back: '',
        note: '',
        example: '',
        pronunciation: '',
        hint: '',
        tags: const <String>[],
        startingStatus: current.startingStatus,
        originalFront: '',
        originalBack: '',
        hasLearningProgress: false,
      ),
    );
  }

  void _patch(
    FlashcardEditorDraftState Function(FlashcardEditorDraftState draft) update,
  ) {
    final current = _currentDraft(state);
    if (current == null) return;
    state = AsyncData(update(current));
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
    if (state.isLoading) {
      return false;
    }

    // guard:retry-reviewed
    final draftState = _currentDraft(
      ref.read(flashcardEditorDraftProvider(args)),
    );
    if (draftState == null) {
      return false;
    }

    if (args.isEditing) {
      return _actionRunner.runResult(
        () => ref
            .read(updateFlashcardUseCaseProvider)
            .execute(
              flashcardId: args.flashcardId!,
              draft: draftState.toDraft(),
              progressPolicy: progressPolicy,
            ),
      );
    }

    return _actionRunner.runResult(
      // Use the live draft.deckId, not args.deckId — the destination picker
      // can re-target the draft to a different deck before save.
      () => ref
          .read(createFlashcardUseCaseProvider)
          .execute(deckId: draftState.deckId, draft: draftState.toDraft()),
      onSuccess: (_) {
        if (keepCreating) {
          ref.read(flashcardEditorDraftProvider(args).notifier).clearForNext();
        }
      },
    );
  }

  MxAsyncActionRunner get _actionRunner => MxAsyncActionRunner(
      isMounted: () => ref.mounted,
      setState: (nextState) => state = nextState,
    );
}

AppFailure? flashcardEditorError(AsyncValue<void> actionState) => actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );

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
) => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

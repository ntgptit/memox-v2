import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/flashcard_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/viewmodels/mx_async_action_runner.dart';

part 'flashcard_import_viewmodel.g.dart';

@immutable
class FlashcardImportDraftState {
  const FlashcardImportDraftState({
    required this.format,
    required this.structuredTextSeparator,
    required this.duplicatePolicy,
    required this.rawContent,
    this.excelHasHeader = true,
    this.sourceBytes,
    this.loadedFileName,
    this.preparation,
  });

  final ImportSourceFormat format;
  final ImportStructuredTextSeparator structuredTextSeparator;
  final FlashcardImportDuplicatePolicy duplicatePolicy;
  final String rawContent;
  final bool excelHasHeader;
  final Uint8List? sourceBytes;
  final String? loadedFileName;
  final FlashcardImportPreparation? preparation;

  FlashcardImportDraftState copyWith({
    ImportSourceFormat? format,
    ImportStructuredTextSeparator? structuredTextSeparator,
    FlashcardImportDuplicatePolicy? duplicatePolicy,
    String? rawContent,
    bool? excelHasHeader,
    Uint8List? sourceBytes,
    String? loadedFileName,
    FlashcardImportPreparation? preparation,
    bool clearPreparation = false,
    bool clearSourceBytes = false,
    bool clearLoadedFileName = false,
  }) => FlashcardImportDraftState(
      format: format ?? this.format,
      structuredTextSeparator:
          structuredTextSeparator ?? this.structuredTextSeparator,
      duplicatePolicy: duplicatePolicy ?? this.duplicatePolicy,
      rawContent: rawContent ?? this.rawContent,
      excelHasHeader: excelHasHeader ?? this.excelHasHeader,
      sourceBytes: clearSourceBytes ? null : (sourceBytes ?? this.sourceBytes),
      loadedFileName: clearLoadedFileName
          ? null
          : (loadedFileName ?? this.loadedFileName),
      preparation: clearPreparation ? null : (preparation ?? this.preparation),
    );
}

@riverpod
class FlashcardImportDraft extends _$FlashcardImportDraft {
  @override
  FlashcardImportDraftState build(String deckId) => const FlashcardImportDraftState(
      format: ImportSourceFormat.excel,
      structuredTextSeparator: ImportStructuredTextSeparator.auto,
      duplicatePolicy: FlashcardImportDuplicatePolicy.skipExactDuplicates,
      rawContent: '',
    );

  void setFormat(ImportSourceFormat format) {
    if (state.format == format) {
      return;
    }
    state = state.copyWith(
      format: format,
      rawContent: '',
      clearPreparation: true,
      clearSourceBytes: true,
      clearLoadedFileName: true,
    );
  }

  void setStructuredTextSeparator(
    ImportStructuredTextSeparator structuredTextSeparator,
  ) {
    if (state.structuredTextSeparator == structuredTextSeparator) {
      return;
    }
    state = state.copyWith(
      structuredTextSeparator: structuredTextSeparator,
      clearPreparation: true,
    );
  }

  void setDuplicatePolicy(FlashcardImportDuplicatePolicy duplicatePolicy) {
    if (state.duplicatePolicy == duplicatePolicy) {
      return;
    }
    state = state.copyWith(
      duplicatePolicy: duplicatePolicy,
      clearPreparation: true,
    );
  }

  void setRawContent(String rawContent) {
    if (state.rawContent == rawContent) {
      return;
    }
    state = state.copyWith(
      rawContent: rawContent,
      clearPreparation: true,
      clearSourceBytes: true,
      clearLoadedFileName: true,
    );
  }

  void setExcelHasHeader(bool excelHasHeader) {
    if (state.excelHasHeader == excelHasHeader) {
      return;
    }
    state = state.copyWith(
      excelHasHeader: excelHasHeader,
      clearPreparation: true,
    );
  }

  void setSourceFile({
    required Uint8List sourceBytes,
    required String loadedFileName,
  }) {
    state = state.copyWith(
      rawContent: '',
      sourceBytes: sourceBytes,
      loadedFileName: loadedFileName,
      clearPreparation: true,
    );
  }

  void clearSourceFile() {
    if (state.sourceBytes == null && state.loadedFileName == null) {
      return;
    }
    state = state.copyWith(
      clearPreparation: true,
      clearSourceBytes: true,
      clearLoadedFileName: true,
    );
  }

  void setPreparation(FlashcardImportPreparation preparation) {
    state = state.copyWith(preparation: preparation);
  }

  void reset() {
    state = const FlashcardImportDraftState(
      format: ImportSourceFormat.excel,
      structuredTextSeparator: ImportStructuredTextSeparator.auto,
      duplicatePolicy: FlashcardImportDuplicatePolicy.skipExactDuplicates,
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
    return _actionRunner.runResultValue(
      () => ref
          .read(prepareFlashcardImportUseCaseProvider)
          .execute(
            deckId: deckId,
            format: draft.format,
            rawContent: draft.rawContent,
            sourceBytes: draft.sourceBytes,
            excelHasHeader: draft.excelHasHeader,
            duplicatePolicy: draft.duplicatePolicy,
            structuredTextSeparator: draft.structuredTextSeparator,
          ),
      onSuccess: (preparation) {
        ref
            .read(flashcardImportDraftProvider(deckId).notifier)
            .setPreparation(preparation);
      },
    );
  }

  Future<int?> commitImport() async {
    final draft = ref.read(flashcardImportDraftProvider(deckId));
    final preparation = draft.preparation;
    if (preparation == null) {
      return null;
    }

    return _actionRunner.runResultValue(
      () => ref
          .read(commitFlashcardImportUseCaseProvider)
          .execute(deckId: deckId, preparation: preparation),
      onSuccess: (_) {
        ref.read(flashcardImportDraftProvider(deckId).notifier).reset();
      },
    );
  }

  void cancelImport() {
    ref.read(flashcardImportDraftProvider(deckId).notifier).reset();
  }

  MxAsyncActionRunner get _actionRunner => MxAsyncActionRunner(
      isMounted: () => ref.mounted,
      setState: (nextState) => state = nextState,
    );
}

AppFailure? flashcardImportError(AsyncValue<void> actionState) => actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );

String flashcardImportErrorMessage(AppFailure? failure) {
  if (failure == null) {
    return '';
  }
  if (failure.cause case final ValidationException cause) {
    return cause.message;
  }
  return failure.message;
}

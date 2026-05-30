import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/di/content/tag_providers.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/feedback/mx_tag_failure_text.dart';
import '../../../shared/layouts/mx_form_scaffold.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../viewmodels/flashcard_editor_destinations_provider.dart';
import '../viewmodels/flashcard_editor_viewmodel.dart';
import '../widgets/flashcard_editor_form.dart';
import '../widgets/flashcard_editor_header_section.dart';
import '../widgets/flashcard_editor_save_bar.dart';

class FlashcardEditorScreen extends ConsumerStatefulWidget {
  const FlashcardEditorScreen({
    required this.deckId,
    this.flashcardId,
    super.key,
  });

  final String deckId;
  final String? flashcardId;

  FlashcardEditorArgs get args =>
      FlashcardEditorArgs(deckId: deckId, flashcardId: flashcardId);

  @override
  ConsumerState<FlashcardEditorScreen> createState() =>
      _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends ConsumerState<FlashcardEditorScreen> {
  late final TextEditingController _frontController = TextEditingController();
  late final TextEditingController _backController = TextEditingController();
  late final TextEditingController _noteController = TextEditingController();
  late final TextEditingController _exampleController = TextEditingController();
  late final TextEditingController _pronunciationController =
      TextEditingController();
  late final TextEditingController _hintController = TextEditingController();
  bool _didSeedControllers = false;

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _noteController.dispose();
    _exampleController.dispose();
    _pronunciationController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _resetControllers() {
    _frontController.clear();
    _backController.clear();
    _noteController.clear();
    _exampleController.clear();
    _pronunciationController.clear();
    _hintController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(
      flashcardEditorControllerProvider(widget.args),
      (_, next) {
        final failure = flashcardEditorError(next);
        if (failure != null) {
          MxSnackbar.error(context, flashcardEditorErrorMessage(failure));
        }
      },
    );

    final actionState = ref.watch(
      flashcardEditorControllerProvider(widget.args),
    );
    final draftState = ref.watch(flashcardEditorDraftProvider(widget.args));
    final draftNotifier = ref.read(
      flashcardEditorDraftProvider(widget.args).notifier,
    );
    final actionController = ref.read(
      flashcardEditorControllerProvider(widget.args).notifier,
    );

    final draft = draftState.value;
    final canSave = (draft?.canSave ?? false) && !actionState.isLoading;

    return MxFormScaffold(
      contentWidth: MxContentWidth.reading,
      bottomAction: draft == null
          ? null
          : FlashcardEditorSaveBar(
              isEditing: draft.isEditing,
              canSave: canSave,
              onSave: () => _save(
                draft: draft,
                actionController: actionController,
                l10n: l10n,
              ),
              onSaveAndAddNext: () => _saveAndAddNext(
                actionController: actionController,
                l10n: l10n,
              ),
            ),
      body: MxRetainedAsyncState<FlashcardEditorDraftState>(
        data: draftState.value,
        isLoading: draftState.isLoading,
        error: draftState.hasError ? draftState.error : null,
        stackTrace: draftState.hasError ? draftState.stackTrace : null,
        dataBuilder: (context, draft) => _buildEditorBody(
          context: context,
          draft: draft,
          canSave: canSave,
          draftNotifier: draftNotifier,
          actionController: actionController,
          l10n: l10n,
        ),
      ),
    );
  }

  Widget _buildEditorBody({
    required BuildContext context,
    required FlashcardEditorDraftState draft,
    required bool canSave,
    required FlashcardEditorDraft draftNotifier,
    required FlashcardEditorController actionController,
    required AppLocalizations l10n,
  }) {
    if (!_didSeedControllers) {
      _frontController.text = draft.front;
      _backController.text = draft.back;
      _noteController.text = draft.note;
      _exampleController.text = draft.example;
      _pronunciationController.text = draft.pronunciation;
      _hintController.text = draft.hint;
      _didSeedControllers = true;
    }

    final title = draft.isEditing
        ? l10n.flashcardsEditTitle
        : l10n.flashcardsNewTitle;

    final breadcrumbItems = <MxBreadcrumb>[
      MxBreadcrumb(label: l10n.libraryTitle, onTap: () => context.goLibrary()),
      for (final segment in draft.breadcrumb) MxBreadcrumb(label: segment),
      MxBreadcrumb(label: title),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlashcardEditorHeaderSection(
          title: title,
          onBack: () => context.popRoute(
            fallback: () => context.goFlashcardList(widget.deckId),
          ),
          onQuickSave: !draft.isEditing && canSave
              ? () => _saveAndAddNext(
                  actionController: actionController,
                  l10n: l10n,
                )
              : null,
          quickSaveTooltip: l10n.flashcardsSaveAndAddNextTooltip,
        ),
        const MxGap(MxSpace.md),
        MxBreadcrumbBar(items: breadcrumbItems),
        const MxGap(MxSpace.lg),
        FlashcardEditorForm(
          draft: draft,
          frontController: _frontController,
          backController: _backController,
          noteController: _noteController,
          exampleController: _exampleController,
          pronunciationController: _pronunciationController,
          hintController: _hintController,
          onFrontChanged: draftNotifier.setFront,
          onBackChanged: draftNotifier.setBack,
          onNoteChanged: draftNotifier.setNote,
          onExampleChanged: draftNotifier.setExample,
          onPronunciationChanged: draftNotifier.setPronunciation,
          onHintChanged: draftNotifier.setHint,
          onAddTag: (raw) => _addTag(raw, draftNotifier, l10n),
          onRemoveTag: draftNotifier.removeTag,
          onValidateTag: (raw) => _validateTag(raw, l10n),
          onStartingStatusChanged: draftNotifier.setStartingStatus,
          // Edit mode keeps the deck destination read-only; moving an existing
          // card belongs to the separate "Move flashcards" action on the list
          // screen, so we suppress the picker chevron there.
          onPickDestination: draft.isEditing
              ? null
              : () => _pickDestination(
                  currentDeckId: draft.deckId,
                  draftNotifier: draftNotifier,
                  l10n: l10n,
                ),
        ),
      ],
    );
  }

  /// Inline validation for the add-tag sheet (no comma, max length), routed
  /// through the domain [TagValidator]. Returns a localized error or null.
  String? _validateTag(String raw, AppLocalizations l10n) {
    final failure = ref.read(tagValidatorProvider).validate(raw).failureOrNull;
    return failure == null ? null : tagValidationMessage(l10n, failure);
  }

  /// Adds a tag to the draft after normalizing it through [TagValidator]
  /// (lowercased storage form). Create and edit modes share this path; tags are
  /// persisted with the card on save, never written directly from the UI.
  void _addTag(String raw, FlashcardEditorDraft draftNotifier, AppLocalizations l10n) {
    final result = ref.read(tagValidatorProvider).validate(raw);
    final normalized = result.valueOrNull;
    if (normalized == null) {
      final failure = result.failureOrNull;
      if (failure != null) {
        MxSnackbar.error(context, tagValidationMessage(l10n, failure));
      }
      return;
    }
    draftNotifier.addTag(normalized);
  }

  Future<void> _pickDestination({
    required String currentDeckId,
    required FlashcardEditorDraft draftNotifier,
    required AppLocalizations l10n,
  }) async {
    final destinations = await ref.read(
      flashcardEditorDestinationsProvider.future,
    );
    if (!mounted) return;
    if (destinations.isEmpty) return;

    final picked = await MxBottomSheet.show<String>(
      context: context,
      title: l10n.flashcardsDeckPickerSheetTitle,
      child: MxActionSheetList<String>(
        selectedValue: currentDeckId,
        items: [
          for (final target in destinations)
            MxActionSheetItem<String>(
              value: target.id,
              label: target.name,
              subtitle: target.breadcrumb
                  .take(target.breadcrumb.length - 1)
                  .join(' / '),
              icon: target.id == currentDeckId
                  ? Icons.check_rounded
                  : Icons.layers_outlined,
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (picked == null || picked == currentDeckId) return;

    final target = destinations.firstWhere((d) => d.id == picked);
    draftNotifier.setDestinationDeck(
      deckId: target.id,
      deckName: target.name,
      // breadcrumb in DeckMoveTarget includes the deck name as last segment;
      // FlashcardEditorDraftState only carries the folder trail, so drop it.
      breadcrumb: target.breadcrumb.length > 1
          ? target.breadcrumb.sublist(0, target.breadcrumb.length - 1)
          : const <String>[],
    );
  }

  Future<void> _saveAndAddNext({
    required FlashcardEditorController actionController,
    required AppLocalizations l10n,
  }) async {
    final success = await actionController.saveFlashcard(keepCreating: true);
    if (!mounted) return;
    if (!success) return;
    _didSeedControllers = false;
    _resetControllers();
    MxSnackbar.success(context, l10n.flashcardsSavedMessage);
  }

  Future<void> _save({
    required FlashcardEditorDraftState draft,
    required FlashcardEditorController actionController,
    required AppLocalizations l10n,
  }) async {
    final progressPolicy = await _resolveProgressPolicy(
      draft: draft,
      l10n: l10n,
    );
    if (!mounted) return;
    if (progressPolicy == null) return;

    final success = await actionController.saveFlashcard(
      progressPolicy: progressPolicy,
    );
    if (!mounted) return;
    if (!success) return;
    final showSavedMessage = MxSnackbar.deferredSuccess(
      context,
      draft.isEditing
          ? l10n.flashcardsUpdatedMessage
          : l10n.flashcardsCreatedMessage,
    );
    await context.popRoute(
      fallback: () => context.goFlashcardList(widget.deckId),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => showSavedMessage());
  }

  Future<FlashcardProgressEditPolicy?> _resolveProgressPolicy({
    required FlashcardEditorDraftState draft,
    required AppLocalizations l10n,
  }) {
    if (!draft.requiresLearningProgressPolicy) {
      return Future.value(FlashcardProgressEditPolicy.keepProgress);
    }

    return MxDialog.show<FlashcardProgressEditPolicy>(
      context: context,
      title: l10n.flashcardsLearningContentChangedTitle,
      icon: Icons.school_outlined,
      child: Text(l10n.flashcardsLearningContentChangedMessage),
      actions: [
        Builder(
          builder: (ctx) => MxSecondaryButton(
            label: l10n.flashcardsResetProgressAction,
            leadingIcon: Icons.restart_alt_outlined,
            variant: MxSecondaryVariant.text,
            tone: MxSecondaryButtonTone.danger,
            onPressed: () => Navigator.of(
              ctx,
            ).pop(FlashcardProgressEditPolicy.resetProgress),
          ),
        ),
        Builder(
          builder: (ctx) => MxPrimaryButton(
            label: l10n.flashcardsKeepProgressAction,
            leadingIcon: Icons.timeline_outlined,
            onPressed: () =>
                Navigator.of(ctx).pop(FlashcardProgressEditPolicy.keepProgress),
          ),
        ),
      ],
    );
  }
}

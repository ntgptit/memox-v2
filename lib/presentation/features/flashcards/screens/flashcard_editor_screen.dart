import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
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

    final draftState = ref.watch(flashcardEditorDraftProvider(widget.args));
    final draftNotifier = ref.read(
      flashcardEditorDraftProvider(widget.args).notifier,
    );
    final actionController = ref.read(
      flashcardEditorControllerProvider(widget.args).notifier,
    );

    final draft = draftState.value;
    final canSave = draft?.canSave ?? false;

    return MxScaffold(
      bottomNavigationBar: draft == null
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
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<FlashcardEditorDraftState>(
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
      MxBreadcrumb(
        label: l10n.libraryTitle,
        onTap: () => context.goLibrary(),
      ),
      for (final segment in draft.breadcrumb) MxBreadcrumb(label: segment),
      MxBreadcrumb(label: title),
    ];

    return ListView(
      children: [
        FlashcardEditorHeaderSection(
          title: title,
          onBack: () => context.popRoute(
            fallback: () => context.goFlashcardList(widget.deckId),
          ),
          onQuickSave: !draft.isEditing && canSave
              ? () =>
                    _saveAndAddNext(actionController: actionController, l10n: l10n)
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
          onAddTag: draftNotifier.addTag,
          onRemoveTag: draftNotifier.removeTag,
          onStartingStatusChanged: draftNotifier.setStartingStatus,
        ),
      ],
    );
  }

  Future<void> _saveAndAddNext({
    required FlashcardEditorController actionController,
    required AppLocalizations l10n,
  }) async {
    final success = await actionController.save(keepCreating: true);
    if (!mounted || !success) {
      return;
    }
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
    if (!mounted || progressPolicy == null) {
      return;
    }

    final success = await actionController.save(progressPolicy: progressPolicy);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(
      context,
      draft.isEditing
          ? l10n.flashcardsUpdatedMessage
          : l10n.flashcardsCreatedMessage,
    );
    await context.popRoute(
      fallback: () => context.goFlashcardList(widget.deckId),
    );
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

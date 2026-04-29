import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../widgets/flashcard_editor_form.dart';
import '../widgets/flashcard_editor_header_section.dart';
import '../viewmodels/flashcard_editor_viewmodel.dart';

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
  bool _didSeedControllers = false;

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _noteController.dispose();
    super.dispose();
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

    return MxScaffold(
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<FlashcardEditorDraftState>(
          data: draftState.value,
          isLoading: draftState.isLoading,
          error: draftState.hasError ? draftState.error : null,
          stackTrace: draftState.hasError ? draftState.stackTrace : null,
          dataBuilder: (context, draft) {
            if (!_didSeedControllers) {
              _frontController.text = draft.front;
              _backController.text = draft.back;
              _noteController.text = draft.note;
              _didSeedControllers = true;
            }

            return ListView(
              children: [
                FlashcardEditorHeaderSection(
                  title: draft.isEditing
                      ? l10n.flashcardsEditTitle
                      : l10n.flashcardsNewTitle,
                  onBack: () => context.popRoute(
                    fallback: () => context.goFlashcardList(widget.deckId),
                  ),
                ),
                const MxGap(MxSpace.xl),
                FlashcardEditorForm(
                  draft: draft,
                  frontController: _frontController,
                  backController: _backController,
                  noteController: _noteController,
                  onFrontChanged: draftNotifier.setFront,
                  onBackChanged: draftNotifier.setBack,
                  onNoteChanged: draftNotifier.setNote,
                  onSaveAndAddNext: () async {
                    final success = await actionController.save(
                      keepCreating: true,
                    );
                    if (!mounted || !success) {
                      return;
                    }
                    _didSeedControllers = false;
                    _frontController.clear();
                    _backController.clear();
                    _noteController.clear();
                    MxSnackbar.success(
                      this.context,
                      l10n.flashcardsSavedMessage,
                    );
                  },
                  onSave: () => _save(
                    draft: draft,
                    actionController: actionController,
                    l10n: l10n,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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

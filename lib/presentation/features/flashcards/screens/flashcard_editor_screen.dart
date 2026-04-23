import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../viewmodels/flashcard_editor_viewmodel.dart';

class FlashcardEditorScreen extends ConsumerStatefulWidget {
  const FlashcardEditorScreen({
    required this.deckId,
    this.flashcardId,
    super.key,
  });

  final String deckId;
  final String? flashcardId;

  FlashcardEditorArgs get args => FlashcardEditorArgs(
    deckId: deckId,
    flashcardId: flashcardId,
  );

  @override
  ConsumerState<FlashcardEditorScreen> createState() =>
      _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends ConsumerState<FlashcardEditorScreen> {
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _frontController = TextEditingController();
  late final TextEditingController _backController = TextEditingController();
  late final TextEditingController _noteController = TextEditingController();
  bool _didSeedControllers = false;

  @override
  void dispose() {
    _titleController.dispose();
    _frontController.dispose();
    _backController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(flashcardEditorControllerProvider(widget.args), (
      _,
      next,
    ) {
      final failure = flashcardEditorError(next);
      if (failure != null) {
        MxSnackbar.error(context, flashcardEditorErrorMessage(failure));
      }
    });

    final draftState = ref.watch(flashcardEditorDraftProvider(widget.args));
    final draftNotifier = ref.read(
      flashcardEditorDraftProvider(widget.args).notifier,
    );
    final actionController = ref.read(
      flashcardEditorControllerProvider(widget.args).notifier,
    );

    return MxScaffold(
      body: SafeArea(
        child: MxContentShell(
          width: MxContentWidth.reading,
          child: MxRetainedAsyncState<FlashcardEditorDraftState>(
            data: draftState.value,
            isLoading: draftState.isLoading,
            error: draftState.hasError ? draftState.error : null,
            stackTrace: draftState.hasError ? draftState.stackTrace : null,
            dataBuilder: (context, draft) {
              if (!_didSeedControllers) {
                _titleController.text = draft.title;
                _frontController.text = draft.front;
                _backController.text = draft.back;
                _noteController.text = draft.note;
                _didSeedControllers = true;
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.xxxl,
                ),
                children: [
                  _EditorHeader(
                    title: draft.isEditing
                        ? l10n.flashcardsEditTitle
                        : l10n.flashcardsNewTitle,
                    onBack: () => context.popRoute(
                      fallback: () => context.goFlashcardList(widget.deckId),
                    ),
                  ),
                  const MxGap(MxFeatureSpacing.xl),
                  MxTextField(
                    controller: _titleController,
                    label: l10n.flashcardsFieldTitleLabel,
                    hintText: l10n.flashcardsFieldTitleHint,
                    onChanged: draftNotifier.setTitle,
                  ),
                  const MxGap(MxFeatureSpacing.lg),
                  MxTextField(
                    controller: _frontController,
                    label: l10n.flashcardsFieldFrontLabel,
                    hintText: l10n.flashcardsFieldFrontHint,
                    minLines: 3,
                    maxLines: 6,
                    onChanged: draftNotifier.setFront,
                  ),
                  const MxGap(MxFeatureSpacing.lg),
                  MxTextField(
                    controller: _backController,
                    label: l10n.flashcardsFieldBackLabel,
                    hintText: l10n.flashcardsFieldBackHint,
                    minLines: 3,
                    maxLines: 6,
                    onChanged: draftNotifier.setBack,
                  ),
                  const MxGap(MxFeatureSpacing.lg),
                  MxTextField(
                    controller: _noteController,
                    label: l10n.flashcardsFieldNoteLabel,
                    hintText: l10n.flashcardsFieldNoteHint,
                    minLines: 2,
                    maxLines: 4,
                    onChanged: draftNotifier.setNote,
                  ),
                  const MxGap(MxFeatureSpacing.xl),
                  Wrap(
                    spacing: MxFeatureSpacing.sm,
                    runSpacing: MxFeatureSpacing.sm,
                    children: [
                      if (!draft.isEditing)
                        MxSecondaryButton(
                          label: l10n.flashcardsSaveAndAddNext,
                          leadingIcon: Icons.playlist_add_outlined,
                          variant: MxSecondaryVariant.outlined,
                          onPressed: () async {
                            final success = await actionController.save(
                              keepCreating: true,
                            );
                            if (!mounted || !success) {
                              return;
                            }
                            _didSeedControllers = false;
                            _titleController.clear();
                            _frontController.clear();
                            _backController.clear();
                            _noteController.clear();
                            MxSnackbar.success(
                              this.context,
                              l10n.flashcardsSavedMessage,
                            );
                          },
                        ),
                      MxPrimaryButton(
                        label: draft.isEditing
                            ? l10n.flashcardsSaveChanges
                            : l10n.flashcardsSaveAction,
                        leadingIcon: draft.isEditing ? Icons.save_outlined : Icons.add,
                        onPressed: () async {
                          final success = await actionController.save();
                          if (!mounted || !success) {
                            return;
                          }
                          MxSnackbar.success(
                            this.context,
                            draft.isEditing
                                ? l10n.flashcardsUpdatedMessage
                                : l10n.flashcardsCreatedMessage,
                          );
                          await this.context.popRoute(
                            fallback: () =>
                                this.context.goFlashcardList(widget.deckId),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
            MxIconButton(
              icon: Icons.arrow_back,
              tooltip: l10n.commonBack,
              onPressed: onBack,
            ),
        const MxGap.h(MxFeatureSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}

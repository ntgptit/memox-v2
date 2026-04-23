import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../viewmodels/flashcard_editor_viewmodel.dart';

class FlashcardEditorForm extends StatelessWidget {
  const FlashcardEditorForm({
    required this.draft,
    required this.titleController,
    required this.frontController,
    required this.backController,
    required this.noteController,
    required this.onTitleChanged,
    required this.onFrontChanged,
    required this.onBackChanged,
    required this.onNoteChanged,
    required this.onSaveAndAddNext,
    required this.onSave,
    super.key,
  });

  final FlashcardEditorDraftState draft;
  final TextEditingController titleController;
  final TextEditingController frontController;
  final TextEditingController backController;
  final TextEditingController noteController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onFrontChanged;
  final ValueChanged<String> onBackChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSaveAndAddNext;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxTextField(
          controller: titleController,
          label: l10n.flashcardsFieldTitleLabel,
          hintText: l10n.flashcardsFieldTitleHint,
          onChanged: onTitleChanged,
        ),
        const MxGap(MxSpace.lg),
        MxTextField(
          controller: frontController,
          label: l10n.flashcardsFieldFrontLabel,
          hintText: l10n.flashcardsFieldFrontHint,
          minLines: 3,
          maxLines: 6,
          onChanged: onFrontChanged,
        ),
        const MxGap(MxSpace.lg),
        MxTextField(
          controller: backController,
          label: l10n.flashcardsFieldBackLabel,
          hintText: l10n.flashcardsFieldBackHint,
          minLines: 3,
          maxLines: 6,
          onChanged: onBackChanged,
        ),
        const MxGap(MxSpace.lg),
        MxTextField(
          controller: noteController,
          label: l10n.flashcardsFieldNoteLabel,
          hintText: l10n.flashcardsFieldNoteHint,
          minLines: 2,
          maxLines: 4,
          onChanged: onNoteChanged,
        ),
        const MxGap(MxSpace.xl),
        Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          children: [
            if (!draft.isEditing)
              MxSecondaryButton(
                label: l10n.flashcardsSaveAndAddNext,
                leadingIcon: Icons.playlist_add_outlined,
                variant: MxSecondaryVariant.outlined,
                onPressed: onSaveAndAddNext,
              ),
            MxPrimaryButton(
              label: draft.isEditing
                  ? l10n.flashcardsSaveChanges
                  : l10n.flashcardsSaveAction,
              leadingIcon: draft.isEditing ? Icons.save_outlined : Icons.add,
              onPressed: onSave,
            ),
          ],
        ),
      ],
    );
  }
}

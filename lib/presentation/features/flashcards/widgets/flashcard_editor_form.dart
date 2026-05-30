import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/extensions/theme_extensions.dart'
    show RepetitionColorRole;
import '../../../../domain/enums/flashcard_starting_status.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_deck_pill.dart';
import '../../../shared/widgets/mx_field_label.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_segmented_status.dart';
import '../../../shared/widgets/mx_tag_input.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../viewmodels/flashcard_editor_viewmodel.dart';

/// Author form for create / edit card per Design System "05 · Create card".
///
/// Layout (top → bottom):
///   1. DeckPill (read-only destination confirmation)
///   2. Front field (single-ish, with character counter)
///   3. Back field (multi-line, with character counter)
///   4. Example field (optional)
///   5. Tag input
///   6. Advanced toggle → Pronunciation / Hint / Starting status
class FlashcardEditorForm extends StatefulWidget {
  const FlashcardEditorForm({
    required this.draft,
    required this.frontController,
    required this.backController,
    required this.noteController,
    required this.exampleController,
    required this.pronunciationController,
    required this.hintController,
    required this.onFrontChanged,
    required this.onBackChanged,
    required this.onNoteChanged,
    required this.onExampleChanged,
    required this.onPronunciationChanged,
    required this.onHintChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onStartingStatusChanged,
    this.onValidateTag,
    this.onPickDestination,
    super.key,
  });

  final FlashcardEditorDraftState draft;
  final TextEditingController frontController;
  final TextEditingController backController;
  final TextEditingController noteController;
  final TextEditingController exampleController;
  final TextEditingController pronunciationController;
  final TextEditingController hintController;
  final ValueChanged<String> onFrontChanged;
  final ValueChanged<String> onBackChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<String> onExampleChanged;
  final ValueChanged<String> onPronunciationChanged;
  final ValueChanged<String> onHintChanged;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<FlashcardStartingStatus> onStartingStatusChanged;

  /// Inline tag validation surfaced inside the add-tag sheet (no comma, max
  /// length). Returns a localized error message, or null when valid.
  final String? Function(String value)? onValidateTag;

  /// Opens the destination-deck picker. Null disables the pill chevron
  /// (e.g., in edit mode where moving the card belongs to a separate flow).
  final VoidCallback? onPickDestination;

  @override
  State<FlashcardEditorForm> createState() => _FlashcardEditorFormState();
}

class _FlashcardEditorFormState extends State<FlashcardEditorForm> {
  static const int _frontSoftCap = 60;
  static const int _backSoftCap = 240;

  bool _advancedOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final frontIsEmpty = widget.draft.front.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxDeckPill(
          deckName: widget.draft.deckName,
          onTap: widget.onPickDestination,
        ),
        const MxGap(MxSpace.lg),
        MxFieldLabel(
          label: l10n.flashcardsFieldFrontLabel,
          used: widget.draft.front.length,
          max: _frontSoftCap,
        ),
        const MxGap(MxSpace.sm),
        MxTextField(
          controller: widget.frontController,
          hintText: l10n.flashcardsFieldFrontHint,
          autofocus: true,
          textInputAction: TextInputAction.next,
          accentBorder: frontIsEmpty ? scheme.primary : null,
          suffixIcon: MxIconButton.compact(
            icon: Icons.mic_none_rounded,
            tooltip: l10n.flashcardsRecordPronunciationTooltip,
            onPressed: null,
          ),
          onChanged: widget.onFrontChanged,
        ),
        const MxGap(MxSpace.lg),
        MxFieldLabel(
          label: l10n.flashcardsFieldBackLabel,
          used: widget.draft.back.length,
          max: _backSoftCap,
        ),
        const MxGap(MxSpace.sm),
        MxTextField(
          controller: widget.backController,
          hintText: l10n.flashcardsFieldBackHint,
          minLines: 2,
          maxLines: 4,
          onChanged: widget.onBackChanged,
        ),
        const MxGap(MxSpace.lg),
        MxFieldLabel(
          label: l10n.flashcardsFieldLabelOptional(
            l10n.flashcardsFieldExampleLabel,
          ),
        ),
        const MxGap(MxSpace.sm),
        MxTextField(
          controller: widget.exampleController,
          hintText: l10n.flashcardsFieldExampleHint,
          minLines: 1,
          maxLines: 3,
          onChanged: widget.onExampleChanged,
        ),
        const MxGap(MxSpace.lg),
        MxFieldLabel(
          label: l10n.flashcardsFieldLabelOptional(
            l10n.flashcardsFieldTagsLabel,
          ),
        ),
        const MxGap(MxSpace.sm),
        MxTagInput(
          tags: widget.draft.tags,
          addLabel: l10n.flashcardsTagsAddAction,
          sheetTitle: l10n.flashcardsTagsSheetTitle,
          hintText: l10n.flashcardsFieldTagsHint,
          confirmLabel: l10n.flashcardsTagsConfirmAction,
          onAdd: widget.onAddTag,
          onRemove: widget.onRemoveTag,
          validate: widget.onValidateTag,
        ),
        const MxGap(MxSpace.lg),
        _AdvancedToggle(
          isOpen: _advancedOpen,
          onTap: () => setState(() => _advancedOpen = !_advancedOpen),
        ),
        if (_advancedOpen) ...[
          const MxGap(MxSpace.sm),
          _AdvancedFields(
            draft: widget.draft,
            pronunciationController: widget.pronunciationController,
            hintController: widget.hintController,
            noteController: widget.noteController,
            onPronunciationChanged: widget.onPronunciationChanged,
            onHintChanged: widget.onHintChanged,
            onNoteChanged: widget.onNoteChanged,
            onStartingStatusChanged: widget.onStartingStatusChanged,
          ),
        ],
      ],
    );
  }
}

class _AdvancedToggle extends StatelessWidget {
  const _AdvancedToggle({required this.isOpen, required this.onTap});

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxSecondaryButton(
      label: isOpen ? l10n.flashcardsHideAdvanced : l10n.flashcardsShowAdvanced,
      variant: MxSecondaryVariant.text,
      leadingIcon: isOpen
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      fullWidth: true,
      onPressed: onTap,
    );
  }
}

class _AdvancedFields extends StatelessWidget {
  const _AdvancedFields({
    required this.draft,
    required this.pronunciationController,
    required this.hintController,
    required this.noteController,
    required this.onPronunciationChanged,
    required this.onHintChanged,
    required this.onNoteChanged,
    required this.onStartingStatusChanged,
  });

  final FlashcardEditorDraftState draft;
  final TextEditingController pronunciationController;
  final TextEditingController hintController;
  final TextEditingController noteController;
  final ValueChanged<String> onPronunciationChanged;
  final ValueChanged<String> onHintChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<FlashcardStartingStatus> onStartingStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxFieldLabel(label: l10n.flashcardsFieldPronunciationLabel),
        const MxGap(MxSpace.sm),
        MxTextField(
          controller: pronunciationController,
          hintText: l10n.flashcardsFieldPronunciationHint,
          suffixIcon: MxIconButton.compact(
            icon: Icons.volume_up_rounded,
            tooltip: l10n.flashcardsListenPronunciationTooltip,
            onPressed: null,
          ),
          onChanged: onPronunciationChanged,
        ),
        const MxGap(MxSpace.lg),
        MxFieldLabel(label: l10n.flashcardsFieldHintLabel),
        const MxGap(MxSpace.sm),
        MxTextField(
          controller: hintController,
          hintText: l10n.flashcardsFieldHintHint,
          minLines: 1,
          maxLines: 3,
          onChanged: onHintChanged,
        ),
        const MxGap(MxSpace.lg),
        MxFieldLabel(label: l10n.flashcardsFieldNoteLabel),
        const MxGap(MxSpace.sm),
        MxTextField(
          controller: noteController,
          hintText: l10n.flashcardsFieldNoteHint,
          minLines: 1,
          maxLines: 3,
          onChanged: onNoteChanged,
        ),
        if (!draft.isEditing) ...[
          const MxGap(MxSpace.lg),
          MxFieldLabel(label: l10n.flashcardsFieldStartingStatusLabel),
          const MxGap(MxSpace.sm),
          MxSegmentedStatus<FlashcardStartingStatus>(
            selected: draft.startingStatus,
            onSelected: onStartingStatusChanged,
            options: [
              MxSegmentedStatusOption(
                value: FlashcardStartingStatus.newCard,
                label: l10n.flashcardsStatusNew,
                dotRole: RepetitionColorRole.first,
              ),
              MxSegmentedStatusOption(
                value: FlashcardStartingStatus.learning,
                label: l10n.flashcardsStatusLearning,
                dotRole: RepetitionColorRole.mid,
              ),
              MxSegmentedStatusOption(
                value: FlashcardStartingStatus.reviewing,
                label: l10n.flashcardsStatusReviewing,
                dotRole: RepetitionColorRole.advanced,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

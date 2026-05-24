import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';

/// Sticky bottom save bar for create / edit card screens.
///
/// Per Design System "05 · Create card", create mode shows two equal-width
/// buttons ("Save & add another" + "Save card"). Edit mode collapses to a
/// single primary "Save changes" button. Both buttons disable until Front +
/// Back have content.
class FlashcardEditorSaveBar extends StatelessWidget {
  const FlashcardEditorSaveBar({
    required this.isEditing,
    required this.canSave,
    required this.onSave,
    required this.onSaveAndAddNext,
    super.key,
  });

  final bool isEditing;
  final bool canSave;
  final VoidCallback onSave;
  final VoidCallback onSaveAndAddNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final saveLabel = isEditing
        ? l10n.flashcardsSaveChanges
        : l10n.flashcardsSaveAction;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            MxSpace.lg,
            MxSpace.sm,
            MxSpace.lg,
            MxSpace.md,
          ),
          child: Row(
            children: [
              if (!isEditing) ...[
                Expanded(
                  child: MxSecondaryButton(
                    label: l10n.flashcardsSaveAndAddNext,
                    variant: MxSecondaryVariant.outlined,
                    fullWidth: true,
                    onPressed: canSave ? onSaveAndAddNext : null,
                  ),
                ),
                const MxGap(MxSpace.sm),
              ],
              Expanded(
                child: MxPrimaryButton(
                  label: saveLabel,
                  fullWidth: true,
                  onPressed: canSave ? onSave : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

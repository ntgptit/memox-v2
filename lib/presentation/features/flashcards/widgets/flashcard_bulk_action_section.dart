import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_bulk_action_bar.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';

class FlashcardBulkActionSection extends StatelessWidget {
  const FlashcardBulkActionSection({
    required this.selectionCount,
    required this.totalItemCount,
    required this.onToggleSelectionMode,
    required this.onMove,
    required this.onExport,
    required this.onDelete,
    super.key,
  });

  final int selectionCount;
  final int totalItemCount;
  final VoidCallback onToggleSelectionMode;
  final VoidCallback onMove;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxBulkActionBar(
      label: l10n.flashcardsBulkSelected(selectionCount),
      subtitle: l10n.flashcardsBulkSubtitle,
      actions: [
        MxSecondaryButton(
          label: selectionCount == totalItemCount
              ? l10n.commonClear
              : l10n.commonSelectAll,
          variant: MxSecondaryVariant.text,
          onPressed: onToggleSelectionMode,
        ),
        MxSecondaryButton(
          label: l10n.commonMove,
          leadingIcon: Icons.drive_file_move_outline,
          variant: MxSecondaryVariant.outlined,
          onPressed: onMove,
        ),
        MxSecondaryButton(
          label: l10n.commonExport,
          leadingIcon: Icons.file_download_outlined,
          variant: MxSecondaryVariant.outlined,
          onPressed: onExport,
        ),
        MxPrimaryButton(
          label: l10n.commonDelete,
          leadingIcon: Icons.delete_outline,
          tone: MxPrimaryButtonTone.danger,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

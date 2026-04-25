import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';

class FolderEmptyStateSection extends StatelessWidget {
  const FolderEmptyStateSection({
    required this.onCreateSubfolder,
    required this.onCreateDeck,
    super.key,
  });

  final VoidCallback onCreateSubfolder;
  final VoidCallback onCreateDeck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        MxEmptyState(
          title: l10n.foldersEmptyTitle,
          message: l10n.foldersEmptyMessage,
          icon: Icons.folder_open_outlined,
        ),
        const MxGap(MxSpace.lg),
        Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          alignment: WrapAlignment.center,
          children: [
            MxPrimaryButton(
              label: l10n.foldersNewSubfolderTooltip,
              leadingIcon: Icons.create_new_folder_outlined,
              onPressed: onCreateSubfolder,
            ),
            MxSecondaryButton(
              label: l10n.foldersNewDeckTooltip,
              leadingIcon: Icons.style_outlined,
              variant: MxSecondaryVariant.outlined,
              onPressed: onCreateDeck,
            ),
          ],
        ),
      ],
    );
  }
}

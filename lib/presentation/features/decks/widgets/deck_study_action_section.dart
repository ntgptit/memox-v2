import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_section.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';

class DeckStudyActionSection extends StatelessWidget {
  const DeckStudyActionSection({
    required this.onOpenFlashcards,
    required this.onAddFlashcard,
    required this.onImport,
    required this.onStartStudy,
    super.key,
  });

  final VoidCallback onOpenFlashcards;
  final VoidCallback onAddFlashcard;
  final VoidCallback onImport;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxSection(
      title: l10n.decksManageContentTitle,
      subtitle: l10n.decksManageContentSubtitle,
      child: Wrap(
        spacing: MxSpace.sm,
        runSpacing: MxSpace.sm,
        children: [
          MxPrimaryButton(
            label: l10n.studyStartAction,
            leadingIcon: Icons.play_arrow_rounded,
            onPressed: onStartStudy,
          ),
          MxSecondaryButton(
            label: l10n.flashcardsOpenListAction,
            leadingIcon: Icons.view_list_outlined,
            variant: MxSecondaryVariant.outlined,
            onPressed: onOpenFlashcards,
          ),
          MxSecondaryButton(
            label: l10n.flashcardsAddAction,
            leadingIcon: Icons.add,
            variant: MxSecondaryVariant.outlined,
            onPressed: onAddFlashcard,
          ),
          MxSecondaryButton(
            label: l10n.commonImport,
            leadingIcon: Icons.file_upload_outlined,
            variant: MxSecondaryVariant.outlined,
            onPressed: onImport,
          ),
        ],
      ),
    );
  }
}

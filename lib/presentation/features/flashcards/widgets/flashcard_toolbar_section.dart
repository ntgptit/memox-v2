import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';

class FlashcardToolbarSection extends StatelessWidget {
  const FlashcardToolbarSection({
    required this.selectedSort,
    required this.isReorderMode,
    required this.canManualReorder,
    required this.canStartStudy,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSortSelected,
    required this.onCancelReorder,
    required this.onSaveReorder,
    required this.onStartStudy,
    required this.onImport,
    required this.onStartReorder,
    super.key,
  });

  final ContentSortMode selectedSort;
  final bool isReorderMode;
  final bool canManualReorder;
  final bool canStartStudy;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<ContentSortMode> onSortSelected;
  final VoidCallback onCancelReorder;
  final VoidCallback onSaveReorder;
  final VoidCallback onStartStudy;
  final VoidCallback onImport;
  final VoidCallback onStartReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sortOptions = buildContentSortOptions(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSearchSortToolbar<ContentSortMode>(
          searchHintText: l10n.flashcardsSearchHint,
          onSearchChanged: onSearchChanged,
          onSearchClear: onSearchClear,
          sortOptions: sortOptions,
          selectedSort: selectedSort,
          sortLabel: l10n.commonSort,
          onSortSelected: onSortSelected,
        ),
        const MxGap(MxSpace.md),
        _buildActions(l10n),
      ],
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    if (isReorderMode) {
      return _ReorderActionGroup(
        cancelLabel: l10n.commonCancel,
        saveLabel: l10n.commonSaveOrder,
        onCancel: onCancelReorder,
        onSave: onSaveReorder,
      );
    }
    return _DeckActionGroup(
      studyLabel: l10n.studyStartAction,
      importLabel: l10n.commonImport,
      reorderLabel: l10n.commonReorder,
      canStartStudy: canStartStudy,
      canReorder: canManualReorder,
      onStartStudy: onStartStudy,
      onImport: onImport,
      onReorder: onStartReorder,
    );
  }
}

class _DeckActionGroup extends StatelessWidget {
  const _DeckActionGroup({
    required this.studyLabel,
    required this.importLabel,
    required this.reorderLabel,
    required this.canStartStudy,
    required this.canReorder,
    required this.onStartStudy,
    required this.onImport,
    required this.onReorder,
  });

  final String studyLabel;
  final String importLabel;
  final String reorderLabel;
  final bool canStartStudy;
  final bool canReorder;
  final VoidCallback onStartStudy;
  final VoidCallback onImport;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildCompact();
        }
        return _buildWide();
      },
    );
  }

  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxPrimaryButton(
          label: studyLabel,
          leadingIcon: Icons.play_arrow_rounded,
          size: MxButtonSize.large,
          fullWidth: true,
          onPressed: canStartStudy ? onStartStudy : null,
        ),
        const MxGap(MxSpace.sm),
        Row(
          children: [
            Expanded(
              child: MxSecondaryButton(
                label: importLabel,
                leadingIcon: Icons.file_upload_outlined,
                variant: MxSecondaryVariant.outlined,
                fullWidth: true,
                onPressed: onImport,
              ),
            ),
            const MxGap(MxSpace.sm),
            Expanded(
              child: MxSecondaryButton(
                label: reorderLabel,
                leadingIcon: Icons.reorder_rounded,
                variant: MxSecondaryVariant.outlined,
                fullWidth: true,
                onPressed: canReorder ? onReorder : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MxSecondaryButton(
          label: importLabel,
          leadingIcon: Icons.file_upload_outlined,
          variant: MxSecondaryVariant.outlined,
          onPressed: onImport,
        ),
        const MxGap(MxSpace.sm),
        MxSecondaryButton(
          label: reorderLabel,
          leadingIcon: Icons.reorder_rounded,
          variant: MxSecondaryVariant.outlined,
          onPressed: canReorder ? onReorder : null,
        ),
        const MxGap(MxSpace.md),
        MxPrimaryButton(
          label: studyLabel,
          leadingIcon: Icons.play_arrow_rounded,
          onPressed: canStartStudy ? onStartStudy : null,
        ),
      ],
    );
  }
}

class _ReorderActionGroup extends StatelessWidget {
  const _ReorderActionGroup({
    required this.cancelLabel,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
  });

  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildCompact();
        }
        return _buildWide();
      },
    );
  }

  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxPrimaryButton(
          label: saveLabel,
          size: MxButtonSize.large,
          fullWidth: true,
          onPressed: onSave,
        ),
        const MxGap(MxSpace.xs),
        MxSecondaryButton(
          label: cancelLabel,
          variant: MxSecondaryVariant.text,
          fullWidth: true,
          onPressed: onCancel,
        ),
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MxSecondaryButton(
          label: cancelLabel,
          variant: MxSecondaryVariant.text,
          onPressed: onCancel,
        ),
        const MxGap(MxSpace.sm),
        MxPrimaryButton(label: saveLabel, onPressed: onSave),
      ],
    );
  }
}

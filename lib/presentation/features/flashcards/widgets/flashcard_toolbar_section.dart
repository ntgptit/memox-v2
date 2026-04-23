import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';

class FlashcardToolbarSection extends StatelessWidget {
  const FlashcardToolbarSection({
    required this.selectedSort,
    required this.isReorderMode,
    required this.canManualReorder,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSortSelected,
    required this.onCancelReorder,
    required this.onSaveReorder,
    required this.onImport,
    required this.onStartReorder,
    super.key,
  });

  final ContentSortMode selectedSort;
  final bool isReorderMode;
  final bool canManualReorder;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<ContentSortMode> onSortSelected;
  final VoidCallback onCancelReorder;
  final VoidCallback onSaveReorder;
  final VoidCallback onImport;
  final VoidCallback onStartReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sortOptions = buildContentSortOptions(l10n);

    return MxSearchSortToolbar<ContentSortMode>(
      searchHintText: l10n.flashcardsSearchHint,
      onSearchChanged: onSearchChanged,
      onSearchClear: onSearchClear,
      sortOptions: sortOptions,
      selectedSort: selectedSort,
      sortLabel: l10n.commonSort,
      onSortSelected: onSortSelected,
      trailing: isReorderMode
          ? <Widget>[
              MxSecondaryButton(
                label: l10n.commonCancel,
                variant: MxSecondaryVariant.text,
                onPressed: onCancelReorder,
              ),
              MxPrimaryButton(
                label: l10n.commonSaveOrder,
                onPressed: onSaveReorder,
              ),
            ]
          : <Widget>[
              MxSecondaryButton(
                label: l10n.commonImport,
                leadingIcon: Icons.file_upload_outlined,
                variant: MxSecondaryVariant.outlined,
                onPressed: onImport,
              ),
              MxSecondaryButton(
                label: l10n.commonReorder,
                leadingIcon: Icons.reorder_rounded,
                variant: MxSecondaryVariant.outlined,
                onPressed: canManualReorder ? onStartReorder : null,
              ),
            ],
    );
  }
}

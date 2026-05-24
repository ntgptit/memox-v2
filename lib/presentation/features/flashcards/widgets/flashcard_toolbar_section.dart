import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/widgets/mx_button_size.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_search_field.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_section_header.dart';

/// Compact "Cards" header + tools row.
///
/// One row contains the section title and a cluster of icon-only actions:
/// search, sort, import, reorder. The search input expands inline only when
/// the user taps the search icon, keeping the deck-detail screen low-noise
/// despite the screen carrying multiple content sections.
class FlashcardToolbarSection extends StatefulWidget {
  const FlashcardToolbarSection({
    required this.selectedSort,
    required this.isReorderMode,
    required this.canManualReorder,
    required this.searchTerm,
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
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<ContentSortMode> onSortSelected;
  final VoidCallback onCancelReorder;
  final VoidCallback onSaveReorder;
  final VoidCallback onImport;
  final VoidCallback onStartReorder;

  @override
  State<FlashcardToolbarSection> createState() =>
      _FlashcardToolbarSectionState();
}

class _FlashcardToolbarSectionState extends State<FlashcardToolbarSection> {
  bool _searchOpen = false;

  bool get _isSearchVisible => _searchOpen || widget.searchTerm.isNotEmpty;

  void _toggleSearch() {
    if (_isSearchVisible && widget.searchTerm.isNotEmpty) {
      widget.onSearchClear();
    }
    setState(() => _searchOpen = !_searchOpen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.isReorderMode) {
      return _ReorderActionGroup(
        cancelLabel: l10n.commonCancel,
        saveLabel: l10n.commonSaveOrder,
        onCancel: widget.onCancelReorder,
        onSave: widget.onSaveReorder,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: MxSectionHeader(
                title: l10n.flashcardsCardsSectionTitle,
              ),
            ),
            const MxGap(MxSpace.xs),
            MxIconButton(
              icon:
                  _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
              tooltip: l10n.commonSearch,
              onPressed: _toggleSearch,
            ),
            const MxGap(MxSpace.xs),
            _SortIconMenu(
              options: buildContentSortOptions(l10n),
              selectedSort: widget.selectedSort,
              tooltip: l10n.commonSort,
              title: l10n.commonSort,
              onSelected: widget.onSortSelected,
            ),
            const MxGap(MxSpace.xs),
            MxIconButton(
              icon: Icons.file_upload_outlined,
              tooltip: l10n.commonImport,
              onPressed: widget.onImport,
            ),
            const MxGap(MxSpace.xs),
            MxIconButton(
              icon: Icons.reorder_rounded,
              tooltip: l10n.commonReorder,
              onPressed:
                  widget.canManualReorder ? widget.onStartReorder : null,
            ),
          ],
        ),
        if (_isSearchVisible) ...[
          const MxGap(MxSpace.sm),
          MxSearchField(
            hintText: l10n.flashcardsSearchHint,
            autofocus: true,
            onChanged: widget.onSearchChanged,
            onClear: widget.onSearchClear,
          ),
        ],
      ],
    );
  }
}

class _SortIconMenu extends StatelessWidget {
  const _SortIconMenu({
    required this.options,
    required this.selectedSort,
    required this.tooltip,
    required this.title,
    required this.onSelected,
  });

  final List<MxSortOption<ContentSortMode>> options;
  final ContentSortMode selectedSort;
  final String tooltip;
  final String title;
  final ValueChanged<ContentSortMode> onSelected;

  Future<void> _openSheet(BuildContext context) async {
    final picked = await MxBottomSheet.show<ContentSortMode>(
      context: context,
      title: title,
      child: MxActionSheetList<ContentSortMode>(
        items: [
          for (final option in options)
            MxActionSheetItem(
              value: option.value,
              label: option.label,
              icon: option.value == selectedSort
                  ? Icons.check_rounded
                  : option.icon ?? Icons.swap_vert_rounded,
            ),
        ],
      ),
    );
    if (picked == null) return;
    onSelected(picked);
  }

  @override
  Widget build(BuildContext context) => MxIconButton(
      icon: Icons.sort_rounded,
      tooltip: tooltip,
      onPressed: () => _openSheet(context),
    );
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
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
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
      },
    );
}

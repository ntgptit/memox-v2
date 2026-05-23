import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_chip.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_search_field.dart';
import '../../../shared/widgets/mx_text.dart';

/// Library top section per Design System "02 · Library".
///
/// Layout: title + search-toggle on a single row, with a scrollable filter
/// chip bar underneath. The search field is hidden by default and reveals
/// inline when the user taps the search icon.
class LibraryAppBar extends StatelessWidget {
  const LibraryAppBar({
    required this.title,
    required this.isSearchOpen,
    required this.onToggleSearch,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.chips,
    super.key,
  });

  final String title;
  final bool isSearchOpen;
  final VoidCallback onToggleSearch;
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final List<LibraryFilterChip> chips;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: MxText(title, role: MxTextRole.pageTitle)),
            MxIconButton(
              icon: isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              tooltip: l10n.commonSearch,
              onPressed: () {
                if (isSearchOpen && searchTerm.isNotEmpty) {
                  onSearchClear();
                }
                onToggleSearch();
              },
            ),
          ],
        ),
        if (isSearchOpen) ...[
          const MxGap(MxSpace.sm),
          MxSearchField(
            hintText: l10n.commonSearch,
            autofocus: true,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
          ),
        ],
        if (chips.isNotEmpty) ...[
          const MxGap(MxSpace.sm),
          SizedBox(
            height: _chipBarHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const MxGap(MxSpace.xs),
              itemBuilder: (context, index) {
                final chip = chips[index];
                return MxChip(
                  label: chip.label,
                  selected: chip.selected,
                  onTap: chip.onTap,
                  count: chip.count,
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// guard:raw-size-reviewed Filter chip bar height accommodates the chip
  /// tap target plus a small breathing margin per Design System spec.
  static const double _chipBarHeight = 40;
}

/// Filter chip declaration used by [LibraryAppBar].
class LibraryFilterChip {
  const LibraryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';
import 'mx_chip.dart';
import 'mx_search_field.dart';

/// Sort option rendered by [MxSearchSortToolbar].
class MxSortOption<T> {
  const MxSortOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Search field plus optional sort picker / trailing actions.
class MxSearchSortToolbar<T> extends StatelessWidget {
  MxSearchSortToolbar({
    this.searchController,
    this.searchHintText,
    this.autofocus = false,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchClear,
    this.textInputAction = TextInputAction.search,
    this.focusNode,
    this.sortOptions = const [],
    this.selectedSort,
    this.onSortSelected,
    this.sortLabel,
    this.trailing = const [],
    super.key,
  }) : assert(sortOptions.isEmpty || onSortSelected != null),
       assert(
         sortOptions.isEmpty ||
             sortLabel != null ||
             _hasSelectedOption(sortOptions, selectedSort),
       );

  final TextEditingController? searchController;
  final String? searchHintText;
  final bool autofocus;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchClear;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final List<MxSortOption<T>> sortOptions;
  final T? selectedSort;
  final ValueChanged<T>? onSortSelected;
  final String? sortLabel;
  final List<Widget> trailing;

  static bool _hasSelectedOption<T>(
    List<MxSortOption<T>> sortOptions,
    T? selectedSort,
  ) {
    if (selectedSort == null) return false;
    return sortOptions.any((option) => option.value == selectedSort);
  }

  @override
  Widget build(BuildContext context) {
    final searchField = MxSearchField(
      controller: searchController,
      hintText: searchHintText,
      autofocus: autofocus,
      onChanged: onSearchChanged,
      onSubmitted: onSearchSubmitted,
      onClear: onSearchClear,
      textInputAction: textInputAction,
      focusNode: focusNode,
    );

    final actionWidgets = _buildActionWidgets();
    if (actionWidgets.isEmpty) return searchField;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 640;
        final actions = Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.end,
          children: actionWidgets,
        );

        if (isStacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchField, const MxGap(AppSpacing.md), actions],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: searchField),
            const MxGap(AppSpacing.md),
            Flexible(
              child: Align(alignment: Alignment.topRight, child: actions),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildActionWidgets() {
    final widgets = <Widget>[];

    final selectedOption = _selectedOption;
    if (sortOptions.isNotEmpty) {
      widgets.add(
        MenuAnchor(
          builder: (context, controller, _) => MxChip(
            label: selectedOption?.label ?? sortLabel!,
            icon: selectedOption?.icon ?? Icons.swap_vert_rounded,
            selected: selectedOption != null,
            tone: selectedOption != null
                ? MxChipTone.primary
                : MxChipTone.neutral,
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
          menuChildren: [
            for (final option in sortOptions)
              MenuItemButton(
                leadingIcon: option.icon != null
                    ? Icon(option.icon, size: AppIconSizes.sm)
                    : null,
                onPressed: () => onSortSelected?.call(option.value),
                child: Text(option.label),
              ),
          ],
        ),
      );
    }

    widgets.addAll(trailing);
    return widgets;
  }

  MxSortOption<T>? get _selectedOption {
    for (final option in sortOptions) {
      if (option.value == selectedSort) return option;
    }
    return null;
  }
}

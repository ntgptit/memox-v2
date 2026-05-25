import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_button_size.dart';
import 'mx_search_field.dart';
import 'mx_secondary_button.dart';
import 'mx_tappable.dart';

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
        // Compact + only the sort menu → drop the chip and inline an icon-only
        // sort trigger next to the search field, the Quizlet-mobile pattern.
        // Trailing actions (eg. "Save order" while reordering) still stack.
        final inlineSortOnly =
            isStacked &&
            trailing.isEmpty &&
            sortOptions.isNotEmpty &&
            actionWidgets.length == 1;
        if (inlineSortOnly) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: searchField),
              const MxGap(AppSpacing.sm),
              _buildSortIconTrigger(context),
            ],
          );
        }

        final stackedAlignment = actionWidgets.length > 1
            ? WrapAlignment.end
            : WrapAlignment.start;
        final actions = Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: isStacked ? stackedAlignment : WrapAlignment.end,
          children: actionWidgets,
        );

        if (isStacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchField, const MxGap(AppSpacing.sm), actions],
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

  Widget _buildSortIconTrigger(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedOption = _selectedOption;
    final tooltipLabel =
        selectedOption?.label ?? sortLabel ?? sortOptions.first.label;
    // Match the search field's pill shape (fill + outline + radius) so the
    // sort trigger reads as part of the same toolbar instead of a floating
    // circular icon button next to it.
    return MenuAnchor(
      builder: (context, controller, _) => MxTappable(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.input,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        backgroundColor: scheme.surfaceContainerLow,
        semanticsLabel: tooltipLabel,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Tooltip(
          message: tooltipLabel,
          child: SizedBox(
            height: kMinInteractiveDimension,
            width: kMinInteractiveDimension,
            child: Center(
              child: Icon(
                selectedOption?.icon ?? Icons.swap_vert_rounded,
                size: AppIconSizes.lg,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
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
    );
  }

  List<Widget> _buildActionWidgets() {
    final widgets = <Widget>[];

    final selectedOption = _selectedOption;
    if (sortOptions.isNotEmpty) {
      final triggerLabel =
          selectedOption?.label ?? sortLabel ?? sortOptions.first.label;
      widgets.add(
        MenuAnchor(
          builder: (context, controller, _) => MxSecondaryButton(
            label: triggerLabel,
            leadingIcon: selectedOption?.icon ?? Icons.swap_vert_rounded,
            size: MxButtonSize.small,
            variant: selectedOption != null
                ? MxSecondaryVariant.tonal
                : MxSecondaryVariant.outlined,
            onPressed: () =>
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

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import 'mx_primary_button.dart';
import 'mx_secondary_button.dart';
import 'mx_search_sort_toolbar.dart' show MxSortOption;

/// Compact menu trigger backed by a shared secondary button and [MenuAnchor] so
/// feature code can offer a sort or filter dropdown without instantiating raw
/// Material menu widgets.
///
/// Matches the visual contract of the sort trigger embedded in
/// [MxSearchSortToolbar] so screens that want the trigger placed elsewhere stay
/// visually consistent.
class MxSortMenuChip<T> extends StatelessWidget {
  const MxSortMenuChip({
    required this.options,
    required this.selectedValue,
    required this.fallbackLabel,
    required this.onSelected,
    this.fallbackIcon = Icons.swap_vert_rounded,
    super.key,
  });

  final List<MxSortOption<T>> options;
  final T? selectedValue;
  final String fallbackLabel;
  final IconData fallbackIcon;
  final ValueChanged<T> onSelected;

  MxSortOption<T>? get _selectedOption {
    for (final option in options) {
      if (option.value == selectedValue) return option;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedOption;
    return MenuAnchor(
      builder: (context, controller, _) => MxSecondaryButton(
        label: selected?.label ?? fallbackLabel,
        leadingIcon: selected?.icon ?? fallbackIcon,
        size: MxButtonSize.small,
        variant: selected != null
            ? MxSecondaryVariant.tonal
            : MxSecondaryVariant.outlined,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            leadingIcon: option.icon != null
                ? Icon(option.icon, size: AppIconSizes.sm)
                : null,
            onPressed: () => onSelected(option.value),
            child: Text(option.label),
          ),
      ],
    );
  }
}

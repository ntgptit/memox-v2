import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/mx_gap.dart';
import '../widgets/mx_search_field.dart';
import 'mx_action_sheet_list.dart';
import 'mx_bottom_sheet.dart';

/// Picker option rendered by [MxDestinationPickerSheet].
class MxDestinationOption<T> {
  const MxDestinationOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.searchTerms = const [],
  });

  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool enabled;
  final List<String> searchTerms;
}

/// Searchable destination picker intended for move / relocate flows.
class MxDestinationPickerSheet<T> extends StatefulWidget {
  const MxDestinationPickerSheet({
    required this.destinations,
    this.selectedValue,
    this.searchHintText,
    this.emptyLabel,
    this.showSearch = true,
    this.maxListHeight = _defaultMaxListHeight,
    this.onSelected,
    this.popOnSelect = true,
    this.initialQuery,
    super.key,
  });

  static const double _defaultMaxListHeight = 360;

  final List<MxDestinationOption<T>> destinations;
  final T? selectedValue;
  final String? searchHintText;
  final String? emptyLabel;
  final bool showSearch;
  final double maxListHeight;
  final ValueChanged<T>? onSelected;
  final bool popOnSelect;
  final String? initialQuery;

  static Future<T?> show<T>({
    required BuildContext context,
    required List<MxDestinationOption<T>> destinations,
    String? title,
    T? selectedValue,
    String? searchHintText,
    String? emptyLabel,
    bool showSearch = true,
    double maxListHeight = _defaultMaxListHeight,
    ValueChanged<T>? onSelected,
    bool popOnSelect = true,
    String? initialQuery,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
  }) {
    return MxBottomSheet.show<T>(
      context: context,
      title: title,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      child: MxDestinationPickerSheet<T>(
        destinations: destinations,
        selectedValue: selectedValue,
        searchHintText: searchHintText,
        emptyLabel: emptyLabel,
        showSearch: showSearch,
        maxListHeight: maxListHeight,
        onSelected: onSelected,
        popOnSelect: popOnSelect,
        initialQuery: initialQuery,
      ),
    );
  }

  @override
  State<MxDestinationPickerSheet<T>> createState() =>
      _MxDestinationPickerSheetState<T>();
}

class _MxDestinationPickerSheetState<T>
    extends State<MxDestinationPickerSheet<T>> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  String get _query => _controller.text.trim().toLowerCase();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDestinations = widget.destinations
        .where((destination) => _matchesQuery(destination, _query))
        .toList(growable: false);
    final content = filteredDestinations.isEmpty
        ? _MxDestinationEmptyState(label: widget.emptyLabel)
        : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxListHeight),
            child: MxActionSheetList<T>(
              items: [
                for (final destination in filteredDestinations)
                  MxActionSheetItem<T>(
                    value: destination.value,
                    label: destination.title,
                    subtitle: destination.subtitle,
                    icon: destination.icon,
                    trailing: destination.trailing,
                    enabled: destination.enabled,
                  ),
              ],
              selectedValue: widget.selectedValue,
              onSelected: widget.onSelected,
              popOnSelect: widget.popOnSelect,
              shrinkWrap: false,
              physics: const ClampingScrollPhysics(),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSearch) ...[
          MxSearchField(
            controller: _controller,
            hintText: widget.searchHintText,
            onChanged: (_) => setState(() {}),
            onClear: () => setState(() {}),
          ),
          const MxGap(AppSpacing.md),
        ],
        content,
      ],
    );
  }

  bool _matchesQuery(MxDestinationOption<T> destination, String query) {
    if (query.isEmpty) return true;

    final haystack = [
      destination.title,
      if (destination.subtitle != null) destination.subtitle!,
      ...destination.searchTerms,
    ].join(' ').toLowerCase();

    return haystack.contains(query);
  }
}

class _MxDestinationEmptyState extends StatelessWidget {
  const _MxDestinationEmptyState({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: AppIconSizes.lg,
            color: scheme.onSurfaceVariant,
          ),
          if (label != null) ...[
            const MxGap(AppSpacing.sm),
            Text(
              label!,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

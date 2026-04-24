import 'package:flutter/material.dart';

/// A thin wrapper around [SegmentedButton] that takes typed options and
/// exposes a simpler callback.
class MxSegment<T> {
  const MxSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class MxSegmentedControl<T> extends StatelessWidget {
  const MxSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = false,
    super.key,
  });

  final List<MxSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments
          .map(
            (s) => ButtonSegment<T>(
              value: s.value,
              label: Text(s.label),
              icon: s.icon != null ? Icon(s.icon) : null,
            ),
          )
          .toList(growable: false),
      selected: selected,
      onSelectionChanged: onChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon,
    );
  }
}

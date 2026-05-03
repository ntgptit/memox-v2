import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';

/// A thin wrapper around [SegmentedButton] that takes typed options and
/// exposes a simpler callback.
class MxSegment<T> {
  const MxSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

enum MxSegmentedControlDensity { regular, compact }

class MxSegmentedControl<T> extends StatelessWidget {
  const MxSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = false,
    this.adaptive = false,
    this.density = MxSegmentedControlDensity.regular,
    super.key,
  });

  /// guard:raw-size-reviewed fallback threshold for regular segmented labels.
  static const double _minimumSegmentWidth = 112;

  /// guard:raw-size-reviewed compact segmented labels fit three options on phones.
  static const double _compactMinimumSegmentWidth = 88;

  static const double _largeTextScale = 1.3;

  final List<MxSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final bool adaptive;
  final MxSegmentedControlDensity density;

  @override
  Widget build(BuildContext context) {
    if (adaptive) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (_shouldUseListFallback(context, constraints)) {
            return _AdaptiveSegmentList<T>(
              segments: segments,
              selected: selected,
              onChanged: onChanged,
              multiSelectionEnabled: multiSelectionEnabled,
              emptySelectionAllowed: emptySelectionAllowed,
              density: density,
            );
          }

          return _buildSegmentedButton(context);
        },
      );
    }

    return _buildSegmentedButton(context);
  }

  Widget _buildSegmentedButton(BuildContext context) {
    return SegmentedButton<T>(
      style: _style(context),
      segments: segments
          .map(
            (s) => ButtonSegment<T>(
              value: s.value,
              label: Text(s.label),
              icon: s.icon != null
                  ? Icon(
                      s.icon,
                      size: density == MxSegmentedControlDensity.compact
                          ? AppIconSizes.sm
                          : null,
                    )
                  : null,
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

  ButtonStyle? _style(BuildContext context) {
    if (density != MxSegmentedControlDensity.compact) {
      return null;
    }

    final compactStyle = ButtonStyle(
      iconSize: const WidgetStatePropertyAll(AppIconSizes.sm),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, AppSpacing.xxxxl)),
      visualDensity: VisualDensity.compact,
    );

    final theme = Theme.of(context);
    final baseStyle = theme.segmentedButtonTheme.style;
    return baseStyle == null ? compactStyle : baseStyle.merge(compactStyle);
  }

  bool _shouldUseListFallback(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    if (!constraints.hasBoundedWidth) {
      return true;
    }
    final minimumSegmentWidth = density == MxSegmentedControlDensity.compact
        ? _compactMinimumSegmentWidth
        : _minimumSegmentWidth;
    final preferredWidth = segments.length * minimumSegmentWidth;

    return constraints.maxWidth < preferredWidth ||
        textScale >= _largeTextScale;
  }
}

class _AdaptiveSegmentList<T> extends StatelessWidget {
  const _AdaptiveSegmentList({
    required this.segments,
    required this.selected,
    required this.onChanged,
    required this.multiSelectionEnabled,
    required this.emptySelectionAllowed,
    required this.density,
  });

  final List<MxSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final MxSegmentedControlDensity density;

  @override
  Widget build(BuildContext context) {
    final children = segments
        .map(
          (segment) => multiSelectionEnabled
              ? _buildCheckboxTile(segment)
              : _buildRadioTile(segment),
        )
        .toList(growable: false);

    if (!multiSelectionEnabled) {
      return RadioGroup<T>(
        groupValue: selected.isEmpty ? null : selected.first,
        onChanged: (value) {
          if (value == null) {
            onChanged(<T>{});
            return;
          }
          onChanged(<T>{value});
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildRadioTile(MxSegment<T> segment) {
    return RadioListTile<T>(
      value: segment.value,
      toggleable: emptySelectionAllowed,
      title: Text(segment.label),
      secondary: segment.icon != null
          ? Icon(
              segment.icon,
              size: density == MxSegmentedControlDensity.compact
                  ? AppIconSizes.sm
                  : null,
            )
          : null,
      selected: selected.contains(segment.value),
      dense: density == MxSegmentedControlDensity.compact,
    );
  }

  Widget _buildCheckboxTile(MxSegment<T> segment) {
    return CheckboxListTile(
      value: selected.contains(segment.value),
      title: Text(segment.label),
      secondary: segment.icon != null
          ? Icon(
              segment.icon,
              size: density == MxSegmentedControlDensity.compact
                  ? AppIconSizes.sm
                  : null,
            )
          : null,
      dense: density == MxSegmentedControlDensity.compact,
      onChanged: (checked) {
        final next = Set<T>.of(selected);
        if (checked ?? false) {
          next.add(segment.value);
          if (next.isEmpty && !emptySelectionAllowed) return;
          onChanged(next);
          return;
        }
        next.remove(segment.value);
        if (next.isEmpty && !emptySelectionAllowed) return;
        onChanged(next);
      },
    );
  }
}

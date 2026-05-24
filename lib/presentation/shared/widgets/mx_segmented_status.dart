import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

/// Single option inside an [MxSegmentedStatus].
class MxSegmentedStatusOption<T> {
  const MxSegmentedStatusOption({
    required this.value,
    required this.label,
    required this.dotRole,
  });

  final T value;
  final String label;

  /// Semantic role for the status dot. The widget resolves the concrete color
  /// through `customColors.repetitionColor(role)` so segments stay aligned
  /// with the rest of the app's mastery palette.
  final RepetitionColorRole dotRole;
}

/// Equal-width segmented pill row showing initial SRS status options.
///
/// Used in the create-card form for "Starting status" — selected segment is
/// outlined in the brand primary and tinted with the disabledSurface alpha.
class MxSegmentedStatus<T> extends StatelessWidget {
  const MxSegmentedStatus({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<MxSegmentedStatusOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _Segment<T>(
              option: options[index],
              isSelected: options[index].value == selected,
              onTap: () => onSelected(options[index].value),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final MxSegmentedStatusOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dotColor = context.mxColors.repetitionColor(option.dotRole);
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
      side: BorderSide(
        color: isSelected
            ? scheme.primary
            : scheme.outlineVariant.withValues(alpha: AppOpacity.ghostBorder),
      ),
    );
    final background = isSelected
        ? scheme.primary.withValues(alpha: AppOpacity.disabledSurface)
        : scheme.surfaceContainerLowest;

    return MxTappable(
      shape: shape,
      backgroundColor: background,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusDot(color: dotColor),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: MxText(
                option.label,
                role: MxTextRole.tileTrailing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: isSelected ? scheme.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sm,
      height: AppSpacing.sm,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

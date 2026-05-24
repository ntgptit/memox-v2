import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/utils/string_utils.dart';
import 'mx_text.dart';

/// Overline label rendered above a form field.
///
/// Optional trailing character counter — `used / max` — uses tabular figures
/// and turns warning-toned once the soft cap is exceeded (per Design System
/// "05 · Create card", soft limit, never blocks input).
class MxFieldLabel extends StatelessWidget {
  const MxFieldLabel({
    required this.label,
    this.used,
    this.max,
    super.key,
  });

  /// Label text — converted to uppercase per the overline role.
  final String label;

  /// Current character count. Pass `null` to hide the counter entirely.
  final int? used;

  /// Soft maximum. Counter renders only when both [used] and [max] are
  /// supplied. The field stays writable past the cap; the counter shifts to
  /// the theme's error color as a visual hint.
  final int? max;

  @override
  Widget build(BuildContext context) {
    final showCounter = used != null && max != null;
    final isOver = showCounter && used! > max!;
    final counterColor = isOver
        ? Theme.of(context).colorScheme.error
        : Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.disabled);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: MxText(
            StringUtils.upperCaseToEmpty(label),
            role: MxTextRole.overline,
          ),
        ),
        if (showCounter)
          MxText(
            '${used!} / ${max!}',
            role: MxTextRole.overline,
            color: counterColor,
          ),
      ],
    );
  }
}

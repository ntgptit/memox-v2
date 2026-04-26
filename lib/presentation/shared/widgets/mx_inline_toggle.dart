import 'package:flutter/material.dart';

import '../layouts/mx_gap.dart';
import '../layouts/mx_space.dart';
import 'mx_text.dart';

class MxInlineToggle extends StatelessWidget {
  const MxInlineToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, color: scheme.primary),
          const MxGap(MxSpace.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MxText(label, role: MxTextRole.formLabel),
              if (subtitle != null) ...[
                const MxGap(MxSpace.xs),
                MxText(subtitle!, role: MxTextRole.formHelper),
              ],
            ],
          ),
        ),
        const MxGap(MxSpace.sm),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

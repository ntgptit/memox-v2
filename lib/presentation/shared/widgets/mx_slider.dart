import 'package:flutter/material.dart';

import '../layouts/mx_gap.dart';
import '../layouts/mx_space.dart';
import 'mx_text.dart';

class MxSlider extends StatelessWidget {
  const MxSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.valueLabel,
    super.key,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: MxText(label, role: MxTextRole.formLabel)),
            if (valueLabel != null)
              MxText(valueLabel!, role: MxTextRole.tileMeta),
          ],
        ),
        const MxGap(MxSpace.xs),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

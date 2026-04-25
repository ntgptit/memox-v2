import 'package:flutter/material.dart';

import '../../../../shared/layouts/mx_gap.dart';
import '../../../../shared/layouts/mx_space.dart';
import '../../../../shared/widgets/mx_progress_indicator.dart';
import '../../../../shared/widgets/mx_text.dart';

class StudyModeProgressRow extends StatelessWidget {
  const StudyModeProgressRow({
    required this.value,
    required this.label,
    super.key,
  });

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MxLinearProgress(value: value, size: MxProgressSize.large),
        ),
        const MxGap(MxSpace.sm),
        MxText(label, role: MxTextRole.studyProgress),
      ],
    );
  }
}

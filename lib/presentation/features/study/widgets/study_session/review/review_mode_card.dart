import 'package:flutter/material.dart';

import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_icon_button.dart';
import '../../../../../shared/widgets/mx_text.dart';

class ReviewModeCard extends StatelessWidget {
  const ReviewModeCard({
    required this.tooltip,
    required this.actionIcon,
    required this.text,
    required this.role,
    super.key,
  });

  final String tooltip;
  final IconData actionIcon;
  final String text;
  final MxTextRole role;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      variant: MxCardVariant.outlined,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: MxIconButton(
              tooltip: tooltip,
              icon: actionIcon,
              onPressed: null,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: MxSpace.xxl),
              child: Center(
                child: SingleChildScrollView(
                  child: MxText(
                    text,
                    role: role,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

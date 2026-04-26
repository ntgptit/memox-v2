import 'package:flutter/material.dart';

import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_icon_button.dart';
import '../../../../../shared/widgets/mx_text.dart';

class ReviewModeCard extends StatelessWidget {
  const ReviewModeCard({
    required this.text,
    required this.role,
    this.tooltip,
    this.actionIcon,
    this.action,
    this.secondaryAction,
    super.key,
  });

  final String? tooltip;
  final IconData? actionIcon;
  final String text;
  final MxTextRole role;
  final Widget? action;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      variant: MxCardVariant.outlined,
      child: Stack(
        children: [
          if (action != null || actionIcon != null)
            Align(
              alignment: Alignment.topRight,
              child:
                  action ??
                  MxIconButton(
                    tooltip: tooltip ?? '',
                    icon: actionIcon!,
                    onPressed: null,
                  ),
            ),
          if (secondaryAction != null)
            Align(alignment: Alignment.bottomRight, child: secondaryAction),
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

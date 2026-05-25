import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../widgets/mx_study_top_bar.dart';
import 'mx_content_shell.dart';
import 'mx_scaffold.dart';
import 'mx_space.dart';

/// Study-session layout template.
///
/// This shell knows only about study chrome slots: top-bar display values,
/// centered body content, and optional bottom action. It must not import or
/// reason about study modes, cards, answer state, providers, or repositories.
class MxStudyScaffold extends StatelessWidget {
  const MxStudyScaffold({
    required this.modeLabel,
    required this.accent,
    required this.progressValue,
    required this.counterLabel,
    required this.body,
    this.onClose,
    this.closeTooltip,
    this.bottomAction,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final String modeLabel;
  final MxStudyTopBarAccent accent;
  final double progressValue;
  final String counterLabel;
  final Widget body;
  final VoidCallback? onClose;
  final String? closeTooltip;
  final Widget? bottomAction;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final action = bottomAction;
    final pageHorizontal = context.pagePadding;

    return MxScaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bodyInsets: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxStudyTopBar(
            modeLabel: modeLabel,
            accent: accent,
            progressValue: progressValue,
            counterLabel: counterLabel,
            onClose: onClose,
            closeTooltip: closeTooltip,
          ),
          Expanded(
            child: MxContentShell(
              width: MxContentWidth.reading,
              padding: EdgeInsets.fromLTRB(
                // guard:layout-value-reviewed -- reason: combines tier-aware horizontal gutters with tokenized vertical insets around the study top bar.
                pageHorizontal.left,
                MxSpace.xs,
                pageHorizontal.right,
                action == null ? MxSpace.md : MxSpace.sm,
              ),
              child: body,
            ),
          ),
          if (action != null)
            SafeArea(
              top: false,
              child: MxContentShell(
                width: MxContentWidth.reading,
                padding: EdgeInsets.fromLTRB(
                  // guard:layout-value-reviewed -- reason: combines tier-aware horizontal gutters with tokenized vertical action spacing, SafeArea-wrapped.
                  pageHorizontal.left,
                  MxSpace.sm,
                  pageHorizontal.right,
                  MxSpace.md,
                ),
                child: action,
              ),
            ),
        ],
      ),
    );
  }
}

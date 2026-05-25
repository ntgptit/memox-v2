import 'package:flutter/material.dart';
import 'package:memox/core/theme/responsive/app_layout.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';

/// Study-session shell.
///
/// Renders the slim study top bar (close + mode badge + progress + counter)
/// over an [MxContentShell]-wrapped body. Mode views build [child] with their
/// own internal column.
class StudyModeSessionScaffold extends StatelessWidget {
  const StudyModeSessionScaffold({
    required this.modeLabel,
    required this.accent,
    required this.progressValue,
    required this.counterLabel,
    required this.canCancel,
    required this.isActionBusy,
    required this.onCancel,
    required this.onBack,
    required this.child,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final String modeLabel;
  final MxStudyTopBarAccent accent;
  final double progressValue;
  final String counterLabel;
  final bool canCancel;
  final bool isActionBusy;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final Widget child;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final closeHandler = isActionBusy ? null : (canCancel ? onCancel : onBack);
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
            onClose: closeHandler,
            closeTooltip: canCancel
                ? l10n.studyCancelAction
                : MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: MxContentShell(
              width: MxContentWidth.reading,
              padding: const EdgeInsets.fromLTRB(
                MxSpace.md,
                MxSpace.xs,
                MxSpace.md,
                MxSpace.md,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../core/theme/responsive/app_layout.dart';
import '../../../../shared/layouts/mx_content_shell.dart';
import '../../../../shared/layouts/mx_scaffold.dart';
import '../../../../shared/widgets/mx_icon_button.dart';

class StudyModeSessionScaffold extends StatelessWidget {
  const StudyModeSessionScaffold({
    required this.title,
    required this.canCancel,
    required this.isActionBusy,
    required this.onCancel,
    required this.onBack,
    required this.child,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final String title;
  final bool canCancel;
  final bool isActionBusy;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final Widget child;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      title: title,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      leading: MxIconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onPressed: onBack,
      ),
      actions: [
        if (canCancel)
          MxIconButton(
            tooltip: l10n.studyCancelAction,
            icon: Icons.close_rounded,
            onPressed: isActionBusy ? null : onCancel,
          ),
        MxIconButton(
          tooltip: l10n.studyTextSettingsTooltip,
          icon: Icons.text_fields,
          onPressed: null,
        ),
        MxIconButton(
          tooltip: l10n.studyAudioTooltip,
          icon: Icons.volume_up_outlined,
          onPressed: null,
        ),
        MxIconButton(
          tooltip: l10n.studyMoreActionsTooltip,
          icon: Icons.more_vert,
          onPressed: null,
        ),
      ],
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: child,
      ),
    );
  }
}

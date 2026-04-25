import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../app/router/app_navigation.dart';
import '../../../../../core/theme/responsive/app_layout.dart';
import '../../../../shared/layouts/mx_content_shell.dart';
import '../../../../shared/layouts/mx_scaffold.dart';
import '../../../../shared/widgets/mx_icon_button.dart';

class StudyModeSessionScaffold extends StatelessWidget {
  const StudyModeSessionScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      title: title,
      leading: MxIconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icons.arrow_back,
        onPressed: () => context.popRoute(fallback: context.goLibrary),
      ),
      actions: [
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

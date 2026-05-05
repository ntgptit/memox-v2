import 'package:flutter/widgets.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../widgets/study_settings_group.dart';

class LearningSettingsScreen extends StatelessWidget {
  const LearningSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.settingsLearningExperienceTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: ListView(children: const [StudySettingsGroup()]),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_text.dart';
import '../widgets/account_settings_group.dart';
import '../widgets/appearance_settings_group.dart';
import '../widgets/drive_sync_settings_group.dart';
import '../widgets/language_settings_group.dart';
import '../widgets/speech_settings_group.dart';
import '../widgets/study_settings_group.dart';

const double _settingsSectionGap = 6;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.settingsTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: ListView(
          key: const ValueKey<String>('settings_content'),
          children: [
            MxText(l10n.settingsTitle, role: MxTextRole.pageTitle),
            const MxGap(_settingsSectionGap),
            const AccountSettingsGroup(),
            const MxGap(_settingsSectionGap),
            const DriveSyncSettingsGroup(),
            const MxGap(_settingsSectionGap),
            const AppearanceSettingsGroup(),
            const MxGap(_settingsSectionGap),
            const LanguageSettingsGroup(),
            const MxGap(_settingsSectionGap),
            const StudySettingsGroup(),
            const MxGap(_settingsSectionGap),
            const SpeechSettingsGroup(),
          ],
        ),
      ),
    );
  }
}

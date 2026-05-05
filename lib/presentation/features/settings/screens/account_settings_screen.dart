import 'package:flutter/widgets.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../widgets/account_settings_group.dart';
import '../widgets/drive_sync_settings_group.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.settingsAccountTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: ListView(
          children: const [
            AccountSettingsGroup(),
            MxGap(MxSpace.xxl),
            DriveSyncSettingsGroup(),
          ],
        ),
      ),
    );
  }
}

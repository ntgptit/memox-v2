import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_empty_state.dart';

class SettingsTagManagementScreen extends StatelessWidget {
  const SettingsTagManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.settingsManageTagsTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxEmptyState(
          icon: Icons.sell_outlined,
          title: l10n.settingsManageTagsShellTitle,
          message: l10n.settingsManageTagsShellMessage,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../providers/theme_mode_notifier.dart';
import 'settings_group.dart';

class AppearanceSettingsGroup extends ConsumerWidget {
  const AppearanceSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return SettingsGroup(
      title: l10n.settingsAppearanceTitle,
      subtitle: l10n.settingsThemeModeLabel,
      child: MxSegmentedControl<ThemeMode>(
        adaptive: true,
        density: MxSegmentedControlDensity.compact,
        segments: [
          MxSegment(
            value: ThemeMode.system,
            label: l10n.settingsThemeSystem,
            icon: Icons.brightness_auto_outlined,
          ),
          MxSegment(
            value: ThemeMode.light,
            label: l10n.settingsThemeLight,
            icon: Icons.light_mode_outlined,
          ),
          MxSegment(
            value: ThemeMode.dark,
            label: l10n.settingsThemeDark,
            icon: Icons.dark_mode_outlined,
          ),
        ],
        selected: {themeMode},
        onChanged: (selection) {
          final nextMode = selection.first;
          ref.read(themeModeProvider.notifier).set(nextMode);
          MxSnackbar.success(context, l10n.settingsUpdatedMessage);
        },
      ),
    );
  }
}

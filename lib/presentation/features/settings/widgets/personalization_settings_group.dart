import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_list_tile.dart';
import '../providers/locale_notifier.dart';
import '../providers/theme_mode_notifier.dart';
import 'settings_group.dart';

enum _LocaleChoice { system, english, vietnamese }

const _themeRowKey = ValueKey<String>('settings-personalization-theme-row');
const _languageRowKey = ValueKey<String>(
  'settings-personalization-language-row',
);

class PersonalizationSettingsGroup extends ConsumerWidget {
  const PersonalizationSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final localeChoice = _localeChoiceOf(locale);

    return SettingsGroup(
      title: l10n.settingsPersonalizationTitle,
      contentPadding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersonalizationRow(
            key: _themeRowKey,
            icon: Icons.palette_outlined,
            title: l10n.settingsAppearanceTitle,
            value: _themeLabel(l10n, themeMode),
            onTap: () => _showThemeSheet(context, ref, themeMode),
          ),
          const MxDivider(indent: MxSpace.xxl, endIndent: MxSpace.xxl),
          _PersonalizationRow(
            key: _languageRowKey,
            icon: Icons.translate_rounded,
            title: l10n.settingsLanguageTitle,
            value: _localeLabel(l10n, localeChoice),
            onTap: () => _showLanguageSheet(context, ref, localeChoice),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final nextMode = await MxBottomSheet.show<ThemeMode>(
      context: context,
      title: l10n.settingsAppearanceTitle,
      child: _ThemeOptions(current: current),
    );
    if (!context.mounted || nextMode == null) {
      return;
    }
    ref.read(themeModeProvider.notifier).set(nextMode);
    MxSnackbar.success(context, l10n.settingsUpdatedMessage);
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    _LocaleChoice current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final nextChoice = await MxBottomSheet.show<_LocaleChoice>(
      context: context,
      title: l10n.settingsLanguageTitle,
      child: _LanguageOptions(current: current),
    );
    if (!context.mounted || nextChoice == null) {
      return;
    }
    final notifier = ref.read(localeProvider.notifier);
    switch (nextChoice) {
      case _LocaleChoice.system:
        notifier.clear();
      case _LocaleChoice.english:
        notifier.set(const Locale('en'));
      case _LocaleChoice.vietnamese:
        notifier.set(const Locale('vi'));
    }
    MxSnackbar.success(context, l10n.settingsUpdatedMessage);
  }
}

class _PersonalizationRow extends StatelessWidget {
  const _PersonalizationRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(icon: icon, title: title, value: value, onTap: onTap);
  }
}

class _ThemeOptions extends StatelessWidget {
  const _ThemeOptions({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OptionTile<ThemeMode>(
          title: l10n.settingsThemeSystem,
          value: ThemeMode.system,
          current: current,
        ),
        const MxDivider(),
        _OptionTile<ThemeMode>(
          title: l10n.settingsThemeLight,
          value: ThemeMode.light,
          current: current,
        ),
        const MxDivider(),
        _OptionTile<ThemeMode>(
          title: l10n.settingsThemeDark,
          value: ThemeMode.dark,
          current: current,
        ),
      ],
    );
  }
}

class _LanguageOptions extends StatelessWidget {
  const _LanguageOptions({required this.current});

  final _LocaleChoice current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OptionTile<_LocaleChoice>(
          title: l10n.settingsLocaleSystem,
          value: _LocaleChoice.system,
          current: current,
        ),
        const MxDivider(),
        _OptionTile<_LocaleChoice>(
          title: l10n.settingsLocaleEnglish,
          value: _LocaleChoice.english,
          current: current,
        ),
        const MxDivider(),
        _OptionTile<_LocaleChoice>(
          title: l10n.settingsLocaleVietnamese,
          value: _LocaleChoice.vietnamese,
          current: current,
        ),
      ],
    );
  }
}

class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.value,
    required this.current,
  });

  final String title;
  final T value;
  final T current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MxListTile(
      title: title,
      trailing: value == current
          ? Icon(
              Icons.check_rounded,
              size: MxSpace.xl,
              color: scheme.onSurfaceVariant,
            )
          : null,
      dense: true,
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}

String _themeLabel(AppLocalizations l10n, ThemeMode themeMode) {
  return switch (themeMode) {
    ThemeMode.system => l10n.settingsThemeSystem,
    ThemeMode.light => l10n.settingsThemeLight,
    ThemeMode.dark => l10n.settingsThemeDark,
  };
}

String _localeLabel(AppLocalizations l10n, _LocaleChoice locale) {
  return switch (locale) {
    _LocaleChoice.system => l10n.settingsLocaleSystem,
    _LocaleChoice.english => l10n.settingsLocaleEnglish,
    _LocaleChoice.vietnamese => l10n.settingsLocaleVietnamese,
  };
}

_LocaleChoice _localeChoiceOf(Locale? locale) {
  return switch (locale?.languageCode) {
    'en' => _LocaleChoice.english,
    'vi' => _LocaleChoice.vietnamese,
    _ => _LocaleChoice.system,
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../domain/entities/cloud_account_link.dart';
import '../../../../domain/entities/drive_sync_models.dart';
import '../../../shared/widgets/mx_badge.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_icon_tile.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../tts/providers/tts_settings_notifier.dart';
import '../viewmodels/account_settings_viewmodel.dart';
import '../viewmodels/drive_sync_settings_viewmodel.dart';
import '../viewmodels/study_settings_defaults_viewmodel.dart';
import 'settings_group.dart';

const _accountOverviewRowKey = ValueKey<String>(
  'settings-overview-account-row',
);
const _learningOverviewRowKey = ValueKey<String>(
  'settings-overview-learning-row',
);
const _audioSpeechOverviewRowKey = ValueKey<String>(
  'settings-overview-audio-speech-row',
);
const _manageTagsOverviewRowKey = ValueKey<String>(
  'settings-overview-manage-tags-row',
);
const _aboutOverviewRowKey = ValueKey<String>('settings-overview-about-row');

class AccountSettingsOverviewGroup extends ConsumerWidget {
  const AccountSettingsOverviewGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountSettingsControllerProvider);

    return MxRetainedAsyncState<AccountSettingsState>(
      data: account.value,
      isLoading: account.isLoading,
      error: account.hasError ? account.error : null,
      stackTrace: account.hasError ? account.stackTrace : null,
      skeletonBuilder: (_) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        contentPadding: EdgeInsets.zero,
        style: SettingsGroupStyle.hub,
        child: SettingsLoadingRow(
          icon: Icons.account_circle_outlined,
          title: l10n.settingsAccountLinkedOverviewTitle,
          subtitleWidth: 160,
          style: SettingsRowStyle.hub,
        ),
      ),
      errorBuilder: (_, _, _) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        contentPadding: EdgeInsets.zero,
        style: SettingsGroupStyle.hub,
        onTap: context.pushSettingsAccount,
        child: SettingsRow(
          icon: Icons.error_outline,
          title: l10n.errorUnexpected,
          iconTone: MxIconTileTone.warning,
          style: SettingsRowStyle.hub,
        ),
      ),
      dataBuilder: (_, state) {
        final sync = _shouldShowSyncStatus(state)
            ? ref.watch(driveSyncSettingsControllerProvider)
            : null;
        return SettingsGroup(
          title: l10n.settingsAccountTitle,
          contentPadding: EdgeInsets.zero,
          style: SettingsGroupStyle.hub,
          onTap: context.pushSettingsAccount,
          child: _AccountOverviewRow(state: state, syncState: sync?.value),
        );
      },
    );
  }
}

class StudySettingsOverviewGroup extends ConsumerWidget {
  const StudySettingsOverviewGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final studySettings = ref.watch(studyDefaultsSettingsProvider);
    final speechSettings = ref.watch(ttsSettingsProvider);

    return SettingsGroup(
      title: l10n.settingsStudySectionTitle,
      contentPadding: EdgeInsets.zero,
      style: SettingsGroupStyle.hub,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LearningOverviewRow(settings: studySettings),
          const MxDivider(),
          _AudioSpeechOverviewRow(settings: speechSettings),
          const MxDivider(),
          SettingsRow(
            key: _manageTagsOverviewRowKey,
            icon: Icons.sell_outlined,
            title: l10n.settingsManageTagsTitle,
            subtitle: l10n.settingsManageTagsOverviewSubtitle,
            onTap: context.pushSettingsLearningTags,
            preserveSubtitleOnCompact: true,
            style: SettingsRowStyle.hub,
          ),
        ],
      ),
    );
  }
}

class AboutSettingsOverviewGroup extends ConsumerWidget {
  const AboutSettingsOverviewGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final version = ref.watch(appVersionLabelProvider);
    final value = version.value;

    if (value != null) {
      return SettingsGroup(
        title: l10n.settingsAboutSectionTitle,
        contentPadding: EdgeInsets.zero,
        style: SettingsGroupStyle.hub,
        child: SettingsRow(
          key: _aboutOverviewRowKey,
          icon: Icons.info_outline,
          title: l10n.settingsAboutMemoXTitle,
          subtitle: l10n.settingsAboutVersion(value),
          onTap: () => _showAboutDialog(context, l10n, value),
          preserveSubtitleOnCompact: true,
          style: SettingsRowStyle.hub,
        ),
      );
    }

    if (version.hasError) {
      return SettingsGroup(
        title: l10n.settingsAboutSectionTitle,
        contentPadding: EdgeInsets.zero,
        style: SettingsGroupStyle.hub,
        child: SettingsRow(
          key: _aboutOverviewRowKey,
          icon: Icons.info_outline,
          title: l10n.settingsAboutMemoXTitle,
          subtitle: l10n.settingsAboutVersionUnknown,
          onTap: () => _showAboutDialog(context, l10n, null),
          preserveSubtitleOnCompact: true,
          style: SettingsRowStyle.hub,
        ),
      );
    }

    return SettingsGroup(
      title: l10n.settingsAboutSectionTitle,
      contentPadding: EdgeInsets.zero,
      style: SettingsGroupStyle.hub,
      child: SettingsLoadingRow(
        icon: Icons.info_outline,
        title: l10n.settingsAboutMemoXTitle,
        subtitleWidth: 150,
        style: SettingsRowStyle.hub,
      ),
    );
  }
}

class SettingsOverviewFooter extends StatelessWidget {
  const SettingsOverviewFooter({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: MxText(
      AppLocalizations.of(context).settingsOverviewFooter,
      role: MxTextRole.formHelper,
      textAlign: TextAlign.center,
    ),
  );
}

class _LearningOverviewRow extends StatelessWidget {
  const _LearningOverviewRow({required this.settings});

  final AsyncValue<StudyDefaultsSettingsState> settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (settings.value != null) {
      return SettingsRow(
        key: _learningOverviewRowKey,
        icon: Icons.track_changes_outlined,
        title: l10n.settingsLearningOverviewTitle,
        subtitle: l10n.settingsLearningOverviewSummary,
        onTap: context.pushSettingsLearning,
        preserveSubtitleOnCompact: true,
        style: SettingsRowStyle.hub,
      );
    }
    if (settings.hasError) {
      return SettingsRow(
        key: _learningOverviewRowKey,
        icon: Icons.track_changes_outlined,
        title: l10n.settingsLearningOverviewTitle,
        subtitle: l10n.errorUnexpected,
        onTap: context.pushSettingsLearning,
        preserveSubtitleOnCompact: true,
        iconTone: MxIconTileTone.warning,
        style: SettingsRowStyle.hub,
      );
    }
    return SettingsLoadingRow(
      icon: Icons.track_changes_outlined,
      title: l10n.settingsLearningOverviewTitle,
      subtitleWidth: 170,
      style: SettingsRowStyle.hub,
    );
  }
}

class _AudioSpeechOverviewRow extends StatelessWidget {
  const _AudioSpeechOverviewRow({required this.settings});

  final AsyncValue<Object> settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (settings.value != null) {
      return SettingsRow(
        key: _audioSpeechOverviewRowKey,
        icon: Icons.volume_up_outlined,
        title: l10n.settingsAudioSpeechTitle,
        subtitle: l10n.settingsAudioSpeechOverviewSummary,
        onTap: context.pushSettingsAudioSpeech,
        preserveSubtitleOnCompact: true,
        style: SettingsRowStyle.hub,
      );
    }
    if (settings.hasError) {
      return SettingsRow(
        key: _audioSpeechOverviewRowKey,
        icon: Icons.volume_up_outlined,
        title: l10n.settingsAudioSpeechTitle,
        subtitle: l10n.errorUnexpected,
        onTap: context.pushSettingsAudioSpeech,
        preserveSubtitleOnCompact: true,
        iconTone: MxIconTileTone.warning,
        style: SettingsRowStyle.hub,
      );
    }
    return SettingsLoadingRow(
      icon: Icons.volume_up_outlined,
      title: l10n.settingsAudioSpeechTitle,
      subtitleWidth: 140,
      style: SettingsRowStyle.hub,
    );
  }
}

class _AccountOverviewRow extends StatelessWidget {
  const _AccountOverviewRow({required this.state, required this.syncState});

  final AccountSettingsState state;
  final DriveSyncSettingsState? syncState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final link = state.link;

    if (link != null &&
        (state.status == AccountLinkStatus.signedIn ||
            state.status == AccountLinkStatus.needsDriveAuthorization)) {
      final isSyncFailure = syncState?.kind == DriveSyncStatusKind.failure;
      final needsDriveAuthorization =
          state.status == AccountLinkStatus.needsDriveAuthorization;
      return SettingsRow(
        key: _accountOverviewRowKey,
        icon: Icons.account_circle_outlined,
        title: l10n.settingsAccountLinkedOverviewTitle,
        subtitle: needsDriveAuthorization
            ? link.email
            : isSyncFailure
            ? l10n.settingsAccountOverviewSyncErrorSubtitle(link.email)
            : l10n.settingsAccountOverviewSyncedMockSubtitle(link.email),
        trailing: isSyncFailure || needsDriveAuthorization
            ? MxBadge(
                label: isSyncFailure
                    ? l10n.settingsOverviewSyncRetry
                    : l10n.settingsAccountDriveReconnectRequired,
                icon: isSyncFailure
                    ? Icons.cloud_off_outlined
                    : Icons.warning_amber_rounded,
                tone: MxBadgeTone.warning,
              )
            : null,
        showChevron: !isSyncFailure && !needsDriveAuthorization,
        preserveSubtitleOnCompact: true,
        iconTone: isSyncFailure || needsDriveAuthorization
            ? MxIconTileTone.warning
            : MxIconTileTone.primarySoft,
        style: SettingsRowStyle.hub,
      );
    }

    if (state.isBusy) {
      return SettingsRow(
        key: _accountOverviewRowKey,
        icon: Icons.account_circle_outlined,
        title: l10n.settingsAccountLinkedOverviewTitle,
        subtitle: l10n.settingsAccountSigningIn,
        preserveSubtitleOnCompact: true,
        trailing: const MxCircularProgress(size: MxProgressSize.small),
        style: SettingsRowStyle.hub,
      );
    }

    return SettingsRow(
      key: _accountOverviewRowKey,
      icon: state.status == AccountLinkStatus.signedOut
          ? Icons.login_rounded
          : Icons.account_circle_outlined,
      title: _accountStatusText(l10n, state),
      subtitle: _accountSubtitle(l10n, state),
      preserveSubtitleOnCompact: _preservesAccountSubtitle(state),
      iconTone: state.status == AccountLinkStatus.signedOut
          ? MxIconTileTone.neutral
          : MxIconTileTone.primarySoft,
      style: SettingsRowStyle.hub,
    );
  }
}

bool _shouldShowSyncStatus(AccountSettingsState state) =>
    state.link != null && state.status == AccountLinkStatus.signedIn;

bool _preservesAccountSubtitle(AccountSettingsState state) =>
    switch (state.status) {
      AccountLinkStatus.signedOut ||
      AccountLinkStatus.needsDriveAuthorization ||
      AccountLinkStatus.unconfigured ||
      AccountLinkStatus.unsupported ||
      AccountLinkStatus.error => true,
      AccountLinkStatus.signedIn => false,
    };

String _accountStatusText(AppLocalizations l10n, AccountSettingsState state) =>
    switch (state.status) {
      AccountLinkStatus.signedIn || AccountLinkStatus.needsDriveAuthorization =>
        l10n.settingsAccountLinkedOverviewTitle,
      AccountLinkStatus.unconfigured => l10n.settingsAccountMissingConfig,
      AccountLinkStatus.unsupported => l10n.settingsAccountUnsupported,
      AccountLinkStatus.error => l10n.settingsAccountSignInFailed,
      AccountLinkStatus.signedOut => l10n.settingsAccountSignInSyncTitle,
    };

String? _accountSubtitle(AppLocalizations l10n, AccountSettingsState state) =>
    switch (state.status) {
      AccountLinkStatus.signedIn ||
      AccountLinkStatus.needsDriveAuthorization => state.link?.email,
      AccountLinkStatus.unconfigured => l10n.settingsAccountSubtitleConfig,
      AccountLinkStatus.unsupported => l10n.settingsAccountSubtitleUnsupported,
      AccountLinkStatus.error => l10n.settingsAccountSubtitleError,
      AccountLinkStatus.signedOut => l10n.settingsAccountSignInSyncSubtitle,
    };

void _showAboutDialog(
  BuildContext context,
  AppLocalizations l10n,
  String? version,
) {
  showAboutDialog(
    context: context,
    applicationName: l10n.appName,
    applicationVersion: version ?? l10n.settingsAboutVersionUnknown,
    applicationLegalese: l10n.settingsAboutLegalese,
    children: [MxText(l10n.settingsAboutMessage, role: MxTextRole.formHelper)],
  );
}

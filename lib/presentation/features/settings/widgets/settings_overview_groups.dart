import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/entities/cloud_account_link.dart';
import '../../../../domain/services/tts_service.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../study/providers/study_settings_defaults_notifier.dart';
import '../../tts/providers/tts_settings_notifier.dart';
import '../viewmodels/account_settings_viewmodel.dart';
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

const double _overviewAvatarRadius = MxSpace.xxl + MxSpace.md;

class AccountSettingsOverviewGroup extends ConsumerWidget {
  const AccountSettingsOverviewGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountSettingsControllerProvider);

    return account.when(
      loading: () => SettingsGroup(
        title: l10n.settingsAccountTitle,
        child: const MxLoadingState(),
      ),
      error: (_, _) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      data: (state) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        onTap: context.pushSettingsAccount,
        child: _AccountOverviewRow(state: state),
      ),
    );
  }
}

class LearningSettingsOverviewGroup extends ConsumerWidget {
  const LearningSettingsOverviewGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(studyDefaultsSettingsProvider);

    return MxRetainedAsyncState<StudyDefaultsSettingsState>(
      data: settings.value,
      isLoading: settings.isLoading,
      error: settings.hasError ? settings.error : null,
      stackTrace: settings.hasError ? settings.stackTrace : null,
      onRetry: () => ref.invalidate(studyDefaultsSettingsProvider),
      skeletonBuilder: (_) => SettingsGroup(
        title: l10n.settingsLearningExperienceTitle,
        child: const MxLoadingState(),
      ),
      errorBuilder: (_, _, _) => SettingsGroup(
        title: l10n.settingsLearningExperienceTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      dataBuilder: (_, state) => SettingsGroup(
        title: l10n.settingsLearningExperienceTitle,
        onTap: context.pushSettingsLearning,
        child: _OverviewFocusContent(
          key: _learningOverviewRowKey,
          icon: Icons.edit_calendar_outlined,
          title: l10n.settingsStudyDefaultsTitle,
          subtitle: l10n.settingsLearningOverviewSummary(
            state.newStudyDefaults.batchSize,
            state.reviewDefaults.batchSize,
          ),
        ),
      ),
    );
  }
}

class AudioSpeechSettingsOverviewGroup extends ConsumerWidget {
  const AudioSpeechSettingsOverviewGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(ttsSettingsProvider);

    return MxRetainedAsyncState<TtsSettings>(
      data: settings.value,
      isLoading: settings.isLoading,
      error: settings.hasError ? settings.error : null,
      stackTrace: settings.hasError ? settings.stackTrace : null,
      onRetry: () => ref.invalidate(ttsSettingsProvider),
      skeletonBuilder: (_) => SettingsGroup(
        title: l10n.settingsAudioSpeechTitle,
        child: const MxLoadingState(),
      ),
      errorBuilder: (_, _, _) => SettingsGroup(
        title: l10n.settingsAudioSpeechTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      dataBuilder: (_, state) => SettingsGroup(
        title: l10n.settingsAudioSpeechTitle,
        onTap: context.pushSettingsAudioSpeech,
        child: _OverviewFocusContent(
          key: _audioSpeechOverviewRowKey,
          icon: Icons.record_voice_over_outlined,
          title: l10n.settingsSpeechTextToSpeechLabel,
          subtitle: l10n.settingsAudioSpeechOverviewSummary(
            state.autoPlay
                ? l10n.settingsAudioSpeechEnabled
                : l10n.settingsAudioSpeechDisabled,
            _voiceSelectionValue(l10n, state),
          ),
        ),
      ),
    );
  }
}

class _AccountOverviewRow extends StatelessWidget {
  const _AccountOverviewRow({required this.state});

  final AccountSettingsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final link = state.link;

    if (link != null &&
        (state.status == AccountLinkStatus.signedIn ||
            state.status == AccountLinkStatus.needsDriveAuthorization)) {
      return _LinkedAccountOverviewRow(
        link: link,
        statusLabel: _accountStatusLabel(l10n, state),
      );
    }

    return _OverviewFocusContent(
      key: _accountOverviewRowKey,
      icon: Icons.account_circle_outlined,
      title: _accountStatusText(l10n, state),
      subtitle: _accountSubtitle(l10n, state),
    );
  }
}

class _LinkedAccountOverviewRow extends StatelessWidget {
  const _LinkedAccountOverviewRow({
    required this.link,
    required this.statusLabel,
  });

  final CloudAccountLink link;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final displayName = link.displayName ?? link.email;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      key: _accountOverviewRowKey,
      children: [
        CircleAvatar(
          radius: _overviewAvatarRadius,
          backgroundColor: scheme.surfaceContainerHigh,
          backgroundImage: link.photoUrl == null
              ? null
              : NetworkImage(link.photoUrl!),
          child: link.photoUrl == null
              ? MxText(_initials(displayName), role: MxTextRole.stateTitle)
              : null,
        ),
        const MxGap(MxSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MxText(
                displayName,
                role: MxTextRole.listTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const MxGap(MxSpace.xxs),
              MxText(
                AppLocalizations.of(
                  context,
                ).settingsAccountOverviewSubtitle(statusLabel, link.email),
                role: MxTextRole.listSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const MxGap(MxSpace.sm),
        Icon(
          Icons.chevron_right_rounded,
          size: MxSpace.xxl,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }

  String _initials(String value) {
    final parts = StringUtils.normalizeSpaceToEmpty(
      value,
    ).split(' ').where((part) => part.isNotEmpty).toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1);
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }
}

class _OverviewFocusContent extends StatelessWidget {
  const _OverviewFocusContent({
    required this.icon,
    required this.title,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: MxSpace.xxl + MxSpace.xxl + MxSpace.lg,
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurfaceVariant, size: MxSpace.xxl),
          const MxGap(MxSpace.lg),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxText(
                  title,
                  role: MxTextRole.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const MxGap(MxSpace.xxs),
                  MxText(
                    subtitle!,
                    role: MxTextRole.listSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const MxGap(MxSpace.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: MxSpace.xxl,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

String _accountStatusLabel(AppLocalizations l10n, AccountSettingsState state) {
  return switch (state.status) {
    AccountLinkStatus.signedIn => l10n.settingsAccountDriveReady,
    AccountLinkStatus.needsDriveAuthorization =>
      l10n.settingsAccountDriveReconnectRequired,
    AccountLinkStatus.unconfigured ||
    AccountLinkStatus.unsupported ||
    AccountLinkStatus.error ||
    AccountLinkStatus.signedOut => '',
  };
}

String _accountStatusText(AppLocalizations l10n, AccountSettingsState state) {
  return switch (state.status) {
    AccountLinkStatus.signedIn || AccountLinkStatus.needsDriveAuthorization =>
      state.link?.displayName ?? state.link?.email ?? l10n.settingsAccountTitle,
    AccountLinkStatus.unconfigured => l10n.settingsAccountMissingConfig,
    AccountLinkStatus.unsupported => l10n.settingsAccountUnsupported,
    AccountLinkStatus.error => l10n.settingsAccountSignInFailed,
    AccountLinkStatus.signedOut => l10n.settingsAccountSignedOut,
  };
}

String? _accountSubtitle(AppLocalizations l10n, AccountSettingsState state) {
  return switch (state.status) {
    AccountLinkStatus.signedIn ||
    AccountLinkStatus.needsDriveAuthorization => state.link?.email,
    AccountLinkStatus.unconfigured => l10n.settingsAccountSubtitleConfig,
    AccountLinkStatus.unsupported => l10n.settingsAccountSubtitleUnsupported,
    AccountLinkStatus.error => l10n.settingsAccountSubtitleError,
    AccountLinkStatus.signedOut => l10n.settingsAccountSubtitleSignedOut,
  };
}

String _voiceSelectionValue(AppLocalizations l10n, TtsSettings settings) {
  final voiceName = settings.frontVoiceName;
  if (StringUtils.isNotBlank(voiceName)) {
    return voiceName!;
  }
  return l10n.settingsSpeechSystemVoice;
}

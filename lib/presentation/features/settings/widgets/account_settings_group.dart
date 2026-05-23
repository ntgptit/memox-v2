import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../core/widgets/app_async_builder.dart';
import '../../../../domain/entities/cloud_account_link.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/account_settings_viewmodel.dart';
import 'google_account_web_button.dart';
import 'settings_group.dart';

const double _accountAvatarRadius = MxSpace.xxl + MxSpace.md;

class AccountSettingsGroup extends ConsumerWidget {
  const AccountSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountSettingsControllerProvider);

    return AppAsyncBuilder<AccountSettingsState>(
      value: account,
      loading: (context) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        subtitle: l10n.settingsAccountLoading,
        child: const MxLoadingState(),
      ),
      error: (context, error, stackTrace) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        subtitle: l10n.sharedErrorTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      data: (context, state) => _AccountSettingsContent(state: state),
    );
  }
}

class _AccountSettingsContent extends ConsumerWidget {
  const _AccountSettingsContent({required this.state});

  final AccountSettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(accountSettingsControllerProvider.notifier);

    return SettingsGroup(
      title: l10n.settingsAccountTitle,
      subtitle: _subtitle(l10n),
      action: _headerAction(
        l10n,
        onSignOut: () => unawaited(controller.signOut()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          switch (state.status) {
            AccountLinkStatus.signedIn ||
            AccountLinkStatus.needsDriveAuthorization => _LinkedAccountRow(
              link: state.link!,
              statusLabel: _statusLabel(l10n),
            ),
            AccountLinkStatus.unconfigured => _AccountStatusText(
              text: l10n.settingsAccountMissingConfig,
            ),
            AccountLinkStatus.unsupported => _AccountStatusText(
              text: l10n.settingsAccountUnsupported,
            ),
            AccountLinkStatus.error => _AccountStatusText(
              text: l10n.settingsAccountSignInFailed,
            ),
            AccountLinkStatus.signedOut => _AccountStatusText(
              text: l10n.settingsAccountSignedOut,
            ),
          },
          if (_message(l10n) case final message?) ...[
            const MxGap(MxSpace.sm),
            MxText(message, role: MxTextRole.formHelper),
          ],
          if (state.status != AccountLinkStatus.signedIn) ...[
            const MxGap(MxSpace.sm),
            _AccountActions(
              state: state,
              onSignIn: () => unawaited(controller.signIn()),
              onReconnect: () => unawaited(controller.reconnectDrive()),
            ),
          ],
        ],
      ),
    );
  }

  String? _subtitle(AppLocalizations l10n) {
    return switch (state.status) {
      AccountLinkStatus.signedIn => null,
      AccountLinkStatus.needsDriveAuthorization =>
        l10n.settingsAccountSubtitleReconnect,
      AccountLinkStatus.unconfigured => l10n.settingsAccountSubtitleConfig,
      AccountLinkStatus.unsupported => l10n.settingsAccountSubtitleUnsupported,
      AccountLinkStatus.error => l10n.settingsAccountSubtitleError,
      AccountLinkStatus.signedOut => l10n.settingsAccountSubtitleSignedOut,
    };
  }

  String _statusLabel(AppLocalizations l10n) {
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

  String? _message(AppLocalizations l10n) {
    return switch (state.message) {
      AccountSettingsMessage.none => null,
      AccountSettingsMessage.signInCanceled =>
        l10n.settingsAccountSignInCanceled,
      AccountSettingsMessage.signInFailed => l10n.settingsAccountSignInFailed,
      AccountSettingsMessage.driveAuthorizationRequired =>
        l10n.settingsAccountDriveAuthorizationRequired,
      AccountSettingsMessage.signedOut => l10n.settingsAccountSignedOutMessage,
    };
  }

  Widget? _headerAction(
    AppLocalizations l10n, {
    required VoidCallback onSignOut,
  }) {
    final canShowSignOut =
        state.status == AccountLinkStatus.signedIn ||
        (state.status == AccountLinkStatus.needsDriveAuthorization &&
            !state.requiresRuntimeReconnect);
    if (!canShowSignOut) {
      return null;
    }
    return MxIconButton.compact(
      icon: Icons.logout,
      tooltip: l10n.settingsAccountSignOut,
      onPressed: state.canSignOut ? onSignOut : null,
    );
  }
}

class _LinkedAccountRow extends StatelessWidget {
  const _LinkedAccountRow({required this.link, required this.statusLabel});

  final CloudAccountLink link;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final displayName = link.displayName ?? link.email;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpace.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: _accountAvatarRadius,
            backgroundColor: scheme.surfaceContainerHigh,
            backgroundImage: link.photoUrl == null
                ? null
                : NetworkImage(link.photoUrl!),
            child: link.photoUrl == null
                ? MxText(_initials(displayName), role: MxTextRole.stateTitle)
                : null,
          ),
          const MxGap(MxSpace.xxl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxText(
                  displayName,
                  role: MxTextRole.stateTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (statusLabel.isNotEmpty) ...[
                  const MxGap(MxSpace.xs),
                  MxText(
                    statusLabel,
                    role: MxTextRole.listSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const MxGap(MxSpace.xs),
                MxText(
                  link.email,
                  role: MxTextRole.listSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const MxGap(MxSpace.md),
          Icon(
            Icons.chevron_right_rounded,
            key: const ValueKey<String>('settings-account-profile-chevron'),
            size: MxSpace.xxl,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
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

class _AccountStatusText extends StatelessWidget {
  const _AccountStatusText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return MxText(text, role: MxTextRole.formHelper);
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions({
    required this.state,
    required this.onSignIn,
    required this.onReconnect,
  });

  final AccountSettingsState state;
  final VoidCallback onSignIn;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.status == AccountLinkStatus.signedIn) {
      return const SizedBox.shrink();
    }

    if (state.status == AccountLinkStatus.needsDriveAuthorization) {
      return _reconnectAction(l10n);
    }

    if (state.status == AccountLinkStatus.unconfigured ||
        state.status == AccountLinkStatus.unsupported) {
      return MxPrimaryButton(
        label: l10n.settingsAccountSignIn,
        onPressed: null,
        leadingIcon: Icons.account_circle_outlined,
        fullWidth: true,
      );
    }

    if (state.requiresPlatformSignInButton) {
      return buildGoogleAccountWebButton();
    }

    return MxPrimaryButton(
      label: l10n.settingsAccountSignIn,
      onPressed: state.canSignIn ? onSignIn : null,
      leadingIcon: Icons.account_circle_outlined,
      isLoading: state.isBusy,
      fullWidth: true,
    );
  }

  Widget _reconnectAction(AppLocalizations l10n) {
    if (state.requiresPlatformSignInButton && state.requiresRuntimeReconnect) {
      return buildGoogleAccountWebButton();
    }
    return MxPrimaryButton(
      label: l10n.settingsAccountReconnectDrive,
      onPressed: state.canReconnectDrive ? onReconnect : null,
      leadingIcon: Icons.cloud_sync_outlined,
      isLoading: state.isBusy,
      fullWidth: true,
    );
  }
}

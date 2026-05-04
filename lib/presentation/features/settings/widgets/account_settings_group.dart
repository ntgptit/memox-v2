import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../domain/entities/cloud_account_link.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/account_settings_viewmodel.dart';
import 'google_account_web_button.dart';
import 'settings_group.dart';

const double _accountAvatarRadius = 14;
const double _accountStatusBadgeRadius = 12;
const double _compactSignOutVerticalPadding = 6;

class AccountSettingsGroup extends ConsumerWidget {
  const AccountSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountSettingsControllerProvider);

    return account.when(
      loading: () => SettingsGroup(
        title: l10n.settingsAccountTitle,
        subtitle: l10n.settingsAccountLoading,
        child: const MxLoadingState(),
      ),
      error: (_, _) => SettingsGroup(
        title: l10n.settingsAccountTitle,
        subtitle: l10n.sharedErrorTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      data: (state) => _AccountSettingsContent(state: state),
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
          const MxGap(MxSpace.sm),
          _AccountActions(
            state: state,
            onSignIn: () => unawaited(controller.signIn()),
            onReconnect: () => unawaited(controller.reconnectDrive()),
            onSignOut: () => unawaited(controller.signOut()),
          ),
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
}

class _LinkedAccountRow extends StatelessWidget {
  const _LinkedAccountRow({required this.link, required this.statusLabel});

  final CloudAccountLink link;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final displayName = link.displayName ?? link.email;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: _accountAvatarRadius,
          backgroundColor: scheme.surfaceContainerHigh,
          backgroundImage: link.photoUrl == null
              ? null
              : NetworkImage(link.photoUrl!),
          child: link.photoUrl == null
              ? MxText(_initials(displayName), role: MxTextRole.avatarInitials)
              : null,
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: MxText(
                      displayName,
                      role: MxTextRole.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (statusLabel.isNotEmpty) ...[
                    const MxGap(MxSpace.xs),
                    Flexible(child: _AccountStatusBadge(label: statusLabel)),
                  ],
                ],
              ),
              const MxGap(MxSpace.xxs),
              MxText(
                link.email,
                role: MxTextRole.listSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

class _AccountStatusBadge extends StatelessWidget {
  const _AccountStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(
          Radius.circular(_accountStatusBadgeRadius),
        ),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpace.xs,
          vertical: MxSpace.xxs,
        ),
        child: MxText(
          label,
          role: MxTextRole.badge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
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
    required this.onSignOut,
  });

  final AccountSettingsState state;
  final VoidCallback onSignIn;
  final VoidCallback onReconnect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.status == AccountLinkStatus.signedIn) {
      return _CompactSignOutButton(
        label: l10n.settingsAccountSignOut,
        onPressed: state.canSignOut ? onSignOut : null,
        isLoading: state.isBusy,
      );
    }

    if (state.status == AccountLinkStatus.needsDriveAuthorization) {
      final showSignOut = !state.requiresRuntimeReconnect;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _reconnectAction(l10n),
          if (showSignOut) ...[
            const MxGap(MxSpace.sm),
            _CompactSignOutButton(
              label: l10n.settingsAccountSignOut,
              onPressed: state.canSignOut ? onSignOut : null,
              fullWidth: true,
            ),
          ],
        ],
      );
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

class _CompactSignOutButton extends StatelessWidget {
  const _CompactSignOutButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textButtonTheme.style ?? const ButtonStyle();

    return Theme(
      data: theme.copyWith(
        textButtonTheme: TextButtonThemeData(
          style: baseStyle.copyWith(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: _compactSignOutVerticalPadding),
            ),
          ),
        ),
      ),
      child: MxSecondaryButton(
        label: label,
        onPressed: onPressed,
        size: MxButtonSize.small,
        variant: MxSecondaryVariant.text,
        tone: MxSecondaryButtonTone.danger,
        isLoading: isLoading,
        fullWidth: fullWidth,
      ),
    );
  }
}

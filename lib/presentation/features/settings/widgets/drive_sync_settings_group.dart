import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/widgets/app_async_builder.dart';
import '../../../../domain/entities/drive_sync_models.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_list_tile.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/drive_sync_settings_viewmodel.dart';
import 'settings_group.dart';

enum _DriveSyncDirection { uploadLocal, restoreDrive }

class DriveSyncSettingsGroup extends ConsumerWidget {
  const DriveSyncSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(driveSyncSettingsControllerProvider);

    return AppAsyncBuilder<DriveSyncSettingsState>(
      value: sync,
      loading: (context) => SettingsGroup(
        title: l10n.settingsDriveSyncTitle,
        subtitle: l10n.settingsDriveSyncLoading,
        child: const MxLoadingState(),
      ),
      error: (context, error, stackTrace) => SettingsGroup(
        title: l10n.settingsDriveSyncTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      data: (context, state) => _DriveSyncContent(state: state),
    );
  }
}

Future<void> _showDirectionSheet(
  BuildContext context,
  WidgetRef ref,
  DriveSyncSettingsState state,
) async {
  final l10n = AppLocalizations.of(context);
  final direction = await MxBottomSheet.show<_DriveSyncDirection>(
    context: context,
    title: l10n.settingsDriveSyncDirectionTitle,
    child: _DriveSyncDirectionSheet(state: state),
  );
  if (!context.mounted) return;
  if (direction == null) return;

  // Cross-device warning: if the user is about to upload and the existing
  // remote backup was created by a different device, insert an extra
  // confirmation step explicitly listing the OTHER device + its backup time.
  if (direction == _DriveSyncDirection.uploadLocal &&
      state.status.remoteIsFromOtherDevice) {
    final remote = state.status.remote!;
    final acknowledged = await MxBottomSheet.show<bool>(
      context: context,
      title: l10n.settingsDriveSyncCrossDeviceTitle,
      child: _DriveSyncCrossDeviceSheet(
        deviceLabel: remote.manifest.deviceLabel,
        createdAt: remote.manifest.createdAt,
        appVersion: remote.manifest.appVersion,
      ),
    );
    if (!context.mounted) return;
    if (acknowledged != true) return;
  }

  final confirmed = await MxBottomSheet.show<bool>(
    context: context,
    title: switch (direction) {
      _DriveSyncDirection.uploadLocal =>
        l10n.settingsDriveSyncUploadConfirmTitle,
      _DriveSyncDirection.restoreDrive =>
        l10n.settingsDriveSyncRestoreConfirmTitle,
    },
    child: _DriveSyncConfirmationSheet(direction: direction, state: state),
  );
  if (!context.mounted) return;
  if (confirmed != true) return;

  final controller = ref.read(driveSyncSettingsControllerProvider.notifier);
  await _runWithBusyDialog(
    context: context,
    direction: direction,
    action: () async {
      switch (direction) {
        case _DriveSyncDirection.uploadLocal:
          await controller.uploadLocalToDrive();
        case _DriveSyncDirection.restoreDrive:
          await controller.restoreDriveToLocal();
      }
    },
  );
}

/// Shows a non-dismissible blocking dialog while [action] runs, so the user
/// cannot start a second sync, navigate away, or accidentally lose progress
/// mid-flight. Closes when [action] completes (success or failure — the
/// surrounding controller maps the failure into the next render).
Future<void> _runWithBusyDialog({
  required BuildContext context,
  required _DriveSyncDirection direction,
  required Future<void> Function() action,
}) async {
  final l10n = AppLocalizations.of(context);
  final isRestore = direction == _DriveSyncDirection.restoreDrive;
  final dialogTitle = isRestore
      ? l10n.settingsDriveSyncRestoreInProgressTitle
      : l10n.settingsDriveSyncUploadInProgressTitle;
  final dialogMessage = isRestore
      ? l10n.settingsDriveSyncRestoreInProgressMessage
      : l10n.settingsDriveSyncUploadInProgressMessage;

  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    MxDialog.show<void>(
      context: context,
      barrierDismissible: false,
      title: dialogTitle,
      icon: isRestore
          ? Icons.cloud_download_outlined
          : Icons.cloud_upload_outlined,
      child: _DriveSyncBusyDialogBody(message: dialogMessage),
    ),
  );

  try {
    await action();
  } finally {
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

class _DriveSyncBusyDialogBody extends StatelessWidget {
  const _DriveSyncBusyDialogBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MxCircularProgress(size: MxProgressSize.large),
        const MxGap(MxSpace.md),
        MxText(message, role: MxTextRole.formHelper),
      ],
    ),
  );
}

class _DriveSyncContent extends ConsumerWidget {
  const _DriveSyncContent({required this.state});

  final DriveSyncSettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statusText = _statusText(l10n);
    final messageText = _messageText(l10n);

    return SettingsGroup(
      title: l10n.settingsDriveSyncTitle,
      action: _syncAction(
        l10n,
        onSync: () => unawaited(_showDirectionSheet(context, ref, state)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsRow(
            icon: _statusIcon,
            title: statusText,
            subtitle: state.lastSyncedAt == null
                ? messageText
                : l10n.settingsDriveSyncLastSynced(
                    _formattedSyncTime(context, state.lastSyncedAt!),
                  ),
            showChevron: false,
            preserveSubtitleOnCompact: true,
          ),
          if (state.lastSyncedAt != null) ...[
            const MxGap(MxSpace.xs),
            if (messageText != null)
              MxText(messageText, role: MxTextRole.formHelper),
          ],
        ],
      ),
    );
  }

  IconData get _statusIcon => switch (state.kind) {
    DriveSyncStatusKind.synced => Icons.cloud_done_outlined,
    DriveSyncStatusKind.failure ||
    DriveSyncStatusKind.unsupportedSchema => Icons.cloud_off_outlined,
    DriveSyncStatusKind.needsDriveAuthorization => Icons.cloud_sync_outlined,
    _ => Icons.cloud_queue_outlined,
  };

  Widget? _syncAction(AppLocalizations l10n, {required VoidCallback onSync}) {
    if (!state.canSync) {
      return null;
    }
    return MxIconButton.compact(
      icon: Icons.sync,
      tooltip: l10n.settingsDriveSyncAction,
      onPressed: state.isBusy ? null : onSync,
    );
  }

  String _statusText(AppLocalizations l10n) => switch (state.kind) {
    DriveSyncStatusKind.signedOut => l10n.settingsDriveSyncSignedOut,
    DriveSyncStatusKind.unconfigured => l10n.settingsDriveSyncUnconfigured,
    DriveSyncStatusKind.needsDriveAuthorization =>
      l10n.settingsDriveSyncReconnectRequired,
    DriveSyncStatusKind.noRemoteSnapshot => l10n.settingsDriveSyncNoRemote,
    DriveSyncStatusKind.synced => l10n.settingsDriveSyncSynced,
    DriveSyncStatusKind.ready ||
    DriveSyncStatusKind.localChanges ||
    DriveSyncStatusKind.remoteChanges => l10n.settingsDriveSyncReady,
    DriveSyncStatusKind.unsupportedSchema =>
      l10n.settingsDriveSyncUnsupportedSchema,
    DriveSyncStatusKind.failure => l10n.settingsDriveSyncFailed,
  };

  String? _messageText(AppLocalizations l10n) => switch (state.message) {
    DriveSyncSettingsMessage.none =>
      state.kind == DriveSyncStatusKind.failure
          ? _technicalMessage(l10n)
          : null,
    DriveSyncSettingsMessage.uploaded ||
    DriveSyncSettingsMessage.restored ||
    DriveSyncSettingsMessage.noChanges ||
    DriveSyncSettingsMessage.canceled => null,
    DriveSyncSettingsMessage.failed =>
      state.kind == DriveSyncStatusKind.failure ||
              state.kind == DriveSyncStatusKind.unsupportedSchema
          ? _technicalMessage(l10n)
          : null,
  };

  String? _technicalMessage(AppLocalizations l10n) {
    final message = state.technicalMessage;
    if (message == null || message.isEmpty || message == _statusText(l10n)) {
      return null;
    }
    return message;
  }

  String _formattedSyncTime(BuildContext context, int epochMillis) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis).toLocal();
    final materialL10n = MaterialLocalizations.of(context);
    final date = materialL10n.formatShortDate(dateTime);
    final time = materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
    return '$date $time';
  }
}

class _DriveSyncDirectionSheet extends StatelessWidget {
  const _DriveSyncDirectionSheet({required this.state});

  final DriveSyncSettingsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxText(
          l10n.settingsDriveSyncDirectionMessage,
          role: MxTextRole.formHelper,
        ),
        const MxGap(MxSpace.md),
        MxListTile(
          title: l10n.settingsDriveSyncUploadLocalAction,
          subtitle: l10n.settingsDriveSyncUploadLocalSubtitle,
          showChevron: true,
          dense: true,
          onTap: state.canUploadLocal
              ? () => Navigator.of(context).pop(_DriveSyncDirection.uploadLocal)
              : null,
        ),
        const MxDivider(),
        MxListTile(
          title: l10n.settingsDriveSyncRestoreDriveAction,
          subtitle: state.canRestoreDrive
              ? l10n.settingsDriveSyncRestoreDriveSubtitle
              : l10n.settingsDriveSyncRestoreUnavailable,
          showChevron: state.canRestoreDrive,
          dense: true,
          onTap: state.canRestoreDrive
              ? () =>
                    Navigator.of(context).pop(_DriveSyncDirection.restoreDrive)
              : null,
        ),
        const MxGap(MxSpace.md),
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
          variant: MxSecondaryVariant.text,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _DriveSyncConfirmationSheet extends StatelessWidget {
  const _DriveSyncConfirmationSheet({
    required this.direction,
    required this.state,
  });

  final _DriveSyncDirection direction;
  final DriveSyncSettingsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRestore = direction == _DriveSyncDirection.restoreDrive;
    final remote = state.status.remote;
    final showBackupSource = isRestore && remote != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxText(
          isRestore
              ? l10n.settingsDriveSyncRestoreConfirmMessage
              : l10n.settingsDriveSyncUploadConfirmMessage,
          role: MxTextRole.formHelper,
        ),
        if (showBackupSource) ...[
          const MxGap(MxSpace.sm),
          MxText(
            l10n.settingsDriveSyncBackupSource(
              remote.manifest.deviceLabel,
              _formatBackupTime(context, remote.manifest.createdAt),
            ),
            role: MxTextRole.formHelper,
          ),
          if (remote.manifest.appVersion != null) ...[
            const MxGap(MxSpace.xxs),
            MxText(
              l10n.settingsDriveSyncBackupAppVersion(
                remote.manifest.appVersion!,
              ),
              role: MxTextRole.formHelper,
            ),
          ],
          if (state.status.remoteIsFromOtherDevice) ...[
            const MxGap(MxSpace.xs),
            MxText(
              l10n.settingsDriveSyncRestoreCrossDeviceWarning,
              role: MxTextRole.formHelper,
            ),
          ],
        ],
        const MxGap(MxSpace.md),
        MxPrimaryButton(
          label: isRestore
              ? l10n.settingsDriveSyncRestoreConfirmAction
              : l10n.settingsDriveSyncUploadConfirmAction,
          onPressed: () => Navigator.of(context).pop(true),
          leadingIcon: isRestore
              ? Icons.cloud_download_outlined
              : Icons.cloud_upload_outlined,
          tone: isRestore
              ? MxPrimaryButtonTone.danger
              : MxPrimaryButtonTone.primary,
          fullWidth: true,
        ),
        const MxGap(MxSpace.sm),
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(false),
          variant: MxSecondaryVariant.text,
          fullWidth: true,
        ),
      ],
    );
  }

  String _formatBackupTime(BuildContext context, int epochMillis) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis).toLocal();
    final materialL10n = MaterialLocalizations.of(context);
    final date = materialL10n.formatShortDate(dateTime);
    final time = materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
    return '$date $time';
  }
}

class _DriveSyncCrossDeviceSheet extends StatelessWidget {
  const _DriveSyncCrossDeviceSheet({
    required this.deviceLabel,
    required this.createdAt,
    required this.appVersion,
  });

  final String deviceLabel;
  final int createdAt;
  final String? appVersion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxText(
          l10n.settingsDriveSyncCrossDeviceMessage,
          role: MxTextRole.formHelper,
        ),
        const MxGap(MxSpace.sm),
        MxText(
          l10n.settingsDriveSyncBackupSource(
            deviceLabel,
            _formatBackupTime(context, createdAt),
          ),
          role: MxTextRole.formHelper,
        ),
        if (appVersion != null) ...[
          const MxGap(MxSpace.xxs),
          MxText(
            l10n.settingsDriveSyncBackupAppVersion(appVersion!),
            role: MxTextRole.formHelper,
          ),
        ],
        const MxGap(MxSpace.md),
        MxPrimaryButton(
          label: l10n.settingsDriveSyncCrossDeviceContinue,
          onPressed: () => Navigator.of(context).pop(true),
          leadingIcon: Icons.warning_amber_rounded,
          tone: MxPrimaryButtonTone.danger,
          fullWidth: true,
        ),
        const MxGap(MxSpace.sm),
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(false),
          variant: MxSecondaryVariant.text,
          fullWidth: true,
        ),
      ],
    );
  }

  String _formatBackupTime(BuildContext context, int epochMillis) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis).toLocal();
    final materialL10n = MaterialLocalizations.of(context);
    final date = materialL10n.formatShortDate(dateTime);
    final time = materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
    return '$date $time';
  }
}

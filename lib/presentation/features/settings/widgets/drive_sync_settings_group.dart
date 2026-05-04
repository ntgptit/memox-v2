import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/entities/drive_sync_models.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_list_tile.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/account_settings_viewmodel.dart';
import '../viewmodels/drive_sync_settings_viewmodel.dart';
import 'settings_group.dart';

enum _DriveSyncDirection { uploadLocal, restoreDrive }

class DriveSyncSettingsGroup extends ConsumerWidget {
  const DriveSyncSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(driveSyncSettingsControllerProvider);

    ref.listen<AsyncValue<DriveSyncSettingsState>>(
      driveSyncSettingsControllerProvider,
      (previous, next) {
        final conflict = next.value?.pendingConflict;
        final previousConflict = previous?.value?.pendingConflict;
        if (conflict != null && !identical(conflict, previousConflict)) {
          unawaited(_showConflictSheet(context, ref, conflict));
        }
      },
    );

    return sync.when(
      loading: () => SettingsGroup(
        title: l10n.settingsDriveSyncTitle,
        subtitle: l10n.settingsDriveSyncLoading,
        child: const MxLoadingState(),
      ),
      error: (_, _) => SettingsGroup(
        title: l10n.settingsDriveSyncTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      data: (state) => _DriveSyncContent(state: state),
    );
  }

  Future<void> _showConflictSheet(
    BuildContext context,
    WidgetRef ref,
    DriveSyncConflict conflict,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await MxBottomSheet.show<DriveSyncConflictChoice>(
      context: context,
      title: l10n.settingsDriveSyncConflictTitle,
      child: _DriveSyncConflictSheet(conflict: conflict),
    );
    if (!context.mounted) {
      return;
    }
    await ref
        .read(driveSyncSettingsControllerProvider.notifier)
        .resolveConflict(choice ?? DriveSyncConflictChoice.cancel);
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
  if (!context.mounted || direction == null) {
    return;
  }

  final confirmed = await MxBottomSheet.show<bool>(
    context: context,
    title: switch (direction) {
      _DriveSyncDirection.uploadLocal =>
        l10n.settingsDriveSyncUploadConfirmTitle,
      _DriveSyncDirection.restoreDrive =>
        l10n.settingsDriveSyncRestoreConfirmTitle,
    },
    child: _DriveSyncConfirmationSheet(direction: direction),
  );
  if (!context.mounted || confirmed != true) {
    return;
  }

  final controller = ref.read(driveSyncSettingsControllerProvider.notifier);
  switch (direction) {
    case _DriveSyncDirection.uploadLocal:
      await controller.uploadLocalToDrive();
    case _DriveSyncDirection.restoreDrive:
      await controller.restoreDriveToLocal();
  }
}

class _DriveSyncContent extends ConsumerWidget {
  const _DriveSyncContent({required this.state});

  final DriveSyncSettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accountController = ref.read(
      accountSettingsControllerProvider.notifier,
    );
    final statusText = _statusText(l10n);
    final messageText = _messageText(l10n);
    final needsReconnect =
        state.kind == DriveSyncStatusKind.needsDriveAuthorization;

    return SettingsGroup(
      title: l10n.settingsDriveSyncTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(statusText, role: MxTextRole.formHelper),
          if (messageText != null) ...[
            const MxGap(MxSpace.xs),
            MxText(messageText, role: MxTextRole.formHelper),
          ],
          const MxGap(MxSpace.sm),
          MxPrimaryButton(
            label: needsReconnect
                ? l10n.settingsAccountReconnectDrive
                : l10n.settingsDriveSyncAction,
            onPressed: needsReconnect
                ? () => unawaited(accountController.reconnectDrive())
                : state.canSync
                ? () => unawaited(_showDirectionSheet(context, ref, state))
                : null,
            leadingIcon: Icons.cloud_sync_outlined,
            isLoading: state.isBusy,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  String _statusText(AppLocalizations l10n) {
    return switch (state.kind) {
      DriveSyncStatusKind.signedOut => l10n.settingsDriveSyncSignedOut,
      DriveSyncStatusKind.unconfigured => l10n.settingsDriveSyncUnconfigured,
      DriveSyncStatusKind.needsDriveAuthorization =>
        l10n.settingsDriveSyncReconnectRequired,
      DriveSyncStatusKind.noRemoteSnapshot => l10n.settingsDriveSyncNoRemote,
      DriveSyncStatusKind.synced => l10n.settingsDriveSyncSynced,
      DriveSyncStatusKind.ready ||
      DriveSyncStatusKind.localChanges ||
      DriveSyncStatusKind.remoteChanges => l10n.settingsDriveSyncReady,
      DriveSyncStatusKind.conflict => l10n.settingsDriveSyncConflictStatus,
      DriveSyncStatusKind.unsupportedSchema =>
        l10n.settingsDriveSyncUnsupportedSchema,
      DriveSyncStatusKind.failure => l10n.settingsDriveSyncFailed,
    };
  }

  String? _messageText(AppLocalizations l10n) {
    return switch (state.message) {
      DriveSyncSettingsMessage.none =>
        state.kind == DriveSyncStatusKind.failure
            ? _technicalMessage(l10n)
            : null,
      DriveSyncSettingsMessage.uploaded => l10n.settingsDriveSyncUploaded,
      DriveSyncSettingsMessage.restored => l10n.settingsDriveSyncRestored,
      DriveSyncSettingsMessage.noChanges => l10n.settingsDriveSyncNoChanges,
      DriveSyncSettingsMessage.canceled => l10n.settingsDriveSyncCanceled,
      DriveSyncSettingsMessage.failed =>
        state.kind == DriveSyncStatusKind.failure ||
                state.kind == DriveSyncStatusKind.unsupportedSchema
            ? _technicalMessage(l10n)
            : null,
    };
  }

  String? _technicalMessage(AppLocalizations l10n) {
    final message = state.technicalMessage;
    if (message == null || message.isEmpty || message == _statusText(l10n)) {
      return null;
    }
    return message;
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
  const _DriveSyncConfirmationSheet({required this.direction});

  final _DriveSyncDirection direction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRestore = direction == _DriveSyncDirection.restoreDrive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxText(
          isRestore
              ? l10n.settingsDriveSyncRestoreConfirmMessage
              : l10n.settingsDriveSyncUploadConfirmMessage,
          role: MxTextRole.formHelper,
        ),
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
}

class _DriveSyncConflictSheet extends StatelessWidget {
  const _DriveSyncConflictSheet({required this.conflict});

  final DriveSyncConflict conflict;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxText(
          l10n.settingsDriveSyncConflictMessage,
          role: MxTextRole.formHelper,
        ),
        const MxGap(MxSpace.md),
        MxListTile(
          title: l10n.settingsDriveSyncKeepLocal,
          subtitle: l10n.settingsDriveSyncKeepLocalSubtitle,
          showChevron: true,
          dense: true,
          onTap: () =>
              Navigator.of(context).pop(DriveSyncConflictChoice.keepLocal),
        ),
        const MxDivider(),
        MxListTile(
          title: l10n.settingsDriveSyncUseDrive,
          subtitle: l10n.settingsDriveSyncUseDriveSubtitle,
          showChevron: true,
          dense: true,
          onTap: () =>
              Navigator.of(context).pop(DriveSyncConflictChoice.useDriveCopy),
        ),
        const MxGap(MxSpace.md),
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () =>
              Navigator.of(context).pop(DriveSyncConflictChoice.cancel),
          variant: MxSecondaryVariant.text,
          fullWidth: true,
        ),
      ],
    );
  }
}

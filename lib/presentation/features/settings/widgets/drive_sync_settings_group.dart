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
import '../viewmodels/drive_sync_settings_viewmodel.dart';
import 'settings_group.dart';

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
        subtitle: l10n.sharedErrorTitle,
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

class _DriveSyncContent extends ConsumerWidget {
  const _DriveSyncContent({required this.state});

  final DriveSyncSettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(driveSyncSettingsControllerProvider.notifier);

    return SettingsGroup(
      title: l10n.settingsDriveSyncTitle,
      subtitle: _subtitle(l10n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(_statusText(l10n), role: MxTextRole.formHelper),
          if (state.lastSyncedAt != null) ...[
            const MxGap(MxSpace.sm),
            MxText(
              l10n.settingsDriveSyncLastSynced(
                _formatDateTime(context, state.lastSyncedAt!),
              ),
              role: MxTextRole.formHelper,
            ),
          ],
          if (state.remoteDeviceLabel != null) ...[
            const MxGap(MxSpace.xs),
            MxText(
              l10n.settingsDriveSyncRemoteDevice(state.remoteDeviceLabel!),
              role: MxTextRole.formHelper,
            ),
          ],
          if (_message(l10n) case final message?) ...[
            const MxGap(MxSpace.sm),
            MxText(message, role: MxTextRole.formHelper),
          ],
          const MxGap(MxSpace.md),
          MxPrimaryButton(
            label: l10n.settingsDriveSyncAction,
            onPressed: state.canSync
                ? () => unawaited(controller.syncNow())
                : null,
            leadingIcon: Icons.cloud_sync_outlined,
            isLoading: state.isBusy,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  String _subtitle(AppLocalizations l10n) {
    return switch (state.kind) {
      DriveSyncStatusKind.signedOut => l10n.settingsDriveSyncSubtitleSignedOut,
      DriveSyncStatusKind.unconfigured =>
        l10n.settingsDriveSyncSubtitleUnconfigured,
      DriveSyncStatusKind.needsDriveAuthorization =>
        l10n.settingsDriveSyncSubtitleReconnect,
      DriveSyncStatusKind.noRemoteSnapshot =>
        l10n.settingsDriveSyncSubtitleNoRemote,
      DriveSyncStatusKind.synced => l10n.settingsDriveSyncSubtitleSynced,
      DriveSyncStatusKind.conflict => l10n.settingsDriveSyncSubtitleConflict,
      DriveSyncStatusKind.unsupportedSchema =>
        l10n.settingsDriveSyncSubtitleUnsupportedSchema,
      DriveSyncStatusKind.failure => l10n.settingsDriveSyncSubtitleError,
      DriveSyncStatusKind.ready ||
      DriveSyncStatusKind.localChanges ||
      DriveSyncStatusKind.remoteChanges => l10n.settingsDriveSyncSubtitleReady,
    };
  }

  String _statusText(AppLocalizations l10n) {
    return switch (state.kind) {
      DriveSyncStatusKind.signedOut => l10n.settingsDriveSyncSignedOut,
      DriveSyncStatusKind.unconfigured => l10n.settingsDriveSyncUnconfigured,
      DriveSyncStatusKind.needsDriveAuthorization =>
        l10n.settingsDriveSyncReconnectRequired,
      DriveSyncStatusKind.noRemoteSnapshot => l10n.settingsDriveSyncNoRemote,
      DriveSyncStatusKind.synced => l10n.settingsDriveSyncSynced,
      DriveSyncStatusKind.conflict => l10n.settingsDriveSyncConflictStatus,
      DriveSyncStatusKind.unsupportedSchema =>
        l10n.settingsDriveSyncUnsupportedSchema,
      DriveSyncStatusKind.failure =>
        state.technicalMessage ?? l10n.errorUnexpected,
      DriveSyncStatusKind.ready ||
      DriveSyncStatusKind.localChanges ||
      DriveSyncStatusKind.remoteChanges => l10n.settingsDriveSyncReady,
    };
  }

  String? _message(AppLocalizations l10n) {
    return switch (state.message) {
      DriveSyncSettingsMessage.none => null,
      DriveSyncSettingsMessage.uploaded => l10n.settingsDriveSyncUploaded,
      DriveSyncSettingsMessage.restored => l10n.settingsDriveSyncRestored,
      DriveSyncSettingsMessage.noChanges => l10n.settingsDriveSyncNoChanges,
      DriveSyncSettingsMessage.canceled => l10n.settingsDriveSyncCanceled,
      DriveSyncSettingsMessage.failed =>
        state.technicalMessage ?? l10n.settingsDriveSyncFailed,
    };
  }

  String _formatDateTime(BuildContext context, int epochMillis) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis).toLocal();
    final materialL10n = MaterialLocalizations.of(context);
    return '${materialL10n.formatShortDate(dateTime)} '
        '${materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime))}';
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

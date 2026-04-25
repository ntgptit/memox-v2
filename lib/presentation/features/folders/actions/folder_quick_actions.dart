import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

enum FolderQuickAction { edit, move, reorder, delete }

final class _FolderMoveDestination {
  const _FolderMoveDestination(this.parentId);

  final String? parentId;
}

Future<void> showFolderActions({
  required BuildContext context,
  required WidgetRef ref,
  required String folderId,
  required String folderName,
  bool allowRootDestination = true,
  bool includeReorder = false,
  bool canReorder = false,
  bool isUnlocked = false,
  VoidCallback? onReorder,
  Future<void> Function()? onDeleted,
}) async {
  final l10n = AppLocalizations.of(context);
  final action = await MxBottomSheet.show<FolderQuickAction>(
    context: context,
    title: l10n.foldersActionsTitle,
    child: MxActionSheetList<FolderQuickAction>(
      items: [
        MxActionSheetItem(
          value: FolderQuickAction.edit,
          label: l10n.commonEdit,
          icon: Icons.edit_outlined,
        ),
        MxActionSheetItem(
          value: FolderQuickAction.move,
          label: l10n.commonMove,
          icon: Icons.drive_file_move_outline,
        ),
        if (includeReorder)
          MxActionSheetItem(
            value: FolderQuickAction.reorder,
            label: l10n.foldersReorder,
            icon: Icons.reorder_rounded,
            enabled: canReorder && !isUnlocked,
            subtitle: canReorder ? null : l10n.foldersReorderManualOnlyHint,
          ),
        MxActionSheetItem(
          value: FolderQuickAction.delete,
          label: l10n.commonDelete,
          icon: Icons.delete_outline,
          tone: MxActionSheetItemTone.destructive,
        ),
      ],
    ),
  );
  if (!context.mounted || action == null) {
    return;
  }

  switch (action) {
    case FolderQuickAction.edit:
      await _renameFolder(context, ref, folderId, folderName);
    case FolderQuickAction.move:
      await _moveFolder(
        context,
        ref,
        folderId,
        allowRootDestination: allowRootDestination,
      );
    case FolderQuickAction.reorder:
      if (!canReorder || isUnlocked || onReorder == null) {
        MxSnackbar.warning(context, l10n.foldersManualReorderWarning);
        return;
      }
      onReorder();
    case FolderQuickAction.delete:
      await _deleteFolder(context, ref, folderId, onDeleted: onDeleted);
  }
}

Future<void> _renameFolder(
  BuildContext context,
  WidgetRef ref,
  String folderId,
  String folderName,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await MxNameDialog.show(
    context: context,
    title: l10n.foldersRenameTitle,
    label: l10n.foldersFolderNameLabel,
    hintText: l10n.foldersFolderNameHint,
    confirmLabel: l10n.commonSave,
    initialValue: folderName,
  );
  if (!context.mounted || name == null) {
    return;
  }

  final success = await ref
      .read(folderActionControllerProvider(folderId).notifier)
      .updateFolder(name);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.foldersUpdatedMessage);
}

Future<void> _moveFolder(
  BuildContext context,
  WidgetRef ref,
  String folderId, {
  required bool allowRootDestination,
}) async {
  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(folderMovePickerProvider(folderId).future);
  if (!context.mounted) {
    return;
  }

  final availableTargets = allowRootDestination
      ? targets
      : targets.where((target) => !target.isRoot).toList(growable: false);
  final destination =
      await MxDestinationPickerSheet.show<_FolderMoveDestination>(
        context: context,
        title: l10n.foldersMoveTitle,
        destinations: [
          for (final target in availableTargets)
            MxDestinationOption<_FolderMoveDestination>(
              value: _FolderMoveDestination(target.id),
              title: target.isRoot ? l10n.foldersMoveRootTitle : target.name,
              subtitle: target.isRoot
                  ? l10n.foldersMoveRootSubtitle
                  : target.breadcrumb.join(' / '),
              icon: target.isRoot
                  ? Icons.home_outlined
                  : Icons.folder_open_outlined,
              searchTerms: target.breadcrumb,
            ),
        ],
        emptyLabel: l10n.commonNoValidDestinationFound,
      );
  if (!context.mounted || destination == null) {
    return;
  }

  final success = await ref
      .read(folderActionControllerProvider(folderId).notifier)
      .moveFolder(destination.parentId);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.foldersMovedMessage);
}

Future<void> _deleteFolder(
  BuildContext context,
  WidgetRef ref,
  String folderId, {
  Future<void> Function()? onDeleted,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await MxConfirmationDialog.show(
    context: context,
    title: l10n.foldersDeleteTitle,
    message: l10n.foldersDeleteMessage,
    confirmLabel: l10n.commonDelete,
    tone: MxConfirmationTone.danger,
    icon: Icons.delete_outline,
  );
  if (!context.mounted || !confirmed) {
    return;
  }

  final success = await ref
      .read(folderActionControllerProvider(folderId).notifier)
      .deleteFolder();
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.foldersDeletedMessage);
  await onDeleted?.call();
}

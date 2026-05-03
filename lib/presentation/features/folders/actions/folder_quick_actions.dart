import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

enum FolderQuickAction { edit, move, import, reorder, delete }

enum _FolderImportChoice { createDeck, existingDeck }

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
  bool canImportFlashcards = false,
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
        if (canImportFlashcards)
          MxActionSheetItem(
            value: FolderQuickAction.import,
            label: l10n.flashcardsImportTitle,
            icon: Icons.file_upload_outlined,
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
    case FolderQuickAction.import:
      await _importIntoFolder(context, ref, folderId);
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

Future<void> _importIntoFolder(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final l10n = AppLocalizations.of(context);
  final targets = await ref
      .read(folderActionControllerProvider(folderId).notifier)
      .loadImportDeckTargets();
  if (!context.mounted) {
    return;
  }

  final choice = await MxBottomSheet.show<_FolderImportChoice>(
    context: context,
    title: l10n.foldersImportChoiceTitle,
    child: MxActionSheetList<_FolderImportChoice>(
      items: [
        MxActionSheetItem(
          value: _FolderImportChoice.createDeck,
          label: l10n.foldersImportCreateDeckAction,
          icon: Icons.add_box_outlined,
        ),
        MxActionSheetItem(
          value: _FolderImportChoice.existingDeck,
          label: l10n.foldersImportExistingDeckAction,
          subtitle: targets.isEmpty ? l10n.foldersImportNoDecksHint : null,
          icon: Icons.style_outlined,
          enabled: targets.isNotEmpty,
        ),
      ],
    ),
  );
  if (!context.mounted || choice == null) {
    return;
  }

  switch (choice) {
    case _FolderImportChoice.createDeck:
      await _createDeckForImport(context, ref, folderId);
    case _FolderImportChoice.existingDeck:
      await _chooseExistingDeckForImport(context, targets);
  }
}

Future<void> _createDeckForImport(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await MxNameDialog.show(
    context: context,
    title: l10n.decksCreateTitle,
    label: l10n.decksNameLabel,
    hintText: l10n.decksNameHint,
    confirmLabel: l10n.commonCreate,
  );
  if (!context.mounted || name == null) {
    return;
  }

  final deckId = await ref
      .read(folderActionControllerProvider(folderId).notifier)
      .createDeck(name);
  if (!context.mounted || deckId == null) {
    return;
  }
  context.pushDeckImport(deckId);
}

Future<void> _chooseExistingDeckForImport(
  BuildContext context,
  List<FolderDeckItem> targets,
) async {
  final l10n = AppLocalizations.of(context);
  final deckId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.foldersImportChooseDeckTitle,
    destinations: [
      for (final target in targets)
        MxDestinationOption<String>(
          value: target.id,
          title: target.name,
          subtitle: l10n.foldersDeckStats(target.cardCount),
          icon: Icons.style_outlined,
        ),
    ],
    emptyLabel: l10n.foldersImportNoDecksHint,
  );
  if (!context.mounted || deckId == null) {
    return;
  }
  context.pushDeckImport(deckId);
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

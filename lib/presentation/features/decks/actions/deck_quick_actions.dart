import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../viewmodels/deck_action_viewmodel.dart';

enum DeckQuickAction { edit, move, duplicate, import, export, delete }

Future<void> showDeckActions({
  required BuildContext context,
  required WidgetRef ref,
  required String deckId,
  required String deckName,
  DeckActionContext? actionContext,
  Future<void> Function()? onDeleted,
}) async {
  final l10n = AppLocalizations.of(context);
  final action = await MxBottomSheet.show<DeckQuickAction>(
    context: context,
    title: l10n.decksActionsTitle,
    child: MxActionSheetList<DeckQuickAction>(
      items: [
        MxActionSheetItem(
          value: DeckQuickAction.edit,
          label: l10n.commonEdit,
          icon: Icons.edit_outlined,
        ),
        MxActionSheetItem(
          value: DeckQuickAction.move,
          label: l10n.commonMove,
          icon: Icons.drive_file_move_outline,
        ),
        MxActionSheetItem(
          value: DeckQuickAction.duplicate,
          label: l10n.decksDuplicateAction,
          icon: Icons.copy_outlined,
        ),
        MxActionSheetItem(
          value: DeckQuickAction.import,
          label: l10n.flashcardsImportTitle,
          icon: Icons.file_upload_outlined,
        ),
        MxActionSheetItem(
          value: DeckQuickAction.export,
          label: l10n.decksExportCsvAction,
          icon: Icons.file_download_outlined,
        ),
        MxActionSheetItem(
          value: DeckQuickAction.delete,
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
    case DeckQuickAction.edit:
      await _renameDeck(context, ref, deckId, deckName);
    case DeckQuickAction.move:
      await _moveDeck(context, ref, deckId, actionContext);
    case DeckQuickAction.duplicate:
      await _duplicateDeck(context, ref, deckId, actionContext);
    case DeckQuickAction.import:
      context.pushDeckImport(deckId);
    case DeckQuickAction.export:
      await _exportDeck(context, ref, deckId);
    case DeckQuickAction.delete:
      await _deleteDeck(context, ref, deckId, onDeleted: onDeleted);
  }
}

Future<void> _renameDeck(
  BuildContext context,
  WidgetRef ref,
  String deckId,
  String deckName,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await MxNameDialog.show(
    context: context,
    title: l10n.decksRenameTitle,
    label: l10n.decksNameLabel,
    hintText: l10n.decksNameHint,
    initialValue: deckName,
    confirmLabel: l10n.commonSave,
  );
  if (!context.mounted || name == null) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(deckId).notifier)
      .updateDeck(name);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksUpdatedMessage);
}

Future<void> _moveDeck(
  BuildContext context,
  WidgetRef ref,
  String deckId,
  DeckActionContext? actionContext,
) async {
  final detail = await _resolveDeckActionContext(ref, deckId, actionContext);
  if (!context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(
    deckMovePickerProvider(deckId, detail.folderId).future,
  );
  if (!context.mounted) {
    return;
  }

  final targetId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.decksMoveTitle,
    destinations: [
      for (final target in targets)
        MxDestinationOption<String>(
          value: target.id,
          title: target.name,
          subtitle: target.breadcrumb.join(' / '),
          icon: Icons.folder_open_outlined,
          searchTerms: target.breadcrumb,
        ),
    ],
    emptyLabel: l10n.commonNoValidDestinationFound,
  );
  if (!context.mounted || targetId == null) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(deckId).notifier)
      .moveDeck(targetId);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksMovedMessage);
}

Future<void> _duplicateDeck(
  BuildContext context,
  WidgetRef ref,
  String deckId,
  DeckActionContext? actionContext,
) async {
  final detail = await _resolveDeckActionContext(ref, deckId, actionContext);
  if (!context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(
    deckMovePickerProvider(deckId, detail.folderId).future,
  );
  if (!context.mounted) {
    return;
  }

  final targetId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.decksDuplicateTitle,
    destinations: [
      MxDestinationOption<String>(
        value: detail.folderId,
        title: l10n.decksCurrentFolderTitle,
        subtitle: detail.breadcrumb
            .take(detail.breadcrumb.length - 1)
            .map((item) => item.label)
            .join(' / '),
        icon: Icons.folder_special_outlined,
      ),
      for (final target in targets)
        if (target.id != detail.folderId)
          MxDestinationOption<String>(
            value: target.id,
            title: target.name,
            subtitle: target.breadcrumb.join(' / '),
            icon: Icons.folder_open_outlined,
            searchTerms: target.breadcrumb,
          ),
    ],
    emptyLabel: l10n.commonNoValidDestinationFound,
  );
  if (!context.mounted || targetId == null) {
    return;
  }

  final duplicatedId = await ref
      .read(deckActionControllerProvider(deckId).notifier)
      .duplicateDeck(targetId);
  if (!context.mounted || duplicatedId == null) {
    return;
  }
  MxSnackbar.success(context, l10n.decksDuplicatedMessage);
  context.pushFlashcardList(duplicatedId);
}

Future<DeckActionContext> _resolveDeckActionContext(
  WidgetRef ref,
  String deckId,
  DeckActionContext? actionContext,
) {
  if (actionContext != null) {
    return Future<DeckActionContext>.value(actionContext);
  }
  return ref.read(deckActionContextProvider(deckId).future);
}

Future<void> _exportDeck(
  BuildContext context,
  WidgetRef ref,
  String deckId,
) async {
  final export = await ref
      .read(deckActionControllerProvider(deckId).notifier)
      .exportDeck();
  if (!context.mounted || export == null) {
    return;
  }

  final bytes = Uint8List.fromList(utf8.encode(export.content));
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: export.mimeType)],
      fileNameOverrides: [export.fileName],
      subject: export.fileName,
    ),
  );
}

Future<void> _deleteDeck(
  BuildContext context,
  WidgetRef ref,
  String deckId, {
  Future<void> Function()? onDeleted,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await MxConfirmationDialog.show(
    context: context,
    title: l10n.decksDeleteTitle,
    message: l10n.decksDeleteMessage,
    confirmLabel: l10n.commonDelete,
    tone: MxConfirmationTone.danger,
    icon: Icons.delete_outline,
  );
  if (!context.mounted || !confirmed) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(deckId).notifier)
      .deleteDeck();
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksDeletedMessage);
  await onDeleted?.call();
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../widgets/deck_detail_skeleton.dart';
import '../widgets/deck_header_section.dart';
import '../widgets/deck_stats_section.dart';
import '../widgets/deck_study_action_section.dart';
import '../viewmodels/deck_detail_viewmodel.dart';

enum _DeckAction { edit, move, duplicate, export, delete }

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(deckActionControllerProvider(deckId), (
      _,
      next,
    ) {
      final failure = deckActionError(next);
      if (failure != null) {
        MxSnackbar.error(context, deckActionErrorMessage(failure));
      }
    });

    final queryState = ref.watch(deckDetailQueryProvider(deckId));

    return MxScaffold(
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<DeckDetailState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          skeletonBuilder: (_) => const DeckDetailSkeleton(),
          onRetry: () => ref.invalidate(deckDetailQueryProvider(deckId)),
          dataBuilder: (context, state) {
            final lastStudiedLabel = l10n.decksLastStudiedLabel(
              _formatLastStudied(context, state.lastStudiedAt),
            );
            return ListView(
              children: [
                DeckHeaderSection(
                  state: state,
                  onBack: () => context.popRoute(
                    fallback: () => context.goFolderDetail(state.folderId),
                  ),
                  onOpenActions: () => _openDeckActions(context, ref, state),
                  onOpenBreadcrumb: (folderId) =>
                      context.goFolderDetail(folderId),
                ),
                const MxGap(MxSpace.xl),
                DeckStatsSection(
                  state: state,
                  lastStudiedLabel: lastStudiedLabel,
                ),
                const MxGap(MxSpace.xl),
                DeckStudyActionSection(
                  onOpenFlashcards: () => context.pushFlashcardList(state.id),
                  onAddFlashcard: () => context.pushFlashcardCreate(state.id),
                  onImport: () => context.pushDeckImport(state.id),
                  onStartStudy: () => context.goStudyEntry(
                    entryType: 'deck',
                    entryRefId: state.id,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> _openDeckActions(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await MxBottomSheet.show<_DeckAction>(
    context: context,
    title: l10n.decksActionsTitle,
    child: MxActionSheetList<_DeckAction>(
      items: [
        MxActionSheetItem(
          value: _DeckAction.edit,
          label: l10n.commonEdit,
          icon: Icons.edit_outlined,
        ),
        MxActionSheetItem(
          value: _DeckAction.move,
          label: l10n.commonMove,
          icon: Icons.drive_file_move_outline,
        ),
        MxActionSheetItem(
          value: _DeckAction.duplicate,
          label: l10n.decksDuplicateAction,
          icon: Icons.copy_outlined,
        ),
        MxActionSheetItem(
          value: _DeckAction.export,
          label: l10n.decksExportCsvAction,
          icon: Icons.file_download_outlined,
        ),
        MxActionSheetItem(
          value: _DeckAction.delete,
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
    case _DeckAction.edit:
      await _renameDeck(context, ref, state);
    case _DeckAction.move:
      await _moveDeck(context, ref, state);
    case _DeckAction.duplicate:
      await _duplicateDeck(context, ref, state);
    case _DeckAction.export:
      await _exportDeck(context, ref, state);
    case _DeckAction.delete:
      await _deleteDeck(context, ref, state);
  }
}

Future<void> _renameDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await MxNameDialog.show(
    context: context,
    title: l10n.decksRenameTitle,
    label: l10n.decksNameLabel,
    hintText: l10n.decksNameHint,
    initialValue: state.name,
    confirmLabel: l10n.commonSave,
  );
  if (!context.mounted || name == null) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(state.id).notifier)
      .updateDeck(name);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksUpdatedMessage);
}

Future<void> _moveDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(deckMovePickerProvider(state.id).future);
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
      .read(deckActionControllerProvider(state.id).notifier)
      .moveDeck(targetId);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksMovedMessage);
}

Future<void> _duplicateDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(deckMovePickerProvider(state.id).future);
  if (!context.mounted) {
    return;
  }

  final targetId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.decksDuplicateTitle,
    destinations: [
      MxDestinationOption<String>(
        value: state.folderId,
        title: l10n.decksCurrentFolderTitle,
        subtitle: state.breadcrumb
            .take(state.breadcrumb.length - 1)
            .map((item) => item.label)
            .join(' / '),
        icon: Icons.folder_special_outlined,
      ),
      for (final target in targets)
        if (target.id != state.folderId)
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
      .read(deckActionControllerProvider(state.id).notifier)
      .duplicateDeck(targetId);
  if (!context.mounted || duplicatedId == null) {
    return;
  }
  MxSnackbar.success(context, l10n.decksDuplicatedMessage);
  context.pushDeckDetail(duplicatedId);
}

Future<void> _exportDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final export = await ref
      .read(deckActionControllerProvider(state.id).notifier)
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
  DeckDetailState state,
) async {
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
      .read(deckActionControllerProvider(state.id).notifier)
      .deleteDeck();
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksDeletedMessage);
  await context.popRoute(
    fallback: () => context.goFolderDetail(state.folderId),
  );
}

String _formatLastStudied(BuildContext context, int? value) {
  final l10n = AppLocalizations.of(context);
  if (value == null) {
    return l10n.commonNever;
  }

  final date = DateTime.fromMillisecondsSinceEpoch(
    value,
    isUtc: true,
  ).toLocal();
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

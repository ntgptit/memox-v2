import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../widgets/folder_detail_skeleton.dart';
import '../widgets/folder_empty_state_section.dart';
import '../widgets/folder_header_section.dart';
import '../widgets/folder_reorder_section.dart';
import '../widgets/folder_summary_section.dart';
import '../widgets/folder_tree_section.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

enum _FolderAction { edit, move, reorder, delete }

class FolderDetailScreen extends ConsumerStatefulWidget {
  const FolderDetailScreen({required this.folderId, super.key});

  final String folderId;

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  bool _isReorderMode = false;
  List<String> _orderedIds = <String>[];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sortOptions = buildContentSortOptions(l10n);
    ref.listen<AsyncValue<void>>(
      folderActionControllerProvider(widget.folderId),
      (_, next) {
        final failure = folderActionError(next);
        if (failure != null) {
          MxSnackbar.error(context, folderActionErrorMessage(failure));
        }
      },
    );

    final queryState = ref.watch(folderDetailQueryProvider(widget.folderId));
    final queryData = queryState.value;
    final toolbarState = ref.watch(
      folderChildrenToolbarStateProvider(widget.folderId),
    );
    final toolbarNotifier = ref.read(
      folderChildrenToolbarStateProvider(widget.folderId).notifier,
    );

    return MxScaffold(
      floatingActionButton: queryData == null
          ? null
          : queryData.isUnlocked
          ? null
          : MxFab(
              icon: queryData.isSubfolderMode
                  ? Icons.create_new_folder_outlined
                  : Icons.style_outlined,
              tooltip: queryData.isSubfolderMode
                  ? l10n.foldersNewSubfolderTooltip
                  : l10n.foldersNewDeckTooltip,
              onPressed: _isReorderMode
                  ? null
                  : () => queryData.isSubfolderMode
                        ? _createSubfolder()
                        : _createDeck(),
            ),
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        hasFab: queryData != null && !queryData.isUnlocked && !_isReorderMode,
        child: MxRetainedAsyncState<FolderDetailState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          skeletonBuilder: (_) => const FolderDetailSkeleton(),
          onRetry: () =>
              ref.invalidate(folderDetailQueryProvider(widget.folderId)),
          dataBuilder: (context, state) {
            final content = switch ((state.isUnlocked, _isReorderMode)) {
              (true, _) => FolderEmptyStateSection(
                onCreateSubfolder: _createSubfolder,
                onCreateDeck: _createDeck,
              ),
              (_, true) => FolderReorderSection(
                state: state,
                orderedIds: _orderedIds,
                onReorder: _handleReorder,
              ),
              _ => FolderTreeSection(
                state: state,
                onOpenSubfolder: _openSubfolder,
              ),
            };
            return ListView(
              children: [
                FolderHeaderSection(
                  state: state,
                  onBack: () => context.popRoute(fallback: context.goLibrary),
                  onOpenActions: () => _openActions(state),
                  onOpenBreadcrumb: (folderId) =>
                      context.goFolderDetail(folderId),
                ),
                const MxGap(MxSpace.xl),
                MxSearchSortToolbar<ContentSortMode>(
                  searchHintText: l10n.commonSearch,
                  onSearchChanged: toolbarNotifier.setSearchTerm,
                  onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                  sortOptions: sortOptions,
                  selectedSort: toolbarState.sortMode,
                  sortLabel: l10n.commonSort,
                  onSortSelected: toolbarNotifier.setSortMode,
                  trailing: _isReorderMode
                      ? <Widget>[
                          MxSecondaryButton(
                            label: l10n.commonCancel,
                            variant: MxSecondaryVariant.text,
                            onPressed: _cancelReorder,
                          ),
                          MxPrimaryButton(
                            label: l10n.commonSaveOrder,
                            onPressed: () => _saveReorder(state),
                          ),
                        ]
                      : const <Widget>[],
                ),
                const MxGap(MxSpace.xl),
                FolderSummarySection(state: state),
                const MxGap(MxSpace.xl),
                content,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _createSubfolder() async {
    final l10n = AppLocalizations.of(context);
    final name = await MxNameDialog.show(
      context: context,
      title: l10n.foldersNewSubfolderTitle,
      label: l10n.foldersFolderNameLabel,
      hintText: l10n.foldersFolderNameHint,
      confirmLabel: l10n.commonCreate,
    );
    if (!mounted || name == null) {
      return;
    }
    final success = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .createSubfolder(name);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.foldersSubfolderCreatedMessage);
  }

  Future<void> _createDeck() async {
    final l10n = AppLocalizations.of(context);
    final name = await MxNameDialog.show(
      context: context,
      title: l10n.decksCreateTitle,
      label: l10n.decksNameLabel,
      hintText: l10n.decksNameHint,
      confirmLabel: l10n.commonCreate,
    );
    if (!mounted || name == null) {
      return;
    }
    final success = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .createDeck(name);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.decksCreatedMessage);
  }

  Future<void> _openActions(FolderDetailState state) async {
    final l10n = AppLocalizations.of(context);
    final action = await MxBottomSheet.show<_FolderAction>(
      context: context,
      title: l10n.foldersActionsTitle,
      child: MxActionSheetList<_FolderAction>(
        items: [
          MxActionSheetItem(
            value: _FolderAction.edit,
            label: l10n.commonEdit,
            icon: Icons.edit_outlined,
          ),
          MxActionSheetItem(
            value: _FolderAction.move,
            label: l10n.commonMove,
            icon: Icons.drive_file_move_outline,
          ),
          MxActionSheetItem(
            value: _FolderAction.reorder,
            label: l10n.foldersReorder,
            icon: Icons.reorder_rounded,
            enabled: state.canManualReorder && !state.isUnlocked,
            subtitle: state.canManualReorder
                ? null
                : l10n.foldersReorderManualOnlyHint,
          ),
          MxActionSheetItem(
            value: _FolderAction.delete,
            label: l10n.commonDelete,
            icon: Icons.delete_outline,
            tone: MxActionSheetItemTone.destructive,
          ),
        ],
      ),
    );
    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _FolderAction.edit:
        await _renameFolder(state);
      case _FolderAction.move:
        await _moveFolder();
      case _FolderAction.reorder:
        _enterReorderMode(state);
      case _FolderAction.delete:
        await _deleteFolder();
    }
  }

  Future<void> _renameFolder(FolderDetailState state) async {
    final l10n = AppLocalizations.of(context);
    final name = await MxNameDialog.show(
      context: context,
      title: l10n.foldersRenameTitle,
      label: l10n.foldersFolderNameLabel,
      hintText: l10n.foldersFolderNameHint,
      confirmLabel: l10n.commonSave,
      initialValue: state.header.name,
    );
    if (!mounted || name == null) {
      return;
    }

    final success = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .updateFolder(name);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.foldersUpdatedMessage);
  }

  Future<void> _moveFolder() async {
    final l10n = AppLocalizations.of(context);
    final targets = await ref.read(
      folderMovePickerProvider(widget.folderId).future,
    );
    if (!mounted) {
      return;
    }

    final destination = await MxDestinationPickerSheet.show<String?>(
      context: context,
      title: l10n.foldersMoveTitle,
      destinations: [
        for (final target in targets)
          MxDestinationOption<String?>(
            value: target.id,
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
    if (!mounted ||
        destination == null && !targets.any((item) => item.id == null)) {
      return;
    }

    final success = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .moveFolder(destination);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.foldersMovedMessage);
  }

  Future<void> _deleteFolder() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.foldersDeleteTitle,
      message: l10n.foldersDeleteMessage,
      confirmLabel: l10n.commonDelete,
      tone: MxConfirmationTone.danger,
      icon: Icons.delete_outline,
    );
    if (!mounted || !confirmed) {
      return;
    }

    final success = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .deleteFolder();
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.foldersDeletedMessage);
    await context.popRoute(fallback: context.goLibrary);
  }

  void _enterReorderMode(FolderDetailState state) {
    final l10n = AppLocalizations.of(context);
    if (!state.canManualReorder || state.isUnlocked) {
      MxSnackbar.warning(context, l10n.foldersManualReorderWarning);
      return;
    }

    setState(() {
      _isReorderMode = true;
      _orderedIds = state.isSubfolderMode
          ? state.subfolders.map((item) => item.id).toList(growable: true)
          : state.decks.map((item) => item.id).toList(growable: true);
    });
  }

  void _cancelReorder() {
    setState(() {
      _isReorderMode = false;
      _orderedIds = <String>[];
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _orderedIds.removeAt(oldIndex);
      _orderedIds.insert(newIndex, item);
    });
  }

  void _openSubfolder(String folderId) {
    ref.read(folderDetailQueryProvider(folderId));
    context.pushFolderDetail(folderId);
  }

  Future<void> _saveReorder(FolderDetailState state) async {
    final controller = ref.read(
      folderActionControllerProvider(widget.folderId).notifier,
    );

    final success = state.isSubfolderMode
        ? await controller.reorderSubfolders(_orderedIds)
        : await controller.reorderDecks(_orderedIds);
    if (!mounted || !success) {
      return;
    }

    setState(() {
      _isReorderMode = false;
      _orderedIds = <String>[];
    });
    MxSnackbar.success(
      context,
      AppLocalizations.of(context).commonDefaultOrderUpdated,
    );
  }
}

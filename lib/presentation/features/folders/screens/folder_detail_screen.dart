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
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_reorderable_list.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../../../shared/widgets/mx_text.dart';
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
          skeletonBuilder: (_) => const _FolderDetailSkeleton(),
          onRetry: () =>
              ref.invalidate(folderDetailQueryProvider(widget.folderId)),
          dataBuilder: (context, state) {
            final content = switch ((state.isUnlocked, _isReorderMode)) {
              (true, _) => _UnlockedFolderState(
                onCreateSubfolder: _createSubfolder,
                onCreateDeck: _createDeck,
              ),
              (_, true) => _ReorderContent(
                state: state,
                orderedIds: _orderedIds,
                onReorder: _handleReorder,
              ),
              _ => _FolderBody(state: state, onOpenSubfolder: _openSubfolder),
            };
            return ListView(
              children: [
                _FolderHeader(
                  state: state,
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
                _FolderSummary(state: state),
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

class _FolderHeader extends StatelessWidget {
  const _FolderHeader({
    required this.state,
    required this.onOpenActions,
    required this.onOpenBreadcrumb,
  });

  final FolderDetailState state;
  final VoidCallback onOpenActions;
  final ValueChanged<String> onOpenBreadcrumb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MxIconButton(
              icon: Icons.arrow_back,
              tooltip: l10n.commonBack,
              onPressed: () => context.popRoute(fallback: context.goLibrary),
            ),
            const MxGap(MxSpace.sm),
            Expanded(
              child: MxText(state.header.name, role: MxTextRole.pageTitle),
            ),
            MxIconButton(
              icon: Icons.more_horiz_rounded,
              tooltip: l10n.foldersMoreActionsTooltip,
              onPressed: onOpenActions,
            ),
          ],
        ),
        const MxGap(MxSpace.sm),
        MxBreadcrumbBar(
          items: [
            for (var index = 0; index < state.header.breadcrumb.length; index++)
              MxBreadcrumb(
                label: state.header.breadcrumb[index].label,
                onTap:
                    index == state.header.breadcrumb.length - 1 ||
                        state.header.breadcrumb[index].folderId == null
                    ? null
                    : () => onOpenBreadcrumb(
                        state.header.breadcrumb[index].folderId!,
                      ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FolderSummary extends StatelessWidget {
  const _FolderSummary({required this.state});

  final FolderDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = switch (state.mode) {
      FolderDetailMode.unlocked => l10n.foldersSummaryUnlocked,
      FolderDetailMode.subfolders => l10n.foldersStatusSubfolders(
        state.subfolders.length,
      ),
      FolderDetailMode.decks => l10n.foldersStatusDecks(
        state.decks.length,
        state.decks.fold<int>(0, (sum, item) => sum + item.cardCount),
      ),
    };

    return MxSection(
      title: state.header.name,
      subtitle: subtitle,
      child: const SizedBox.shrink(),
    );
  }
}

class _UnlockedFolderState extends StatelessWidget {
  const _UnlockedFolderState({
    required this.onCreateSubfolder,
    required this.onCreateDeck,
  });

  final VoidCallback onCreateSubfolder;
  final VoidCallback onCreateDeck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        MxEmptyState(
          title: l10n.foldersEmptyTitle,
          message: l10n.foldersEmptyMessage,
          icon: Icons.folder_open_outlined,
        ),
        const MxGap(MxSpace.lg),
        Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          alignment: WrapAlignment.center,
          children: [
            MxPrimaryButton(
              label: l10n.foldersNewSubfolderTooltip,
              leadingIcon: Icons.create_new_folder_outlined,
              onPressed: onCreateSubfolder,
            ),
            MxSecondaryButton(
              label: l10n.foldersNewDeckTooltip,
              leadingIcon: Icons.style_outlined,
              variant: MxSecondaryVariant.outlined,
              onPressed: onCreateDeck,
            ),
          ],
        ),
      ],
    );
  }
}

class _FolderBody extends StatelessWidget {
  const _FolderBody({required this.state, required this.onOpenSubfolder});

  final FolderDetailState state;
  final ValueChanged<String> onOpenSubfolder;

  @override
  Widget build(BuildContext context) {
    if (state.isSubfolderMode) {
      final l10n = AppLocalizations.of(context);
      return Column(
        children: [
          for (var index = 0; index < state.subfolders.length; index++) ...[
            MxFolderTile(
              name: state.subfolders[index].name,
              icon: state.subfolders[index].icon,
              caption: l10n.libraryFolderStats(
                state.subfolders[index].deckCount,
                state.subfolders[index].itemCount,
              ),
              onTap: () => onOpenSubfolder(state.subfolders[index].id),
            ),
            if (index < state.subfolders.length - 1) const MxDivider(),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < state.decks.length; index++) ...[
          MxStudySetTile(
            title: state.decks[index].name,
            icon: Icons.style_outlined,
            metaLine: AppLocalizations.of(context).foldersDeckCardProgress(
              state.decks[index].cardCount,
              state.decks[index].dueToday,
            ),
            onTap: () => context.pushDeckDetail(state.decks[index].id),
            trailing: MxText(
              AppLocalizations.of(
                context,
              ).commonPercentValue(state.decks[index].masteryPercent),
              role: MxTextRole.tileTrailing,
            ),
          ),
          if (index < state.decks.length - 1) const MxDivider(),
        ],
      ],
    );
  }
}

class _ReorderContent extends StatelessWidget {
  const _ReorderContent({
    required this.state,
    required this.orderedIds,
    required this.onReorder,
  });

  final FolderDetailState state;
  final List<String> orderedIds;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    if (state.isSubfolderMode) {
      final orderedItems = [
        for (final id in orderedIds)
          state.subfolders.firstWhere((item) => item.id == id),
      ];
      return SizedBox(
        height: MxFeatureSizes.reorderPanelHeight,
        child: MxReorderableList.builder(
          itemCount: orderedItems.length,
          buildDefaultDragHandles: true,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final item = orderedItems[index];
            return KeyedSubtree(
              key: ValueKey(item.id),
              child: MxFolderTile(name: item.name, icon: item.icon),
            );
          },
        ),
      );
    }

    final orderedItems = [
      for (final id in orderedIds)
        state.decks.firstWhere((item) => item.id == id),
    ];
    return SizedBox(
      height: MxFeatureSizes.reorderPanelHeight,
      child: MxReorderableList.builder(
        itemCount: orderedItems.length,
        buildDefaultDragHandles: true,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = orderedItems[index];
          return KeyedSubtree(
            key: ValueKey(item.id),
            child: MxStudySetTile(
              title: item.name,
              icon: Icons.style_outlined,
              metaLine: AppLocalizations.of(
                context,
              ).foldersDeckCardProgress(item.cardCount, item.dueToday),
              trailing: MxText(
                AppLocalizations.of(
                  context,
                ).commonPercentValue(item.masteryPercent),
                role: MxTextRole.tileTrailing,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FolderDetailSkeleton extends StatelessWidget {
  const _FolderDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('folder_detail_skeleton'),
      children: const [
        _FolderHeaderSkeleton(),
        MxGap(MxSpace.xl),
        _ToolbarSkeleton(),
        MxGap(MxSpace.xl),
        _SectionSkeleton(titleWidth: 160, subtitleWidth: 220, bodyHeight: 0),
        MxGap(MxSpace.xl),
        _FolderTileSkeleton(),
        MxDivider(),
        _FolderTileSkeleton(),
        MxDivider(),
        _FolderTileSkeleton(),
      ],
    );
  }
}

class _FolderHeaderSkeleton extends StatelessWidget {
  const _FolderHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
            MxGap(MxSpace.sm),
            Expanded(child: MxSkeleton(height: 28, width: 220)),
            MxGap(MxSpace.sm),
            MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(height: 14, width: 180),
      ],
    );
  }
}

class _ToolbarSkeleton extends StatelessWidget {
  const _ToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        MxSkeleton(height: 48, borderRadius: MxFeatureRadii.full),
        MxGap(MxSpace.sm),
        Row(
          children: [
            MxSkeleton(
              height: 32,
              width: 120,
              borderRadius: MxFeatureRadii.full,
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({
    required this.titleWidth,
    required this.subtitleWidth,
    this.bodyHeight = 16,
  });

  final double titleWidth;
  final double subtitleWidth;
  final double bodyHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxSkeleton(height: 18, width: titleWidth),
        const MxGap(MxSpace.xs),
        MxSkeleton(height: 14, width: subtitleWidth),
        if (bodyHeight > 0) ...[
          const MxGap(MxSpace.md),
          MxSkeleton(height: bodyHeight),
        ],
      ],
    );
  }
}

class _FolderTileSkeleton extends StatelessWidget {
  const _FolderTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.md,
      ),
      child: Row(
        children: [
          MxSkeleton(width: 48, height: 48, borderRadius: MxFeatureRadii.md),
          MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(height: 18, width: 180),
                MxGap(MxSpace.xs),
                MxSkeleton(height: 14, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_animated_switcher.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../decks/actions/deck_quick_actions.dart';
import '../../decks/viewmodels/deck_detail_viewmodel.dart';
import '../actions/folder_quick_actions.dart';
import '../widgets/folder_detail_skeleton.dart';
import '../widgets/folder_empty_state_section.dart';
import '../widgets/folder_header_section.dart';
import '../widgets/folder_reorder_section.dart';
import '../widgets/folder_tree_section.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

enum _FolderBodyMode { empty, reorder, tree }

enum _FolderCreateChoice { subfolder, deck }

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
    if (queryData != null) {
      for (final subfolder in queryData.subfolders) {
        ref.listen<AsyncValue<void>>(
          folderActionControllerProvider(subfolder.id),
          (_, next) {
            final failure = folderActionError(next);
            if (failure != null) {
              MxSnackbar.error(context, folderActionErrorMessage(failure));
            }
          },
        );
      }
      for (final deck in queryData.decks) {
        ref.listen<AsyncValue<void>>(deckActionControllerProvider(deck.id), (
          _,
          next,
        ) {
          final failure = deckActionError(next);
          if (failure != null) {
            MxSnackbar.error(context, deckActionErrorMessage(failure));
          }
        });
      }
    }
    final showFab = queryData != null && _shouldShowFab(queryData);
    final toolbarState = ref.watch(
      folderChildrenToolbarStateProvider(widget.folderId),
    );
    return MxScaffold(
      floatingActionButton: showFab
          ? MxFab(
              icon: Icons.add,
              tooltip: _resolveFabTooltip(l10n, queryData),
              onPressed: _isReorderMode
                  ? null
                  : () {
                      if (queryData.isUnlocked) {
                        _chooseCreateContent();
                        return;
                      }
                      if (queryData.isSubfolderMode) {
                        _createSubfolder();
                        return;
                      }
                      _createDeck();
                    },
            )
          : null,
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        hasFab: showFab,
        child: MxRetainedAsyncState<FolderDetailState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          skeletonBuilder: (_) => const FolderDetailSkeleton(),
          onRetry: () =>
              ref.invalidate(folderDetailQueryProvider(widget.folderId)),
          dataBuilder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: FolderHeaderSection(
                    state: state,
                    onBack: () => context.popRoute(fallback: context.goLibrary),
                    onOpenActions: () => showFolderActions(
                      context: context,
                      ref: ref,
                      folderId: widget.folderId,
                      folderName: state.header.name,
                      includeReorder: true,
                      canReorder: state.canManualReorder,
                      isUnlocked: state.isUnlocked,
                      onReorder: () => _enterReorderMode(state),
                      onDeleted: () async {
                        await context.popRoute(fallback: context.goLibrary);
                      },
                    ),
                    onOpenBreadcrumb: (folderId) =>
                        context.goFolderDetail(folderId),
                  ),
                ),
                const MxSliverGap(MxSpace.xl),
                SliverToBoxAdapter(
                  child: MxSearchSortToolbar<ContentSortMode>(
                    searchHintText: l10n.commonSearch,
                    onSearchChanged: (value) => ref
                        .read(
                          folderChildrenToolbarStateProvider(
                            widget.folderId,
                          ).notifier,
                        )
                        .setSearchTerm(value),
                    onSearchClear: () => ref
                        .read(
                          folderChildrenToolbarStateProvider(
                            widget.folderId,
                          ).notifier,
                        )
                        .setSearchTerm(''),
                    sortOptions: sortOptions,
                    selectedSort: toolbarState.sortMode,
                    sortLabel: l10n.commonSort,
                    onSortSelected: (sortMode) => ref
                        .read(
                          folderChildrenToolbarStateProvider(
                            widget.folderId,
                          ).notifier,
                        )
                        .setSortMode(sortMode),
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
                ),
                const MxSliverGap(MxSpace.xl),
                ..._buildBodySlivers(state),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBodySlivers(FolderDetailState state) {
    final mode = _resolveBodyMode(state);
    return switch (mode) {
      _FolderBodyMode.tree => [
        FolderTreeSliver(
          state: state,
          onOpenSubfolder: _openSubfolder,
          onOpenSubfolderActions: _openSubfolderActions,
          onOpenDeckActions: _openDeckActions,
        ),
      ],
      _FolderBodyMode.empty => [
        SliverToBoxAdapter(
          child: MxAnimatedSwitcher(
            child: KeyedSubtree(
              key: const ValueKey(_FolderBodyMode.empty),
              child: FolderEmptyStateSection(
                mode: _resolveEmptyStateMode(state),
                onCreateSubfolder: _createSubfolder,
                onCreateDeck: _createDeck,
                onClearSearch: _clearSearch,
              ),
            ),
          ),
        ),
      ],
      _FolderBodyMode.reorder => [
        SliverToBoxAdapter(
          child: MxAnimatedSwitcher(
            child: KeyedSubtree(
              key: const ValueKey(_FolderBodyMode.reorder),
              child: FolderReorderSection(
                state: state,
                orderedIds: _orderedIds,
                onReorder: _handleReorder,
              ),
            ),
          ),
        ),
      ],
    };
  }

  _FolderBodyMode _resolveBodyMode(FolderDetailState state) {
    if (state.isUnlocked) {
      return _FolderBodyMode.empty;
    }
    if (_isReorderMode && _hasActiveItems(state)) {
      return _FolderBodyMode.reorder;
    }
    if (_hasActiveItems(state)) {
      return _FolderBodyMode.tree;
    }
    return _FolderBodyMode.empty;
  }

  FolderEmptyStateMode _resolveEmptyStateMode(FolderDetailState state) {
    if (_isSearchNoResult(state)) {
      return FolderEmptyStateMode.noResults;
    }
    if (state.isSubfolderMode) {
      return FolderEmptyStateMode.subfolders;
    }
    if (state.isDeckMode) {
      return FolderEmptyStateMode.decks;
    }
    return FolderEmptyStateMode.unlocked;
  }

  bool _shouldShowFab(FolderDetailState state) {
    return !_isReorderMode && !_isSearchNoResult(state);
  }

  String _resolveFabTooltip(AppLocalizations l10n, FolderDetailState state) {
    if (state.isUnlocked) {
      return l10n.commonCreate;
    }
    if (state.isSubfolderMode) {
      return l10n.foldersNewSubfolderTooltip;
    }
    return l10n.foldersNewDeckTooltip;
  }

  bool _isSearchNoResult(FolderDetailState state) {
    return !state.isUnlocked &&
        state.searchTerm.isNotEmpty &&
        !_hasActiveItems(state);
  }

  bool _hasActiveItems(FolderDetailState state) {
    if (state.isSubfolderMode) {
      return state.subfolders.isNotEmpty;
    }
    if (state.isDeckMode) {
      return state.decks.isNotEmpty;
    }
    return false;
  }

  void _clearSearch() {
    ref
        .read(folderChildrenToolbarStateProvider(widget.folderId).notifier)
        .setSearchTerm('');
  }

  Future<void> _chooseCreateContent() async {
    final l10n = AppLocalizations.of(context);
    final choice = await MxBottomSheet.show<_FolderCreateChoice>(
      context: context,
      title: l10n.foldersCreateChoiceTitle,
      child: MxActionSheetList<_FolderCreateChoice>(
        items: [
          MxActionSheetItem(
            value: _FolderCreateChoice.subfolder,
            label: l10n.foldersNewSubfolderTooltip,
            icon: Icons.create_new_folder_outlined,
          ),
          MxActionSheetItem(
            value: _FolderCreateChoice.deck,
            label: l10n.foldersNewDeckTooltip,
            icon: Icons.style_outlined,
          ),
        ],
      ),
    );
    if (!mounted || choice == null) {
      return;
    }

    switch (choice) {
      case _FolderCreateChoice.subfolder:
        await _createSubfolder();
      case _FolderCreateChoice.deck:
        await _createDeck();
    }
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

  Future<void> _openSubfolderActions(FolderSubfolderItem item) {
    return showFolderActions(
      context: context,
      ref: ref,
      folderId: item.id,
      folderName: item.name,
    );
  }

  Future<void> _openDeckActions(FolderDeckItem item) {
    return showDeckActions(
      context: context,
      ref: ref,
      deckId: item.id,
      deckName: item.name,
    );
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

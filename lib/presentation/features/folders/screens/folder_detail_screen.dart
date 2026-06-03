import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/usecases/folder_study_entry_usecase.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/study/discard_resume_session.dart';
import '../../../shared/widgets/mx_animated_switcher.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../decks/actions/deck_quick_actions.dart';
import '../../decks/viewmodels/deck_action_viewmodel.dart';
import '../actions/folder_quick_actions.dart';
import '../viewmodels/folder_detail_viewmodel.dart';
import '../viewmodels/folder_study_entry_provider.dart';
import '../widgets/folder_detail_skeleton.dart';
import '../widgets/folder_empty_state_section.dart';
import '../widgets/folder_header_section.dart';
import '../widgets/folder_reorder_section.dart';
import '../widgets/folder_stat_strip.dart';
import '../widgets/folder_study_entry_section.dart';
import '../widgets/folder_tree_section.dart';

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
          MxSnackbar.error(context, folderActionErrorMessage(l10n, failure));
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
              MxSnackbar.error(
                context,
                folderActionErrorMessage(l10n, failure),
              );
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
    // Study-entry summary is best-effort: while it loads or if the scope probe
    // fails, the banners simply stay hidden (folder browsing is unaffected).
    final studyEntry =
        ref.watch(folderStudyEntryProvider(widget.folderId)).value ??
        const FolderStudyEntry.empty();
    return _buildScaffold(
      l10n: l10n,
      sortOptions: sortOptions,
      queryState: queryState,
      queryData: queryData,
      showFab: showFab,
      toolbarState: toolbarState,
      studyEntry: studyEntry,
    );
  }

  Widget _buildScaffold({
    required AppLocalizations l10n,
    required List<MxSortOption<ContentSortMode>> sortOptions,
    required AsyncValue<FolderDetailState> queryState,
    required FolderDetailState? queryData,
    required bool showFab,
    required ContentQuery toolbarState,
    required FolderStudyEntry studyEntry,
  }) => MxScaffold(
    floatingActionButton: showFab
        ? MxFab(
            icon: Icons.add,
            tooltip: _resolveFabTooltip(l10n, queryData!),
            onPressed: _isReorderMode
                ? null
                : () {
                    if (queryData.isUnlocked) {
                      unawaited(_chooseCreateContent());
                      return;
                    }
                    if (queryData.isSubfolderMode) {
                      unawaited(_createSubfolder());
                      return;
                    }
                    unawaited(_createDeck());
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
        dataBuilder: (context, state) => CustomScrollView(
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
                  canImportFlashcards: state.canImportFlashcards,
                  onReorder: () => _enterReorderMode(state),
                  onDeleted: () async {
                    await context.popRoute(fallback: context.goLibrary);
                  },
                ),
                onOpenBreadcrumb: (folderId) =>
                    context.goFolderDetail(folderId),
              ),
            ),
            ..._buildStudyEntrySlivers(studyEntry),
            if (state.isDeckMode && state.decks.isNotEmpty) ...[
              const MxSliverGap(MxSpace.md),
              SliverToBoxAdapter(child: FolderStatStrip(decks: state.decks)),
            ],
            const MxSliverGap(MxSpace.md),
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
            const MxSliverGap(MxSpace.lg),
            ..._buildBodySlivers(state),
          ],
        ),
      ),
    ),
  );

  List<Widget> _buildStudyEntrySlivers(FolderStudyEntry studyEntry) {
    if (!studyEntry.hasResume && !studyEntry.hasCards) {
      return const <Widget>[];
    }
    return [
      const MxSliverGap(MxSpace.md),
      SliverToBoxAdapter(
        child: FolderStudyEntrySection(
          entry: studyEntry,
          onResume: (sessionId) => context.goStudySession(sessionId),
          onDiscard: _discardResumeSession,
          onStudyToday: _studyFolderDueCards,
          onStudyFolder: _studyFolder,
        ),
      ),
    ];
  }

  /// Folder-scoped SRS review of due cards via the Study Entry Gate. The gate
  /// owns empty-scope validation, resume conflict, and session creation; this
  /// never starts a session directly.
  void _studyFolderDueCards() {
    context.goStudyEntry(
      entryType: StudyEntryType.folder.storageValue,
      entryRefId: widget.folderId,
      studyType: StudyType.srsReview.storageValue,
    );
  }

  /// Discards the existing folder-scoped paused session via the shared
  /// Resume-Discard flow. Cancels the session (never creates one); on success
  /// the study-session revision bump refreshes the banner so it disappears.
  Future<void> _discardResumeSession(String sessionId) =>
      confirmAndDiscardResumeSession(
        context: context,
        ref: ref,
        sessionId: sessionId,
      );

  /// Folder-scoped new study of the whole folder via the Study Entry Gate.
  void _studyFolder() {
    context.goStudyEntry(
      entryType: StudyEntryType.folder.storageValue,
      entryRefId: widget.folderId,
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
          onOpenDeckActions: (item) => _openDeckActions(state, item),
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

  bool _shouldShowFab(FolderDetailState state) =>
      !_isReorderMode && !_isSearchNoResult(state);

  String _resolveFabTooltip(AppLocalizations l10n, FolderDetailState state) {
    if (state.isUnlocked) {
      return l10n.commonCreate;
    }
    if (state.isSubfolderMode) {
      return l10n.foldersNewSubfolderTooltip;
    }
    return l10n.foldersNewDeckTooltip;
  }

  bool _isSearchNoResult(FolderDetailState state) =>
      !state.isUnlocked &&
      state.searchTerm.isNotEmpty &&
      !_hasActiveItems(state) &&
      // A genuinely empty folder stays "true empty" regardless of the search
      // term — no-results only applies when the search hid existing children.
      state.hasUnfilteredChildren;

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
    if (!mounted) return;
    if (choice == null) return;

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
    if (!mounted) return;
    if (name == null) return;
    final success = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .createSubfolder(name);
    if (!mounted) return;
    if (!success) return;
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
    if (!mounted) return;
    if (name == null) return;
    final deckId = await ref
        .read(folderActionControllerProvider(widget.folderId).notifier)
        .createDeck(name);
    if (!mounted) return;
    if (deckId == null) return;
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

  Future<void> _openSubfolderActions(FolderSubfolderItem item) =>
      showFolderActions(
        context: context,
        ref: ref,
        folderId: item.id,
        folderName: item.name,
        canImportFlashcards: item.canImportFlashcards,
      );

  Future<void> _openDeckActions(FolderDetailState state, FolderDeckItem item) =>
      showDeckActions(
        context: context,
        ref: ref,
        deckId: item.id,
        deckName: item.name,
        actionContext: DeckActionContext(
          deckId: item.id,
          deckName: item.name,
          folderId: state.header.id,
          breadcrumb: <BreadcrumbSegmentReadModel>[
            ...state.header.breadcrumb,
            BreadcrumbSegmentReadModel(label: item.name),
          ],
        ),
      );

  Future<void> _saveReorder(FolderDetailState state) async {
    final controller = ref.read(
      folderActionControllerProvider(widget.folderId).notifier,
    );

    final success = state.isSubfolderMode
        ? await controller.reorderSubfolders(_orderedIds)
        : await controller.reorderDecks(_orderedIds);
    if (!mounted) return;
    if (!success) return;

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

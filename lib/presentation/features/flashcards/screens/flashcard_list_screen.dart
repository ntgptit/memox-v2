import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/services/tts_service.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../decks/actions/deck_quick_actions.dart';
import '../../decks/viewmodels/deck_action_viewmodel.dart';
import '../../tts/providers/tts_controller_notifier.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';
import '../widgets/flashcard_breadcrumb_section.dart';
import '../widgets/flashcard_bulk_action_section.dart';
import '../widgets/flashcard_deck_summary_section.dart';
import '../widgets/flashcard_empty_state_section.dart';
import '../widgets/flashcard_header_section.dart';
import '../widgets/flashcard_items_section.dart';
import '../widgets/flashcard_list_skeleton.dart';
import '../widgets/flashcard_progress_section.dart';
import '../widgets/flashcard_reorder_list.dart';
import '../widgets/flashcard_study_modes_section.dart';
import '../widgets/flashcard_toolbar_section.dart';

enum _FlashcardRowAction { edit, move, export, select, delete }

class FlashcardListScreen extends ConsumerStatefulWidget {
  const FlashcardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<FlashcardListScreen> createState() =>
      _FlashcardListScreenState();
}

class _FlashcardListScreenState extends ConsumerState<FlashcardListScreen> {
  bool _isReorderMode = false;
  List<String> _orderedIds = <String>[];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(
      flashcardActionControllerProvider(widget.deckId),
      (_, next) {
        final failure = flashcardActionError(next);
        if (failure != null) {
          MxSnackbar.error(context, flashcardActionErrorMessage(failure));
        }
      },
    );
    ref.listen<AsyncValue<void>>(deckActionControllerProvider(widget.deckId), (
      _,
      next,
    ) {
      final failure = deckActionError(next);
      if (failure != null) {
        MxSnackbar.error(context, deckActionErrorMessage(failure));
      }
    });

    final queryState = ref.watch(flashcardListQueryProvider(widget.deckId));
    final toolbarState = ref.watch(
      flashcardToolbarStateProvider(widget.deckId),
    );
    final toolbarNotifier = ref.read(
      flashcardToolbarStateProvider(widget.deckId).notifier,
    );
    final selection = ref.watch(flashcardSelectionProvider(widget.deckId));
    final selectionNotifier = ref.read(
      flashcardSelectionProvider(widget.deckId).notifier,
    );

    return _buildScaffold(
      l10n: l10n,
      queryState: queryState,
      toolbarState: toolbarState,
      toolbarNotifier: toolbarNotifier,
      selection: selection,
      selectionNotifier: selectionNotifier,
    );
  }

  Widget _buildScaffold({
    required AppLocalizations l10n,
    required AsyncValue<FlashcardListState> queryState,
    required ContentQuery toolbarState,
    required FlashcardToolbarState toolbarNotifier,
    required Set<String> selection,
    required FlashcardSelection selectionNotifier,
  }) => MxScaffold(
      floatingActionButton: _isReorderMode
          ? null
          : MxFab(
              icon: Icons.add,
              tooltip: l10n.flashcardsAddTooltip,
              onPressed: () => context.pushFlashcardCreate(widget.deckId),
            ),
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        hasFab: !_isReorderMode,
        child: MxRetainedAsyncState<FlashcardListState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          skeletonBuilder: (_) => const FlashcardListSkeleton(),
          onRetry: () =>
              ref.invalidate(flashcardListQueryProvider(widget.deckId)),
          dataBuilder: (context, state) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: FlashcardHeaderSection(
                    title: state.deckName,
                    onBack: () => context.popRoute(
                      fallback: () => _goToDeckParent(context, state),
                    ),
                    onShare: _exportDeck,
                    onOpenActions: () => showDeckActions(
                      context: context,
                      ref: ref,
                      deckId: state.deckId,
                      deckName: state.deckName,
                      actionContext: DeckActionContext(
                        deckId: state.deckId,
                        deckName: state.deckName,
                        folderId: state.folderId,
                        breadcrumb: state.breadcrumb,
                      ),
                      onDeleted: () async {
                        await context.popRoute(
                          fallback: () => _goToDeckParent(context, state),
                        );
                      },
                    ),
                  ),
                ),
                const MxSliverGap(MxSpace.sm),
                // DS Deck Detail order: appbar → breadcrumb → hero summary →
                // study modes (primary CTA) → card breakdown → preview → items.
                SliverToBoxAdapter(
                  child: FlashcardBreadcrumbSection(
                    breadcrumb: state.breadcrumb,
                    onOpenBreadcrumb: (folderId) =>
                        context.goFolderDetail(folderId),
                    onOpenLibrary: context.goLibrary,
                  ),
                ),
                const MxSliverGap(MxSpace.md),
                SliverToBoxAdapter(
                  child: FlashcardDeckSummarySection(
                    state: state,
                    studyEnabled: state.items.isNotEmpty,
                    onStartStudy: () => _goStudyEntry(state, null),
                  ),
                ),
                const MxSliverGap(MxSpace.xl),
                SliverToBoxAdapter(
                  child: FlashcardStudyModesSection(
                    enabled: state.items.isNotEmpty,
                    onStartStudy: (mode) => _goStudyEntry(state, mode),
                  ),
                ),
                const MxSliverGap(MxSpace.xl),
                SliverToBoxAdapter(
                  child: FlashcardProgressSection(progress: state.progress),
                ),
                const MxSliverGap(MxSpace.xl),
                SliverToBoxAdapter(
                  child: FlashcardToolbarSection(
                    selectedSort: toolbarState.sortMode,
                    isReorderMode: _isReorderMode,
                    canManualReorder: state.canManualReorder,
                    searchTerm: toolbarState.searchTerm,
                    onSearchChanged: toolbarNotifier.setSearchTerm,
                    onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                    onSortSelected: toolbarNotifier.setSortMode,
                    onCancelReorder: _cancelReorder,
                    onSaveReorder: _saveReorder,
                    onImport: () => context.pushDeckImport(widget.deckId),
                    onStartReorder: () => _enterReorderMode(state),
                  ),
                ),
                if (selection.isNotEmpty) ...[
                  const MxSliverGap(MxSpace.lg),
                  SliverToBoxAdapter(
                    child: FlashcardBulkActionSection(
                      selectionCount: selection.length,
                      totalItemCount: state.items.length,
                      onToggleSelectionMode: () {
                        if (selection.length == state.items.length) {
                          selectionNotifier.clear();
                          return;
                        }
                        selectionNotifier.setAll(
                          state.items.map((item) => item.id),
                        );
                      },
                      onMove: () => _moveSelected(selection.toList()),
                      onExport: () => _exportSelected(selection.toList()),
                      onDelete: () => _deleteSelected(selection.toList()),
                    ),
                  ),
                ],
                const MxSliverGap(MxSpace.lg),
                ..._buildBodySlivers(
                  state: state,
                  selection: selection,
                  onToggleSelection: selectionNotifier.toggle,
                ),
                if (!_isReorderMode)
                  const MxSliverGap(kMinInteractiveDimension + MxSpace.xxl),
              ],
            ),
        ),
      ),
    );

  void _enterReorderMode(FlashcardListState state) {
    setState(() {
      _isReorderMode = true;
      _orderedIds = state.items.map((item) => item.id).toList(growable: true);
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

  Future<void> _saveReorder() async {
    final success = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .reorderFlashcards(_orderedIds);
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

  Future<void> _moveSelected(List<String> flashcardIds) async {
    final l10n = AppLocalizations.of(context);
    final targets = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .loadMoveTargets(flashcardIds);
    if (!mounted) {
      return;
    }

    final targetDeckId = await MxDestinationPickerSheet.show<String>(
      context: context,
      title: l10n.flashcardsMoveTitle,
      supportingText: l10n.flashcardsMoveProgressKeptNote,
      destinations: [
        for (final target in targets)
          MxDestinationOption<String>(
            value: target.id,
            title: target.name,
            subtitle: target.breadcrumb.join(' / '),
            icon: Icons.style_outlined,
            searchTerms: target.breadcrumb,
          ),
      ],
      emptyLabel: l10n.commonNoValidDestinationFound,
    );
    if (!mounted) return;
    if (targetDeckId == null) return;

    final success = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .moveFlashcards(flashcardIds: flashcardIds, targetDeckId: targetDeckId);
    if (!mounted) return;
    if (!success) return;
    MxSnackbar.success(context, l10n.flashcardsMovedMessage);
  }

  Future<void> _exportSelected(List<String> flashcardIds) async {
    final export = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .exportFlashcards(flashcardIds);
    if (!mounted) return;
    if (export == null) return;

    final bytes = Uint8List.fromList(utf8.encode(export.content));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: export.mimeType)],
        fileNameOverrides: [export.fileName],
        subject: export.fileName,
      ),
    );
  }

  Future<void> _exportDeck() async {
    final export = await ref
        .read(deckActionControllerProvider(widget.deckId).notifier)
        .exportDeck();
    if (!mounted) return;
    if (export == null) return;

    final bytes = Uint8List.fromList(utf8.encode(export.content));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: export.mimeType)],
        fileNameOverrides: [export.fileName],
        subject: export.fileName,
      ),
    );
  }

  Future<void> _deleteSelected(List<String> flashcardIds) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.flashcardsDeleteTitle,
      message: l10n.flashcardsDeleteMessage,
      confirmLabel: l10n.commonDelete,
      tone: MxConfirmationTone.danger,
      icon: Icons.delete_outline,
    );
    if (!mounted) return;
    if (!confirmed) return;

    final success = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .deleteFlashcards(flashcardIds);
    if (!mounted) return;
    if (!success) return;
    MxSnackbar.success(context, l10n.flashcardsDeletedMessage);
  }

  Future<void> _openFlashcardActions(FlashcardListItemState item) async {
    final l10n = AppLocalizations.of(context);
    final action = await MxBottomSheet.show<_FlashcardRowAction>(
      context: context,
      title: l10n.flashcardsActionsTitle,
      child: MxActionSheetList<_FlashcardRowAction>(
        items: [
          MxActionSheetItem(
            value: _FlashcardRowAction.edit,
            label: l10n.commonEdit,
            icon: Icons.edit_outlined,
          ),
          MxActionSheetItem(
            value: _FlashcardRowAction.move,
            label: l10n.commonMove,
            icon: Icons.drive_file_move_outline,
          ),
          MxActionSheetItem(
            value: _FlashcardRowAction.export,
            label: l10n.commonExport,
            icon: Icons.file_download_outlined,
          ),
          MxActionSheetItem(
            value: _FlashcardRowAction.select,
            label: l10n.commonSelect,
            icon: Icons.check_circle_outline_rounded,
          ),
          MxActionSheetItem(
            value: _FlashcardRowAction.delete,
            label: l10n.commonDelete,
            icon: Icons.delete_outline,
            tone: MxActionSheetItemTone.destructive,
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == null) return;

    switch (action) {
      case _FlashcardRowAction.edit:
        context.pushFlashcardEdit(deckId: widget.deckId, flashcardId: item.id);
      case _FlashcardRowAction.move:
        await _moveSelected([item.id]);
      case _FlashcardRowAction.export:
        await _exportSelected([item.id]);
      case _FlashcardRowAction.select:
        ref
            .read(flashcardSelectionProvider(widget.deckId).notifier)
            .toggle(item.id);
      case _FlashcardRowAction.delete:
        await _deleteSelected([item.id]);
    }
  }

  List<Widget> _buildBodySlivers({
    required FlashcardListState state,
    required Set<String> selection,
    required ValueChanged<String> onToggleSelection,
  }) {
    if (_isReorderMode) {
      return [
        SliverToBoxAdapter(
          child: FlashcardReorderList(
            state: state,
            orderedIds: _orderedIds,
            onReorder: _handleReorder,
          ),
        ),
      ];
    }
    if (state.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: FlashcardEmptyStateSection(deckId: widget.deckId),
        ),
      ];
    }
    return [
      FlashcardItemsSection(
        state: state,
        deckId: widget.deckId,
        selection: selection,
        onToggleSelection: onToggleSelection,
        onOpenActions: _openFlashcardActions,
        onSpeak: _speakFront,
      ),
    ];
  }

  void _goStudyEntry(FlashcardListState state, StudyMode? studyMode) {
    context.goStudyEntry(
      entryType: 'deck',
      entryRefId: state.deckId,
      studyMode: studyMode?.storageValue,
    );
  }

  void _speakFront(FlashcardListItemState item) {
    unawaited(
      ref
          .read(ttsControllerProvider.notifier)
          .speakTextSide(text: item.front, side: TtsTextSide.front),
    );
  }

  void _goToDeckParent(BuildContext context, FlashcardListState state) {
    final folderId = _parentFolderId(state);
    if (folderId == null) {
      context.goLibrary();
      return;
    }
    context.goFolderDetail(folderId);
  }

  String? _parentFolderId(FlashcardListState state) {
    for (final segment in state.breadcrumb.reversed) {
      if (segment.folderId != null) {
        return segment.folderId;
      }
    }
    return null;
  }
}

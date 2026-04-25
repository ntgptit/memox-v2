import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../widgets/flashcard_bulk_action_section.dart';
import '../widgets/flashcard_empty_state_section.dart';
import '../widgets/flashcard_header_section.dart';
import '../widgets/flashcard_items_section.dart';
import '../widgets/flashcard_list_skeleton.dart';
import '../widgets/flashcard_reorder_list.dart';
import '../widgets/flashcard_toolbar_section.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

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

    return MxScaffold(
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
          dataBuilder: (context, state) {
            Widget content = FlashcardItemsSection(
              state: state,
              deckId: widget.deckId,
              selection: selection,
              onToggleSelection: selectionNotifier.toggle,
            );
            if (state.items.isEmpty) {
              content = FlashcardEmptyStateSection(deckId: widget.deckId);
            }
            if (_isReorderMode) {
              content = FlashcardReorderList(
                state: state,
                orderedIds: _orderedIds,
                onReorder: _handleReorder,
              );
            }

            return ListView(
              children: [
                FlashcardHeaderSection(
                  state: state,
                  onBack: () => context.popRoute(
                    fallback: () => context.goDeckDetail(state.deckId),
                  ),
                  onOpenBreadcrumb: (folderId) =>
                      context.goFolderDetail(folderId),
                ),
                const MxGap(MxSpace.xl),
                FlashcardToolbarSection(
                  selectedSort: toolbarState.sortMode,
                  isReorderMode: _isReorderMode,
                  canManualReorder: state.canManualReorder,
                  onSearchChanged: toolbarNotifier.setSearchTerm,
                  onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                  onSortSelected: toolbarNotifier.setSortMode,
                  onCancelReorder: _cancelReorder,
                  onSaveReorder: _saveReorder,
                  onImport: () => context.pushDeckImport(widget.deckId),
                  onStartReorder: () => _enterReorderMode(state),
                ),
                if (selection.isNotEmpty) ...[
                  const MxGap(MxSpace.lg),
                  FlashcardBulkActionSection(
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
                ],
                const MxGap(MxSpace.xl),
                content,
              ],
            );
          },
        ),
      ),
    );
  }

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

  Future<void> _moveSelected(List<String> flashcardIds) async {
    final l10n = AppLocalizations.of(context);
    final targets = await ref.read(
      flashcardMoveTargetsProvider(widget.deckId).future,
    );
    if (!mounted) {
      return;
    }

    final targetDeckId = await MxDestinationPickerSheet.show<String>(
      context: context,
      title: l10n.flashcardsMoveTitle,
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
    if (!mounted || targetDeckId == null) {
      return;
    }

    final success = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .moveFlashcards(flashcardIds: flashcardIds, targetDeckId: targetDeckId);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.flashcardsMovedMessage);
  }

  Future<void> _exportSelected(List<String> flashcardIds) async {
    final export = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .exportFlashcards(flashcardIds);
    if (!mounted || export == null) {
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
    if (!mounted || !confirmed) {
      return;
    }

    final success = await ref
        .read(flashcardActionControllerProvider(widget.deckId).notifier)
        .deleteFlashcards(flashcardIds);
    if (!mounted || !success) {
      return;
    }
    MxSnackbar.success(context, l10n.flashcardsDeletedMessage);
  }
}

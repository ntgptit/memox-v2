import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_bulk_action_bar.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_reorderable_list.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_term_row.dart';
import '../../../shared/widgets/mx_text.dart';
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
    final sortOptions = buildContentSortOptions(l10n);

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
          skeletonBuilder: (_) => const _FlashcardListSkeleton(),
          onRetry: () =>
              ref.invalidate(flashcardListQueryProvider(widget.deckId)),
          dataBuilder: (context, state) {
            Widget content = _FlashcardItems(
              state: state,
              deckId: widget.deckId,
              selection: selection,
              onToggleSelection: selectionNotifier.toggle,
            );
            if (state.items.isEmpty) {
              content = _FlashcardEmptyState(deckId: widget.deckId);
            }
            if (_isReorderMode) {
              content = _FlashcardReorderList(
                state: state,
                orderedIds: _orderedIds,
                onReorder: _handleReorder,
              );
            }

            return ListView(
              children: [
                _FlashcardHeader(
                  state: state,
                  onBack: () => context.popRoute(
                    fallback: () => context.goDeckDetail(state.deckId),
                  ),
                  onOpenBreadcrumb: (folderId) =>
                      context.goFolderDetail(folderId),
                ),
                const MxGap(MxSpace.xl),
                MxSearchSortToolbar<ContentSortMode>(
                  searchHintText: l10n.flashcardsSearchHint,
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
                            onPressed: _saveReorder,
                          ),
                        ]
                      : <Widget>[
                          MxSecondaryButton(
                            label: l10n.commonImport,
                            leadingIcon: Icons.file_upload_outlined,
                            variant: MxSecondaryVariant.outlined,
                            onPressed: () =>
                                context.pushDeckImport(widget.deckId),
                          ),
                          MxSecondaryButton(
                            label: l10n.commonReorder,
                            leadingIcon: Icons.reorder_rounded,
                            variant: MxSecondaryVariant.outlined,
                            onPressed: state.canManualReorder
                                ? () => _enterReorderMode(state)
                                : null,
                          ),
                        ],
                ),
                if (selection.isNotEmpty) ...[
                  const MxGap(MxSpace.lg),
                  MxBulkActionBar(
                    label: l10n.flashcardsBulkSelected(selection.length),
                    subtitle: l10n.flashcardsBulkSubtitle,
                    actions: [
                      MxSecondaryButton(
                        label: selection.length == state.items.length
                            ? l10n.commonClear
                            : l10n.commonSelectAll,
                        variant: MxSecondaryVariant.text,
                        onPressed: () {
                          if (selection.length == state.items.length) {
                            selectionNotifier.clear();
                            return;
                          }
                          selectionNotifier.setAll(
                            state.items.map((item) => item.id),
                          );
                        },
                      ),
                      MxSecondaryButton(
                        label: l10n.commonMove,
                        leadingIcon: Icons.drive_file_move_outline,
                        variant: MxSecondaryVariant.outlined,
                        onPressed: () => _moveSelected(selection.toList()),
                      ),
                      MxSecondaryButton(
                        label: l10n.commonExport,
                        leadingIcon: Icons.file_download_outlined,
                        variant: MxSecondaryVariant.outlined,
                        onPressed: () => _exportSelected(selection.toList()),
                      ),
                      MxPrimaryButton(
                        label: l10n.commonDelete,
                        leadingIcon: Icons.delete_outline,
                        tone: MxPrimaryButtonTone.danger,
                        onPressed: () => _deleteSelected(selection.toList()),
                      ),
                    ],
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

class _FlashcardHeader extends StatelessWidget {
  const _FlashcardHeader({
    required this.state,
    required this.onBack,
    required this.onOpenBreadcrumb,
  });

  final FlashcardListState state;
  final VoidCallback onBack;
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
              onPressed: onBack,
            ),
            const MxGap(MxSpace.sm),
            Expanded(child: MxText(state.deckName, role: MxTextRole.pageTitle)),
          ],
        ),
        const MxGap(MxSpace.sm),
        MxBreadcrumbBar(
          items: [
            for (var index = 0; index < state.breadcrumb.length; index++)
              MxBreadcrumb(
                label: state.breadcrumb[index].label,
                onTap:
                    index == state.breadcrumb.length - 1 ||
                        state.breadcrumb[index].folderId == null
                    ? null
                    : () => onOpenBreadcrumb(state.breadcrumb[index].folderId!),
              ),
          ],
        ),
      ],
    );
  }
}

class _FlashcardEmptyState extends StatelessWidget {
  const _FlashcardEmptyState({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      title: l10n.flashcardsEmptyTitle,
      message: l10n.flashcardsEmptyMessage,
      icon: Icons.style_outlined,
      actionLabel: l10n.flashcardsAddAction,
      actionLeadingIcon: Icons.add,
      onAction: () => context.pushFlashcardCreate(deckId),
    );
  }
}

class _FlashcardItems extends StatelessWidget {
  const _FlashcardItems({
    required this.state,
    required this.deckId,
    required this.selection,
    required this.onToggleSelection,
  });

  final FlashcardListState state;
  final String deckId;
  final Set<String> selection;
  final ValueChanged<String> onToggleSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < state.items.length; index++) ...[
          MxTermRow(
            term: state.items[index].title,
            definition: state.items[index].back,
            caption: state.items[index].front,
            selected: selection.contains(state.items[index].id),
            onTap: () {
              if (selection.isNotEmpty) {
                onToggleSelection(state.items[index].id);
                return;
              }
              context.pushFlashcardEdit(
                deckId: deckId,
                flashcardId: state.items[index].id,
              );
            },
            onLongPress: () => onToggleSelection(state.items[index].id),
          ),
          if (index < state.items.length - 1) const MxGap(MxSpace.sm),
        ],
      ],
    );
  }
}

class _FlashcardReorderList extends StatelessWidget {
  const _FlashcardReorderList({
    required this.state,
    required this.orderedIds,
    required this.onReorder,
  });

  final FlashcardListState state;
  final List<String> orderedIds;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MxFeatureSizes.flashcardReorderPanelHeight,
      child: MxReorderableList.builder(
        itemCount: orderedIds.length,
        buildDefaultDragHandles: true,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = state.items.firstWhere(
            (flashcard) => flashcard.id == orderedIds[index],
          );
          return KeyedSubtree(
            key: ValueKey(item.id),
            child: MxTermRow(
              term: item.title,
              definition: item.back,
              caption: item.front,
            ),
          );
        },
      ),
    );
  }
}

class _FlashcardListSkeleton extends StatelessWidget {
  const _FlashcardListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('flashcard_list_skeleton'),
      children: const [
        _FlashcardHeaderSkeleton(),
        MxGap(MxSpace.xl),
        _FlashcardToolbarSkeleton(),
        MxGap(MxSpace.xl),
        _TermRowSkeleton(),
        MxGap(MxSpace.sm),
        _TermRowSkeleton(),
        MxGap(MxSpace.sm),
        _TermRowSkeleton(),
      ],
    );
  }
}

class _FlashcardHeaderSkeleton extends StatelessWidget {
  const _FlashcardHeaderSkeleton();

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
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(height: 14, width: 180),
      ],
    );
  }
}

class _FlashcardToolbarSkeleton extends StatelessWidget {
  const _FlashcardToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        MxSkeleton(height: 48, borderRadius: MxFeatureRadii.full),
        MxGap(MxSpace.sm),
        Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          children: [
            MxSkeleton(
              height: 32,
              width: 120,
              borderRadius: MxFeatureRadii.full,
            ),
            MxSkeleton(
              height: 40,
              width: 120,
              borderRadius: MxFeatureRadii.full,
            ),
            MxSkeleton(
              height: 40,
              width: 132,
              borderRadius: MxFeatureRadii.full,
            ),
          ],
        ),
      ],
    );
  }
}

class _TermRowSkeleton extends StatelessWidget {
  const _TermRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(MxSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSkeleton(height: 18, width: 180),
          MxGap(MxSpace.xs),
          MxSkeleton(height: 16, width: 240),
          MxGap(MxSpace.sm),
          MxSkeleton(height: 14, width: 132),
        ],
      ),
    );
  }
}

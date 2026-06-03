import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_animated_switcher.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_error_state.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_icon_tile.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_section_header.dart';
import '../../../shared/widgets/mx_text.dart';
import '../actions/folder_quick_actions.dart';
import '../models/library_folder.dart';
import '../viewmodels/folder_detail_viewmodel.dart';
import '../viewmodels/library_overview_viewmodel.dart';
import '../widgets/library_app_bar.dart';
import '../widgets/library_empty_state_section.dart';
import '../widgets/library_folder_list.dart';
import '../widgets/library_skeleton.dart';

Widget buildLibraryOverviewFab(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);

  // DS "03 · Library overview": a labelled "New folder" pill sitting above the
  // bottom nav (Prompt 49B), not an icon-only add FAB. The action is the
  // existing create-folder flow — no New deck / Import entry here.
  return MxFab(
    icon: Icons.create_new_folder_outlined,
    extendedLabel: l10n.libraryNewFolderLabel,
    tooltip: l10n.libraryCreateFolderTooltip,
    onPressed: () => _handleCreateFolder(context, ref),
  );
}

class LibraryOverviewView extends ConsumerStatefulWidget {
  const LibraryOverviewView({super.key});

  @override
  ConsumerState<LibraryOverviewView> createState() =>
      _LibraryOverviewViewState();
}

class _LibraryOverviewViewState extends ConsumerState<LibraryOverviewView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(libraryOverviewActionControllerProvider, (
      _,
      next,
    ) {
      final failure = libraryOverviewActionError(next);
      if (failure != null) {
        MxSnackbar.error(context, failure.message);
      }
    });

    final queryState = ref.watch(libraryOverviewQueryProvider);
    for (final folder in queryState.value?.folders ?? <LibraryFolder>[]) {
      ref.listen<AsyncValue<void>>(folderActionControllerProvider(folder.id), (
        _,
        next,
      ) {
        final failure = folderActionError(next);
        if (failure != null) {
          MxSnackbar.error(context, folderActionErrorMessage(l10n, failure));
        }
      });
    }
    final toolbarState = ref.watch(libraryToolbarStateProvider);
    final toolbarNotifier = ref.read(libraryToolbarStateProvider.notifier);

    return MxScaffold(
      floatingActionButton: buildLibraryOverviewFab(context, ref),
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        hasFab: true,
        child: MxRetainedAsyncState<LibraryOverviewState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          skeletonBuilder: (_) => const LibrarySkeleton(),
          onRetry: () => ref.invalidate(libraryOverviewQueryProvider),
          errorBuilder: (context, _, _) => MxErrorState(
            icon: Icons.cloud_off_outlined,
            title: l10n.libraryLoadFailedTitle,
            message: l10n.libraryLoadFailedMessage,
            onRetry: () => ref.invalidate(libraryOverviewQueryProvider),
          ),
          dataBuilder: (context, state) {
            final hasSearchTerm = StringUtils.isNotBlank(
              toolbarState.searchTerm,
            );
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: LibraryAppBar(
                    title: l10n.libraryTitle,
                    searchTerm: toolbarState.searchTerm,
                    onSearchChanged: toolbarNotifier.setSearchTerm,
                    onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                  ),
                ),
                // Due summary card renders in the loaded state only, when at
                // least one card is due and no scope-local search is active. It
                // stays non interactive because no approved study launch exists
                // from this surface yet.
                if (!hasSearchTerm && state.dueToday > 0) ...[
                  const MxSliverGap(MxSpace.md),
                  SliverToBoxAdapter(
                    child: _LibraryDueSummaryCard(dueToday: state.dueToday),
                  ),
                ],
                ..._buildSectionHeaderSlivers(
                  context,
                  state,
                  hasSearchTerm: hasSearchTerm,
                ),
                const MxSliverGap(MxSpace.md),
                ..._buildFolderListSlivers(
                  context,
                  ref,
                  state,
                  hasSearchTerm: hasSearchTerm,
                  onClearSearch: () => toolbarNotifier.setSearchTerm(''),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Section header above the folder list. When a search is active it keeps the
/// "Folders / Search results" heading; otherwise the loaded state shows a
/// `{n} FOLDERS` overline count. Returns no slivers while the list is visibly
/// empty (the empty / no-results sections own their own copy).
List<Widget> _buildSectionHeaderSlivers(
  BuildContext context,
  LibraryOverviewState state, {
  required bool hasSearchTerm,
}) {
  final l10n = AppLocalizations.of(context);
  if (hasSearchTerm) {
    return [
      const MxSliverGap(MxSpace.md),
      SliverToBoxAdapter(
        child: _LibrarySectionHeader(
          title: l10n.libraryFoldersSectionTitle,
          subtitle: l10n.librarySearchResultsSubtitle,
          showSubtitle: true,
        ),
      ),
    ];
  }
  if (state.isVisibleEmpty) {
    return const [];
  }
  return [
    const MxSliverGap(MxSpace.md),
    SliverToBoxAdapter(
      child: MxSectionHeader(
        title: l10n.libraryFolderCountLabel(state.folders.length),
        style: MxSectionHeaderStyle.overline,
      ),
    ),
  ];
}

List<Widget> _buildFolderListSlivers(
  BuildContext context,
  WidgetRef ref,
  LibraryOverviewState state, {
  required bool hasSearchTerm,
  required VoidCallback onClearSearch,
}) {
  if (state.isVisibleEmpty) {
    // A scope-local search that matches nothing is distinct from a genuinely
    // empty library: the former offers "clear search", the latter offers
    // "create folder". The library is only truly empty when it holds zero
    // folders (`totalFolderCount == 0`) — typing a search term over a
    // populated library must never be mistaken for an empty library.
    final isSearchNoResult = hasSearchTerm && state.hasAnyFolder;
    if (isSearchNoResult) {
      return [
        SliverToBoxAdapter(
          child: MxAnimatedSwitcher(
            child: KeyedSubtree(
              key: const ValueKey('library_search_no_results'),
              child: LibrarySearchNoResultsSection(onClearSearch: onClearSearch),
            ),
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: MxAnimatedSwitcher(
          child: KeyedSubtree(
            key: const ValueKey('library_empty'),
            child: LibraryEmptyStateSection(
              onCreateFolder: () => _handleCreateFolder(context, ref),
            ),
          ),
        ),
      ),
    ];
  }
  return [
    LibraryFolderSliver(
      folders: state.folders,
      onOpenFolder: (folderId) => _openFolder(context, ref, folderId),
      onOpenActions: (folder) => showFolderActions(
        context: context,
        ref: ref,
        folderId: folder.id,
        folderName: folder.name,
        allowRootDestination: false,
        canImportFlashcards: folder.canImportFlashcards,
      ),
    ),
  ];
}

class _LibrarySectionHeader extends StatelessWidget {
  const _LibrarySectionHeader({
    required this.title,
    required this.subtitle,
    required this.showSubtitle,
  });

  final String title;
  final String subtitle;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MxText(title, role: MxTextRole.sectionTitle),
      if (showSubtitle) ...[
        const MxGap(MxSpace.xxs),
        MxText(subtitle, role: MxTextRole.sectionSubtitle),
      ],
    ],
  );
}

/// Due-today summary card for the loaded Library Overview (Prompt 49B).
///
/// Non-interactive: Library state only knows the aggregate `dueToday` count, so
/// the card surfaces that figure without a subtitle (folder span / estimated
/// minutes are not available here) and without a study-launch affordance (no
/// approved navigation exists from this surface).
class _LibraryDueSummaryCard extends StatelessWidget {
  const _LibraryDueSummaryCard({required this.dueToday});

  final int dueToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Row(
        children: [
          const MxIconTile(
            icon: Icons.bolt_outlined,
            tone: MxIconTileTone.primary,
          ),
          const MxGap(MxSpace.md),
          Expanded(
            child: MxText(
              l10n.libraryDueSummaryTitle(dueToday),
              role: MxTextRole.tileTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

void _openFolder(BuildContext context, WidgetRef ref, String folderId) {
  ref.read(folderDetailQueryProvider(folderId));
  context.pushFolderDetail(folderId);
}

Future<void> _handleCreateFolder(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final name = await MxNameDialog.show(
    context: context,
    title: l10n.libraryCreateFolderDialogTitle,
    label: l10n.foldersFolderNameLabel,
    hintText: l10n.foldersFolderNameHint,
    confirmLabel: l10n.commonCreate,
  );
  if (!context.mounted) return;
  if (name == null) return;

  final success = await ref
      .read(libraryOverviewActionControllerProvider.notifier)
      .createFolder(name);
  if (!context.mounted) {
    return;
  }

  if (success) {
    MxSnackbar.success(context, l10n.libraryFolderCreatedMessage);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_animated_switcher.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../../../shared/widgets/mx_text.dart';
import '../actions/folder_quick_actions.dart';
import '../models/library_folder.dart';
import '../widgets/library_empty_state_section.dart';
import '../widgets/library_folder_list.dart';
import '../widgets/library_hero_section.dart';
import '../viewmodels/folder_detail_viewmodel.dart';
import '../viewmodels/library_overview_viewmodel.dart';

Widget buildLibraryOverviewFab(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);

  return MxFab(
    icon: Icons.add,
    tooltip: l10n.libraryCreateFolderTooltip,
    onPressed: () => _handleCreateFolder(context, ref),
  );
}

class LibraryOverviewView extends ConsumerWidget {
  const LibraryOverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sortOptions = buildContentSortOptions(l10n);
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
          MxSnackbar.error(context, folderActionErrorMessage(failure));
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
          dataBuilder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: LibraryHeroSection(state: state)),
                const MxSliverGap(MxSpace.xl),
                SliverToBoxAdapter(
                  child: MxSearchSortToolbar<ContentSortMode>(
                    searchHintText: l10n.commonSearch,
                    onSearchChanged: toolbarNotifier.setSearchTerm,
                    onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                    sortOptions: sortOptions,
                    selectedSort: toolbarState.sortMode,
                    sortLabel: l10n.commonSort,
                    onSortSelected: toolbarNotifier.setSortMode,
                  ),
                ),
                const MxSliverGap(MxSpace.xl),
                SliverToBoxAdapter(
                  child: _LibrarySectionHeader(
                    title: l10n.libraryFoldersSectionTitle,
                    subtitle: StringUtils.isBlank(toolbarState.searchTerm)
                        ? l10n.libraryManageFoldersSubtitle
                        : l10n.librarySearchResultsSubtitle,
                  ),
                ),
                const MxSliverGap(MxSpace.md),
                ..._buildFolderListSlivers(context, ref, state),
              ],
            );
          },
        ),
      ),
    );
  }
}

List<Widget> _buildFolderListSlivers(
  BuildContext context,
  WidgetRef ref,
  LibraryOverviewState state,
) {
  if (state.isEmpty) {
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
      ),
      onStartStudy: (folderId) =>
          context.goStudyEntry(entryType: 'folder', entryRefId: folderId),
    ),
  ];
}

class _LibrarySectionHeader extends StatelessWidget {
  const _LibrarySectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(title, role: MxTextRole.sectionTitle),
        const MxGap(MxSpace.xxs),
        MxText(subtitle, role: MxTextRole.sectionSubtitle),
      ],
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
  if (!context.mounted || name == null) {
    return;
  }

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

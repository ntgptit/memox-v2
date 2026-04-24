import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
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
            return ListView(
              children: [
                LibraryHeroSection(state: state),
                const MxGap(MxSpace.xl),
                MxSearchSortToolbar<ContentSortMode>(
                  searchHintText: l10n.commonSearch,
                  onSearchChanged: toolbarNotifier.setSearchTerm,
                  onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                  sortOptions: sortOptions,
                  selectedSort: toolbarState.sortMode,
                  sortLabel: l10n.commonSort,
                  onSortSelected: toolbarNotifier.setSortMode,
                ),
                const MxGap(MxSpace.xl),
                MxSection(
                  title: l10n.libraryFoldersSectionTitle,
                  subtitle: toolbarState.searchTerm.trim().isEmpty
                      ? l10n.libraryManageFoldersSubtitle
                      : l10n.librarySearchResultsSubtitle,
                  child: state.isEmpty
                      ? LibraryEmptyStateSection(
                          onCreateFolder: () =>
                              _handleCreateFolder(context, ref),
                        )
                      : LibraryFolderList(
                          folders: state.folders,
                          onOpenFolder: (folderId) =>
                              _openFolder(context, ref, folderId),
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

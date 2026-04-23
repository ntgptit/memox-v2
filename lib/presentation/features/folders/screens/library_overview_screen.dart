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
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/options/content_sort_options.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_search_sort_toolbar.dart';
import '../models/library_folder.dart';
import '../viewmodels/folder_detail_viewmodel.dart';
import '../viewmodels/library_overview_viewmodel.dart';

Widget buildLibraryOverviewFab(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);

  return MxFab(
    icon: Icons.create_new_folder_outlined,
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
      body: SafeArea(
        child: MxContentShell(
          width: MxContentWidth.wide,
          child: MxRetainedAsyncState<LibraryOverviewState>(
            data: queryState.value,
            isLoading: queryState.isLoading,
            error: queryState.hasError ? queryState.error : null,
            stackTrace: queryState.hasError ? queryState.stackTrace : null,
            dataBuilder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.xxxl,
                ),
                children: [
                  _LibraryHero(state: state),
                  const MxGap(MxFeatureSpacing.xl),
                  MxSearchSortToolbar<ContentSortMode>(
                    searchHintText: l10n.commonSearch,
                    onSearchChanged: toolbarNotifier.setSearchTerm,
                    onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                    sortOptions: sortOptions,
                    selectedSort: toolbarState.sortMode,
                    sortLabel: l10n.commonSort,
                    onSortSelected: toolbarNotifier.setSortMode,
                  ),
                  const MxGap(MxFeatureSpacing.xl),
                  MxSection(
                    title: l10n.libraryFoldersSectionTitle,
                    subtitle: toolbarState.searchTerm.trim().isEmpty
                        ? l10n.libraryManageFoldersSubtitle
                        : l10n.librarySearchResultsSubtitle,
                    child: state.isEmpty
                        ? _EmptyLibrary(
                            onCreateFolder: () =>
                                _handleCreateFolder(context, ref),
                          )
                        : _FolderList(
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
      ),
    );
  }
}

class _LibraryHero extends StatelessWidget {
  const _LibraryHero({required this.state});

  final LibraryOverviewState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(MxFeatureSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: MxFeatureRadii.heroPanel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.greeting.salutation}, ${state.greeting.userName}',
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const MxGap(MxFeatureSpacing.xs),
          Text(
            l10n.libraryTitle,
            style: textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
          ),
          const MxGap(MxFeatureSpacing.md),
          Text(
            l10n.libraryHeroDueToday(state.dueToday),
            style: textTheme.titleMedium?.copyWith(color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

class _FolderList extends StatelessWidget {
  const _FolderList({required this.folders, required this.onOpenFolder});

  final List<LibraryFolder> folders;
  final ValueChanged<String> onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < folders.length; index++) ...[
          MxFolderTile(
            name: folders[index].name,
            icon: folders[index].icon,
            caption: AppLocalizations.of(context).libraryFolderStats(
              folders[index].deckCount,
              folders[index].itemCount,
            ),
            masteryPercent: folders[index].masteryPercent,
            onTap: () => onOpenFolder(folders[index].id),
          ),
          if (index < folders.length - 1) const MxDivider(),
        ],
      ],
    );
  }
}

void _openFolder(BuildContext context, WidgetRef ref, String folderId) {
  ref.read(folderDetailQueryProvider(folderId));
  context.pushFolderDetail(folderId);
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onCreateFolder});

  final VoidCallback onCreateFolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.folder_open_outlined,
      title: l10n.libraryEmptyTitle,
      message: l10n.libraryEmptyMessage,
      actionLabel: l10n.libraryCreateFolderTooltip,
      actionLeadingIcon: Icons.add,
      onAction: onCreateFolder,
    );
  }
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

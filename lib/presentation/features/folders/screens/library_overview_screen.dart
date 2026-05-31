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
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_text.dart';
import '../actions/folder_quick_actions.dart';
import '../models/library_folder.dart';
import '../viewmodels/folder_detail_viewmodel.dart';
import '../viewmodels/library_overview_viewmodel.dart';
import '../widgets/library_app_bar.dart';
import '../widgets/library_empty_state_section.dart';
import '../widgets/library_folder_list.dart';

Widget buildLibraryOverviewFab(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);

  // DS Library: compact icon-only FAB sitting above the bottom nav. The wide
  // "Create folder" pill belonged to the previous dashboard pattern.
  return MxFab(
    icon: Icons.add,
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
  bool _searchOpen = false;

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
    final isSearchVisible =
        _searchOpen || StringUtils.isNotBlank(toolbarState.searchTerm);

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
          dataBuilder: (context, state) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: LibraryAppBar(
                  title: l10n.libraryTitle,
                  isSearchOpen: isSearchVisible,
                  onToggleSearch: () =>
                      setState(() => _searchOpen = !_searchOpen),
                  searchTerm: toolbarState.searchTerm,
                  onSearchChanged: toolbarNotifier.setSearchTerm,
                  onSearchClear: () => toolbarNotifier.setSearchTerm(''),
                  chips: [
                    LibraryFilterChip(
                      label: l10n.libraryFilterAll,
                      selected: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              if (StringUtils.isNotBlank(toolbarState.searchTerm)) ...[
                const MxSliverGap(MxSpace.md),
                SliverToBoxAdapter(
                  child: _LibrarySectionHeader(
                    title: l10n.libraryFoldersSectionTitle,
                    subtitle: l10n.librarySearchResultsSubtitle,
                    showSubtitle: true,
                  ),
                ),
              ],
              const MxSliverGap(MxSpace.md),
              ..._buildFolderListSlivers(context, ref, state),
            ],
          ),
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

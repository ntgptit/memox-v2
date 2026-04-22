import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../../core/theme/mx_tokens.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/widgets/mx_avatar.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../models/library_folder.dart';
import '../viewmodels/library_overview_viewmodel.dart';

/// FAB builder used by the root `AppShell` so the "create folder" action
/// stays owned by this feature while the scaffold lives in the shell.
///
/// Takes [ref] so the handler can hit the feature viewmodel without reaching
/// for a global locator — the shell already has a `WidgetRef` handy.
Widget buildLibraryOverviewFab(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  return MxFab(
    icon: Icons.add,
    tooltip: l10n.libraryCreateFolderTooltip,
    onPressed: () =>
        ref.read(libraryOverviewViewModelProvider.notifier).createFolder(),
  );
}

/// Library overview body.
///
/// Deliberately quiet: one primary action (the `+` FAB owned by the shell),
/// one accent color (primary), and a single vertical list. No cards, no
/// shadows, no heroes. Follows the "calm technology" design contract.
///
/// Renders the body only — the surrounding [MxAdaptiveScaffold] + bottom nav
/// belong to the root `AppShell` so all top-level tabs share one shell.
///
/// State (`greeting` + `folders`) flows from [libraryOverviewViewModelProvider].
class LibraryOverviewView extends ConsumerWidget {
  const LibraryOverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryOverviewViewModelProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _TopBar()),
        SliverToBoxAdapter(child: _Greeting(greeting: state.greeting)),
        if (state.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyLibrary(),
          ),
        if (!state.isEmpty)
          SliverToBoxAdapter(
            child: _FoldersSection(folders: state.folders),
          ),
        const SliverToBoxAdapter(child: MxGap(MxSpace.xxxl)),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MxSpace.lg,
        MxSpace.sm,
        MxSpace.lg,
        MxSpace.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                l10n.appName,
                style: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
              ),
              const Spacer(),
              MxIconButton(
                icon: Icons.search_outlined,
                tooltip: l10n.commonSearch,
                onPressed: () {},
              ),
              const MxGap.h(MxSpace.xs),
              const MxAvatar(initials: 'AL', size: MxAvatarSize.sm),
            ],
          ),
          const MxGap(MxSpace.sm),
          const MxDivider(),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.greeting});

  final LibraryOverviewGreeting greeting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final custom = context.mxColors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MxSpace.lg,
        MxSpace.lg,
        MxSpace.lg,
        MxSpace.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${greeting.salutation}, ${greeting.userName}',
            style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const MxGap(MxSpace.xs),
          Text.rich(
            TextSpan(
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              children: [
                TextSpan(text: l10n.libraryDueTodayPrefix),
                TextSpan(
                  text: greeting.dueToday.toString(),
                  style: textTheme.titleMedium
                      ?.copyWith(color: custom.success),
                ),
                TextSpan(text: l10n.libraryDueTodaySuffix),
              ],
            ),
          ),
          const MxGap(MxSpace.sm),
          InkWell(
            onTap: () {},
            borderRadius: MxRadii.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: MxSpace.xxs),
              child: Text(
                l10n.libraryStudyNow,
                style: textTheme.labelLarge?.copyWith(color: scheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoldersSection extends StatelessWidget {
  const _FoldersSection({required this.folders});

  final List<LibraryFolder> folders;

  static const _accents = <_FolderAccent>[
    _FolderAccent.primary,
    _FolderAccent.tertiary,
    _FolderAccent.info,
    _FolderAccent.success,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MxSpace.lg,
            MxSpace.none,
            MxSpace.lg,
            MxSpace.sm,
          ),
          child: Text(
            l10n.libraryFoldersSectionTitle,
            style: textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        for (var i = 0; i < folders.length; i++) ...[
          _FolderRow(
            folder: folders[i],
            accent: _accents[i % _accents.length],
          ),
          if (i < folders.length - 1)
            const Padding(
              padding: EdgeInsets.only(
                // guard:raw-size-reviewed divider aligns with the text column:
                // lg(24) horizontal pad + xxxl(48) tile + md(12) gap = 84.
                left: 84,
                right: MxSpace.lg,
              ),
              child: MxDivider(),
            ),
        ],
      ],
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({required this.folder, required this.accent});

  final LibraryFolder folder;
  final _FolderAccent accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final custom = context.mxColors;
    final (bg, fg) = _resolveColors(scheme, custom);
    final l10n = AppLocalizations.of(context);

    return MxFolderTile(
      name: folder.name,
      icon: folder.icon,
      caption: l10n.libraryFolderStats(folder.deckCount, folder.itemCount),
      masteryPercent: folder.masteryPercent,
      tileColor: bg,
      iconColor: fg,
      onTap: () => context.pushFolderDetail(folder.id),
    );
  }

  (Color bg, Color fg) _resolveColors(
    ColorScheme scheme,
    MxColorsExtension custom,
  ) {
    return switch (accent) {
      _FolderAccent.primary => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer
        ),
      _FolderAccent.tertiary => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer
        ),
      _FolderAccent.info => (custom.infoContainer, custom.onInfoContainer),
      _FolderAccent.success => (
          custom.successContainer,
          custom.onSuccessContainer
        ),
    };
  }
}

enum _FolderAccent { primary, tertiary, info, success }

class _EmptyLibrary extends ConsumerWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.folder_open_outlined,
      title: l10n.libraryEmptyTitle,
      message: l10n.libraryEmptyMessage,
      actionLabel: l10n.libraryCreateFolderTooltip,
      actionLeadingIcon: Icons.add,
      onAction: () =>
          ref.read(libraryOverviewViewModelProvider.notifier).createFolder(),
    );
  }
}

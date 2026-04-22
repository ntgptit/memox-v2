import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../../core/theme/mx_tokens.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_chip.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_fab.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

enum _FolderMenuAction { edit, reorder, delete }

/// Folder-detail leaf screen.
///
/// Renders either a quiet subfolder list or a calm deck list depending on
/// the viewmodel mode. The demo toggle at the top is scaffolding so both
/// states can be seen in one implementation; in production the mode is
/// dictated by the folder entity.
class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({required this.folderId, super.key});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(folderDetailViewModelProvider(folderId));
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      body: SafeArea(
        child: MxContentShell(
          width: MxContentWidth.wide,
          child: ListView(
            padding: const EdgeInsets.only(bottom: MxSpace.xxxxl),
            children: [
              const MxGap(MxSpace.sm),
              _Header(folderId: folderId),
              const MxGap(MxSpace.md),
              _StatusIndicator(state: state),
              const MxGap(MxSpace.lg),
              _ModeToggle(folderId: folderId, mode: state.mode),
              const MxGap(MxSpace.lg),
              AnimatedSwitcher(
                duration: MxDurations.md,
                switchInCurve: MxCurves.standardDecelerate,
                switchOutCurve: MxCurves.standardAccelerate,
                transitionBuilder: _fadeSlide,
                child: state.isSubfolderMode
                    ? _SubfolderList(
                        key: const ValueKey('subfolders'),
                        items: state.subfolders,
                      )
                    : _DeckList(
                        key: const ValueKey('decks'),
                        folderId: folderId,
                        items: state.decks,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: MxFab(
        icon: Icons.add,
        tooltip: state.isSubfolderMode
            ? l10n.foldersNewSubfolderTooltip
            : l10n.foldersNewDeckTooltip,
        onPressed: () =>
            _handleFabTap(context, ref, folderId, state.isSubfolderMode),
      ),
    );
  }

  static Widget _fadeSlide(Widget child, Animation<double> animation) {
    final offset = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: offset, child: child),
    );
  }

  Future<void> _handleFabTap(
    BuildContext context,
    WidgetRef ref,
    String folderId,
    bool isSubfolderMode,
  ) async {
    final notifier = ref.read(folderDetailViewModelProvider(folderId).notifier);
    if (!isSubfolderMode) {
      notifier.createDeck();
      return;
    }
    final name = await _showCreateSubfolderDialog(context);
    if (name == null || name.trim().isEmpty) return;
    notifier.createSubfolder(name);
  }
}

Future<String?> _showCreateSubfolderDialog(BuildContext context) {
  final controller = TextEditingController();
  final l10n = AppLocalizations.of(context);
  return MxDialog.show<String>(
    context: context,
    title: l10n.foldersNewSubfolderTitle,
    icon: Icons.create_new_folder_outlined,
    child: _CreateSubfolderForm(controller: controller),
    actions: [
      MxSecondaryButton(
        label: l10n.commonCancel,
        variant: MxSecondaryVariant.text,
        onPressed: () => Navigator.of(context).pop(),
      ),
      MxPrimaryButton(
        label: l10n.commonCreate,
        onPressed: () => Navigator.of(context).pop(controller.text),
      ),
    ],
  );
}

class _CreateSubfolderForm extends StatelessWidget {
  const _CreateSubfolderForm({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxTextField(
      label: l10n.foldersFolderNameLabel,
      controller: controller,
      autofocus: true,
      hintText: l10n.foldersFolderNameHint,
      textInputAction: TextInputAction.done,
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(folderDetailViewModelProvider(folderId));
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MxIconButton(
              icon: Icons.arrow_back,
              tooltip: l10n.commonBack,
              onPressed: context.popRoute,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: MxSpace.xs),
                child: Text(
                  state.header.name,
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            MxIconButton(
              icon: Icons.more_vert,
              tooltip: l10n.foldersMoreActionsTooltip,
              onPressed: () => _openOverflowMenu(context, ref, folderId),
            ),
          ],
        ),
        const MxGap(MxSpace.xs),
        Padding(
          padding: const EdgeInsets.only(left: MxSpace.xs),
          child: MxBreadcrumbBar(
            items: [
              for (final label in state.header.breadcrumb)
                MxBreadcrumb(
                  label: label,
                  onTap: label == state.header.breadcrumb.last ? null : () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _openOverflowMenu(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await MxBottomSheet.show<_FolderMenuAction>(
    context: context,
    title: l10n.foldersActionsTitle,
    child: _OverflowMenuBody(l10n: l10n),
  );
  if (action == null) return;
  final notifier = ref.read(folderDetailViewModelProvider(folderId).notifier);
  switch (action) {
    case _FolderMenuAction.edit:
      notifier.editFolder();
    case _FolderMenuAction.reorder:
      notifier.reorderChildren();
    case _FolderMenuAction.delete:
      notifier.deleteFolder();
  }
}

class _OverflowMenuBody extends StatelessWidget {
  const _OverflowMenuBody({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OverflowMenuItem(
          icon: Icons.edit_outlined,
          label: l10n.commonEdit,
          action: _FolderMenuAction.edit,
        ),
        _OverflowMenuItem(
          icon: Icons.reorder,
          label: l10n.foldersReorder,
          action: _FolderMenuAction.reorder,
        ),
        _OverflowMenuItem(
          icon: Icons.delete_outline,
          label: l10n.commonDelete,
          action: _FolderMenuAction.delete,
        ),
      ],
    );
  }
}

class _OverflowMenuItem extends StatelessWidget {
  const _OverflowMenuItem({
    required this.icon,
    required this.label,
    required this.action,
  });

  final IconData icon;
  final String label;
  final _FolderMenuAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDestructive = action == _FolderMenuAction.delete;
    final fg = isDestructive ? scheme.error : scheme.onSurface;

    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      borderRadius: MxRadii.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpace.md,
          vertical: MxSpace.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: MxIconSize.md, color: fg),
            const MxGap.h(MxSpace.md),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.state});

  final FolderDetailState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final (IconData icon, String message) = state.isSubfolderMode
        ? (
            Icons.folder_outlined,
            l10n.foldersStatusSubfolders(state.subfolderCount),
          )
        : (
            Icons.style_outlined,
            l10n.foldersStatusDecks(state.deckCount, state.totalCardCount),
          );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: MxRadii.borderMd,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.md,
        vertical: MxSpace.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: MxIconSize.sm, color: scheme.onSurfaceVariant),
          const MxGap.h(MxSpace.sm),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends ConsumerWidget {
  const _ModeToggle({required this.folderId, required this.mode});

  final String folderId;
  final FolderDetailMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: MxSegmentedControl<FolderDetailMode>(
        segments: [
          MxSegment(
            value: FolderDetailMode.subfolders,
            label: l10n.foldersSegmentSubfolders,
            icon: Icons.folder_outlined,
          ),
          MxSegment(
            value: FolderDetailMode.decks,
            label: l10n.foldersSegmentDecks,
            icon: Icons.style_outlined,
          ),
        ],
        selected: {mode},
        onChanged: (set) => ref
            .read(folderDetailViewModelProvider(folderId).notifier)
            .setMode(set.first),
      ),
    );
  }
}

class _SubfolderList extends StatelessWidget {
  const _SubfolderList({super.key, required this.items});

  final List<FolderSubfolderItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          MxFolderTile(
            name: items[i].name,
            icon: items[i].icon,
            caption: items[i].caption,
            onTap: () => context.pushFolderDetail(items[i].id),
          ),
          if (i < items.length - 1) const MxDivider(),
        ],
        const MxGap(MxSpace.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MxSpace.md),
          child: Text(
            l10n.foldersSubfolderDeckHint,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeckList extends ConsumerWidget {
  const _DeckList({super.key, required this.folderId, required this.items});

  final String folderId;
  final List<FolderDeckItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final deck in items) ...[
          _DeckCard(
            deck: deck,
            onTap: () => ref
                .read(folderDetailViewModelProvider(folderId).notifier)
                .openDeck(deck.id),
          ),
          const MxGap(MxSpace.sm),
        ],
      ],
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck, required this.onTap});

  final FolderDeckItem deck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mx = context.mxColors;
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.outlined,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  deck.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: MxIconSize.md,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
          const MxGap(MxSpace.xxs),
          Text(
            l10n.foldersDeckCardProgress(deck.cardCount, deck.dueToday),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const MxGap(MxSpace.md),
          MxLinearProgress(
            value: deck.masteryPercent / 100,
            color: mx.masteryProgress(deck.masteryPercent / 100),
          ),
          if (deck.tags.isNotEmpty) ...[
            const MxGap(MxSpace.md),
            Wrap(
              spacing: MxSpace.xs,
              runSpacing: MxSpace.xs,
              children: [for (final tag in deck.tags) MxChip(label: tag)],
            ),
          ],
        ],
      ),
    );
  }
}

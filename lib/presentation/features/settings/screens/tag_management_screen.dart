import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/di/content/tag_providers.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/widgets/app_async_builder.dart';
import '../../../../domain/value_objects/tag_read_models.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/feedback/mx_tag_failure_text.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_empty_state.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_tappable.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../providers/tag_management_notifier.dart';

enum _TagAction { rename, merge, delete }

class SettingsTagManagementScreen extends ConsumerStatefulWidget {
  const SettingsTagManagementScreen({super.key});

  @override
  ConsumerState<SettingsTagManagementScreen> createState() =>
      _SettingsTagManagementScreenState();
}

class _SettingsTagManagementScreenState
    extends ConsumerState<SettingsTagManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tags = ref.watch(tagListProvider);
    final filter = ref.watch(tagManagementFilterProvider);

    return MxScaffold(
      title: l10n.settingsManageTagsTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: AppAsyncBuilder<List<TagWithCount>>(
          value: tags,
          loading: (_) => const MxLoadingState(),
          error: (_, _, _) => MxEmptyState(
            icon: Icons.error_outline_rounded,
            title: l10n.errorStorage,
          ),
          data: (context, allTags) =>
              _buildBody(context, l10n, allTags, filter),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    List<TagWithCount> allTags,
    TagManagementFilterState filter,
  ) {
    if (allTags.isEmpty) {
      return MxEmptyState(
        icon: Icons.sell_outlined,
        title: l10n.settingsTagsEmptyTitle,
        message: l10n.settingsTagsEmptyMessage,
        actionLabel: l10n.settingsTagsEmptyAction,
        actionLeadingIcon: Icons.menu_book_outlined,
        onAction: () => context.goLibrary(),
      );
    }

    final visible = filterAndSortTags(allTags, filter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxTextField(
          controller: _searchController,
          hintText: l10n.settingsTagsSearchHint,
          prefixIcon: Icons.search_rounded,
          textCapitalization: TextCapitalization.none,
          onChanged: ref.read(tagManagementFilterProvider.notifier).setSearch,
        ),
        const MxGap(AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MxText(
                l10n.settingsTagsCount(allTags.length),
                role: MxTextRole.tileMeta,
              ),
            ),
            _SortButton(
              mode: filter.sortMode,
              onPick: ref.read(tagManagementFilterProvider.notifier).setSort,
            ),
          ],
        ),
        const MxGap(AppSpacing.sm),
        Expanded(
          child: visible.isEmpty
              ? MxEmptyState(
                  icon: Icons.search_off_rounded,
                  title: l10n.settingsTagsSearchEmptyTitle,
                  message: l10n.settingsTagsSearchEmptyMessage,
                )
              : ListView.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const MxGap(AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final tag = visible[index];
                    return _TagRow(
                      tag: tag,
                      onTap: () => _openContextSheet(tag),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openContextSheet(TagWithCount tag) async {
    final l10n = AppLocalizations.of(context);
    final action = await MxBottomSheet.show<_TagAction>(
      context: context,
      title: l10n.tagHashLabel(tag.tag),
      child: MxActionSheetList<_TagAction>(
        items: [
          MxActionSheetItem(
            value: _TagAction.rename,
            label: l10n.settingsTagsActionRename,
            icon: Icons.edit_outlined,
          ),
          MxActionSheetItem(
            value: _TagAction.merge,
            label: l10n.settingsTagsActionMerge,
            icon: Icons.merge_rounded,
          ),
          MxActionSheetItem(
            value: _TagAction.delete,
            label: l10n.settingsTagsActionDelete,
            icon: Icons.delete_outline_rounded,
            tone: MxActionSheetItemTone.destructive,
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == null) return;

    switch (action) {
      case _TagAction.rename:
        await _rename(tag);
      case _TagAction.merge:
        await _merge(tag);
      case _TagAction.delete:
        await _delete(tag);
    }
  }

  Future<void> _rename(TagWithCount tag) async {
    final l10n = AppLocalizations.of(context);
    final newName = await MxNameDialog.show(
      context: context,
      title: l10n.settingsTagsRenameTitle,
      label: l10n.settingsTagsRenameLabel,
      hintText: l10n.settingsTagsRenameHint,
      confirmLabel: l10n.settingsTagsRenameConfirm,
      initialValue: tag.tag,
    );
    if (!mounted) return;
    if (newName == null) return;

    final result = await ref
        .read(renameTagUseCaseProvider)
        .execute(oldName: tag.tag, newName: newName);
    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure == null) {
      MxSnackbar.success(context, l10n.settingsTagsRenamedMessage);
      return;
    }
    if (failure.code == FailureCodes.tagNameConflict) {
      await _confirmAndMerge(source: tag.tag, destination: newName);
      return;
    }
    MxSnackbar.error(context, tagValidationMessage(l10n, failure));
  }

  Future<void> _merge(TagWithCount tag) async {
    final l10n = AppLocalizations.of(context);
    final allTags =
        ref.read(tagListProvider).value ?? const <TagWithCount>[];
    final candidates = allTags.where((other) => other.tag != tag.tag).toList();

    if (candidates.isEmpty) {
      MxSnackbar.warning(context, l10n.settingsTagsMergeSheetEmpty);
      return;
    }

    final destination = await MxBottomSheet.show<String>(
      context: context,
      title: l10n.settingsTagsMergeSheetTitle(l10n.tagHashLabel(tag.tag)),
      child: _MergeTargetSheetBody(candidates: candidates),
    );
    if (!mounted) return;
    if (destination == null) return;

    await _confirmAndMerge(source: tag.tag, destination: destination);
  }

  Future<void> _confirmAndMerge({
    required String source,
    required String destination,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.settingsTagsMergeConfirmTitle,
      message: l10n.settingsTagsMergeConfirmMessage(
        l10n.tagHashLabel(source),
        l10n.tagHashLabel(destination),
      ),
      confirmLabel: l10n.settingsTagsMergeConfirmAction,
    );
    if (!mounted) return;
    if (!confirmed) return;

    final result = await ref
        .read(mergeTagUseCaseProvider)
        .execute(sourceName: source, destinationName: destination);
    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure == null) {
      MxSnackbar.success(context, l10n.settingsTagsMergedMessage);
      return;
    }
    MxSnackbar.error(context, tagValidationMessage(l10n, failure));
  }

  Future<void> _delete(TagWithCount tag) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.settingsTagsDeleteTitle,
      message: l10n.settingsTagsDeleteMessage(
        l10n.tagHashLabel(tag.tag),
        tag.cardCount,
      ),
      confirmLabel: l10n.settingsTagsDeleteConfirm,
      tone: MxConfirmationTone.danger,
    );
    if (!mounted) return;
    if (!confirmed) return;

    final result = await ref.read(deleteTagUseCaseProvider).execute(tag.tag);
    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure == null) {
      MxSnackbar.success(context, l10n.settingsTagsDeletedMessage);
      return;
    }
    MxSnackbar.error(context, tagValidationMessage(l10n, failure));
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tag, required this.onTap});

  final TagWithCount tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxTappable(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: MxText(
                l10n.tagHashLabel(tag.tag),
                role: MxTextRole.tileTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const MxGap(AppSpacing.sm),
            MxText(
              l10n.settingsTagsCardCount(tag.cardCount),
              role: MxTextRole.tileMeta,
            ),
            const MxGap(AppSpacing.sm),
            Icon(
              Icons.more_vert_rounded,
              size: AppIconSizes.md,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.mode, required this.onPick});

  final TagSortMode mode;
  final ValueChanged<TagSortMode> onPick;

  String _label(AppLocalizations l10n, TagSortMode value) => switch (value) {
    TagSortMode.mostCards => l10n.settingsTagsSortMostCards,
    TagSortMode.nameAsc => l10n.settingsTagsSortNameAsc,
    TagSortMode.nameDesc => l10n.settingsTagsSortNameDesc,
  };

  Future<void> _open(BuildContext context, AppLocalizations l10n) async {
    final picked = await MxBottomSheet.show<TagSortMode>(
      context: context,
      title: l10n.settingsTagsSortMostCards,
      child: MxActionSheetList<TagSortMode>(
        selectedValue: mode,
        items: [
          for (final value in TagSortMode.values)
            MxActionSheetItem(value: value, label: _label(l10n, value)),
        ],
      ),
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxTappable(
      shape: const StadiumBorder(),
      onTap: () => _open(context, l10n),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxText(_label(l10n, mode), role: MxTextRole.tileTrailing),
            const MxGap(AppSpacing.xxs),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: AppIconSizes.md,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeTargetSheetBody extends StatefulWidget {
  const _MergeTargetSheetBody({required this.candidates});

  final List<TagWithCount> candidates;

  @override
  State<_MergeTargetSheetBody> createState() => _MergeTargetSheetBodyState();
}

class _MergeTargetSheetBodyState extends State<_MergeTargetSheetBody> {
  final TextEditingController _controller = TextEditingController();
  String _term = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _term.isEmpty
        ? widget.candidates
        : widget.candidates
              .where((tag) => StringUtils.containsNormalized(tag.tag, _term))
              .toList();

    final Widget results = filtered.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: MxText(
              l10n.settingsTagsSearchEmptyMessage,
              role: MxTextRole.tileMeta,
            ),
          )
        : MxActionSheetList<String>(
            items: [
              for (final tag in filtered)
                MxActionSheetItem(
                  value: tag.tag,
                  label: l10n.tagHashLabel(tag.tag),
                  subtitle: l10n.settingsTagsCardCount(tag.cardCount),
                ),
            ],
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxTextField(
          controller: _controller,
          hintText: l10n.settingsTagsSearchHint,
          prefixIcon: Icons.search_rounded,
          textCapitalization: TextCapitalization.none,
          onChanged: (value) =>
              setState(() => _term = StringUtils.trimmed(value)),
        ),
        const MxGap(AppSpacing.md),
        results,
      ],
    );
  }
}

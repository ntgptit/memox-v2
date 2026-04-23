import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../../../shared/dialogs/mx_name_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../viewmodels/deck_detail_viewmodel.dart';

enum _DeckAction { edit, move, duplicate, export, delete }

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(deckActionControllerProvider(deckId), (
      _,
      next,
    ) {
      final failure = deckActionError(next);
      if (failure != null) {
        MxSnackbar.error(context, deckActionErrorMessage(failure));
      }
    });

    final queryState = ref.watch(deckDetailQueryProvider(deckId));

    return MxScaffold(
      body: SafeArea(
        child: MxContentShell(
          width: MxContentWidth.wide,
          child: MxRetainedAsyncState<DeckDetailState>(
            data: queryState.value,
            isLoading: queryState.isLoading,
            error: queryState.hasError ? queryState.error : null,
            stackTrace: queryState.hasError ? queryState.stackTrace : null,
            skeletonBuilder: (_) => const _DeckDetailSkeleton(),
            onRetry: () => ref.invalidate(deckDetailQueryProvider(deckId)),
            dataBuilder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.lg,
                  MxFeatureSpacing.xxxl,
                ),
                children: [
                  _DeckHeader(
                    state: state,
                    onOpenActions: () => _openDeckActions(context, ref, state),
                    onBack: () => context.popRoute(
                      fallback: () => context.goFolderDetail(state.folderId),
                    ),
                  ),
                  const MxGap(MxFeatureSpacing.xl),
                  MxSection(
                    title: l10n.commonOverview,
                    subtitle: l10n.decksOverviewSubtitle(
                      state.cardCount,
                      state.dueTodayCount,
                      state.masteryPercent,
                    ),
                    child: MxStudySetTile(
                      title: state.name,
                      icon: Icons.style_outlined,
                      metaLine: l10n.decksLastStudiedLabel(
                        _formatLastStudied(context, state.lastStudiedAt),
                      ),
                    ),
                  ),
                  const MxGap(MxFeatureSpacing.xl),
                  MxSection(
                    title: l10n.decksManageContentTitle,
                    subtitle: l10n.decksManageContentSubtitle,
                    child: Wrap(
                      spacing: MxFeatureSpacing.sm,
                      runSpacing: MxFeatureSpacing.sm,
                      children: [
                        MxPrimaryButton(
                          label: l10n.flashcardsOpenListAction,
                          leadingIcon: Icons.view_list_outlined,
                          onPressed: () => context.pushFlashcardList(state.id),
                        ),
                        MxSecondaryButton(
                          label: l10n.flashcardsAddAction,
                          leadingIcon: Icons.add,
                          variant: MxSecondaryVariant.outlined,
                          onPressed: () =>
                              context.pushFlashcardCreate(state.id),
                        ),
                        MxSecondaryButton(
                          label: l10n.commonImport,
                          leadingIcon: Icons.file_upload_outlined,
                          variant: MxSecondaryVariant.outlined,
                          onPressed: () => context.pushDeckImport(state.id),
                        ),
                      ],
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

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.state,
    required this.onOpenActions,
    required this.onBack,
  });

  final DeckDetailState state;
  final VoidCallback onOpenActions;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
              onPressed: onBack,
            ),
            const MxGap.h(MxFeatureSpacing.sm),
            Expanded(
              child: Text(
                state.name,
                style: textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            MxIconButton(
              icon: Icons.more_horiz_rounded,
              tooltip: l10n.decksMoreActionsTooltip,
              onPressed: onOpenActions,
            ),
          ],
        ),
        const MxGap(MxFeatureSpacing.sm),
        MxBreadcrumbBar(
          items: [
            for (var index = 0; index < state.breadcrumb.length; index++)
              MxBreadcrumb(
                label: state.breadcrumb[index],
                onTap: index == state.breadcrumb.length - 1 ? null : () {},
              ),
          ],
        ),
      ],
    );
  }
}

Future<void> _openDeckActions(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await MxBottomSheet.show<_DeckAction>(
    context: context,
    title: l10n.decksActionsTitle,
    child: MxActionSheetList<_DeckAction>(
      items: [
        MxActionSheetItem(
          value: _DeckAction.edit,
          label: l10n.commonEdit,
          icon: Icons.edit_outlined,
        ),
        MxActionSheetItem(
          value: _DeckAction.move,
          label: l10n.commonMove,
          icon: Icons.drive_file_move_outline,
        ),
        MxActionSheetItem(
          value: _DeckAction.duplicate,
          label: l10n.decksDuplicateAction,
          icon: Icons.copy_outlined,
        ),
        MxActionSheetItem(
          value: _DeckAction.export,
          label: l10n.decksExportCsvAction,
          icon: Icons.file_download_outlined,
        ),
        MxActionSheetItem(
          value: _DeckAction.delete,
          label: l10n.commonDelete,
          icon: Icons.delete_outline,
          tone: MxActionSheetItemTone.destructive,
        ),
      ],
    ),
  );
  if (!context.mounted || action == null) {
    return;
  }

  switch (action) {
    case _DeckAction.edit:
      await _renameDeck(context, ref, state);
    case _DeckAction.move:
      await _moveDeck(context, ref, state);
    case _DeckAction.duplicate:
      await _duplicateDeck(context, ref, state);
    case _DeckAction.export:
      await _exportDeck(context, ref, state);
    case _DeckAction.delete:
      await _deleteDeck(context, ref, state);
  }
}

Future<void> _renameDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await MxNameDialog.show(
    context: context,
    title: l10n.decksRenameTitle,
    label: l10n.decksNameLabel,
    hintText: l10n.decksNameHint,
    initialValue: state.name,
    confirmLabel: l10n.commonSave,
  );
  if (!context.mounted || name == null) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(state.id).notifier)
      .updateDeck(name);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksUpdatedMessage);
}

Future<void> _moveDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(deckMovePickerProvider(state.id).future);
  if (!context.mounted) {
    return;
  }

  final targetId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.decksMoveTitle,
    destinations: [
      for (final target in targets)
        MxDestinationOption<String>(
          value: target.id,
          title: target.name,
          subtitle: target.breadcrumb.join(' / '),
          icon: Icons.folder_open_outlined,
          searchTerms: target.breadcrumb,
        ),
    ],
    emptyLabel: l10n.commonNoValidDestinationFound,
  );
  if (!context.mounted || targetId == null) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(state.id).notifier)
      .moveDeck(targetId);
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksMovedMessage);
}

Future<void> _duplicateDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final targets = await ref.read(deckMovePickerProvider(state.id).future);
  if (!context.mounted) {
    return;
  }

  final targetId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.decksDuplicateTitle,
    destinations: [
      MxDestinationOption<String>(
        value: state.folderId,
        title: l10n.decksCurrentFolderTitle,
        subtitle: state.breadcrumb
            .take(state.breadcrumb.length - 1)
            .join(' / '),
        icon: Icons.folder_special_outlined,
      ),
      for (final target in targets)
        if (target.id != state.folderId)
          MxDestinationOption<String>(
            value: target.id,
            title: target.name,
            subtitle: target.breadcrumb.join(' / '),
            icon: Icons.folder_open_outlined,
            searchTerms: target.breadcrumb,
          ),
    ],
    emptyLabel: l10n.commonNoValidDestinationFound,
  );
  if (!context.mounted || targetId == null) {
    return;
  }

  final duplicatedId = await ref
      .read(deckActionControllerProvider(state.id).notifier)
      .duplicateDeck(targetId);
  if (!context.mounted || duplicatedId == null) {
    return;
  }
  MxSnackbar.success(context, l10n.decksDuplicatedMessage);
  context.pushDeckDetail(duplicatedId);
}

Future<void> _exportDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final export = await ref
      .read(deckActionControllerProvider(state.id).notifier)
      .exportDeck();
  if (!context.mounted || export == null) {
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

Future<void> _deleteDeck(
  BuildContext context,
  WidgetRef ref,
  DeckDetailState state,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await MxConfirmationDialog.show(
    context: context,
    title: l10n.decksDeleteTitle,
    message: l10n.decksDeleteMessage,
    confirmLabel: l10n.commonDelete,
    tone: MxConfirmationTone.danger,
    icon: Icons.delete_outline,
  );
  if (!context.mounted || !confirmed) {
    return;
  }

  final success = await ref
      .read(deckActionControllerProvider(state.id).notifier)
      .deleteDeck();
  if (!context.mounted || !success) {
    return;
  }
  MxSnackbar.success(context, l10n.decksDeletedMessage);
  await context.popRoute(
    fallback: () => context.goFolderDetail(state.folderId),
  );
}

String _formatLastStudied(BuildContext context, int? value) {
  final l10n = AppLocalizations.of(context);
  if (value == null) {
    return l10n.commonNever;
  }

  final date = DateTime.fromMillisecondsSinceEpoch(
    value,
    isUtc: true,
  ).toLocal();
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

class _DeckDetailSkeleton extends StatelessWidget {
  const _DeckDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('deck_detail_skeleton'),
      padding: const EdgeInsets.fromLTRB(
        MxFeatureSpacing.lg,
        MxFeatureSpacing.lg,
        MxFeatureSpacing.lg,
        MxFeatureSpacing.xxxl,
      ),
      children: const [
        _DeckHeaderSkeleton(),
        MxGap(MxFeatureSpacing.xl),
        _DeckSectionSkeleton(
          titleWidth: 140,
          subtitleWidth: 240,
          body: _StudySetTileSkeleton(),
        ),
        MxGap(MxFeatureSpacing.xl),
        _DeckSectionSkeleton(
          titleWidth: 180,
          subtitleWidth: 260,
          body: _DeckActionSkeleton(),
        ),
      ],
    );
  }
}

class _DeckHeaderSkeleton extends StatelessWidget {
  const _DeckHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
            MxGap.h(MxFeatureSpacing.sm),
            Expanded(child: MxSkeleton(height: 28, width: 220)),
            MxGap.h(MxFeatureSpacing.sm),
            MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
          ],
        ),
        MxGap(MxFeatureSpacing.sm),
        MxSkeleton(height: 14, width: 180),
      ],
    );
  }
}

class _DeckSectionSkeleton extends StatelessWidget {
  const _DeckSectionSkeleton({
    required this.titleWidth,
    required this.subtitleWidth,
    required this.body,
  });

  final double titleWidth;
  final double subtitleWidth;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxSkeleton(height: 18, width: titleWidth),
        const MxGap(MxFeatureSpacing.xs),
        MxSkeleton(height: 14, width: subtitleWidth),
        const MxGap(MxFeatureSpacing.md),
        body,
      ],
    );
  }
}

class _StudySetTileSkeleton extends StatelessWidget {
  const _StudySetTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MxFeatureSpacing.lg,
        vertical: MxFeatureSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
          MxGap.h(MxFeatureSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(height: 18, width: 180),
                MxGap(MxFeatureSpacing.xs),
                MxSkeleton(height: 14, width: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckActionSkeleton extends StatelessWidget {
  const _DeckActionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: MxFeatureSpacing.sm,
      runSpacing: MxFeatureSpacing.sm,
      children: [
        MxSkeleton(height: 40, width: 132, borderRadius: MxFeatureRadii.full),
        MxSkeleton(height: 40, width: 136, borderRadius: MxFeatureRadii.full),
        MxSkeleton(height: 40, width: 128, borderRadius: MxFeatureRadii.full),
      ],
    );
  }
}

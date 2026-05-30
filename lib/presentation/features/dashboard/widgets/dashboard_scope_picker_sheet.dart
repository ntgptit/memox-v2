import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

/// Study scope picked from the "Start new learning" sheet. Tag scope is
/// intentionally excluded in V1 (see `docs/wireframes/25-shared-bottom-sheets.md`
/// §scope-picker note).
enum _StudyScopeKind { today, deck, folder }

/// Opens the "Start new learning" scope picker. Step one chooses a scope kind;
/// Deck/Folder then open a searchable picker. The chosen scope routes through
/// the Study Entry Gate.
Future<void> showDashboardScopePicker(
  BuildContext context,
  WidgetRef ref, {
  required int reviewCount,
}) async {
  final l10n = AppLocalizations.of(context);
  final kind = await MxBottomSheet.show<_StudyScopeKind>(
    context: context,
    title: l10n.dashboardScopePickerTitle,
    child: MxActionSheetList<_StudyScopeKind>(
      items: [
        MxActionSheetItem(
          value: _StudyScopeKind.today,
          label: l10n.dashboardScopeToday,
          subtitle: l10n.dashboardScopeTodaySubtitle(reviewCount),
          icon: Icons.today_outlined,
        ),
        MxActionSheetItem(
          value: _StudyScopeKind.deck,
          label: l10n.dashboardScopeDeck,
          subtitle: l10n.dashboardScopeDeckSubtitle,
          icon: Icons.menu_book_outlined,
        ),
        MxActionSheetItem(
          value: _StudyScopeKind.folder,
          label: l10n.dashboardScopeFolder,
          subtitle: l10n.dashboardScopeFolderSubtitle,
          icon: Icons.folder_outlined,
        ),
      ],
    ),
  );

  if (!context.mounted) return;
  if (kind == null) return;

  switch (kind) {
    case _StudyScopeKind.today:
      context.goStudyToday();
    case _StudyScopeKind.deck:
      await _pickDeckScope(context, ref);
    case _StudyScopeKind.folder:
      await _pickFolderScope(context, ref);
  }
}

Future<void> _pickDeckScope(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final decks = await ref.read(dashboardDeckScopeOptionsProvider.future);
  if (!context.mounted) return;
  final deckId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.dashboardScopeDeckPickerTitle,
    searchHintText: l10n.dashboardScopeDeckSearchHint,
    emptyLabel: l10n.dashboardScopeDeckEmpty,
    destinations: [
      for (final deck in decks)
        MxDestinationOption<String>(
          value: deck.id,
          title: deck.name,
          subtitle: deck.breadcrumb.isEmpty ? null : deck.breadcrumb.join(' / '),
          icon: Icons.menu_book_outlined,
        ),
    ],
  );
  if (!context.mounted) return;
  if (deckId == null) return;
  context.goStudyEntry(
    entryType: StudyEntryType.deck.storageValue,
    entryRefId: deckId,
    preserveStack: false,
  );
}

Future<void> _pickFolderScope(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final folders = await ref.read(dashboardFolderScopeOptionsProvider.future);
  if (!context.mounted) return;
  final folderId = await MxDestinationPickerSheet.show<String>(
    context: context,
    title: l10n.dashboardScopeFolderPickerTitle,
    searchHintText: l10n.dashboardScopeFolderSearchHint,
    emptyLabel: l10n.dashboardScopeFolderEmpty,
    destinations: [
      for (final folder in folders)
        MxDestinationOption<String>(
          value: folder.id,
          title: folder.name,
          subtitle: folder.parentBreadcrumb.isEmpty
              ? null
              : folder.parentBreadcrumb.join(' / '),
          icon: Icons.folder_outlined,
        ),
    ],
  );
  if (!context.mounted) return;
  if (folderId == null) return;
  context.goStudyEntry(
    entryType: StudyEntryType.folder.storageValue,
    entryRefId: folderId,
    preserveStack: false,
  );
}

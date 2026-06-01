import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/bottom_sheets/study_scope_picker_sheet.dart';
import '../../../shared/dialogs/mx_destination_picker_sheet.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

/// Dashboard-flavored thin wrapper over the shared
/// [showStudyScopePicker]. Kept for call-site discoverability and so future
/// Dashboard-only decoration (e.g. greeting copy) can attach here without
/// touching Study Result.
Future<void> showDashboardScopePicker(
  BuildContext context,
  WidgetRef ref, {
  int? reviewCount,
}) => showStudyScopePicker(
  context,
  reviewCount: reviewCount,
  loadDeckDestinations: () async {
    final decks = await ref.read(dashboardDeckScopeOptionsProvider.future);
    return [
      for (final deck in decks)
        MxDestinationOption<String>(
          value: deck.id,
          title: deck.name,
          subtitle: deck.breadcrumb.isEmpty
              ? null
              : deck.breadcrumb.join(' / '),
          icon: Icons.menu_book_outlined,
        ),
    ];
  },
  loadFolderDestinations: () async {
    final folders = await ref.read(dashboardFolderScopeOptionsProvider.future);
    return [
      for (final folder in folders)
        MxDestinationOption<String>(
          value: folder.id,
          title: folder.name,
          subtitle: folder.parentBreadcrumb.isEmpty
              ? null
              : folder.parentBreadcrumb.join(' / '),
          icon: Icons.folder_outlined,
        ),
    ];
  },
);

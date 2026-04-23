import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../domain/enums/content_sort_mode.dart';
import '../widgets/mx_search_sort_toolbar.dart';

List<MxSortOption<ContentSortMode>> buildContentSortOptions(
  AppLocalizations l10n,
) {
  return <MxSortOption<ContentSortMode>>[
    MxSortOption(
      value: ContentSortMode.manual,
      label: l10n.sortManual,
      icon: Icons.reorder_rounded,
    ),
    MxSortOption(
      value: ContentSortMode.name,
      label: l10n.sortName,
      icon: Icons.sort_by_alpha_rounded,
    ),
    MxSortOption(
      value: ContentSortMode.newest,
      label: l10n.sortNewest,
      icon: Icons.schedule_rounded,
    ),
    MxSortOption(
      value: ContentSortMode.lastStudied,
      label: l10n.sortLastStudied,
      icon: Icons.history_rounded,
    ),
  ];
}

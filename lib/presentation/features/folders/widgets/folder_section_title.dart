import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

/// Compact "{n} DECKS" / "{n} SUBFOLDERS" overline above the search/sort
/// toolbar, matching the mock section header. Names the active content mode for
/// a locked folder with children.
class FolderSectionTitle extends StatelessWidget {
  const FolderSectionTitle({required this.state, super.key});

  final FolderDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = state.isSubfolderMode
        ? l10n.folderDetailSubfoldersSectionTitle(state.subfolders.length)
        : l10n.folderDetailDecksSectionTitle(state.decks.length);
    return MxText(
      StringUtils.upperCaseToEmpty(title),
      role: MxTextRole.overline,
    );
  }
}

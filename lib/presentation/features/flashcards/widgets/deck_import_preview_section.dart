import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_error_state.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_term_row.dart';

List<Widget> buildDeckImportPreviewSlivers({
  required BuildContext context,
  required FlashcardImportPreparation preparation,
}) {
  final l10n = AppLocalizations.of(context);

  return [
    SliverToBoxAdapter(
      child: MxText(
        preparation.skippedDuplicateCount > 0
            ? l10n.importPreviewSummaryWithSkipped(
                preparation.previewItems.length,
                preparation.issues.length,
                preparation.skippedDuplicateCount,
              )
            : l10n.importPreviewSummary(
                preparation.previewItems.length,
                preparation.issues.length,
              ),
        role: MxTextRole.formHelper,
      ),
    ),
    const MxSliverGap(MxSpace.xl),
    if (preparation.issues.isNotEmpty) ...[
      SliverToBoxAdapter(
        child: _ImportPreviewHeader(
          title: l10n.importValidationIssuesTitle,
          subtitle: l10n.importValidationIssuesSubtitle,
        ),
      ),
      const MxSliverGap(MxSpace.md),
      SliverList.separated(
        key: const ValueKey('deck_import_issue_lazy_items'),
        itemCount: preparation.issues.length,
        itemBuilder: (context, index) {
          final issue = preparation.issues[index];
          return MxTermRow(
            term: l10n.importValidationIssueLine(issue.lineNumber),
            definition: issue.message,
          );
        },
        separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
      ),
      const MxSliverGap(MxSpace.xl),
    ],
    if (preparation.skippedDuplicates.isNotEmpty) ...[
      SliverToBoxAdapter(
        child: _ImportPreviewHeader(
          title: l10n.importSkippedDuplicatesTitle,
          subtitle: l10n.importSkippedDuplicatesSubtitle(
            preparation.skippedDuplicateCount,
          ),
        ),
      ),
      const MxSliverGap(MxSpace.md),
      SliverList.separated(
        key: const ValueKey('deck_import_skipped_duplicate_lazy_items'),
        itemCount: preparation.skippedDuplicates.length,
        itemBuilder: (context, index) {
          final skipped = preparation.skippedDuplicates[index];
          return MxTermRow(
            term: skipped.draft.front,
            definition: skipped.draft.back,
            caption:
                '${skipped.sourceLabel} · ${_skippedDuplicateReason(l10n, skipped.source)}',
          );
        },
        separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
      ),
      const MxSliverGap(MxSpace.xl),
    ],
    SliverToBoxAdapter(
      child: _ImportPreviewHeader(
        title: l10n.importPreviewTitle,
        subtitle: l10n.importPreviewSubtitle(preparation.previewItems.length),
      ),
    ),
    const MxSliverGap(MxSpace.md),
    _buildPreviewItemsSliver(l10n, preparation),
  ];
}

Widget _buildPreviewItemsSliver(
  AppLocalizations l10n,
  FlashcardImportPreparation preparation,
) {
  if (preparation.previewItems.isEmpty) {
    return SliverToBoxAdapter(
      child: MxErrorState(
        title: l10n.importNothingTitle,
        message: l10n.importNothingMessage,
      ),
    );
  }

  return SliverList.separated(
    key: const ValueKey('deck_import_preview_lazy_items'),
    itemCount: preparation.previewItems.length,
    itemBuilder: (context, index) {
      final preview = preparation.previewItems[index];
      return MxTermRow(
        term: preview.draft.front,
        definition: preview.draft.back,
        caption: preview.sourceLabel,
      );
    },
    separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
  );
}

class _ImportPreviewHeader extends StatelessWidget {
  const _ImportPreviewHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(title, role: MxTextRole.sectionTitle),
        const MxGap(MxSpace.xs),
        MxText(subtitle, role: MxTextRole.sectionSubtitle),
      ],
    );
  }
}

String _skippedDuplicateReason(
  AppLocalizations l10n,
  FlashcardImportDuplicateSource source,
) {
  return switch (source) {
    FlashcardImportDuplicateSource.importFile =>
      l10n.importSkippedDuplicateInFile,
    FlashcardImportDuplicateSource.deck => l10n.importSkippedDuplicateInDeck,
  };
}

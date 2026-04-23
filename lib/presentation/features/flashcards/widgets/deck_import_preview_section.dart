import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/states/mx_error_state.dart';
import '../../../shared/widgets/mx_term_row.dart';

class DeckImportPreviewSection extends StatelessWidget {
  const DeckImportPreviewSection({required this.preparation, super.key});

  final FlashcardImportPreparation preparation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preparation.issues.isNotEmpty)
          MxSection(
            title: l10n.importValidationIssuesTitle,
            subtitle: l10n.importValidationIssuesSubtitle,
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < preparation.issues.length;
                  index++
                ) ...[
                  MxTermRow(
                    term: l10n.importValidationIssueLine(
                      preparation.issues[index].lineNumber,
                    ),
                    definition: preparation.issues[index].message,
                  ),
                  if (index < preparation.issues.length - 1)
                    const MxGap(MxSpace.sm),
                ],
              ],
            ),
          ),
        const MxGap(MxSpace.xl),
        MxSection(
          title: l10n.importPreviewTitle,
          subtitle: l10n.importPreviewSubtitle(preparation.previewItems.length),
          child: preparation.previewItems.isEmpty
              ? MxErrorState(
                  title: l10n.importNothingTitle,
                  message: l10n.importNothingMessage,
                )
              : Column(
                  children: [
                    for (
                      var index = 0;
                      index < preparation.previewItems.length;
                      index++
                    ) ...[
                      MxTermRow(
                        term:
                            preparation.previewItems[index].draft.title
                                    ?.trim()
                                    .isNotEmpty ==
                                true
                            ? preparation.previewItems[index].draft.title!
                            : preparation.previewItems[index].draft.front,
                        definition: preparation.previewItems[index].draft.back,
                        caption: preparation.previewItems[index].sourceLabel,
                      ),
                      if (index < preparation.previewItems.length - 1)
                        const MxGap(MxSpace.sm),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

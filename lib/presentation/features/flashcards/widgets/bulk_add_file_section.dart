import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_button_size.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_toggle.dart';
import '../viewmodels/flashcard_import_viewmodel.dart';
import 'bulk_add_widgets.dart';

/// File-source section for Bulk add — outer File tab.
///
/// Lets the user pick a CSV or Excel file (max 10 MB, first sheet only),
/// shows the selected file card with format-specific options, and runs the
/// existing `preparePreview` pipeline to render rows inline.
class BulkAddFileSection extends StatelessWidget {
  const BulkAddFileSection({
    required this.draft,
    required this.actionState,
    required this.enabled,
    required this.onPickFile,
    required this.onClearFile,
    required this.onExcelHasHeaderChanged,
    super.key,
  });

  final FlashcardImportDraftState draft;
  final AsyncValue<void> actionState;
  final bool enabled;
  final VoidCallback onPickFile;
  final VoidCallback onClearFile;
  final ValueChanged<bool> onExcelHasHeaderChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasFile = draft.sourceBytes != null && draft.loadedFileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hasFile
            ? _FileLoadedCard(
                fileName: draft.loadedFileName!,
                sizeBytes: draft.sourceBytes!.lengthInBytes,
                isExcel: draft.format == ImportSourceFormat.excel,
                excelHasHeader: draft.excelHasHeader,
                enabled: enabled,
                onChangeFile: onPickFile,
                onClearFile: onClearFile,
                onExcelHasHeaderChanged: onExcelHasHeaderChanged,
              )
            : _FileEmptyCard(enabled: enabled, onPickFile: onPickFile),
        const MxGap(MxSpace.md),
        Center(
          child: MxText(
            l10n.bulkAddFileFormatHint,
            role: MxTextRole.formHelper,
          ),
        ),
        if (hasFile && draft.preparation != null) ...[
          const MxGap(MxSpace.xl),
          BulkAddPreparedPreview(preparation: draft.preparation!),
        ],
      ],
    );
  }
}

class _FileEmptyCard extends StatelessWidget {
  const _FileEmptyCard({required this.enabled, required this.onPickFile});

  final bool enabled;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return MxCard(
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: AppIconSizes.xl,
            color: scheme.primary,
          ),
          const MxGap(MxSpace.md),
          MxText(
            l10n.bulkAddFileEmptyTitle,
            role: MxTextRole.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const MxGap(MxSpace.xs),
          MxText(
            l10n.bulkAddFileEmptyDescription,
            role: MxTextRole.contentBody,
            textAlign: TextAlign.center,
          ),
          const MxGap(MxSpace.lg),
          Center(
            child: MxPrimaryButton(
              label: l10n.bulkAddFileChooseAction,
              leadingIcon: Icons.upload_file_outlined,
              size: MxButtonSize.compact,
              shape: MxPrimaryButtonShape.pill,
              onPressed: enabled ? onPickFile : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileLoadedCard extends StatelessWidget {
  const _FileLoadedCard({
    required this.fileName,
    required this.sizeBytes,
    required this.isExcel,
    required this.excelHasHeader,
    required this.enabled,
    required this.onChangeFile,
    required this.onClearFile,
    required this.onExcelHasHeaderChanged,
  });

  final String fileName;
  final int sizeBytes;
  final bool isExcel;
  final bool excelHasHeader;
  final bool enabled;
  final VoidCallback onChangeFile;
  final VoidCallback onClearFile;
  final ValueChanged<bool> onExcelHasHeaderChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sizeKb = (sizeBytes / 1024).toStringAsFixed(1);
    return MxCard(
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  isExcel
                      ? Icons.table_chart_outlined
                      : Icons.description_outlined,
                  color: scheme.primary,
                  size: AppIconSizes.lg,
                ),
                const MxGap(MxSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MxText(
                        l10n.bulkAddFileLoadedTitle(fileName),
                        role: MxTextRole.listTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const MxGap(MxSpace.xxs),
                      MxText(
                        l10n.bulkAddFileSizeLabel(sizeKb),
                        role: MxTextRole.formHelper,
                      ),
                    ],
                  ),
                ),
                const MxGap(MxSpace.sm),
                MxSecondaryButton(
                  label: l10n.importChangeFile,
                  size: MxButtonSize.xsmall,
                  onPressed: enabled ? onChangeFile : null,
                ),
                const MxGap(MxSpace.xs),
                MxSecondaryButton(
                  label: l10n.importRemoveFile,
                  size: MxButtonSize.xsmall,
                  tone: MxSecondaryButtonTone.danger,
                  onPressed: enabled ? onClearFile : null,
                ),
              ],
            ),
          ),
          if (isExcel) ...[
            const MxDivider(),
            MxToggle(
              label: l10n.importExcelHasHeaderLabel,
              subtitle: l10n.importExcelHasHeaderDescription,
              value: excelHasHeader,
              onChanged: enabled ? onExcelHasHeaderChanged : (_) {},
            ),
          ],
        ],
      ),
    );
  }
}

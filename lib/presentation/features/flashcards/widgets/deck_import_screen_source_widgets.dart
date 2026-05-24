part of '../screens/deck_import_screen.dart';

class _ImportSourceSection extends StatelessWidget {
  const _ImportSourceSection({
    required this.format,
    required this.enabled,
    required this.onChanged,
  });

  final ImportSourceFormat format;
  final bool enabled;
  final ValueChanged<ImportSourceFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxSection(
      title: l10n.importSourceTitle,
      spacing: MxSpace.sm,
      child: Semantics(
        enabled: enabled,
        child: IgnorePointer(
          ignoring: !enabled,
          child: MxSegmentedControl<ImportSourceFormat>(
            density: MxSegmentedControlDensity.compact,
            segments: [
              MxSegment(
                value: ImportSourceFormat.csv,
                label: l10n.importCsvLabel,
                icon: Icons.table_chart_outlined,
              ),
              MxSegment(
                value: ImportSourceFormat.excel,
                label: l10n.importExcelLabel,
                icon: Icons.grid_on_outlined,
              ),
              MxSegment(
                value: ImportSourceFormat.structuredText,
                label: l10n.importTextFormatLabel,
                icon: Icons.notes_outlined,
              ),
            ],
            selected: <ImportSourceFormat>{format},
            adaptive: true,
            onChanged: (selection) => onChanged(selection.first),
          ),
        ),
      ),
    );
  }
}

class _ImportExcelSource extends StatelessWidget {
  const _ImportExcelSource({
    required this.fileName,
    required this.fileSummary,
    required this.enabled,
    required this.onSelect,
    required this.onChange,
    required this.onRemove,
  });

  final String? fileName;
  final String fileSummary;
  final bool enabled;
  final VoidCallback onSelect;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedFileName = fileName;
    if (selectedFileName == null) {
      return MxPrimaryButton(
        key: const ValueKey('deck_import_select_file_action'),
        label: l10n.importSelectExcelFile,
        leadingIcon: Icons.file_open_outlined,
        size: MxButtonSize.medium,
        fullWidth: true,
        onPressed: enabled ? onSelect : null,
      );
    }

    return _ImportFileRow(
      fileName: selectedFileName,
      summary: fileSummary,
      enabled: enabled,
      onChange: onChange,
      onRemove: onRemove,
    );
  }
}

class _ImportFileRow extends StatelessWidget {
  const _ImportFileRow({
    required this.fileName,
    required this.summary,
    required this.enabled,
    required this.onChange,
    required this.onRemove,
  });

  final String fileName;
  final String summary;
  final bool enabled;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      key: const ValueKey('deck_import_file_row'),
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.md,
        vertical: MxSpace.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: scheme.onSurfaceVariant),
          const MxGap(MxSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MxText(
                  fileName,
                  role: MxTextRole.formLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const MxGap(MxSpace.xs),
                MxText(summary, role: MxTextRole.formHelper),
              ],
            ),
          ),
          const MxGap(MxSpace.sm),
          MxSecondaryButton(
            label: l10n.importChangeFile,
            size: MxButtonSize.small,
            variant: MxSecondaryVariant.text,
            onPressed: enabled ? onChange : null,
          ),
          MxSecondaryButton(
            key: const ValueKey('deck_import_remove_file_action'),
            label: l10n.importRemoveFile,
            size: MxButtonSize.small,
            variant: MxSecondaryVariant.text,
            onPressed: enabled ? onRemove : null,
          ),
        ],
      ),
    );
  }
}

class _ImportTextSource extends StatelessWidget {
  const _ImportTextSource({
    required this.controller,
    required this.format,
    required this.enabled,
    required this.onLoadFile,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ImportSourceFormat format;
  final bool enabled;
  final VoidCallback onLoadFile;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxTextField(
          controller: controller,
          label: _contentLabel(l10n, format),
          hintText: _contentHint(l10n, format),
          enabled: enabled,
          minLines: 5,
          maxLines: 5,
          onChanged: onChanged,
        ),
        const MxGap(MxSpace.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: MxSecondaryButton(
            label: l10n.importLoadFile,
            leadingIcon: Icons.file_open_outlined,
            size: MxButtonSize.small,
            variant: MxSecondaryVariant.text,
            onPressed: enabled ? onLoadFile : null,
          ),
        ),
      ],
    );
  }
}

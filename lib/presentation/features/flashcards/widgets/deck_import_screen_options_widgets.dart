part of '../screens/deck_import_screen.dart';

class _ImportOptionsSection extends StatelessWidget {
  const _ImportOptionsSection({
    required this.format,
    required this.duplicatePolicy,
    required this.excelHasHeader,
    required this.structuredTextSeparator,
    required this.enabled,
    required this.onDuplicateTap,
    required this.onSeparatorTap,
    required this.onHeaderChanged,
  });

  final ImportSourceFormat format;
  final FlashcardImportDuplicatePolicy duplicatePolicy;
  final bool excelHasHeader;
  final ImportStructuredTextSeparator structuredTextSeparator;
  final bool enabled;
  final VoidCallback onDuplicateTap;
  final VoidCallback onSeparatorTap;
  final ValueChanged<bool> onHeaderChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (format == ImportSourceFormat.excel) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MxSpace.lg,
                vertical: MxSpace.sm,
              ),
              child: IgnorePointer(
                ignoring: !enabled,
                child: MxInlineToggle(
                  key: const ValueKey('deck_import_excel_has_header_toggle'),
                  label: l10n.importExcelHasHeaderLabel,
                  subtitle: l10n.importExcelHasHeaderDescription,
                  value: excelHasHeader,
                  onChanged: onHeaderChanged,
                ),
              ),
            ),
            const MxDivider(),
          ],
          if (format == ImportSourceFormat.structuredText) ...[
            _ImportSeparatorRow(
              separator: structuredTextSeparator,
              enabled: enabled,
              onTap: onSeparatorTap,
            ),
            const MxDivider(),
          ],
          _ImportDuplicatePolicyRow(
            policy: duplicatePolicy,
            enabled: enabled,
            onTap: onDuplicateTap,
          ),
        ],
      ),
    );
  }
}

class _ImportDuplicatePolicyRow extends StatelessWidget {
  const _ImportDuplicatePolicyRow({
    required this.policy,
    required this.enabled,
    required this.onTap,
  });

  final FlashcardImportDuplicatePolicy policy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxListTile(
      dense: true,
      title: l10n.importDuplicateHandlingTitle,
      subtitle: _duplicatePolicyLabel(l10n, policy),
      showChevron: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}

class _ImportActionButton extends StatelessWidget {
  const _ImportActionButton({
    required this.previewLabel,
    required this.importLabel,
    required this.canCommit,
    required this.isBusy,
    required this.pendingAction,
    required this.onPreview,
    required this.onCommit,
  });

  final String previewLabel;
  final String? importLabel;
  final bool canCommit;
  final bool isBusy;
  final _ImportPendingAction? pendingAction;
  final VoidCallback onPreview;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    if (canCommit) {
      return MxPrimaryButton(
        key: const ValueKey('deck_import_commit_action'),
        label: importLabel!,
        leadingIcon: Icons.file_upload_outlined,
        fullWidth: true,
        isLoading: pendingAction == _ImportPendingAction.commit,
        onPressed: isBusy ? null : onCommit,
      );
    }

    return MxPrimaryButton(
      key: const ValueKey('deck_import_preview_action'),
      label: previewLabel,
      leadingIcon: Icons.preview_outlined,
      fullWidth: true,
      isLoading: pendingAction == _ImportPendingAction.preview,
      onPressed: isBusy ? null : onPreview,
    );
  }
}

String _duplicatePolicyLabel(
  AppLocalizations l10n,
  FlashcardImportDuplicatePolicy policy,
) => switch (policy) {
    FlashcardImportDuplicatePolicy.skipExactDuplicates =>
      l10n.importDuplicatePolicySkipExact,
  };

List<MxActionSheetItem<_ImportDuplicatePolicyChoice>>
_buildImportDuplicatePolicyActions(AppLocalizations l10n) => [
    MxActionSheetItem<_ImportDuplicatePolicyChoice>(
      value: _ImportDuplicatePolicyChoice.skipExactDuplicates,
      label: l10n.importDuplicatePolicySkipExact,
      subtitle: l10n.importDuplicatePolicySkipExactDescription,
      icon: Icons.filter_alt_outlined,
    ),
  ];

_ImportDuplicatePolicyChoice _duplicatePolicyChoice(
  FlashcardImportDuplicatePolicy policy,
) => switch (policy) {
    FlashcardImportDuplicatePolicy.skipExactDuplicates =>
      _ImportDuplicatePolicyChoice.skipExactDuplicates,
  };

class _ImportSeparatorRow extends StatelessWidget {
  const _ImportSeparatorRow({
    required this.separator,
    required this.enabled,
    required this.onTap,
  });

  final ImportStructuredTextSeparator separator;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxListTile(
      dense: true,
      title: l10n.importSeparatorLabel,
      subtitle: _separatorLabel(l10n, separator),
      showChevron: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}

List<MxActionSheetItem<ImportStructuredTextSeparator>>
_buildImportSeparatorActions(AppLocalizations l10n) => [
    for (final separator in ImportStructuredTextSeparator.values)
      MxActionSheetItem(
        value: separator,
        label: _separatorLabel(l10n, separator),
        subtitle: _separatorDescription(l10n, separator),
        icon: _separatorIcon(separator),
      ),
  ];

String _separatorLabel(
  AppLocalizations l10n,
  ImportStructuredTextSeparator separator,
) => switch (separator) {
    ImportStructuredTextSeparator.auto => l10n.importSeparatorAuto,
    ImportStructuredTextSeparator.tab => l10n.importSeparatorTab,
    ImportStructuredTextSeparator.colon => l10n.importSeparatorColon,
    ImportStructuredTextSeparator.slash => l10n.importSeparatorSlash,
    ImportStructuredTextSeparator.semicolon => l10n.importSeparatorSemicolon,
    ImportStructuredTextSeparator.pipe => l10n.importSeparatorPipe,
  };

String _separatorDescription(
  AppLocalizations l10n,
  ImportStructuredTextSeparator separator,
) => switch (separator) {
    ImportStructuredTextSeparator.auto => l10n.importSeparatorAutoDescription,
    ImportStructuredTextSeparator.tab => l10n.importSeparatorTabDescription,
    ImportStructuredTextSeparator.colon => l10n.importSeparatorColonDescription,
    ImportStructuredTextSeparator.slash => l10n.importSeparatorSlashDescription,
    ImportStructuredTextSeparator.semicolon =>
      l10n.importSeparatorSemicolonDescription,
    ImportStructuredTextSeparator.pipe => l10n.importSeparatorPipeDescription,
  };

IconData _separatorIcon(ImportStructuredTextSeparator separator) => switch (separator) {
    ImportStructuredTextSeparator.auto => Icons.auto_awesome_outlined,
    ImportStructuredTextSeparator.tab => Icons.keyboard_tab_outlined,
    ImportStructuredTextSeparator.colon => Icons.more_vert_outlined,
    ImportStructuredTextSeparator.slash => Icons.code_outlined,
    ImportStructuredTextSeparator.semicolon => Icons.data_array_outlined,
    ImportStructuredTextSeparator.pipe => Icons.vertical_align_center_outlined,
  };

bool _hasImportSource(FlashcardImportDraftState draft) => switch (draft.format) {
    ImportSourceFormat.excel => draft.sourceBytes != null,
    ImportSourceFormat.csv || ImportSourceFormat.structuredText =>
      StringUtils.isNotBlank(draft.rawContent),
  };

String _fileSummary(
  AppLocalizations l10n,
  FlashcardImportPreparation? preparation,
) {
  if (preparation == null) {
    return l10n.importFileReadyToPreview;
  }
  final rowCount =
      preparation.previewItems.length +
      preparation.issues.length +
      preparation.skippedDuplicateCount;
  return l10n.importDetectedRowsLabel(rowCount);
}

String _rulesText(AppLocalizations l10n, ImportSourceFormat format) => switch (format) {
    ImportSourceFormat.csv => l10n.importCsvRulesText,
    ImportSourceFormat.excel => l10n.importExcelRulesText,
    ImportSourceFormat.structuredText => l10n.importTextRulesText,
  };

List<String> _allowedImportFileExtensions(ImportSourceFormat format) => switch (format) {
    ImportSourceFormat.csv => const <String>['csv'],
    ImportSourceFormat.excel => const <String>['xlsx'],
    ImportSourceFormat.structuredText => const <String>['txt'],
  };

String _contentLabel(AppLocalizations l10n, ImportSourceFormat format) => switch (format) {
    ImportSourceFormat.csv => l10n.importCsvContentLabel,
    ImportSourceFormat.excel => l10n.importExcelFileLabel,
    ImportSourceFormat.structuredText => l10n.importTextContentLabel,
  };

String _contentHint(AppLocalizations l10n, ImportSourceFormat format) => switch (format) {
    ImportSourceFormat.csv => l10n.importCsvHint,
    ImportSourceFormat.excel => l10n.importExcelRulesText,
    ImportSourceFormat.structuredText => l10n.importTextHint,
  };

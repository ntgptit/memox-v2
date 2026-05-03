import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_inline_toggle.dart';
import '../../../shared/widgets/mx_list_tile.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../viewmodels/flashcard_import_viewmodel.dart';
import '../widgets/deck_import_preview_section.dart';

class DeckImportScreen extends ConsumerStatefulWidget {
  const DeckImportScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<DeckImportScreen> createState() => _DeckImportScreenState();
}

class _DeckImportScreenState extends ConsumerState<DeckImportScreen> {
  late final TextEditingController _rawContentController =
      TextEditingController();
  _ImportPendingAction? _pendingAction;

  @override
  void dispose() {
    _rawContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen<AsyncValue<void>>(
      flashcardImportControllerProvider(widget.deckId),
      (_, next) {
        final failure = flashcardImportError(next);
        if (failure != null) {
          MxSnackbar.error(context, flashcardImportErrorMessage(failure));
        }
      },
    );

    final draft = ref.watch(flashcardImportDraftProvider(widget.deckId));
    final importActionState = ref.watch(
      flashcardImportControllerProvider(widget.deckId),
    );
    final isImportBusy = importActionState.isLoading || _pendingAction != null;
    final isExcelImport = draft.format == ImportSourceFormat.excel;
    final hasImportSource = _hasImportSource(draft);
    final preparation = draft.preparation;
    final canCommit = preparation?.canCommit == true;

    if (!isExcelImport && _rawContentController.text != draft.rawContent) {
      _rawContentController.value = TextEditingValue(
        text: draft.rawContent,
        selection: TextSelection.collapsed(offset: draft.rawContent.length),
      );
    }

    return MxScaffold(
      title: l10n.flashcardsImportTitle,
      automaticallyImplyLeading: false,
      leading: MxIconButton.toolbar(
        icon: Icons.arrow_back,
        tooltip: l10n.commonBack,
        onPressed: () => context.popRoute(
          fallback: () => context.goFlashcardList(widget.deckId),
        ),
      ),
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        child: CustomScrollView(
          key: const ValueKey('deck_import_content'),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImportSourceSection(
                    format: draft.format,
                    enabled: !isImportBusy,
                    onChanged: (format) => ref
                        .read(
                          flashcardImportDraftProvider(widget.deckId).notifier,
                        )
                        .setFormat(format),
                  ),
                  const MxGap(MxSpace.lg),
                  _buildImportSourceInput(
                    draft: draft,
                    enabled: !isImportBusy,
                    l10n: l10n,
                  ),
                  const MxGap(MxSpace.lg),
                  _ImportOptionsSection(
                    format: draft.format,
                    duplicatePolicy: draft.duplicatePolicy,
                    excelHasHeader: draft.excelHasHeader,
                    structuredTextSeparator: draft.structuredTextSeparator,
                    enabled: !isImportBusy,
                    onDuplicateTap: () =>
                        _chooseDuplicatePolicy(draft.duplicatePolicy),
                    onSeparatorTap: () => _chooseStructuredTextSeparator(
                      draft.structuredTextSeparator,
                    ),
                    onHeaderChanged: (value) => ref
                        .read(
                          flashcardImportDraftProvider(widget.deckId).notifier,
                        )
                        .setExcelHasHeader(value),
                  ),
                  const MxGap(MxSpace.sm),
                  MxText(
                    _rulesText(l10n, draft.format),
                    role: MxTextRole.formHelper,
                  ),
                  if (hasImportSource) ...[
                    const MxGap(MxSpace.lg),
                    _ImportActionButton(
                      previewLabel: l10n.importPreviewAction,
                      importLabel: canCommit
                          ? l10n.importCommitCardsAction(
                              preparation!.previewItems.length,
                            )
                          : null,
                      canCommit: canCommit,
                      isBusy: isImportBusy,
                      pendingAction: _pendingAction,
                      onPreview: _preparePreview,
                      onCommit: () => _commitImport(context),
                    ),
                  ],
                ],
              ),
            ),
            if (preparation != null) ...[
              const MxSliverGap(MxSpace.lg),
              ...buildDeckImportPreviewSlivers(
                context: context,
                preparation: preparation,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _preparePreview() async {
    setState(() => _pendingAction = _ImportPendingAction.preview);
    await ref
        .read(flashcardImportControllerProvider(widget.deckId).notifier)
        .preparePreview();
    if (mounted) {
      setState(() => _pendingAction = null);
    }
  }

  Future<void> _commitImport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _pendingAction = _ImportPendingAction.commit);
    final count = await ref
        .read(flashcardImportControllerProvider(widget.deckId).notifier)
        .commitImport();
    if (!context.mounted) {
      return;
    }
    if (count == null) {
      setState(() => _pendingAction = null);
      return;
    }
    MxSnackbar.success(context, l10n.importSuccessMessage(count));
    await context.popRoute(
      fallback: () => context.goFlashcardList(widget.deckId),
    );
    if (mounted) {
      setState(() => _pendingAction = null);
    }
  }

  Widget _buildImportSourceInput({
    required FlashcardImportDraftState draft,
    required bool enabled,
    required AppLocalizations l10n,
  }) {
    return switch (draft.format) {
      ImportSourceFormat.excel => _ImportExcelSource(
        fileName: draft.loadedFileName,
        fileSummary: _fileSummary(l10n, draft.preparation),
        enabled: enabled,
        onSelect: () => _pickFile(context),
        onChange: () => _pickFile(context),
        onRemove: () => ref
            .read(flashcardImportDraftProvider(widget.deckId).notifier)
            .clearSourceFile(),
      ),
      ImportSourceFormat.csv ||
      ImportSourceFormat.structuredText => _ImportTextSource(
        controller: _rawContentController,
        format: draft.format,
        enabled: enabled,
        onLoadFile: () => _pickFile(context),
        onChanged: (value) => ref
            .read(flashcardImportDraftProvider(widget.deckId).notifier)
            .setRawContent(value),
      ),
    };
  }

  Future<void> _pickFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final draft = ref.read(flashcardImportDraftProvider(widget.deckId));
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedImportFileExtensions(draft.format),
      withData: true,
    );
    if (!context.mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    if (draft.format == ImportSourceFormat.excel) {
      final bytes = await readDeckImportFileBytes(file);
      if (!context.mounted) {
        return;
      }
      if (bytes == null) {
        MxSnackbar.error(context, l10n.importFileUnavailableMessage);
        return;
      }
      ref
          .read(flashcardImportDraftProvider(widget.deckId).notifier)
          .setSourceFile(sourceBytes: bytes, loadedFileName: file.name);
      MxSnackbar.success(context, l10n.importLoadedFileMessage(file.name));
      return;
    }

    final content = await readDeckImportFileContent(file);
    if (!context.mounted) {
      return;
    }
    if (content == null) {
      MxSnackbar.error(context, l10n.importFileUnavailableMessage);
      return;
    }
    ref
        .read(flashcardImportDraftProvider(widget.deckId).notifier)
        .setRawContent(content);
    MxSnackbar.success(context, l10n.importLoadedFileMessage(file.name));
  }

  Future<void> _chooseDuplicatePolicy(
    FlashcardImportDuplicatePolicy current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await MxBottomSheet.show<_ImportDuplicatePolicyChoice>(
      context: context,
      title: l10n.importDuplicateHandlingTitle,
      child: MxActionSheetList<_ImportDuplicatePolicyChoice>(
        items: _buildImportDuplicatePolicyActions(l10n),
        selectedValue: _duplicatePolicyChoice(current),
      ),
    );
    if (!mounted || selected == null) {
      return;
    }
    ref
        .read(flashcardImportDraftProvider(widget.deckId).notifier)
        .setDuplicatePolicy(FlashcardImportDuplicatePolicy.skipExactDuplicates);
  }

  Future<void> _chooseStructuredTextSeparator(
    ImportStructuredTextSeparator current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await MxBottomSheet.show<ImportStructuredTextSeparator>(
      context: context,
      title: l10n.importSeparatorLabel,
      child: MxActionSheetList<ImportStructuredTextSeparator>(
        items: _buildImportSeparatorActions(l10n),
        selectedValue: current,
      ),
    );
    if (!mounted || selected == null) {
      return;
    }
    ref
        .read(flashcardImportDraftProvider(widget.deckId).notifier)
        .setStructuredTextSeparator(selected);
  }
}

enum _ImportPendingAction { preview, commit }

enum _ImportDuplicatePolicyChoice { skipExactDuplicates }

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
) {
  return switch (policy) {
    FlashcardImportDuplicatePolicy.skipExactDuplicates =>
      l10n.importDuplicatePolicySkipExact,
  };
}

List<MxActionSheetItem<_ImportDuplicatePolicyChoice>>
_buildImportDuplicatePolicyActions(AppLocalizations l10n) {
  return [
    MxActionSheetItem<_ImportDuplicatePolicyChoice>(
      value: _ImportDuplicatePolicyChoice.skipExactDuplicates,
      label: l10n.importDuplicatePolicySkipExact,
      subtitle: l10n.importDuplicatePolicySkipExactDescription,
      icon: Icons.filter_alt_outlined,
    ),
  ];
}

_ImportDuplicatePolicyChoice _duplicatePolicyChoice(
  FlashcardImportDuplicatePolicy policy,
) {
  return switch (policy) {
    FlashcardImportDuplicatePolicy.skipExactDuplicates =>
      _ImportDuplicatePolicyChoice.skipExactDuplicates,
  };
}

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
_buildImportSeparatorActions(AppLocalizations l10n) {
  return [
    for (final separator in ImportStructuredTextSeparator.values)
      MxActionSheetItem(
        value: separator,
        label: _separatorLabel(l10n, separator),
        subtitle: _separatorDescription(l10n, separator),
        icon: _separatorIcon(separator),
      ),
  ];
}

String _separatorLabel(
  AppLocalizations l10n,
  ImportStructuredTextSeparator separator,
) {
  return switch (separator) {
    ImportStructuredTextSeparator.auto => l10n.importSeparatorAuto,
    ImportStructuredTextSeparator.tab => l10n.importSeparatorTab,
    ImportStructuredTextSeparator.colon => l10n.importSeparatorColon,
    ImportStructuredTextSeparator.slash => l10n.importSeparatorSlash,
    ImportStructuredTextSeparator.semicolon => l10n.importSeparatorSemicolon,
    ImportStructuredTextSeparator.pipe => l10n.importSeparatorPipe,
  };
}

String _separatorDescription(
  AppLocalizations l10n,
  ImportStructuredTextSeparator separator,
) {
  return switch (separator) {
    ImportStructuredTextSeparator.auto => l10n.importSeparatorAutoDescription,
    ImportStructuredTextSeparator.tab => l10n.importSeparatorTabDescription,
    ImportStructuredTextSeparator.colon => l10n.importSeparatorColonDescription,
    ImportStructuredTextSeparator.slash => l10n.importSeparatorSlashDescription,
    ImportStructuredTextSeparator.semicolon =>
      l10n.importSeparatorSemicolonDescription,
    ImportStructuredTextSeparator.pipe => l10n.importSeparatorPipeDescription,
  };
}

IconData _separatorIcon(ImportStructuredTextSeparator separator) {
  return switch (separator) {
    ImportStructuredTextSeparator.auto => Icons.auto_awesome_outlined,
    ImportStructuredTextSeparator.tab => Icons.keyboard_tab_outlined,
    ImportStructuredTextSeparator.colon => Icons.more_vert_outlined,
    ImportStructuredTextSeparator.slash => Icons.code_outlined,
    ImportStructuredTextSeparator.semicolon => Icons.data_array_outlined,
    ImportStructuredTextSeparator.pipe => Icons.vertical_align_center_outlined,
  };
}

bool _hasImportSource(FlashcardImportDraftState draft) {
  return switch (draft.format) {
    ImportSourceFormat.excel => draft.sourceBytes != null,
    ImportSourceFormat.csv || ImportSourceFormat.structuredText =>
      StringUtils.isNotBlank(draft.rawContent),
  };
}

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

String _rulesText(AppLocalizations l10n, ImportSourceFormat format) {
  return switch (format) {
    ImportSourceFormat.csv => l10n.importCsvRulesText,
    ImportSourceFormat.excel => l10n.importExcelRulesText,
    ImportSourceFormat.structuredText => l10n.importTextRulesText,
  };
}

List<String> _allowedImportFileExtensions(ImportSourceFormat format) {
  return switch (format) {
    ImportSourceFormat.csv => const <String>['csv'],
    ImportSourceFormat.excel => const <String>['xlsx'],
    ImportSourceFormat.structuredText => const <String>['txt'],
  };
}

String _contentLabel(AppLocalizations l10n, ImportSourceFormat format) {
  return switch (format) {
    ImportSourceFormat.csv => l10n.importCsvContentLabel,
    ImportSourceFormat.excel => l10n.importExcelFileLabel,
    ImportSourceFormat.structuredText => l10n.importTextContentLabel,
  };
}

String _contentHint(AppLocalizations l10n, ImportSourceFormat format) {
  return switch (format) {
    ImportSourceFormat.csv => l10n.importCsvHint,
    ImportSourceFormat.excel => l10n.importExcelRulesText,
    ImportSourceFormat.structuredText => l10n.importTextHint,
  };
}

@visibleForTesting
Future<String?> readDeckImportFileContent(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) {
    return utf8.decode(bytes);
  }

  final path = file.path;
  if (path == null) {
    return null;
  }

  return File(path).readAsString(encoding: utf8);
}

@visibleForTesting
Future<Uint8List?> readDeckImportFileBytes(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) {
    return Uint8List.fromList(bytes);
  }

  final path = file.path;
  if (path == null) {
    return null;
  }

  return File(path).readAsBytes();
}

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_list_tile.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../widgets/deck_import_header_section.dart';
import '../widgets/deck_import_preview_section.dart';
import '../viewmodels/flashcard_import_viewmodel.dart';

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

    if (_rawContentController.text != draft.rawContent) {
      _rawContentController.value = TextEditingValue(
        text: draft.rawContent,
        selection: TextSelection.collapsed(offset: draft.rawContent.length),
      );
    }

    return MxScaffold(
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        child: CustomScrollView(
          key: const ValueKey('deck_import_content'),
          slivers: [
            SliverToBoxAdapter(
              child: DeckImportHeaderSection(deckId: widget.deckId),
            ),
            const MxSliverGap(MxSpace.xl),
            SliverToBoxAdapter(
              child: MxSection(
                title: l10n.importSourceTitle,
                subtitle: l10n.importSourceSubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      enabled: !isImportBusy,
                      child: IgnorePointer(
                        ignoring: isImportBusy,
                        child: MxSegmentedControl<ImportSourceFormat>(
                          segments: [
                            MxSegment(
                              value: ImportSourceFormat.csv,
                              label: l10n.importCsvLabel,
                              icon: Icons.table_chart_outlined,
                            ),
                            MxSegment(
                              value: ImportSourceFormat.structuredText,
                              label: l10n.importTextFormatLabel,
                              icon: Icons.notes_outlined,
                            ),
                          ],
                          selected: <ImportSourceFormat>{draft.format},
                          onChanged: (selection) => ref
                              .read(
                                flashcardImportDraftProvider(
                                  widget.deckId,
                                ).notifier,
                              )
                              .setFormat(selection.first),
                        ),
                      ),
                    ),
                    if (draft.format == ImportSourceFormat.structuredText) ...[
                      const MxGap(MxSpace.lg),
                      MxText(
                        l10n.importSeparatorLabel,
                        role: MxTextRole.formLabel,
                      ),
                      const MxGap(MxSpace.xs),
                      _ImportSeparatorSelector(
                        value: draft.structuredTextSeparator,
                        enabled: !isImportBusy,
                        onTap: () => _chooseStructuredTextSeparator(
                          draft.structuredTextSeparator,
                        ),
                      ),
                    ],
                    const MxGap(MxSpace.lg),
                    MxText(
                      l10n.importDuplicateHandlingTitle,
                      role: MxTextRole.formLabel,
                    ),
                    const MxGap(MxSpace.xs),
                    _ImportDuplicatePolicyCard(
                      policy: draft.duplicatePolicy,
                      enabled: !isImportBusy,
                      onTap: () =>
                          _chooseDuplicatePolicy(draft.duplicatePolicy),
                    ),
                    const MxGap(MxSpace.lg),
                    Wrap(
                      spacing: MxSpace.sm,
                      runSpacing: MxSpace.sm,
                      children: [
                        MxSecondaryButton(
                          label: l10n.importLoadFile,
                          leadingIcon: Icons.file_open_outlined,
                          variant: MxSecondaryVariant.outlined,
                          onPressed: isImportBusy
                              ? null
                              : () => _pickFile(context),
                        ),
                        MxSecondaryButton(
                          label: l10n.commonClear,
                          variant: MxSecondaryVariant.text,
                          onPressed: isImportBusy
                              ? null
                              : () => ref
                                    .read(
                                      flashcardImportDraftProvider(
                                        widget.deckId,
                                      ).notifier,
                                    )
                                    .reset(),
                        ),
                      ],
                    ),
                    const MxGap(MxSpace.lg),
                    MxTextField(
                      controller: _rawContentController,
                      label: draft.format == ImportSourceFormat.csv
                          ? l10n.importCsvContentLabel
                          : l10n.importTextContentLabel,
                      hintText: draft.format == ImportSourceFormat.csv
                          ? l10n.importCsvHint
                          : l10n.importTextHint,
                      minLines: 10,
                      maxLines: 18,
                      onChanged: (value) => ref
                          .read(
                            flashcardImportDraftProvider(
                              widget.deckId,
                            ).notifier,
                          )
                          .setRawContent(value),
                    ),
                    const MxGap(MxSpace.xl),
                    _ImportSubmitRow(
                      previewLabel: l10n.importPreviewAction,
                      importLabel: l10n.commonImport,
                      isBusy: isImportBusy,
                      canCommit: draft.preparation?.canCommit == true,
                      pendingAction: _pendingAction,
                      onPreview: _preparePreview,
                      onCommit: () => _commitImport(context),
                    ),
                  ],
                ),
              ),
            ),
            if (draft.preparation != null) ...[
              const MxSliverGap(MxSpace.xl),
              ...buildDeckImportPreviewSlivers(
                context: context,
                preparation: draft.preparation!,
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
    await context.popRoute(fallback: () => context.goDeckDetail(widget.deckId));
    if (mounted) {
      setState(() => _pendingAction = null);
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );
    if (!context.mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
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
    if (selected != _ImportDuplicatePolicyChoice.skipExactDuplicates) {
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

enum _ImportDuplicatePolicyChoice {
  skipExactDuplicates,
  importAnyway,
  updateExistingCards,
}

class _ImportDuplicatePolicyCard extends StatelessWidget {
  const _ImportDuplicatePolicyCard({
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

    return MxCard(
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: MxListTile(
        leadingIcon: Icons.rule_outlined,
        title: _duplicatePolicyLabel(l10n, policy),
        subtitle: _duplicatePolicyDescription(l10n, policy),
        showChevron: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

class _ImportSubmitRow extends StatelessWidget {
  const _ImportSubmitRow({
    required this.previewLabel,
    required this.importLabel,
    required this.isBusy,
    required this.canCommit,
    required this.pendingAction,
    required this.onPreview,
    required this.onCommit,
  });

  final String previewLabel;
  final String importLabel;
  final bool isBusy;
  final bool canCommit;
  final _ImportPendingAction? pendingAction;
  final VoidCallback onPreview;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildCompact();
        }
        return _buildWide();
      },
    );
  }

  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSecondaryButton(
          key: const ValueKey('deck_import_preview_action'),
          label: previewLabel,
          leadingIcon: Icons.preview_outlined,
          variant: MxSecondaryVariant.outlined,
          fullWidth: true,
          isLoading: pendingAction == _ImportPendingAction.preview,
          onPressed: isBusy ? null : onPreview,
        ),
        const MxGap(MxSpace.sm),
        MxPrimaryButton(
          label: importLabel,
          leadingIcon: Icons.file_upload_outlined,
          size: MxButtonSize.large,
          fullWidth: true,
          isLoading: pendingAction == _ImportPendingAction.commit,
          onPressed: isBusy || !canCommit ? null : onCommit,
        ),
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MxSecondaryButton(
          key: const ValueKey('deck_import_preview_action'),
          label: previewLabel,
          leadingIcon: Icons.preview_outlined,
          variant: MxSecondaryVariant.outlined,
          isLoading: pendingAction == _ImportPendingAction.preview,
          onPressed: isBusy ? null : onPreview,
        ),
        const MxGap(MxSpace.md),
        MxPrimaryButton(
          label: importLabel,
          leadingIcon: Icons.file_upload_outlined,
          isLoading: pendingAction == _ImportPendingAction.commit,
          onPressed: isBusy || !canCommit ? null : onCommit,
        ),
      ],
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

String _duplicatePolicyDescription(
  AppLocalizations l10n,
  FlashcardImportDuplicatePolicy policy,
) {
  return switch (policy) {
    FlashcardImportDuplicatePolicy.skipExactDuplicates =>
      l10n.importDuplicatePolicySkipExactDescription,
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
    MxActionSheetItem<_ImportDuplicatePolicyChoice>(
      value: _ImportDuplicatePolicyChoice.importAnyway,
      label: l10n.importDuplicatePolicyImportAnyway,
      subtitle: l10n.importDuplicatePolicyImportAnywayDescription,
      icon: Icons.playlist_add_outlined,
      enabled: false,
    ),
    MxActionSheetItem<_ImportDuplicatePolicyChoice>(
      value: _ImportDuplicatePolicyChoice.updateExistingCards,
      label: l10n.importDuplicatePolicyUpdateExisting,
      subtitle: l10n.importDuplicatePolicyUpdateExistingDescription,
      icon: Icons.update_outlined,
      enabled: false,
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

class _ImportSeparatorSelector extends StatelessWidget {
  const _ImportSeparatorSelector({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final ImportStructuredTextSeparator value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      onTap: enabled ? onTap : null,
      child: MxListTile(
        leadingIcon: _separatorIcon(value),
        title: _separatorLabel(l10n, value),
        subtitle: _separatorDescription(l10n, value),
        showChevron: enabled,
      ),
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

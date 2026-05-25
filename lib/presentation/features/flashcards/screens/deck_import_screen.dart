import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/files/deck_import_file_reader.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_button_size.dart';
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

part '../widgets/deck_import_screen_options_widgets.dart';
part '../widgets/deck_import_screen_source_widgets.dart';

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

    return _buildScaffold(
      context: context,
      l10n: l10n,
      draft: draft,
      isImportBusy: isImportBusy,
      hasImportSource: hasImportSource,
      preparation: preparation,
      canCommit: canCommit,
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required AppLocalizations l10n,
    required FlashcardImportDraftState draft,
    required bool isImportBusy,
    required bool hasImportSource,
    required FlashcardImportPreparation? preparation,
    required bool canCommit,
  }) => MxScaffold(
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
  }) => switch (draft.format) {
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

  Future<void> _pickFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final draft = ref.read(flashcardImportDraftProvider(widget.deckId));
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedImportFileExtensions(draft.format),
      withData: true,
    );
    if (!context.mounted) return;
    if (result == null || result.files.isEmpty) return;

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
    if (!mounted) return;
    if (selected == null) return;
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
    if (!mounted) return;
    if (selected == null) return;
    ref
        .read(flashcardImportDraftProvider(widget.deckId).notifier)
        .setStructuredTextSeparator(selected);
  }
}

enum _ImportPendingAction { preview, commit }

enum _ImportDuplicatePolicyChoice { skipExactDuplicates }

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/files/deck_import_file_reader.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_form_scaffold.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_tab_bar.dart';
import '../viewmodels/flashcard_import_viewmodel.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';
import '../widgets/bulk_add_controls.dart';
import '../widgets/bulk_add_file_section.dart';
import '../widgets/bulk_add_widgets.dart';

/// Bulk add (paste) — Design System mock `05d`.
///
/// Top-level `MxTabBar` switches between two input sources:
/// - **Text**: paste textarea + inline Paste/Preview pill switch (mock 05d).
/// - **File**: CSV / Excel (.xlsx) file picker, up to 10 MB, first sheet
///   only for Excel. The same `preparePreview` pipeline renders the parsed
///   rows inline.
class DeckImportScreen extends ConsumerStatefulWidget {
  const DeckImportScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<DeckImportScreen> createState() => _DeckImportScreenState();
}

enum _BulkAddTab { paste, preview }

enum _ImportSourceMode { text, file }

// guard:raw-size-reviewed file picker upper bound per product spec (10 MB).
const int _kMaxImportFileBytes = 10 * 1024 * 1024;

class _DeckImportScreenState extends ConsumerState<DeckImportScreen> {
  late final TextEditingController _pasteController;
  _ImportSourceMode _sourceMode = _ImportSourceMode.text;
  _BulkAddTab _tab = _BulkAddTab.paste;
  bool _isCommitting = false;

  @override
  void initState() {
    super.initState();
    _pasteController = TextEditingController(
      text: ref.read(flashcardImportDraftProvider(widget.deckId)).rawContent,
    );
  }

  @override
  void dispose() {
    _pasteController.dispose();
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
    final actionState = ref.watch(
      flashcardImportControllerProvider(widget.deckId),
    );
    final deckQuery = ref.watch(flashcardListQueryProvider(widget.deckId));

    if (_pasteController.text != draft.rawContent) {
      _pasteController.value = TextEditingValue(
        text: draft.rawContent,
        selection: TextSelection.collapsed(offset: draft.rawContent.length),
      );
    }

    final preparation = draft.preparation;
    final cardsCount = preparation?.previewItems.length ?? 0;
    final isBusy = actionState.isLoading;
    final canCommit = preparation?.canCommit == true && !isBusy;
    final deckName = deckQuery.value?.deckName ?? '';
    final breadcrumb = deckQuery.value?.breadcrumb ?? const [];

    return MxFormScaffold(
      title: l10n.bulkAddTitle,
      automaticallyImplyLeading: false,
      contentWidth: MxContentWidth.wide,
      leading: MxIconButton.toolbar(
        icon: Icons.close,
        tooltip: l10n.commonClose,
        onPressed: _closeScreen,
      ),
      actions: [
        MxIconButton.toolbar(
          icon: Icons.help_outline,
          tooltip: l10n.bulkAddHelpTooltip,
          onPressed: () =>
              MxSnackbar.show(context, message: l10n.bulkAddHelper),
        ),
      ],
      bottomAction: BulkAddFooter(
        count: cardsCount,
        deckName: deckName,
        isBusy: isBusy,
        canCommit: canCommit,
        onCommit: _commit,
      ),
      body: _BulkAddBody(
        l10n: l10n,
        deckId: widget.deckId,
        deckName: deckName,
        breadcrumb: breadcrumb,
        sourceMode: _sourceMode,
        tab: _tab,
        draft: draft,
        cardsCount: cardsCount,
        isBusy: isBusy,
        actionState: actionState,
        pasteController: _pasteController,
        onSourceModeChanged: _onSourceModeChanged,
        onTabChanged: _onTabChanged,
        onPickFile: _pickFile,
        onClearFile: _clearFile,
      ),
    );
  }

  Future<void> _closeScreen() async {
    await context.popRoute(
      fallback: () => context.goFlashcardList(widget.deckId),
    );
  }

  void _onSourceModeChanged(_ImportSourceMode mode) {
    if (mode == _sourceMode) return;
    setState(() {
      _sourceMode = mode;
      // Reset internal tab when leaving Text mode so re-entering shows Paste.
      _tab = _BulkAddTab.paste;
    });
    final notifier = ref.read(
      flashcardImportDraftProvider(widget.deckId).notifier,
    );
    if (mode == _ImportSourceMode.text) {
      notifier.setFormat(ImportSourceFormat.structuredText);
      return;
    }
    // Switching to File without picking yet — clear paste content,
    // leave format to be set on file selection.
    notifier
      ..setRawContent('')
      ..clearSourceFile();
  }

  void _onTabChanged(Set<_BulkAddTab> next) {
    if (next.isEmpty) return;
    final value = next.first;
    setState(() => _tab = value);
    if (value != _BulkAddTab.preview) return;
    unawaited(_triggerPreview());
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx'],
      withData: true,
    );
    if (!mounted) return;
    final file = picked?.files.firstOrNull;
    if (file == null) return;
    if (file.size > _kMaxImportFileBytes) {
      MxSnackbar.error(context, l10n.bulkAddFileSizeError);
      return;
    }
    final extension = StringUtils.lowerCaseToEmpty(file.extension);
    final format = extension == 'xlsx'
        ? ImportSourceFormat.excel
        : ImportSourceFormat.csv;
    final notifier = ref.read(
      flashcardImportDraftProvider(widget.deckId).notifier,
    );
    notifier.setFormat(format);

    if (format == ImportSourceFormat.csv) {
      final content = await readDeckImportFileContent(file);
      if (!mounted) return;
      if (content == null) return;
      notifier
        ..setSourceFile(
          sourceBytes: Uint8List.fromList(file.bytes ?? <int>[]),
          loadedFileName: file.name,
        )
        ..setRawContent(content);
      unawaited(_triggerPreview());
      return;
    }
    final bytes = await readDeckImportFileBytes(file);
    if (!mounted) return;
    if (bytes == null) return;
    notifier.setSourceFile(
      sourceBytes: bytes,
      loadedFileName: file.name,
    );
    unawaited(_triggerPreview());
  }

  void _clearFile() {
    ref
        .read(flashcardImportDraftProvider(widget.deckId).notifier)
        .clearSourceFile();
  }

  Future<void> _triggerPreview() async {
    final draft = ref.read(flashcardImportDraftProvider(widget.deckId));
    final isTextSource =
        draft.format == ImportSourceFormat.structuredText;
    if (isTextSource && StringUtils.isBlank(draft.rawContent)) return;
    if (!isTextSource && draft.sourceBytes == null) return;
    await ref
        .read(flashcardImportControllerProvider(widget.deckId).notifier)
        .preparePreview();
  }

  Future<void> _commit() async {
    if (_isCommitting) return;
    _isCommitting = true;
    try {
      final l10n = AppLocalizations.of(context);
      final count = await ref
          .read(flashcardImportControllerProvider(widget.deckId).notifier)
          .commitImport();
      if (!mounted) return;
      if (count == null) return;
      final showSavedMessage = MxSnackbar.deferredSuccess(
        context,
        l10n.importSuccessMessage(count),
      );
      await context.popRoute(
        fallback: () => context.goFlashcardList(widget.deckId),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => showSavedMessage());
    } finally {
      _isCommitting = false;
    }
  }
}

class _BulkAddBody extends ConsumerWidget {
  const _BulkAddBody({
    required this.l10n,
    required this.deckId,
    required this.deckName,
    required this.breadcrumb,
    required this.sourceMode,
    required this.tab,
    required this.draft,
    required this.cardsCount,
    required this.isBusy,
    required this.actionState,
    required this.pasteController,
    required this.onSourceModeChanged,
    required this.onTabChanged,
    required this.onPickFile,
    required this.onClearFile,
  });

  final AppLocalizations l10n;
  final String deckId;
  final String deckName;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
  final _ImportSourceMode sourceMode;
  final _BulkAddTab tab;
  final FlashcardImportDraftState draft;
  final int cardsCount;
  final bool isBusy;
  final AsyncValue<void> actionState;
  final TextEditingController pasteController;
  final ValueChanged<_ImportSourceMode> onSourceModeChanged;
  final ValueChanged<Set<_BulkAddTab>> onTabChanged;
  final VoidCallback onPickFile;
  final VoidCallback onClearFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      BulkAddBreadcrumb(
        breadcrumb: breadcrumb,
        deckName: deckName,
        onOpenLibrary: context.goLibrary,
        onOpenFolder: context.goFolderDetail,
        onOpenDeck: () => context.goFlashcardList(deckId),
      ),
      const MxGap(MxSpace.md),
      MxTabBar(
        items: [
          MxTabBarItem(label: l10n.bulkAddSourceTabText),
          MxTabBarItem(label: l10n.bulkAddSourceTabFile),
        ],
        selectedIndex: sourceMode.index,
        onChanged: (i) => onSourceModeChanged(_ImportSourceMode.values[i]),
      ),
      const MxGap(MxSpace.lg),
      sourceMode == _ImportSourceMode.text
          ? _TextModeBody(
              l10n: l10n,
              deckId: deckId,
              tab: tab,
              draft: draft,
              cardsCount: cardsCount,
              isBusy: isBusy,
              actionState: actionState,
              pasteController: pasteController,
              onTabChanged: onTabChanged,
            )
          : BulkAddFileSection(
              draft: draft,
              actionState: actionState,
              enabled: !isBusy,
              onPickFile: onPickFile,
              onClearFile: onClearFile,
              onExcelHasHeaderChanged: (value) {
                ref
                    .read(flashcardImportDraftProvider(deckId).notifier)
                    .setExcelHasHeader(value);
                unawaited(
                  ref
                      .read(flashcardImportControllerProvider(deckId).notifier)
                      .preparePreview(),
                );
              },
            ),
    ],
  );
}

class _TextModeBody extends ConsumerWidget {
  const _TextModeBody({
    required this.l10n,
    required this.deckId,
    required this.tab,
    required this.draft,
    required this.cardsCount,
    required this.isBusy,
    required this.actionState,
    required this.pasteController,
    required this.onTabChanged,
  });

  final AppLocalizations l10n;
  final String deckId;
  final _BulkAddTab tab;
  final FlashcardImportDraftState draft;
  final int cardsCount;
  final bool isBusy;
  final AsyncValue<void> actionState;
  final TextEditingController pasteController;
  final ValueChanged<Set<_BulkAddTab>> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: BulkAddTabs(
          pasteLabel: l10n.bulkAddTabPaste,
          previewLabel: l10n.bulkAddTabPreview,
          previewCount: cardsCount,
          selectedPaste: tab == _BulkAddTab.paste,
          onChanged: (bool isPaste) => onTabChanged(
            <_BulkAddTab>{
              isPaste ? _BulkAddTab.paste : _BulkAddTab.preview,
            },
          ),
        ),
      ),
      const MxGap(MxSpace.lg),
      _tabContent(ref),
    ],
  );

  Widget _tabContent(WidgetRef ref) {
    if (tab == _BulkAddTab.preview) {
      return BulkAddPreviewSection(draft: draft, actionState: actionState);
    }
    return BulkAddPasteSection(
      controller: pasteController,
      hint: l10n.bulkAddPasteHint,
      helper: l10n.bulkAddHelper,
      separator: draft.structuredTextSeparator,
      enabled: !isBusy,
      separatorLabels: _separatorLabels(l10n),
      onChanged: (text) => ref
          .read(flashcardImportDraftProvider(deckId).notifier)
          .setRawContent(text),
      onSeparatorChanged: (sep) => ref
          .read(flashcardImportDraftProvider(deckId).notifier)
          .setStructuredTextSeparator(sep),
    );
  }

  Map<ImportStructuredTextSeparator, String> _separatorLabels(
    AppLocalizations l10n,
  ) => {
    ImportStructuredTextSeparator.tab: l10n.importSeparatorTab,
    ImportStructuredTextSeparator.comma: l10n.importSeparatorComma,
    ImportStructuredTextSeparator.pipe: l10n.importSeparatorPipe,
  };
}

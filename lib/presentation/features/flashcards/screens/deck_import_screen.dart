import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/layouts/mx_section.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
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
    final draftNotifier = ref.read(
      flashcardImportDraftProvider(widget.deckId).notifier,
    );
    final controller = ref.read(
      flashcardImportControllerProvider(widget.deckId).notifier,
    );

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
        child: ListView(
          children: [
            DeckImportHeaderSection(deckId: widget.deckId),
            const MxGap(MxSpace.xl),
            MxSection(
              title: l10n.importSourceTitle,
              subtitle: l10n.importSourceSubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MxSegmentedControl<ImportSourceFormat>(
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
                    onChanged: (selection) =>
                        draftNotifier.setFormat(selection.first),
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
                        onPressed: () => _pickFile(context, draftNotifier),
                      ),
                      MxSecondaryButton(
                        label: l10n.commonClear,
                        variant: MxSecondaryVariant.text,
                        onPressed: draftNotifier.reset,
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
                    onChanged: draftNotifier.setRawContent,
                  ),
                  const MxGap(MxSpace.lg),
                  Wrap(
                    spacing: MxSpace.sm,
                    runSpacing: MxSpace.sm,
                    children: [
                      MxSecondaryButton(
                        label: l10n.importPreviewAction,
                        leadingIcon: Icons.preview_outlined,
                        variant: MxSecondaryVariant.outlined,
                        onPressed: controller.preparePreview,
                      ),
                      MxPrimaryButton(
                        label: l10n.commonImport,
                        leadingIcon: Icons.file_upload_outlined,
                        onPressed: draft.preparation?.canCommit == true
                            ? () async {
                                final count = await controller.commitImport();
                                if (!context.mounted || count == null) {
                                  return;
                                }
                                MxSnackbar.success(
                                  context,
                                  l10n.importSuccessMessage(count),
                                );
                                await context.popRoute(
                                  fallback: () =>
                                      context.goDeckDetail(widget.deckId),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (draft.preparation != null) ...[
              const MxGap(MxSpace.xl),
              DeckImportPreviewSection(preparation: draft.preparation!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(
    BuildContext context,
    FlashcardImportDraft draftNotifier,
  ) async {
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
    final content = file.bytes != null
        ? String.fromCharCodes(file.bytes!)
        : await File(file.path!).readAsString();
    if (!context.mounted) {
      return;
    }
    draftNotifier.setRawContent(content);
    MxSnackbar.success(context, l10n.importLoadedFileMessage(file.name));
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_import_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';

void main() {
  testWidgets('DT1 onOpen: renders default Excel import flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            const _ImportOnlyFlashcardRepository(),
          ),
        ],
        child: const DeckImportScreen(deckId: 'deck-001'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import flashcards'), findsOneWidget);
    expect(find.text('Import from'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('Excel'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Select Excel file'), findsOneWidget);
    expect(
      tester
          .widget<MxPrimaryButton>(
            find.byKey(const ValueKey('deck_import_select_file_action')),
          )
          .size,
      MxButtonSize.medium,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('deck_import_select_file_action')))
          .height,
      inInclusiveRange(48, 52),
    );
    expect(
      find.text('Column A = front, Column B = back, Column C = note.'),
      findsOneWidget,
    );
    expect(find.text('First row is header'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Preview import'), findsNothing);
    expect(find.text('Clear'), findsNothing);
  });

  testWidgets(
    'DT1 onDisplay: text format shows separator choices before preview',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _TestApp(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(
              const _ImportOnlyFlashcardRepository(),
            ),
          ],
          child: const DeckImportScreen(deckId: 'deck-001'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();

      expect(find.text('Separator'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Duplicate handling'), findsOneWidget);
      expect(find.byType(MxCard), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Separator'),
          matching: find.byType(MxCard),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('Duplicate handling'),
          matching: find.byType(MxCard),
        ),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(TextFormField)).height, lessThan(190));
      expect(
        tester.getSize(find.byType(TextFormField)).height,
        greaterThan(130),
      );
      expect(
        tester.getTopLeft(find.text('Load file')).dy,
        greaterThan(tester.getBottomLeft(find.byType(TextFormField)).dy),
      );
      expect(
        tester.getTopLeft(find.text('Load file')).dy,
        lessThan(tester.getTopLeft(find.byType(MxCard)).dy),
      );
    },
  );

  testWidgets('DT3 onDisplay: shows only active duplicate handling policy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            const _ImportOnlyFlashcardRepository(),
          ),
        ],
        child: const DeckImportScreen(deckId: 'deck-001'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Duplicate handling'), findsOneWidget);
    expect(find.text('Skip exact duplicates'), findsOneWidget);
    expect(find.text('Import anyway'), findsNothing);
    expect(find.text('Update existing cards'), findsNothing);

    await tester.tap(find.text('Duplicate handling'));
    await tester.pumpAndSettle();

    expect(
      find.text('Same front with a different back will still be imported.'),
      findsOneWidget,
    );
    expect(find.text('Import anyway'), findsNothing);
    expect(find.text('Update existing cards'), findsNothing);
  });

  testWidgets('DT4 onDisplay: preview shows skipped exact duplicates', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) => Future.value(const Success(_preparationWithSkippedDuplicates)),
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,Xin chao\nHello,Xin chao\nExisting,Deck card',
    );
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('deck_import_preview_action')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    for (var index = 0; index < 8; index++) {
      if (find
          .textContaining('Exact duplicate in this deck')
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.drag(
        find.byKey(const ValueKey('deck_import_content')),
        const Offset(0, -360),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('1 valid · 0 issues · 2 skipped'), findsOneWidget);
    expect(find.text('Skipped duplicates'), findsOneWidget);
    expect(find.textContaining('Exact duplicate in this file'), findsOneWidget);
    expect(find.textContaining('Exact duplicate in this deck'), findsOneWidget);
  });

  testWidgets('DT5 onDisplay: Excel source is file-only before load', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            const _ImportOnlyFlashcardRepository(),
          ),
        ],
        child: const DeckImportScreen(deckId: 'deck-001'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Select Excel file'), findsOneWidget);
    expect(
      find.text('Column A = front, Column B = back, Column C = note.'),
      findsOneWidget,
    );
    expect(find.text('First row is header'), findsOneWidget);
    expect(find.text('Duplicate handling'), findsOneWidget);
    expect(find.byType(MxCard), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('First row is header'),
        matching: find.byType(MxCard),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Duplicate handling'),
        matching: find.byType(MxCard),
      ),
      findsOneWidget,
    );
    expect(find.text('Preview import'), findsNothing);
  });

  testWidgets('DT6 onDisplay: Excel file row updates after preview succeeds', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final workbookBytes = Uint8List.fromList(<int>[80, 75, 3, 4]);
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) => Future.value(
            const Success(
              FlashcardImportPreparation(
                format: ImportSourceFormat.excel,
                previewItems: [
                  FlashcardImportPreviewItem(
                    sourceLabel: 'Row 2',
                    draft: FlashcardDraft(front: '개다', back: 'Clear up'),
                  ),
                ],
                issues: [],
              ),
            ),
          ),
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(DeckImportScreen)),
    );
    container
        .read(flashcardImportDraftProvider(deckId).notifier)
        .setSourceFile(
          sourceBytes: workbookBytes,
          loadedFileName: 'cards.xlsx',
        );
    await tester.pumpAndSettle();

    expect(find.text('cards.xlsx'), findsOneWidget);
    expect(find.text('Ready to preview'), findsOneWidget);
    expect(find.text('Preview import'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    expect(find.text('1 row detected'), findsOneWidget);
    expect(find.text('Import 1 card'), findsOneWidget);
  });

  test('DT1 onInsert: readDeckImportFileContent decodes UTF-8 bytes', () async {
    const content = 'front,back\nXin chào,Tiếng Việt có dấu: ă ê ô ư';
    final file = PlatformFile(
      name: 'cards.csv',
      size: utf8.encode(content).length,
      bytes: Uint8List.fromList(utf8.encode(content)),
    );

    final decoded = await readDeckImportFileContent(file);

    expect(decoded, content);
  });

  test(
    'DT2 onInsert: readDeckImportFileContent returns null when file has no source',
    () {
      final file = PlatformFile(name: 'missing.csv', size: 0);

      expect(readDeckImportFileContent(file), completion(isNull));
    },
  );

  test('DT6 onInsert: readDeckImportFileBytes returns binary bytes', () async {
    final sourceBytes = Uint8List.fromList(<int>[80, 75, 3, 4, 0, 1]);
    final file = PlatformFile(
      name: 'cards.xlsx',
      size: sourceBytes.length,
      bytes: sourceBytes,
    );

    final decoded = await readDeckImportFileBytes(file);

    expect(decoded, sourceBytes);
  });

  testWidgets(
    'DT3 onInsert: disables import controls while preview is running',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final prepareCompleter = Completer<Result<FlashcardImportPreparation>>();
      final repository = _ImportOnlyFlashcardRepository(
        prepareHandler:
            ({
              required deckId,
              required format,
              required rawContent,
              sourceBytes,
              required excelHasHeader,
              required duplicatePolicy,
              required structuredTextSeparator,
            }) => prepareCompleter.future,
      );

      await tester.pumpWidget(
        _TestApp(
          overrides: [
            flashcardRepositoryProvider.overrideWithValue(repository),
          ],
          child: const DeckImportScreen(deckId: deckId),
        ),
      );

      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'front,back\nXin chao,Hello',
      );
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('deck_import_preview_action')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('deck_import_preview_action')),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_primaryButton(tester).onPressed, isNull);
      expect(find.text('Clear'), findsNothing);

      await tester.ensureVisible(find.text('Text'));
      await tester.pump();
      await tester.tap(find.text('Text'), warnIfMissed: false);
      await tester.pump();

      expect(find.text('CSV content'), findsOneWidget);

      prepareCompleter.complete(const Success(_validPreparation));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('DT4 onInsert: shows import loading while commit is running', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final commitCompleter = Completer<Result<int>>();
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) => Future.value(const Success(_validPreparation)),
      commitHandler: ({required deckId, required preparation}) =>
          commitCompleter.future,
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nXin chao,Hello',
    );
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('deck_import_preview_action')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Import 1 card'));
    await tester.pump();
    await tester.tap(find.text('Import 1 card'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_primaryButton(tester).onPressed, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('DT5 onInsert: preview summary shows valid and issue counts', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) => Future.value(const Success(_preparationWithIssue)),
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nXin chao,Hello\nMissing back,',
    );
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('deck_import_preview_action')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('deck_import_content')),
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 valid · 1 issues'), findsOneWidget);
    expect(find.text('Line 3'), findsOneWidget);
    expect(find.text('Back is required.'), findsOneWidget);
  });

  testWidgets('DT2 onDisplay: lazily builds long import preview rows', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    const deckId = 'deck-001';
    final preparation = _largePreparation();
    var prepareCallCount = 0;
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) {
            prepareCallCount++;
            return Future.value(Success(preparation));
          },
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'front,back\nF,B');
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('deck_import_preview_action')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    expect(prepareCallCount, 1);
    expect(find.byType(CustomScrollView), findsOneWidget);
    for (var index = 0; index < 8; index++) {
      if (find
          .byKey(const ValueKey('deck_import_preview_lazy_items'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.drag(
        find.byKey(const ValueKey('deck_import_content')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
    }

    final initiallyBuiltRows = find.byType(MxTermRow).evaluate().length;

    expect(
      find.byKey(const ValueKey('deck_import_preview_lazy_items')),
      findsOneWidget,
    );
    expect(initiallyBuiltRows, lessThan(preparation.previewItems.length));
    expect(find.text('Front 79'), findsNothing);

    for (var index = 0; index < 20; index++) {
      if (find.text('Front 79').evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(
        find.byKey(const ValueKey('deck_import_content')),
        const Offset(0, -600),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Front 79'), findsOneWidget);
    expect(find.text('Back 79'), findsOneWidget);
  });

  testWidgets('DT1 onSelect: text separator selection is passed to preview', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    ImportSourceFormat? capturedFormat;
    ImportStructuredTextSeparator? capturedSeparator;
    String? capturedContent;
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) {
            capturedFormat = format;
            capturedContent = rawContent;
            capturedSeparator = structuredTextSeparator;
            return Future.value(
              const Success(
                FlashcardImportPreparation(
                  format: ImportSourceFormat.structuredText,
                  previewItems: [
                    FlashcardImportPreviewItem(
                      sourceLabel: 'Line 1',
                      draft: FlashcardDraft(front: '개다', back: 'Clear up'),
                    ),
                  ],
                  issues: [],
                ),
              ),
            );
          },
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    expect(find.text('Separator'), findsOneWidget);

    await tester.tap(find.text('Auto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slash'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '개다 / Clear up');
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('deck_import_preview_action')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    expect(capturedFormat, ImportSourceFormat.structuredText);
    expect(capturedSeparator, ImportStructuredTextSeparator.slash);
    expect(capturedContent, '개다 / Clear up');
  });

  testWidgets('DT2 onSelect: Excel header option is passed to preview', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final workbookBytes = Uint8List.fromList(<int>[80, 75, 3, 4]);
    bool? capturedExcelHasHeader;
    Uint8List? capturedSourceBytes;
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required deckId,
            required format,
            required rawContent,
            sourceBytes,
            required excelHasHeader,
            required duplicatePolicy,
            required structuredTextSeparator,
          }) {
            capturedExcelHasHeader = excelHasHeader;
            capturedSourceBytes = sourceBytes;
            return Future.value(
              const Success(
                FlashcardImportPreparation(
                  format: ImportSourceFormat.excel,
                  previewItems: [
                    FlashcardImportPreviewItem(
                      sourceLabel: 'Row 1',
                      draft: FlashcardDraft(front: '개다', back: 'Clear up'),
                    ),
                  ],
                  issues: [],
                ),
              ),
            );
          },
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(DeckImportScreen)),
    );
    container
        .read(flashcardImportDraftProvider(deckId).notifier)
        .setSourceFile(
          sourceBytes: workbookBytes,
          loadedFileName: 'cards.xlsx',
        );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('deck_import_preview_action')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('deck_import_preview_action')));
    await tester.pumpAndSettle();

    expect(capturedExcelHasHeader, isFalse);
    expect(capturedSourceBytes, workbookBytes);
  });
}

const _validPreparation = FlashcardImportPreparation(
  format: ImportSourceFormat.csv,
  previewItems: [
    FlashcardImportPreviewItem(
      sourceLabel: 'Line 2',
      draft: FlashcardDraft(front: 'Xin chao', back: 'Hello'),
    ),
  ],
  issues: [],
);

const _preparationWithIssue = FlashcardImportPreparation(
  format: ImportSourceFormat.csv,
  previewItems: [
    FlashcardImportPreviewItem(
      sourceLabel: 'Line 2',
      draft: FlashcardDraft(front: 'Xin chao', back: 'Hello'),
    ),
  ],
  issues: [ImportValidationIssue(lineNumber: 3, message: 'Back is required.')],
);

const _preparationWithSkippedDuplicates = FlashcardImportPreparation(
  format: ImportSourceFormat.csv,
  previewItems: [
    FlashcardImportPreviewItem(
      sourceLabel: 'Line 2',
      draft: FlashcardDraft(front: 'Hello', back: 'Xin chao'),
    ),
  ],
  issues: [],
  skippedDuplicates: [
    FlashcardImportSkippedDuplicate(
      sourceLabel: 'Line 3',
      draft: FlashcardDraft(front: 'Hello', back: 'Xin chao'),
      source: FlashcardImportDuplicateSource.importFile,
    ),
    FlashcardImportSkippedDuplicate(
      sourceLabel: 'Line 4',
      draft: FlashcardDraft(front: 'Existing', back: 'Deck card'),
      source: FlashcardImportDuplicateSource.deck,
    ),
  ],
);

FlashcardImportPreparation _largePreparation() {
  return FlashcardImportPreparation(
    format: ImportSourceFormat.csv,
    previewItems: List<FlashcardImportPreviewItem>.generate(
      80,
      (index) => FlashcardImportPreviewItem(
        sourceLabel: 'Line ${index + 2}',
        draft: FlashcardDraft(front: 'Front $index', back: 'Back $index'),
      ),
    ),
    issues: const [],
  );
}

final class _ImportOnlyFlashcardRepository implements FlashcardRepository {
  const _ImportOnlyFlashcardRepository({
    this.prepareHandler,
    this.commitHandler,
  });

  final Future<Result<FlashcardImportPreparation>> Function({
    required String deckId,
    required ImportSourceFormat format,
    required String rawContent,
    Uint8List? sourceBytes,
    required bool excelHasHeader,
    required FlashcardImportDuplicatePolicy duplicatePolicy,
    required ImportStructuredTextSeparator structuredTextSeparator,
  })?
  prepareHandler;

  final Future<Result<int>> Function({
    required String deckId,
    required FlashcardImportPreparation preparation,
  })?
  commitHandler;

  @override
  Future<Result<FlashcardImportPreparation>> prepareImport({
    required String deckId,
    required ImportSourceFormat format,
    required String rawContent,
    Uint8List? sourceBytes,
    bool excelHasHeader = true,
    FlashcardImportDuplicatePolicy duplicatePolicy =
        FlashcardImportDuplicatePolicy.skipExactDuplicates,
    ImportStructuredTextSeparator structuredTextSeparator =
        ImportStructuredTextSeparator.auto,
  }) {
    return prepareHandler?.call(
          deckId: deckId,
          format: format,
          rawContent: rawContent,
          sourceBytes: sourceBytes,
          excelHasHeader: excelHasHeader,
          duplicatePolicy: duplicatePolicy,
          structuredTextSeparator: structuredTextSeparator,
        ) ??
        Future.value(const Success(_validPreparation));
  }

  @override
  Future<Result<int>> commitImport({
    required String deckId,
    required FlashcardImportPreparation preparation,
  }) {
    return commitHandler?.call(deckId: deckId, preparation: preparation) ??
        Future.value(const Success(1));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, required this.overrides});

  final Widget child;
  final dynamic overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

ElevatedButton _primaryButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(find.byType(ElevatedButton));
}

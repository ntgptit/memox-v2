import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';

void main() {
  testWidgets('DT1 onOpen: renders import title source tabs and empty editor', (
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
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('Text format'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'CSV content'), findsOneWidget);
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

      await tester.tap(find.text('Text format'));
      await tester.pumpAndSettle();

      expect(find.text('Separator'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    },
  );

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

  testWidgets(
    'DT3 onInsert: disables import controls while preview is running',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final prepareCompleter = Completer<Result<FlashcardImportPreparation>>();
      final repository = _ImportOnlyFlashcardRepository(
        prepareHandler:
            ({
              required format,
              required rawContent,
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

      await tester.enterText(
        find.byType(TextFormField),
        'front,back\nXin chao,Hello',
      );
      await tester.ensureVisible(find.text('Preview'));
      await tester.pump();
      await tester.tap(find.text('Preview'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_allOutlinedButtonsDisabled(tester), isTrue);
      expect(_textButton(tester, 'Clear').onPressed, isNull);
      expect(_primaryButton(tester).onPressed, isNull);

      await tester.ensureVisible(find.text('Text format'));
      await tester.pump();
      await tester.tap(find.text('Text format'), warnIfMissed: false);
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
            required format,
            required rawContent,
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

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nXin chao,Hello',
    );
    await tester.ensureVisible(find.text('Preview'));
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Import'));
    await tester.pump();
    await tester.tap(find.text('Import'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_primaryButton(tester).onPressed, isNull);
    expect(_allOutlinedButtonsDisabled(tester), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('DT5 onInsert: preview summary shows valid and issue counts', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required format,
            required rawContent,
            required structuredTextSeparator,
          }) => Future.value(const Success(_preparationWithIssue)),
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nXin chao,Hello\nMissing back,',
    );
    await tester.ensureVisible(find.text('Preview'));
    await tester.pump();
    await tester.tap(find.text('Preview'));
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
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler:
          ({
            required format,
            required rawContent,
            required structuredTextSeparator,
          }) => Future.value(Success(preparation)),
    );

    await tester.pumpWidget(
      _TestApp(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
        child: const DeckImportScreen(deckId: deckId),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'front,back\nF,B');
    await tester.ensureVisible(find.text('Preview'));
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    final initiallyBuiltRows = find.byType(MxTermRow).evaluate().length;

    expect(find.byType(CustomScrollView), findsOneWidget);
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
            required format,
            required rawContent,
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

    await tester.tap(find.text('Text format'));
    await tester.pumpAndSettle();
    expect(find.text('Separator'), findsOneWidget);

    await tester.tap(find.text('Auto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slash'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '개다 / Clear up');
    await tester.ensureVisible(find.text('Preview'));
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(capturedFormat, ImportSourceFormat.structuredText);
    expect(capturedSeparator, ImportStructuredTextSeparator.slash);
    expect(capturedContent, '개다 / Clear up');
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
    required ImportSourceFormat format,
    required String rawContent,
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
    required ImportSourceFormat format,
    required String rawContent,
    ImportStructuredTextSeparator structuredTextSeparator =
        ImportStructuredTextSeparator.auto,
  }) {
    return prepareHandler?.call(
          format: format,
          rawContent: rawContent,
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

bool _allOutlinedButtonsDisabled(WidgetTester tester) {
  return tester
      .widgetList<OutlinedButton>(find.byType(OutlinedButton))
      .every((button) => button.onPressed == null);
}

ElevatedButton _primaryButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(find.byType(ElevatedButton));
}

TextButton _textButton(WidgetTester tester, String label) {
  return tester.widget<TextButton>(find.widgetWithText(TextButton, label));
}

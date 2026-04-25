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

void main() {
  test('readDeckImportFileContent decodes UTF-8 bytes', () async {
    const content = 'front,back\nXin chào,Tiếng Việt có dấu: ă ê ô ư';
    final file = PlatformFile(
      name: 'cards.csv',
      size: utf8.encode(content).length,
      bytes: Uint8List.fromList(utf8.encode(content)),
    );

    final decoded = await readDeckImportFileContent(file);

    expect(decoded, content);
  });

  test('readDeckImportFileContent returns null when file has no source', () {
    final file = PlatformFile(name: 'missing.csv', size: 0);

    expect(readDeckImportFileContent(file), completion(isNull));
  });

  testWidgets('disables import controls while preview is running', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final prepareCompleter = Completer<Result<FlashcardImportPreparation>>();
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler: ({required format, required rawContent}) =>
          prepareCompleter.future,
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
  });

  testWidgets('shows import loading while commit is running', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final commitCompleter = Completer<Result<int>>();
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler: ({required format, required rawContent}) =>
          Future.value(const Success(_validPreparation)),
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

  testWidgets('preview summary shows valid and issue counts', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final repository = _ImportOnlyFlashcardRepository(
      prepareHandler: ({required format, required rawContent}) =>
          Future.value(const Success(_preparationWithIssue)),
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

final class _ImportOnlyFlashcardRepository implements FlashcardRepository {
  const _ImportOnlyFlashcardRepository({
    this.prepareHandler,
    this.commitHandler,
  });

  final Future<Result<FlashcardImportPreparation>> Function({
    required ImportSourceFormat format,
    required String rawContent,
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
  }) {
    return prepareHandler?.call(format: format, rawContent: rawContent) ??
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

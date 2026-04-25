import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';

void main() {
  testWidgets('DT1 onOpen: opens a new flashcard draft for the deck route', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(child: FlashcardEditorScreen(deckId: 'deck-001')),
    );
    await tester.pumpAndSettle();

    expect(find.text('New flashcard'), findsOneWidget);
    expect(find.text('Save & add next'), findsOneWidget);
    expect(find.text('Save flashcard'), findsOneWidget);
  });

  testWidgets('DT1 onDisplay: renders multiline front back and note fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(child: FlashcardEditorScreen(deckId: 'deck-001')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(
      find.text('Supports multiple lines. Keep the full answer readable during study.'),
      findsNWidgets(2),
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

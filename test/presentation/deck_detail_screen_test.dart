import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/screens/deck_detail_screen.dart';
import 'package:memox/presentation/features/decks/viewmodels/deck_detail_viewmodel.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets(
    'DT1 onOpen: shows layout skeleton instead of full loading state on first load',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          deckDetailQueryProvider(
            deckId,
          ).overrideWith((ref) => Completer<DeckDetailState>().future),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: DeckDetailScreen(deckId: deckId)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('deck_detail_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(MxLoadingState), findsNothing);
    },
  );

  testWidgets('DT1 onDisplay: renders deck title and zero-card metrics', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        deckDetailQueryProvider(deckId).overrideWith(
          (ref) => Future<DeckDetailState>.value(_zeroCardDeckState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: DeckDetailScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Empty deck'), findsWidgets);
    expect(find.text('0 cards · 0 due today · 0% mastery'), findsOneWidget);
    expect(find.text('Manage content'), findsNothing);
    expect(find.text('Study now'), findsNothing);
    expect(find.text('Open flashcards'), findsNothing);
    expect(find.text('Add flashcard'), findsNothing);
    expect(find.text('Import'), findsNothing);
  });

  testWidgets('DT1 onNavigate: header more action still opens deck actions', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        deckDetailQueryProvider(deckId).overrideWith(
          (ref) => Future<DeckDetailState>.value(_zeroCardDeckState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: DeckDetailScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();

    expect(find.text('Deck actions'), findsOneWidget);
    expect(find.text('Duplicate deck'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);
  });
}

const _zeroCardDeckState = DeckDetailState(
  id: 'deck-001',
  folderId: 'folder-001',
  name: 'Empty deck',
  breadcrumb: <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Library', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Empty deck', folderId: null),
  ],
  cardCount: 0,
  dueTodayCount: 0,
  masteryPercent: 0,
  lastStudiedAt: null,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

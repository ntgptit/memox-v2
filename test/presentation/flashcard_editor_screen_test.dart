import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/entities/flashcard_entity.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/usecases/flashcard_usecases.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';

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
      find.text(
        'Supports multiple lines. Keep the full answer readable during study.',
      ),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'DT1 onUpdate: learned content edit asks whether to reset progress',
    (tester) async {
      const deckId = 'deck-001';
      const flashcardId = 'card-001';
      final repository = _EditorFlashcardRepository(
        flashcard: _flashcard(hasLearningProgress: true),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: deckId, flashcardId: flashcardId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Changed front');
      await tester.pump();
      await tester.tap(find.widgetWithText(MxPrimaryButton, 'Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('You changed the learning content.'), findsOneWidget);
      expect(
        find.text('Keep existing progress or reset this card?'),
        findsOneWidget,
      );
      expect(find.text('Keep progress'), findsOneWidget);
      expect(find.text('Reset progress'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(MxSecondaryButton, 'Reset progress'),
      );
      await tester.pumpAndSettle();

      expect(
        repository.lastProgressPolicy,
        FlashcardProgressEditPolicy.resetProgress,
      );
      expect(repository.lastDraft?.front, 'Changed front');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/$deckId/flashcards',
      );
    },
  );

  testWidgets(
    'DT2 onUpdate: learned note-only edit keeps progress without policy dialog',
    (tester) async {
      const deckId = 'deck-001';
      const flashcardId = 'card-001';
      final repository = _EditorFlashcardRepository(
        flashcard: _flashcard(hasLearningProgress: true),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: deckId, flashcardId: flashcardId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(2), 'Updated note');
      await tester.pump();
      await tester.tap(find.widgetWithText(MxPrimaryButton, 'Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('You changed the learning content.'), findsNothing);
      expect(
        repository.lastProgressPolicy,
        FlashcardProgressEditPolicy.keepProgress,
      );
      expect(repository.lastDraft?.note, 'Updated note');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/$deckId/flashcards',
      );
    },
  );
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

ProviderContainer _editorContainer(_EditorFlashcardRepository repository) {
  return ProviderContainer(
    overrides: [
      getFlashcardUseCaseProvider.overrideWithValue(
        GetFlashcardUseCase(repository),
      ),
      updateFlashcardUseCaseProvider.overrideWithValue(
        UpdateFlashcardUseCase(repository),
      ),
    ],
  );
}

GoRouter _editorRouter({required String deckId, required String flashcardId}) {
  return GoRouter(
    initialLocation: '/deck/$deckId/flashcards/$flashcardId/edit',
    routes: [
      GoRoute(
        path: '/${RoutePaths.flashcardEditSegment}',
        name: RouteNames.flashcardEdit,
        builder: (context, state) => FlashcardEditorScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam]!,
          flashcardId: state.pathParameters[RoutePaths.flashcardIdParam]!,
        ),
      ),
      GoRoute(
        path: '/${RoutePaths.flashcardListSegment}',
        name: RouteNames.flashcardList,
        builder: (context, state) =>
            const SizedBox(key: ValueKey('flashcard_list_destination')),
      ),
    ],
  );
}

FlashcardEntity _flashcard({required bool hasLearningProgress}) {
  return FlashcardEntity(
    id: 'card-001',
    deckId: 'deck-001',
    front: 'Original front',
    back: 'Original back',
    note: 'Original note',
    sortOrder: 0,
    createdAt: 1,
    updatedAt: 1,
    hasLearningProgress: hasLearningProgress,
  );
}

final class _EditorFlashcardRepository implements FlashcardRepository {
  _EditorFlashcardRepository({required FlashcardEntity flashcard})
    : _flashcard = flashcard;

  FlashcardEntity _flashcard;
  FlashcardDraft? lastDraft;
  FlashcardProgressEditPolicy? lastProgressPolicy;

  @override
  Future<FlashcardEntity> getFlashcard(String flashcardId) async {
    return _flashcard;
  }

  @override
  Future<Result<FlashcardEntity>> updateFlashcard({
    required String flashcardId,
    required FlashcardDraft draft,
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) async {
    lastDraft = draft;
    lastProgressPolicy = progressPolicy;
    _flashcard = FlashcardEntity(
      id: _flashcard.id,
      deckId: _flashcard.deckId,
      front: draft.front,
      back: draft.back,
      note: draft.note,
      sortOrder: _flashcard.sortOrder,
      createdAt: _flashcard.createdAt,
      updatedAt: _flashcard.updatedAt + 1,
      hasLearningProgress:
          progressPolicy == FlashcardProgressEditPolicy.keepProgress &&
          _flashcard.hasLearningProgress,
    );
    return Success(_flashcard);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

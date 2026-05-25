import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/content/deck_providers.dart';
import 'package:memox/app/di/content/flashcard_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/entities/deck_entity.dart';
import 'package:memox/domain/entities/flashcard_entity.dart';
import 'package:memox/domain/repositories/deck_repository.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/usecases/content_query_usecases.dart';
import 'package:memox/domain/usecases/flashcard_usecases.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';

void main() {
  testWidgets('DT1 onOpen: opens a new card draft for the deck route', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCreateApp());
    await tester.pumpAndSettle();

    expect(find.text('New card'), findsWidgets);
    expect(find.text('Save & add another'), findsOneWidget);
    expect(find.text('Save card'), findsOneWidget);
  });

  testWidgets(
    'DT1 onDisplay: renders front back example tags fields + advanced toggle',
    (tester) async {
      await tester.pumpWidget(_buildCreateApp());
      await tester.pumpAndSettle();

      // Front, Back, Example = 3 visible TextFormFields. Tags use a bottom-
      // sheet trigger instead of an inline field.
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Add tag'), findsOneWidget);
      expect(find.text('Show advanced fields'), findsOneWidget);
    },
  );

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
      expect(find.text('Keep'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.widgetWithText(MxSecondaryButton, 'Reset'));
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

      // Note field lives inside the "Show advanced fields" section and would
      // require scrolling + advanced-toggle interaction in the rendered form.
      // For this Decision-Table test we only care that a learned note-only
      // edit skips the policy dialog, so we drive the draft notifier directly
      // through the provider container.
      container
          .read(
            flashcardEditorDraftProvider(
              const FlashcardEditorArgs(
                deckId: deckId,
                flashcardId: flashcardId,
              ),
            ).notifier,
          )
          .setNote('Updated note');
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

Widget _buildCreateApp() {
  final container = _editorContainer(
    _EditorFlashcardRepository(
      flashcard: _flashcard(hasLearningProgress: false),
    ),
  );
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FlashcardEditorScreen(deckId: 'deck-001'),
    ),
  );
}

ProviderContainer _editorContainer(_EditorFlashcardRepository repository) =>
    ProviderContainer(
      overrides: [
        getFlashcardUseCaseProvider.overrideWithValue(
          GetFlashcardUseCase(repository),
        ),
        updateFlashcardUseCaseProvider.overrideWithValue(
          UpdateFlashcardUseCase(repository),
        ),
        createFlashcardUseCaseProvider.overrideWithValue(
          CreateFlashcardUseCase(repository),
        ),
        getDeckActionContextUseCaseProvider.overrideWithValue(
          GetDeckActionContextUseCase(_StubDeckRepository()),
        ),
      ],
    );

GoRouter _editorRouter({required String deckId, required String flashcardId}) =>
    GoRouter(
      initialLocation: '/deck/$deckId/flashcards/$flashcardId/edit',
      routes: [
        GoRoute(
          path: '/${RoutePaths.flashcardEditSegment}',
          name: RouteNames.flashcardEdit,
          builder: (context, state) => FlashcardEditorScreen(
            deckId: state.pathParameters[RoutePaths.deckIdParam]!,
            flashcardId: state.pathParameters[RoutePaths.flashcardIdParam],
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

FlashcardEntity _flashcard({required bool hasLearningProgress}) =>
    FlashcardEntity(
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

final class _EditorFlashcardRepository implements FlashcardRepository {
  _EditorFlashcardRepository({required FlashcardEntity flashcard})
    : _flashcard = flashcard;

  FlashcardEntity _flashcard;
  FlashcardDraft? lastDraft;
  FlashcardProgressEditPolicy? lastProgressPolicy;

  @override
  Future<FlashcardEntity> getFlashcard(String flashcardId) async => _flashcard;

  @override
  Future<Result<FlashcardEntity>> createFlashcard({
    required String deckId,
    required FlashcardDraft draft,
  }) async {
    lastDraft = draft;
    return Success(
      FlashcardEntity(
        id: 'new-card',
        deckId: deckId,
        front: draft.front,
        back: draft.back,
        note: draft.note,
        sortOrder: 0,
        createdAt: 1,
        updatedAt: 1,
      ),
    );
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

final class _StubDeckRepository implements DeckRepository {
  @override
  Future<DeckActionContextReadModel> getDeckActionContext(
    String deckId,
  ) async => DeckActionContextReadModel(
    deck: DeckEntity(
      id: deckId,
      folderId: 'folder-001',
      name: 'Sample deck',
      sortOrder: 0,
      createdAt: 1,
      updatedAt: 1,
    ),
    breadcrumb: const <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Sample folder'),
      BreadcrumbSegmentReadModel(label: 'Sample deck'),
    ],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

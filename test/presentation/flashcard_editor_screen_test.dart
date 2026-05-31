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
import 'package:memox/domain/usecases/deck_usecases.dart';
import 'package:memox/domain/usecases/flashcard_usecases.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/mx_deck_pill.dart';
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

  testWidgets('DT2 onInsert: empty front keeps create save actions disabled', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCreateApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Back only');
    await tester.pump();

    final saveAndAdd = tester.widget<MxSecondaryButton>(
      find.widgetWithText(MxSecondaryButton, 'Save & add another'),
    );
    final save = tester.widget<MxPrimaryButton>(
      find.widgetWithText(MxPrimaryButton, 'Save card'),
    );

    expect(saveAndAdd.onPressed, isNull);
    expect(save.onPressed, isNull);
  });

  testWidgets('DT3 onInsert: empty back keeps create save actions disabled', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCreateApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Front only');
    await tester.pump();

    final saveAndAdd = tester.widget<MxSecondaryButton>(
      find.widgetWithText(MxSecondaryButton, 'Save & add another'),
    );
    final save = tester.widget<MxPrimaryButton>(
      find.widgetWithText(MxPrimaryButton, 'Save card'),
    );

    expect(saveAndAdd.onPressed, isNull);
    expect(save.onPressed, isNull);
  });

  testWidgets(
    'C9 onNavigate: create close with blank form leaves without dialog',
    (tester) async {
      const deckId = 'deck-001';
      final repository = _EditorFlashcardRepository(
        flashcard: _flashcard(hasLearningProgress: false),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: deckId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(_routedEditorApp(container, router));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/$deckId/flashcards',
      );
    },
  );

  testWidgets(
    'C10 onNavigate: create close with typed front shows discard dialog',
    (tester) async {
      const deckId = 'deck-001';
      final repository = _EditorFlashcardRepository(
        flashcard: _flashcard(hasLearningProgress: false),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: deckId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(_routedEditorApp(container, router));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Draft front');
      await tester.pump();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(
        find.text('Your unsaved flashcard changes will be lost.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('C11 onNavigate: cancelling discard keeps typed create input', (
    tester,
  ) async {
    const deckId = 'deck-001';
    final repository = _EditorFlashcardRepository(
      flashcard: _flashcard(hasLearningProgress: false),
    );
    final container = _editorContainer(repository);
    final router = _editorRouter(deckId: deckId);
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routedEditorApp(container, router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Draft front');
    await tester.pump();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxSecondaryButton, 'Keep editing'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Draft front'), findsOneWidget);
    expect(find.byType(FlashcardEditorScreen), findsOneWidget);
  });

  testWidgets('C12 onNavigate: confirming discard leaves dirty create editor', (
    tester,
  ) async {
    const deckId = 'deck-001';
    final repository = _EditorFlashcardRepository(
      flashcard: _flashcard(hasLearningProgress: false),
    );
    final container = _editorContainer(repository);
    final router = _editorRouter(deckId: deckId);
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routedEditorApp(container, router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Draft front');
    await tester.pump();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxPrimaryButton, 'Discard'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/deck/$deckId/flashcards',
    );
  });

  testWidgets(
    'DT1 onOpen: edit route uses shared editor without live Future actions',
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

      expect(find.byType(FlashcardEditorScreen), findsOneWidget);
      expect(find.text('Edit card'), findsWidgets);
      expect(find.text('Original front'), findsOneWidget);
      expect(find.text('Original back'), findsOneWidget);
      expect(find.textContaining('history'), findsNothing);
      expect(find.textContaining('History'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(find.textContaining('Suspend'), findsNothing);
      expect(find.text('Save & add another'), findsNothing);
    },
  );

  testWidgets(
    'C13 onNavigate: edit close without changes leaves without dialog',
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

      await tester.pumpWidget(_routedEditorApp(container, router));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/$deckId/flashcards',
      );
    },
  );

  testWidgets('C14 onNavigate: edit close after changing front asks discard', (
    tester,
  ) async {
    const deckId = 'deck-001';
    const flashcardId = 'card-001';
    final repository = _EditorFlashcardRepository(
      flashcard: _flashcard(hasLearningProgress: true),
    );
    final container = _editorContainer(repository);
    final router = _editorRouter(deckId: deckId, flashcardId: flashcardId);
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routedEditorApp(container, router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Changed front');
    await tester.pump();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('C15 onNavigate: edit close after changing note asks discard', (
    tester,
  ) async {
    const deckId = 'deck-001';
    const flashcardId = 'card-001';
    final repository = _EditorFlashcardRepository(
      flashcard: _flashcard(hasLearningProgress: true),
    );
    final container = _editorContainer(repository);
    final router = _editorRouter(deckId: deckId, flashcardId: flashcardId);
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routedEditorApp(container, router));
    await tester.pumpAndSettle();

    final advancedToggle = find.widgetWithText(
      MxSecondaryButton,
      'Show advanced fields',
    );
    await tester.ensureVisible(advancedToggle);
    await tester.pumpAndSettle();
    await tester.tap(advancedToggle);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextFormField).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Changed note');
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('C16 onNavigate: edit close after changing tag asks discard', (
    tester,
  ) async {
    const deckId = 'deck-001';
    const flashcardId = 'card-001';
    final repository = _EditorFlashcardRepository(
      flashcard: _flashcard(hasLearningProgress: true),
    );
    final container = _editorContainer(repository);
    final router = _editorRouter(deckId: deckId, flashcardId: flashcardId);
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routedEditorApp(container, router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'noun');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets(
    'C17 onNavigate: edit loaded with note and tags closes clean until changed',
    (tester) async {
      const deckId = 'deck-001';
      const flashcardId = 'card-001';
      final repository = _EditorFlashcardRepository(
        flashcard: const FlashcardEntity(
          id: flashcardId,
          deckId: deckId,
          front: 'Front',
          back: 'Back',
          note: 'Existing note',
          sortOrder: 0,
          createdAt: 1,
          updatedAt: 1,
          tags: <String>['verb'],
        ),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: deckId, flashcardId: flashcardId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(_routedEditorApp(container, router));
      await tester.pumpAndSettle();

      expect(find.text('verb'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/$deckId/flashcards',
      );
    },
  );

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

  testWidgets('attaches a newly created tag (normalized) to the draft', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCreateApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Verb');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Stored lowercased per tag-system.md.
    expect(find.text('verb'), findsOneWidget);
  });

  testWidgets('rejects a tag containing a comma with an inline error', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCreateApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'a,b');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Inline error shown; the sheet stays open and no chip is committed.
    expect(find.text('Tags cannot contain commas.'), findsOneWidget);
  });

  testWidgets('keeps existing tags and attaches new ones in edit mode', (
    tester,
  ) async {
    const deckId = 'deck-001';
    const flashcardId = 'card-001';
    final repository = _EditorFlashcardRepository(
      flashcard: const FlashcardEntity(
        id: flashcardId,
        deckId: deckId,
        front: 'Front',
        back: 'Back',
        note: null,
        sortOrder: 0,
        createdAt: 1,
        updatedAt: 1,
        tags: <String>['verb'],
      ),
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

    // Existing tag rendered as a chip.
    expect(find.text('verb'), findsOneWidget);

    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'noun');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('noun'), findsOneWidget);
    expect(find.text('verb'), findsOneWidget);
  });

  testWidgets(
    'C18 onInsert: create save after changing destination opens selected deck list',
    (tester) async {
      const routeDeckId = 'deck-001';
      const selectedDeckId = 'deck-002';
      final repository = _EditorFlashcardRepository(
        flashcard: _flashcard(hasLearningProgress: false),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: routeDeckId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(_routedEditorApp(container, router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MxDeckPill));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other deck'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Front');
      await tester.enterText(find.byType(TextFormField).at(1), 'Back');
      await tester.pump();
      await tester.tap(find.widgetWithText(MxPrimaryButton, 'Save card'));
      await tester.pumpAndSettle();

      expect(repository.lastCreatedDeckId, selectedDeckId);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/$selectedDeckId/flashcards',
      );
    },
  );

  testWidgets(
    'C19 onInsert: save and add another stays clean in selected destination',
    (tester) async {
      const routeDeckId = 'deck-001';
      final repository = _EditorFlashcardRepository(
        flashcard: _flashcard(hasLearningProgress: false),
      );
      final container = _editorContainer(repository);
      final router = _editorRouter(deckId: routeDeckId);
      addTearDown(container.dispose);
      addTearDown(router.dispose);

      await tester.pumpWidget(_routedEditorApp(container, router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MxDeckPill));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other deck'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Front');
      await tester.enterText(find.byType(TextFormField).at(1), 'Back');
      await tester.pump();
      await tester.tap(
        find.widgetWithText(MxSecondaryButton, 'Save & add another'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlashcardEditorScreen), findsOneWidget);
      expect(find.text('Other deck'), findsOneWidget);
      expect(find.text('Front'), findsNothing);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/deck/deck-002/flashcards',
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
        listDeckDestinationsUseCaseProvider.overrideWithValue(
          ListDeckDestinationsUseCase(_StubDeckRepository()),
        ),
      ],
    );

Widget _routedEditorApp(ProviderContainer container, GoRouter router) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

GoRouter _editorRouter({required String deckId, String? flashcardId}) =>
    GoRouter(
      initialLocation: flashcardId == null
          ? '/deck/$deckId/flashcards/new'
          : '/deck/$deckId/flashcards/$flashcardId/edit',
      routes: [
        GoRoute(
          path: '/${RoutePaths.flashcardCreateSegment}',
          name: RouteNames.flashcardCreate,
          builder: (context, state) => FlashcardEditorScreen(
            deckId: state.pathParameters[RoutePaths.deckIdParam]!,
          ),
        ),
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
  String? lastCreatedDeckId;
  FlashcardProgressEditPolicy? lastProgressPolicy;

  @override
  Future<FlashcardEntity> getFlashcard(String flashcardId) async => _flashcard;

  @override
  Future<Result<FlashcardEntity>> createFlashcard({
    required String deckId,
    required FlashcardDraft draft,
  }) async {
    lastCreatedDeckId = deckId;
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
      name: deckId == 'deck-002' ? 'Other deck' : 'Sample deck',
      sortOrder: 0,
      createdAt: 1,
      updatedAt: 1,
    ),
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(
        label: deckId == 'deck-002' ? 'Other folder' : 'Sample folder',
      ),
      BreadcrumbSegmentReadModel(
        label: deckId == 'deck-002' ? 'Other deck' : 'Sample deck',
      ),
    ],
  );

  @override
  Future<List<DeckMoveTarget>> getDeckDestinations() async =>
      const <DeckMoveTarget>[
        DeckMoveTarget(
          id: 'deck-001',
          name: 'Sample deck',
          breadcrumb: <String>['Sample folder', 'Sample deck'],
        ),
        DeckMoveTarget(
          id: 'deck-002',
          name: 'Other deck',
          breadcrumb: <String>['Other folder', 'Other deck'],
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/content/flashcard_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/core/theme/tokens/app_icon_sizes.dart';
import 'package:memox/domain/entities/flashcard_entity.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/usecases/flashcard_usecases.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_queries.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_deck_summary_section.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_detail_card_row.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_study_modes_section.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_toolbar_section.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_progress_ring.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';

void main() {
  testWidgets(
    'DT1 onOpen: shows layout skeleton instead of full loading state on first load',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(
            deckId,
          ).overrideWith((ref) => Completer<FlashcardListState>().future),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('flashcard_list_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(MxLoadingState), findsNothing);
    },
  );

  testWidgets('DT1 onDisplay: renders flashcard rows for loaded deck data', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToText(tester, 'Korean deck');
    expect(find.text('Korean deck'), findsWidgets);
    await _scrollToText(tester, 'Cards');
    expect(find.text('Cards'), findsOneWidget);
    await _scrollToRowText(tester, 'Front 1');
    expect(find.text('Front 1'), findsWidgets);
    expect(find.text('Back 1'), findsOneWidget);
    expect(find.text('Front 2'), findsWidgets);
    await _scrollToText(tester, 'YOUR PROGRESS');
    expect(find.text('YOUR PROGRESS'), findsOneWidget);
    await _scrollToText(tester, 'STUDY FLOW');
    expect(find.text('STUDY FLOW'), findsOneWidget);
  });

  testWidgets(
    'DT3 onDisplay: lazily builds long flashcard lists as they scroll',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      const deckId = 'deck-001';
      final state = _largeFlashcardState();
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(
            deckId,
          ).overrideWith((ref) => Future<FlashcardListState>.value(state)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('flashcard_lazy_items')),
        400,
        scrollable: _verticalScrollable(),
      );
      await tester.pumpAndSettle();

      final initiallyBuiltRows = find
          .byType(FlashcardDetailCardRow)
          .evaluate()
          .length;

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(
        find.byKey(const ValueKey('flashcard_lazy_items')),
        findsOneWidget,
      );
      expect(initiallyBuiltRows, lessThan(state.items.length));
      expect(find.text('Front 79'), findsNothing);

      for (var index = 0; index < 20; index++) {
        if (find.text('Front 79').evaluate().isNotEmpty) {
          break;
        }
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('Front 79'), findsOneWidget);
      expect(find.text('Back 79'), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onDisplay: empty deck disables study and keeps creation entry points',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_emptyFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollToText(tester, 'STUDY FLOW');
      expect(find.byTooltip('Import'), findsOneWidget);
      expect(find.byKey(const ValueKey('study_mode_mix')), findsNothing);

      await _scrollToText(tester, 'No flashcards yet');
      expect(find.text('No flashcards yet'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      await _scrollToText(tester, 'STUDY FLOW');
      final disabledTiles = tester
          .widgetList<MxCard>(_studyModeTiles())
          .toList();
      expect(disabledTiles, hasLength(5));
      expect(
        find.descendant(
          of: _studyModeSection(),
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'DT4 onDisplay: compact layout renders study, progress, and toolbar sections',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollToText(tester, 'STUDY FLOW');
      await _scrollToText(tester, 'Cards');
      expect(find.byTooltip('Import'), findsOneWidget);
      expect(find.byTooltip('Reorder'), findsOneWidget);
      await _scrollToText(tester, 'Cards');
      expect(find.text('Cards'), findsOneWidget);
      await _scrollToText(tester, 'YOUR PROGRESS');
      expect(find.text('YOUR PROGRESS'), findsOneWidget);
      expect(
        find.text("Progress is derived from this deck's SRS state."),
        findsNothing,
      );
      await _scrollToText(tester, 'STUDY FLOW');
      expect(find.text('STUDY FLOW'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'DT6 onDisplay: keeps quick study action and toolbar above preview on compact layout',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollToText(tester, 'STUDY FLOW');
      final studyModes = find.byType(FlashcardStudyModesSection);
      await _scrollToText(tester, 'Cards');
      final toolbar = find.byType(FlashcardToolbarSection);

      expect(studyModes, findsOneWidget);
      expect(toolbar, findsOneWidget);
      expect(
        tester.getTopLeft(studyModes).dy,
        lessThan(tester.getTopLeft(toolbar).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'DT7 onDisplay: renders deck metadata row and visual progress bar',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      final summary = find.byType(FlashcardDeckSummarySection);

      expect(
        find.descendant(of: summary, matching: find.byType(MxProgressRing)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summary,
          matching: find.textContaining('0 of 2 cards mastered'),
        ),
        findsOneWidget,
      );

      await _scrollToText(tester, 'YOUR PROGRESS');
      expect(find.text('Mastered'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
    },
  );

  testWidgets(
    'DT8 onDisplay: renders enabled study mode tiles in mockup order',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollToText(tester, 'STUDY FLOW');

      final tiles = tester.widgetList<MxCard>(_studyModeTiles()).toList();
      final section = _studyModeSection();

      expect(tiles, hasLength(5));
      expect(
        find.descendant(
          of: section,
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsNothing,
      );
      expect(
        tester
            .getTopLeft(
              find.descendant(of: section, matching: find.text('Review')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.descendant(of: section, matching: find.text('Guess')),
              )
              .dy,
        ),
      );
      expect(
        find.descendant(of: section, matching: find.text('Guess')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('Recall')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('Fill')),
        findsOneWidget,
      );
    },
  );

  testWidgets('DT5 onDisplay: flashcard card uses template top action row', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToRowText(tester, 'Front 1');

    final row = _rowForText('Front 1');
    final speakerIcon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.volume_up_outlined),
    );
    final starIcon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.star_border_rounded),
    );
    final oldSelectIcon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.radio_button_unchecked_rounded),
    );
    final frontText = find.descendant(of: row, matching: find.text('Front 1'));
    final backText = find.descendant(of: row, matching: find.text('Back 1'));
    final frontTop = tester.getTopLeft(frontText).dy;
    final speakerTop = tester.getTopLeft(speakerIcon).dy;
    final starTop = tester.getTopLeft(starIcon).dy;

    expect(speakerIcon, findsOneWidget);
    expect(starIcon, findsOneWidget);
    expect(oldSelectIcon, findsNothing);
    expect((speakerTop - frontTop).abs(), lessThanOrEqualTo(6));
    expect((starTop - frontTop).abs(), lessThanOrEqualTo(6));
    expect(speakerTop, lessThan(tester.getTopLeft(backText).dy));
    expect(
      tester.getTopLeft(starIcon).dx,
      greaterThanOrEqualTo(
        tester.getTopLeft(speakerIcon).dx + AppIconSizes.xl + MxSpace.xs,
      ),
    );
  });

  testWidgets('DT1 onNavigate: starts deck study from flashcard management', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/library/deck/$deckId/flashcards',
      routes: [
        GoRoute(
          path: '/library',
          builder: (context, state) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: RoutePaths.flashcardListSegment,
              name: RouteNames.flashcardList,
              builder: (context, state) => FlashcardListScreen(
                deckId: state.pathParameters[RoutePaths.deckIdParam]!,
              ),
            ),
            GoRoute(
              path: RoutePaths.studyEntrySegment,
              name: RouteNames.studyEntry,
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
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

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('study_mode_Review')),
      300,
      scrollable: _verticalScrollable(),
    );
    await tester.tap(find.byKey(const ValueKey('study_mode_Review')));
    await _pumpUntilPath(tester, router, '/library/study/deck/$deckId');

    expect(
      router.routeInformationProvider.value.uri.path,
      '/library/study/deck/$deckId',
    );
  });

  testWidgets(
    'DT4 onNavigate: starts deck study from the study-flow Mix card',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/library/deck/$deckId/flashcards',
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const SizedBox.shrink(),
            routes: [
              GoRoute(
                path: RoutePaths.flashcardListSegment,
                name: RouteNames.flashcardList,
                builder: (context, state) => FlashcardListScreen(
                  deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                ),
              ),
              GoRoute(
                path: RoutePaths.studyEntrySegment,
                name: RouteNames.studyEntry,
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      );
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

      final mixCard = find.byKey(const ValueKey('study_mode_mix'));
      await tester.scrollUntilVisible(
        mixCard,
        300,
        scrollable: _verticalScrollable(),
      );
      await tester.tap(mixCard);
      await _pumpUntilPath(tester, router, '/library/study/deck/$deckId');

      expect(
        router.routeInformationProvider.value.uri.path,
        '/library/study/deck/$deckId',
      );
    },
  );

  testWidgets(
    'DT2 onNavigate: header more opens deck actions from flashcard management',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();

      expect(find.text('Deck actions'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Import flashcards'), findsOneWidget);
      expect(find.text('Export deck'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    },
  );

  testWidgets('DT3 onNavigate: deck action import opens deck import route', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/library/deck/$deckId/flashcards',
      routes: [
        GoRoute(
          path: '/library',
          builder: (context, state) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: RoutePaths.flashcardListSegment,
              name: RouteNames.flashcardList,
              builder: (context, state) => FlashcardListScreen(
                deckId: state.pathParameters[RoutePaths.deckIdParam]!,
              ),
            ),
            GoRoute(
              path: RoutePaths.deckImportSegment,
              name: RouteNames.deckImport,
              builder: (context, state) => SizedBox(
                key: ValueKey(
                  'deck_import_${state.pathParameters[RoutePaths.deckIdParam]}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
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

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    final importAction = find.ancestor(
      of: find.text('Import flashcards'),
      matching: find.byType(InkWell),
    );
    expect(importAction, findsOneWidget);
    await tester.tap(importAction);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('deck_import_$deckId')), findsOneWidget);
  });

  testWidgets('DT1 onDelete: long pressing a flashcard opens row actions', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToRowText(tester, 'Front 1');
    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();

    expect(find.text('Flashcard actions'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Move'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('DT1 onSelect: flashcard select action enables bulk mode', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToRowText(tester, 'Front 1');
    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);

    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsNothing);
    expect(find.text('Flashcard actions'), findsNothing);
  });

  testWidgets('DT2 onSelect: card star action enables bulk mode', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToRowText(tester, 'Front 1');
    await tester.tap(_rowIcon('Front 1', Icons.star_border_rounded));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(_rowIcon('Front 1', Icons.star_rounded), findsOneWidget);
  });

  testWidgets('DT3 onSelect: flashcard row shows front and back together', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToRowText(tester, 'Front 1');

    final row = _rowForText('Front 1');
    expect(
      find.descendant(of: row, matching: find.text('Front 1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: row, matching: find.text('Back 1')),
      findsOneWidget,
    );
  });

  testWidgets('DT1 onMove: move destination picker states progress is kept', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
        getFlashcardMoveTargetsUseCaseProvider.overrideWithValue(
          const GetFlashcardMoveTargetsUseCase(
            _MoveTargetsFlashcardRepository([
              DeckMoveTarget(
                id: 'deck-target-001',
                name: 'Target deck',
                breadcrumb: <String>['Korean', 'Target deck'],
              ),
            ]),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToRowText(tester, 'Front 1');
    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    final moveButton = find.widgetWithText(MxSecondaryButton, 'Move');
    await tester.ensureVisible(moveButton);
    await tester.pumpAndSettle();
    await tester.tap(moveButton);
    await tester.pumpAndSettle();

    expect(find.text('Move flashcards'), findsOneWidget);
    expect(
      find.text('Learning progress will be kept after moving.'),
      findsOneWidget,
    );
    expect(find.text('Target deck'), findsOneWidget);
  });

  testWidgets(
    'DT1 onUpdate: flashcard edit action keeps direct editor navigation',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/library/deck/$deckId/flashcards',
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const SizedBox.shrink(),
            routes: [
              GoRoute(
                path: RoutePaths.flashcardListSegment,
                name: RouteNames.flashcardList,
                builder: (context, state) => FlashcardListScreen(
                  deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                ),
              ),
              GoRoute(
                path: RoutePaths.flashcardEditSegment,
                name: RouteNames.flashcardEdit,
                builder: (context, state) =>
                    const SizedBox(key: ValueKey('flashcard_edit_destination')),
              ),
            ],
          ),
        ],
      );
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

      await _scrollToRowText(tester, 'Front 1');
      await tester.longPress(_rowText('Front 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('flashcard_edit_destination')),
        findsOneWidget,
      );
    },
  );
}

final _sampleFlashcardState = FlashcardListState(
  deckId: 'deck-001',
  folderId: 'folder-001',
  deckName: 'Korean deck',
  breadcrumb: const <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  progress: const FlashcardDeckProgressState(
    newCount: 1,
    learningCount: 1,
    masteredCount: 0,
    masteryPercent: 7,
  ),
  items: const <FlashcardListItemState>[
    FlashcardListItemState(
      id: 'card-001',
      front: 'Front 1',
      back: 'Back 1',
      note: null,
      lastStudiedAt: null,
    ),
    FlashcardListItemState(
      id: 'card-002',
      front: 'Front 2',
      back: 'Back 2',
      note: null,
      lastStudiedAt: null,
    ),
  ],
);

final _emptyFlashcardState = FlashcardListState(
  deckId: 'deck-001',
  folderId: 'folder-001',
  deckName: 'Korean deck',
  breadcrumb: const <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  progress: const FlashcardDeckProgressState(
    newCount: 0,
    learningCount: 0,
    masteredCount: 0,
    masteryPercent: 0,
  ),
  items: const <FlashcardListItemState>[],
);

FlashcardListState _largeFlashcardState() => FlashcardListState(
  deckId: 'deck-001',
  folderId: 'folder-001',
  deckName: 'Korean deck',
  breadcrumb: const <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  progress: const FlashcardDeckProgressState(
    newCount: 80,
    learningCount: 0,
    masteredCount: 0,
    masteryPercent: 0,
  ),
  items: List<FlashcardListItemState>.generate(
    80,
    (index) => FlashcardListItemState(
      id: 'card-$index',
      front: 'Front $index',
      back: 'Back $index',
      note: null,
      lastStudiedAt: null,
    ),
  ),
);

Finder _rowText(String text) => find.descendant(
  of: find.byType(FlashcardDetailCardRow),
  matching: find.text(text),
);

Finder _rowForText(String text) => find
    .ancestor(of: _rowText(text), matching: find.byType(FlashcardDetailCardRow))
    .first;

Finder _rowIcon(String rowText, IconData icon) =>
    find.descendant(of: _rowForText(rowText), matching: find.byIcon(icon));

Finder _studyModeSection() => find.byType(FlashcardStudyModesSection);

Finder _studyModeTiles() => find.descendant(
  of: _studyModeSection(),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is MxCard &&
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('study_mode_'),
  ),
);

Finder _verticalScrollable() => find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

Future<void> _pumpUntilPath(
  WidgetTester tester,
  GoRouter router,
  String expectedPath,
) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (router.routeInformationProvider.value.uri.path == expectedPath) {
      return;
    }
  }
  fail(
    'Timed out waiting for path $expectedPath; '
    'actual=${router.routeInformationProvider.value.uri.path}',
  );
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await _scrollUntilAny(tester, find.text(text));
}

Future<void> _scrollToRowText(WidgetTester tester, String text) async {
  await _scrollUntilAny(tester, _rowText(text));
}

Future<void> _scrollUntilAny(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 24; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(_verticalScrollable(), const Offset(0, -300));
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(finder, findsWidgets);
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

final class _MoveTargetsFlashcardRepository implements FlashcardRepository {
  const _MoveTargetsFlashcardRepository(this.targets);

  final List<DeckMoveTarget> targets;

  @override
  Future<List<DeckMoveTarget>> getFlashcardMoveTargets({
    required String deckId,
    required List<String> flashcardIds,
  }) async => targets;

  @override
  Future<FlashcardEntity> getFlashcard(String flashcardId) {
    throw UnimplementedError();
  }

  @override
  Future<FlashcardListReadModel> getFlashcards(
    String deckId,
    ContentQuery query,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FlashcardEntity>> createFlashcard({
    required String deckId,
    required FlashcardDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FlashcardEntity>> updateFlashcard({
    required String flashcardId,
    required FlashcardDraft draft,
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFlashcards(List<String> flashcardIds) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedFlashcardIds,
  }) {
    throw UnimplementedError();
  }

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
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> commitImport({
    required String deckId,
    required FlashcardImportPreparation preparation,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ExportData>> exportFlashcards(
    List<String> flashcardIds, {
    required ExportFormat format,
  }) {
    throw UnimplementedError();
  }
}

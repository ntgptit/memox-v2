import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/study/usecases/deck_study_entry_usecase.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/deck_study_entry_provider.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/progress/providers/progress_session_notifier.dart';
import 'package:memox/presentation/shared/providers/study_revision_providers.dart';

// P47 — Resume Discard shared flow for the Flashcard List deck resume banner.
// Split out of flashcard_list_screen_test.dart to keep each file under the
// guard's test-file line budget; banner display/navigation lives there.
void main() {
  group('P47 deck resume discard', () {
    testWidgets('onDisplay: paused deck session shows Resume + Discard', (
      WidgetTester tester,
    ) async {
      await _pumpDeckDiscard(tester);

      expect(find.byKey(const ValueKey('deck_resume_action')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('deck_resume_discard_action')),
        findsOneWidget,
      );
    });

    testWidgets('onDiscard: tapping Discard shows the confirmation dialog', (
      WidgetTester tester,
    ) async {
      await _pumpDeckDiscard(tester);

      await tester.tap(
        find.byKey(const ValueKey('deck_resume_discard_action')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discard this session?'), findsOneWidget);
    });

    testWidgets('onDiscard: cancelling keeps the session and banner', (
      WidgetTester tester,
    ) async {
      final controller = _StubProgressSessionActionController();
      await _pumpDeckDiscard(tester, controller: controller);

      await tester.tap(
        find.byKey(const ValueKey('deck_resume_discard_action')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(controller.cancelledSessionId, isNull);
      expect(find.byKey(const ValueKey('deck_resume_banner')), findsOneWidget);
    });

    testWidgets(
      'onDiscard: confirming cancels the session and removes the banner '
      'without creating a new session',
      (WidgetTester tester) async {
        final controller = _StubProgressSessionActionController();
        await _pumpDeckDiscard(tester, controller: controller);

        await tester.tap(
          find.byKey(const ValueKey('deck_resume_discard_action')),
        );
        await tester.pumpAndSettle();
        // The card's Discard is a lighter secondary; the dialog confirm is the
        // primary (ElevatedButton), so target the primary explicitly.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Discard'));
        await tester.pumpAndSettle();

        expect(controller.cancelledSessionId, 'session-046');
        expect(controller.createdSession, isFalse);
        expect(find.text('Discard this session?'), findsNothing);
        expect(find.text('Session discarded.'), findsOneWidget);
        expect(find.byKey(const ValueKey('deck_resume_banner')), findsNothing);
      },
    );

    testWidgets('onDiscard: failure shows a safe localized error', (
      WidgetTester tester,
    ) async {
      final controller = _StubProgressSessionActionController(succeeds: false);
      await _pumpDeckDiscard(tester, controller: controller);

      await tester.tap(
        find.byKey(const ValueKey('deck_resume_discard_action')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Discard'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't discard the session. Try again."),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('deck_resume_banner')), findsOneWidget);
    });
  });
}

/// Pumps Flashcard List with a paused deck session whose resume banner
/// re-resolves to empty once the study-session revision is bumped (mirroring the
/// production [deckStudyEntryProvider] dependency on the revision).
Future<void> _pumpDeckDiscard(
  WidgetTester tester, {
  _StubProgressSessionActionController? controller,
}) async {
  const deckId = 'deck-001';
  final container = ProviderContainer(
    overrides: [
      deckStudyEntryProvider.overrideWith((ref, _) {
        final revision = ref.watch(studySessionDataRevisionProvider);
        return revision == 0
            ? const DeckStudyEntry(
                totalCardCount: 0,
                dueCount: 0,
                resumeSessionId: 'session-046',
              )
            : const DeckStudyEntry.empty();
      }),
      flashcardListQueryProvider(deckId).overrideWith(
        (ref) => Future<FlashcardListState>.value(_emptyFlashcardState),
      ),
      progressSessionActionControllerProvider.overrideWith(
        () => controller ?? _StubProgressSessionActionController(),
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
}

/// Stub that captures the discard through the use-case path without binding the
/// real study repository. On success it bumps the study-session revision exactly
/// like the production controller, so the resume banner provider re-resolves.
class _StubProgressSessionActionController
    extends ProgressSessionActionController {
  _StubProgressSessionActionController({this.succeeds = true});

  final bool succeeds;
  String? cancelledSessionId;

  /// Always false: discard must never create a session.
  bool get createdSession => false;

  @override
  Future<bool> cancel(String sessionId) async {
    cancelledSessionId = sessionId;
    if (succeeds) {
      ref.read(studySessionDataRevisionProvider.notifier).bump();
    }
    return succeeds;
  }
}

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

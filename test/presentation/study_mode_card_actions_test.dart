import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/widgets/study_session/fill/fill_mode_session_view.dart';
import 'package:memox/presentation/features/study/widgets/study_session/guess/guess_mode_session_view.dart';
import 'package:memox/presentation/features/study/widgets/study_session/match/match_mode_session_view.dart';
import 'package:memox/presentation/features/study/widgets/study_session/recall/recall_mode_session_view.dart';
import 'package:memox/presentation/features/study/widgets/study_session/review/review_mode_session_view.dart';
import 'package:memox/presentation/features/study/widgets/study_session/study_mode_session_scaffold.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';

/// P0-2 fix: the card-actions trigger (Edit / Bury / Suspend) must be reachable
/// from every active study mode view. History must never be exposed (the sheet
/// content is asserted in card_actions_sheet_test.dart).
void main() {
  StudyFlashcardRef card(String id) => StudyFlashcardRef(
    id: id,
    deckId: 'deck-1',
    front: 'front $id',
    back: 'back $id',
    sourcePool: SessionItemSourcePool.due,
  );

  StudySessionItem item(String id, StudyMode mode) => StudySessionItem(
    id: 'item-$id',
    sessionId: 'session-1',
    flashcard: card(id),
    studyMode: mode,
    modeOrder: 1,
    roundIndex: 1,
    queuePosition: 1,
    sourcePool: SessionItemSourcePool.due,
    status: SessionItemStatus.pending,
    completedAt: null,
  );

  StudySessionSnapshot snapshotFor(StudyMode mode) => StudySessionSnapshot(
    session: const StudySession(
      id: 'session-1',
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.newStudy,
      studyFlow: StudyFlow.newFullCycle,
      settings: StudySettingsSnapshot(
        batchSize: 20,
        shuffleFlashcards: false,
        shuffleAnswers: false,
        prioritizeOverdue: false,
      ),
      status: SessionStatus.inProgress,
      startedAt: 0,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: item('c1', mode),
    currentRoundItems: <StudySessionItem>[item('c1', mode), item('c2', mode)],
    sessionFlashcards: <StudyFlashcardRef>[card('c1'), card('c2')],
    summary: const StudySummary(
      totalCards: 2,
      completedAttempts: 0,
      correctAttempts: 0,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: 2,
    ),
    canFinalize: false,
  );

  Future<void> pump(WidgetTester tester, Widget view) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ttsServiceProvider.overrideWithValue(_NoopTts())],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: view,
        ),
      ),
    );
    await tester.pump();
  }

  Widget reviewView(VoidCallback onCardActions) => ReviewModeSessionView(
    snapshot: snapshotFor(StudyMode.review),
    isSubmitting: false,
    canCancel: true,
    onSubmit: () async => true,
    onCancel: () {},
    onBack: () {},
    onCardActions: onCardActions,
  );

  Widget batchView(
    StudyMode mode,
    Widget Function({
      required StudySessionSnapshot snapshot,
      required bool isSubmitting,
      required bool canCancel,
      required Future<bool> Function(Map<String, AttemptGrade>) onSubmit,
      required VoidCallback onCancel,
      required VoidCallback onBack,
      required VoidCallback onCardActions,
    })
    build,
    VoidCallback onCardActions,
  ) => build(
    snapshot: snapshotFor(mode),
    isSubmitting: false,
    canCancel: true,
    onSubmit: (_) async => true,
    onCancel: () {},
    onBack: () {},
    onCardActions: onCardActions,
  );

  final modeViews = <String, Widget Function(VoidCallback)>{
    'review': reviewView,
    'match': (cb) => batchView(
      StudyMode.match,
      ({
        required snapshot,
        required isSubmitting,
        required canCancel,
        required onSubmit,
        required onCancel,
        required onBack,
        required onCardActions,
      }) => MatchModeSessionView(
        snapshot: snapshot,
        isSubmitting: isSubmitting,
        canCancel: canCancel,
        onSubmit: onSubmit,
        onCancel: onCancel,
        onBack: onBack,
        onCardActions: onCardActions,
      ),
      cb,
    ),
    'guess': (cb) => batchView(
      StudyMode.guess,
      ({
        required snapshot,
        required isSubmitting,
        required canCancel,
        required onSubmit,
        required onCancel,
        required onBack,
        required onCardActions,
      }) => GuessModeSessionView(
        snapshot: snapshot,
        isSubmitting: isSubmitting,
        canCancel: canCancel,
        onSubmit: onSubmit,
        onCancel: onCancel,
        onBack: onBack,
        onCardActions: onCardActions,
      ),
      cb,
    ),
    'recall': (cb) => batchView(
      StudyMode.recall,
      ({
        required snapshot,
        required isSubmitting,
        required canCancel,
        required onSubmit,
        required onCancel,
        required onBack,
        required onCardActions,
      }) => RecallModeSessionView(
        snapshot: snapshot,
        isSubmitting: isSubmitting,
        canCancel: canCancel,
        onSubmit: onSubmit,
        onCancel: onCancel,
        onBack: onBack,
        onCardActions: onCardActions,
      ),
      cb,
    ),
    'fill': (cb) => batchView(
      StudyMode.fill,
      ({
        required snapshot,
        required isSubmitting,
        required canCancel,
        required onSubmit,
        required onCancel,
        required onBack,
        required onCardActions,
      }) => FillModeSessionView(
        snapshot: snapshot,
        isSubmitting: isSubmitting,
        canCancel: canCancel,
        onSubmit: onSubmit,
        onCancel: onCancel,
        onBack: onBack,
        onCardActions: onCardActions,
      ),
      cb,
    ),
  };

  for (final entry in modeViews.entries) {
    testWidgets(
      '${entry.key} mode view exposes a working card-actions trigger',
      (tester) async {
        var tapped = false;
        await pump(tester, entry.value(() => tapped = true));

        final trigger = find.byTooltip('Card actions');
        expect(trigger, findsOneWidget);
        expect(find.textContaining('History'), findsNothing);

        await tester.tap(trigger);
        await tester.pump();
        expect(tapped, isTrue);

        // Drain mode-view auto-advance / auto-reveal timers so the test teardown
        // does not see a pending timer.
        await tester.pump(const Duration(seconds: 21));
      },
    );
  }

  testWidgets('card-actions trigger is hidden when no handler is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StudyModeSessionScaffold(
          modeLabel: 'Review',
          accent: MxStudyTopBarAccent.primary,
          progressValue: 0.5,
          counterLabel: '1 / 2',
          canCancel: true,
          isActionBusy: false,
          onCancel: () {},
          onBack: () {},
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Card actions'), findsNothing);
  });
}

final class _NoopTts implements TtsService {
  @override
  Stream<TtsState> get state => const Stream<TtsState>.empty();

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async =>
      const <TtsVoice>[];

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    required double pitch,
    required double volume,
    String? voiceName,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

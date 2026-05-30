import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/guess/guess_option_builder.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/widgets/study_session/guess/guess_mode_session_view.dart';
import 'package:memox/presentation/features/study/widgets/study_session/guess/guess_option_tile.dart';

StudyFlashcardRef _card(String id, {String? front, String? back}) =>
    StudyFlashcardRef(
      id: id,
      deckId: 'deck-1',
      front: front ?? 'front-$id',
      back: back ?? 'back-$id',
      sourcePool: SessionItemSourcePool.due,
    );

StudySessionItem _item(StudyFlashcardRef card) => StudySessionItem(
  id: 'item-${card.id}',
  sessionId: 'session-1',
  flashcard: card,
  studyMode: StudyMode.guess,
  modeOrder: 1,
  roundIndex: 1,
  queuePosition: 1,
  sourcePool: SessionItemSourcePool.due,
  status: SessionItemStatus.pending,
  completedAt: null,
);

StudySessionSnapshot _snapshot({
  required StudyFlashcardRef current,
  required List<StudyFlashcardRef> pool,
}) {
  final currentItem = _item(current);
  return StudySessionSnapshot(
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
    currentItem: currentItem,
    currentRoundItems: <StudySessionItem>[currentItem],
    sessionFlashcards: pool,
    summary: const StudySummary(
      totalCards: 1,
      completedAttempts: 0,
      correctAttempts: 0,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: 1,
    ),
    canFinalize: false,
  );
}

class _Submissions {
  final List<Map<String, AttemptGrade>> calls = [];
  Future<bool> submit(Map<String, AttemptGrade> grades) async {
    calls.add(Map<String, AttemptGrade>.from(grades));
    return true;
  }
}

class _NoopTts implements TtsService {
  @override
  Stream<TtsState> get state => const Stream.empty();

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

class _FakeTtsSettingsRepository implements TtsSettingsRepository {
  @override
  Future<TtsSettings> load() async => const TtsSettings(
    autoPlay: false,
    frontLanguage: TtsLanguage.korean,
    rate: TtsSettings.defaultRate,
    pitch: TtsSettings.defaultPitch,
    volume: TtsSettings.defaultVolume,
  );

  @override
  Future<void> save(TtsSettings settings) async {}
}

Future<_Submissions> _pump(
  WidgetTester tester,
  StudySessionSnapshot snapshot,
) async {
  await tester.binding.setSurfaceSize(const Size(430, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final submissions = _Submissions();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ttsServiceProvider.overrideWithValue(_NoopTts()),
        ttsSettingsRepositoryProvider.overrideWith(
          (ref) async => _FakeTtsSettingsRepository(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GuessModeSessionView(
          snapshot: snapshot,
          isSubmitting: false,
          canCancel: true,
          onSubmit: submissions.submit,
          onCancel: () {},
          onBack: () {},
        ),
      ),
    ),
  );
  await tester.pump();
  return submissions;
}

void main() {
  final current = _card('c1', back: 'library');
  final fivePool = <StudyFlashcardRef>[
    current,
    _card('c2', back: 'school'),
    _card('c3', back: 'office'),
    _card('c4', back: 'hospital'),
    _card('c5', back: 'kitchen'),
  ];

  testWidgets('renders 5 options when 4 valid decoys exist', (tester) async {
    await _pump(tester, _snapshot(current: current, pool: fivePool));
    expect(find.byType(GuessOptionTile), findsNWidgets(5));
  });

  testWidgets('does not render duplicate option text', (tester) async {
    await _pump(
      tester,
      _snapshot(
        current: current,
        pool: <StudyFlashcardRef>[
          current,
          _card('c2', back: 'school'),
          _card('c3', back: 'school'),
          _card('c4', back: 'office'),
          _card('c5', back: 'hospital'),
        ],
      ),
    );
    final tiles = tester.widgetList<GuessOptionTile>(
      find.byType(GuessOptionTile),
    );
    final backs = tiles.map((t) => t.option.back.toLowerCase()).toList();
    expect(backs.toSet().length, backs.length);
  });

  testWidgets('tapping correct option submits correct grade after 800ms', (
    tester,
  ) async {
    final submissions = await _pump(
      tester,
      _snapshot(current: current, pool: fivePool),
    );
    final correctTile = tester
        .widgetList<GuessOptionTile>(find.byType(GuessOptionTile))
        .firstWhere((t) => t.option.isCorrect);
    correctTile.onTap();
    await tester.pump();
    // Before 800ms, no submit.
    await tester.pump(const Duration(milliseconds: 799));
    expect(submissions.calls, isEmpty);
    // Cross the 800ms boundary.
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();
    expect(submissions.calls, hasLength(1));
    expect(submissions.calls.single.values.single, AttemptGrade.correct);
  });

  testWidgets(
    'tapping wrong option holds feedback ~1500ms then submits incorrect',
    (tester) async {
      final submissions = await _pump(
        tester,
        _snapshot(current: current, pool: fivePool),
      );
      final wrongTile = tester
          .widgetList<GuessOptionTile>(find.byType(GuessOptionTile))
          .firstWhere((t) => !t.option.isCorrect);
      wrongTile.onTap();
      await tester.pump();
      // At 800ms (correct delay) the wrong path must NOT have submitted yet.
      await tester.pump(const Duration(milliseconds: 800));
      expect(submissions.calls, isEmpty);
      // Just before 1500ms still not submitted.
      await tester.pump(const Duration(milliseconds: 699));
      expect(submissions.calls, isEmpty);
      // Crossing 1500ms triggers submission.
      await tester.pump(const Duration(milliseconds: 2));
      await tester.pumpAndSettle();
      expect(submissions.calls, hasLength(1));
      expect(submissions.calls.single.values.single, AttemptGrade.incorrect);
    },
  );

  testWidgets('option order is stable across rebuilds for same item', (
    tester,
  ) async {
    await _pump(tester, _snapshot(current: current, pool: fivePool));
    final firstOrder = tester
        .widgetList<GuessOptionTile>(find.byType(GuessOptionTile))
        .map((t) => t.option.id)
        .toList();
    await tester.pump();
    await tester.pump();
    final secondOrder = tester
        .widgetList<GuessOptionTile>(find.byType(GuessOptionTile))
        .map((t) => t.option.id)
        .toList();
    expect(secondOrder, firstOrder);
  });

  testWidgets('rendered options use GuessOptionBuilder full-pool selection', (
    tester,
  ) async {
    final pool = <StudyFlashcardRef>[
      current,
      _card('c2', back: 'school'),
      _card('c3', back: 'office'),
      _card('c4', back: 'hospital'),
      _card('c5', back: 'kitchen'),
      _card('c6', back: 'museum'),
      _card('c7', back: 'station'),
      _card('c8', back: 'market'),
    ];
    final snapshot = _snapshot(current: current, pool: pool);
    final expected = GuessOptionBuilder.build(
      currentCard: current,
      candidateCards: pool,
      seed: 'session-1:item-c1:guess:c1:false',
      shuffle: false,
    ).options.map((o) => o.id).toList();

    await _pump(tester, snapshot);

    final rendered = tester
        .widgetList<GuessOptionTile>(find.byType(GuessOptionTile))
        .map((t) => t.option.id)
        .toList();
    expect(rendered, expected);
    expect(
      rendered.toSet().containsAll(<String>{'c2', 'c3', 'c4', 'c5'}),
      isFalse,
    );
  });

  testWidgets('fewer than 4 valid decoys does not crash', (tester) async {
    await _pump(
      tester,
      _snapshot(
        current: current,
        pool: <StudyFlashcardRef>[
          current,
          _card('c2', back: 'school'),
          _card('c3', back: 'office'),
        ],
      ),
    );
    expect(find.byType(GuessOptionTile), findsNWidgets(3));
  });
}

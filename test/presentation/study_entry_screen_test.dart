import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets('DT1 onOpen: shows loading state while study entry loads', (
    tester,
  ) async {
    final completer = Completer<StudyEntryState>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_deckEntryState);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => completer.future),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('DT1 onDisplay: deck entry shows new and review study flows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_deckEntryState)),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start a study session'), findsOneWidget);
    expect(find.text('New Study'), findsOneWidget);
    expect(find.text('SRS Review'), findsOneWidget);
    expect(find.text('Session settings'), findsOneWidget);
  });

  testWidgets('DT2 onDisplay: today entry locks the flow to SRS Review', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'today',
            null,
          ).overrideWith((ref) => Future.value(_todayEntryState)),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'today', entryRefId: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SRS Review'), findsOneWidget);
    expect(find.text('New Study'), findsNothing);
    expect(
      find.text('Today supports SRS Review due and overdue cards in v1.'),
      findsOneWidget,
    );
  });
}

const _newDefaults = StudySettingsSnapshot(
  batchSize: 20,
  shuffleFlashcards: true,
  shuffleAnswers: true,
  prioritizeOverdue: false,
);

const _reviewDefaults = StudySettingsSnapshot(
  batchSize: 12,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

const _deckEntryState = StudyEntryState(
  entryType: StudyEntryType.deck,
  entryRefId: 'deck-001',
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewDefaults,
  resumeCandidate: null,
);

const _todayEntryState = StudyEntryState(
  entryType: StudyEntryType.today,
  entryRefId: null,
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewDefaults,
  resumeCandidate: null,
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

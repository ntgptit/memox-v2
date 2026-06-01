import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_overview_viewmodel.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_paused_sessions_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';

void main() {
  testWidgets(
    'DT1 onSelect: Resume closes the paused-sessions sheet and returns session',
    (tester) async {
      String? resumedSessionId;
      var resolved = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) async => _state([_resumeItem('session-001')]),
            ),
          ],
          child: _TestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await MxBottomSheet.show<void>(
                    context: context,
                    title: 'Paused sessions',
                    child: DashboardPausedSessionsSheet(
                      initialSessions: [_resumeItem('session-001')],
                      onResume: (sheetContext, session) {
                        resumedSessionId = session.sessionId;
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  );
                  resolved = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('dashboard_paused_resume_session-001')),
      );
      await tester.pumpAndSettle();

      expect(resumedSessionId, 'session-001');
      expect(resolved, isTrue);
      expect(find.byType(DashboardPausedSessionsSheet), findsNothing);
    },
  );

  testWidgets(
    'DT1 onSelect: Discard opens the shared discard confirmation dialog',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) async => _state([_resumeItem('session-001')]),
            ),
          ],
          child: _TestApp(
            child: DashboardPausedSessionsSheet(
              initialSessions: [_resumeItem('session-001')],
              onResume: (_, _) {},
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('dashboard_paused_discard_session-001')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discard this session?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Discard'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onDisplay: Sheet auto-closes when live paused sessions become empty',
    (tester) async {
      var resolved = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) async => _state(const <DashboardResumeSessionItem>[]),
            ),
          ],
          child: _TestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await MxBottomSheet.show<void>(
                    context: context,
                    title: 'Paused sessions',
                    child: DashboardPausedSessionsSheet(
                      initialSessions: [_resumeItem('session-001')],
                      onResume: (_, _) {},
                    ),
                  );
                  resolved = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(resolved, isTrue);
      expect(find.byType(DashboardPausedSessionsSheet), findsNothing);
    },
  );
}

DashboardResumeSessionItem _resumeItem(String id) => DashboardResumeSessionItem(
  sessionId: id,
  studyType: StudyType.srsReview,
  entryType: StudyEntryType.deck,
  completedSteps: 12,
  totalSteps: 24,
  remainingCount: 12,
  startedAt: 1000,
);

DashboardOverviewState _state(List<DashboardResumeSessionItem> sessions) =>
    DashboardOverviewState(
      overdueCount: 0,
      dueTodayCount: 0,
      newCardCount: 0,
      resumeSessions: sessions,
      folderCount: 0,
      deckCount: 0,
      cardCount: 0,
      masteryPercent: 0,
      deckHighlights: const <DashboardDeckHighlightItem>[],
    );

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

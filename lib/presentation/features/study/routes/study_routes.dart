import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';

import '../screens/study_entry_screen.dart';
import '../screens/study_result_screen.dart';
import '../screens/study_session_screen.dart';

List<RouteBase> studyLibraryRoutes() => [
    GoRoute(
      path: RoutePaths.studyTodaySegment,
      name: RouteNames.studyToday,
      pageBuilder: (_, _) => const NoTransitionPage(
        child: StudyEntryScreen(entryType: 'today', entryRefId: null),
      ),
    ),
    GoRoute(
      path: RoutePaths.studySessionSegment,
      name: RouteNames.studySession,
      pageBuilder: (_, state) => NoTransitionPage(
        child: StudySessionScreen(
          sessionId: state.pathParameters[RoutePaths.studySessionIdParam]!,
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.studyResultSegment,
      name: RouteNames.studyResult,
      pageBuilder: (_, state) => NoTransitionPage(
        child: StudyResultScreen(
          sessionId: state.pathParameters[RoutePaths.studySessionIdParam]!,
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.studyEntrySegment,
      name: RouteNames.studyEntry,
      pageBuilder: (_, state) => NoTransitionPage(
        child: StudyEntryScreen(
          entryType: state.pathParameters[RoutePaths.studyEntryTypeParam]!,
          entryRefId: state.pathParameters[RoutePaths.studyEntryRefIdParam],
          studyMode: state.uri.queryParameters['mode'],
        ),
      ),
    ),
  ];

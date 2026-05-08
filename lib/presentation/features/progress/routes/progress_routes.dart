import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';

import '../screens/progress_screen.dart';

List<RouteBase> progressBranchRoutes() {
  return [
    GoRoute(
      path: RoutePaths.progress,
      name: RouteNames.progress,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProgressScreen()),
    ),
  ];
}

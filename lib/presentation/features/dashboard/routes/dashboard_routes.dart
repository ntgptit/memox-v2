import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';

import '../screens/dashboard_screen.dart';

List<RouteBase> dashboardBranchRoutes() {
  return [
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DashboardScreen()),
    ),
  ];
}

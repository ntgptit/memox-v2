import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';

import '../screens/folder_detail_screen.dart';
import '../screens/library_overview_screen.dart';

List<RouteBase> libraryBranchRoutes({required List<RouteBase> childRoutes}) => [
  GoRoute(
    path: RoutePaths.library,
    name: RouteNames.library,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: LibraryOverviewView()),
    routes: [
      ...childRoutes,
      GoRoute(
        path: RoutePaths.folderDetailSegment,
        name: RouteNames.folderDetail,
        pageBuilder: (_, state) => NoTransitionPage(
          child: FolderDetailScreen(
            folderId: state.pathParameters[RoutePaths.folderIdParam]!,
          ),
        ),
      ),
    ],
  ),
];

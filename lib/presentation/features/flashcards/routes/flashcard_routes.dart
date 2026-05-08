import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';

import '../screens/deck_import_screen.dart';
import '../screens/flashcard_editor_screen.dart';
import '../screens/flashcard_list_screen.dart';

List<RouteBase> flashcardLibraryRoutes() {
  return [
    GoRoute(
      path: RoutePaths.flashcardCreateSegment,
      name: RouteNames.flashcardCreate,
      pageBuilder: (_, state) => NoTransitionPage(
        child: FlashcardEditorScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam]!,
          key: ValueKey(
            'create-${state.pathParameters[RoutePaths.deckIdParam]}',
          ),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.flashcardEditSegment,
      name: RouteNames.flashcardEdit,
      pageBuilder: (_, state) => NoTransitionPage(
        child: FlashcardEditorScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam]!,
          flashcardId: state.pathParameters[RoutePaths.flashcardIdParam]!,
          key: ValueKey(
            'edit-${state.pathParameters[RoutePaths.flashcardIdParam]}',
          ),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.flashcardListSegment,
      name: RouteNames.flashcardList,
      pageBuilder: (_, state) => NoTransitionPage(
        child: FlashcardListScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam]!,
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.deckImportSegment,
      name: RouteNames.deckImport,
      pageBuilder: (_, state) => NoTransitionPage(
        child: DeckImportScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam]!,
          key: ValueKey(
            'import-${state.pathParameters[RoutePaths.deckIdParam]}',
          ),
        ),
      ),
    ),
  ];
}

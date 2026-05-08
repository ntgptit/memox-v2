import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart';

part 'content_revision_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<int> contentDataRevision(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  var revision = 0;
  return database
      .customSelect(
        'SELECT 1 AS changed',
        readsFrom: {
          database.folders,
          database.decks,
          database.flashcards,
          database.flashcardProgress,
        },
      )
      .watch()
      .map((_) => revision++);
}

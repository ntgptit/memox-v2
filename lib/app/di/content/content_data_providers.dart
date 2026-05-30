import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/local/daos/deck_dao.dart';
import '../../../data/datasources/local/daos/flashcard_dao.dart';
import '../../../data/datasources/local/daos/flashcard_tag_dao.dart';
import '../../../data/datasources/local/daos/folder_dao.dart';
import '../../../domain/services/folder_structure_service.dart';
import '../providers.dart';

part 'content_data_providers.g.dart';

@Riverpod(keepAlive: true)
FolderDao folderDao(Ref ref) => FolderDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
DeckDao deckDao(Ref ref) => DeckDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FlashcardDao flashcardDao(Ref ref) =>
    FlashcardDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FlashcardTagDao flashcardTagDao(Ref ref) =>
    FlashcardTagDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FolderStructureService folderStructureService(Ref ref) =>
    const FolderStructureService();

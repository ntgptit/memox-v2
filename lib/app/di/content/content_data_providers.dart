import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/local/daos/deck_dao.dart';
import '../../../data/datasources/local/daos/flashcard_dao.dart';
import '../../../data/datasources/local/daos/folder_dao.dart';
import '../../../domain/services/folder_structure_service.dart';
import '../providers.dart';

part 'content_data_providers.g.dart';

@riverpod
FolderDao folderDao(Ref ref) => FolderDao(ref.watch(appDatabaseProvider));

@riverpod
DeckDao deckDao(Ref ref) => DeckDao(ref.watch(appDatabaseProvider));

@riverpod
FlashcardDao flashcardDao(Ref ref) => FlashcardDao(ref.watch(appDatabaseProvider));

@riverpod
FolderStructureService folderStructureService(Ref ref) => const FolderStructureService();

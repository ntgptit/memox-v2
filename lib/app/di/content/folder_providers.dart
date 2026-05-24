import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/folder_repository_impl.dart';
import '../../../domain/repositories/folder_repository.dart';
import '../../../domain/usecases/content_query_usecases.dart';
import '../../../domain/usecases/folder_usecases.dart';
import 'content_core_providers.dart';
import 'content_data_providers.dart';

part 'folder_providers.g.dart';

@riverpod
FolderRepository folderRepository(Ref ref) => FolderRepositoryImpl(
    folderDao: ref.watch(folderDaoProvider),
    deckDao: ref.watch(deckDaoProvider),
    transactionRunner: ref.watch(localTransactionRunnerProvider),
    structureService: ref.watch(folderStructureServiceProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );

@riverpod
WatchLibraryOverviewUseCase watchLibraryOverviewUseCase(Ref ref) => WatchLibraryOverviewUseCase(ref.watch(folderRepositoryProvider));

@riverpod
WatchFolderDetailUseCase watchFolderDetailUseCase(Ref ref) => WatchFolderDetailUseCase(ref.watch(folderRepositoryProvider));

@riverpod
CreateFolderUseCase createFolderUseCase(Ref ref) => CreateFolderUseCase(ref.watch(folderRepositoryProvider));

@riverpod
GetFolderMoveTargetsUseCase getFolderMoveTargetsUseCase(Ref ref) => GetFolderMoveTargetsUseCase(ref.watch(folderRepositoryProvider));

@riverpod
UpdateFolderUseCase updateFolderUseCase(Ref ref) => UpdateFolderUseCase(ref.watch(folderRepositoryProvider));

@riverpod
DeleteFolderUseCase deleteFolderUseCase(Ref ref) => DeleteFolderUseCase(ref.watch(folderRepositoryProvider));

@riverpod
MoveFolderUseCase moveFolderUseCase(Ref ref) => MoveFolderUseCase(ref.watch(folderRepositoryProvider));

@riverpod
ReorderFoldersUseCase reorderFoldersUseCase(Ref ref) => ReorderFoldersUseCase(ref.watch(folderRepositoryProvider));

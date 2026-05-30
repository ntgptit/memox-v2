import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/tag_repository_impl.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../domain/tag/tag_validator.dart';
import '../../../domain/usecases/tag_usecases.dart';
import 'content_core_providers.dart';
import 'content_data_providers.dart';

part 'tag_providers.g.dart';

@Riverpod(keepAlive: true)
TagValidator tagValidator(Ref ref) => const TagValidator();

@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) => TagRepositoryImpl(
  flashcardTagDao: ref.watch(flashcardTagDaoProvider),
  transactionRunner: ref.watch(localTransactionRunnerProvider),
);

@riverpod
WatchAllTagsWithCountUseCase watchAllTagsWithCountUseCase(Ref ref) =>
    WatchAllTagsWithCountUseCase(ref.watch(tagRepositoryProvider));

@riverpod
AddTagToCardUseCase addTagToCardUseCase(Ref ref) => AddTagToCardUseCase(
  ref.watch(tagRepositoryProvider),
  ref.watch(tagValidatorProvider),
);

@riverpod
RemoveTagFromCardUseCase removeTagFromCardUseCase(Ref ref) =>
    RemoveTagFromCardUseCase(
      ref.watch(tagRepositoryProvider),
      ref.watch(tagValidatorProvider),
    );

@riverpod
RenameTagUseCase renameTagUseCase(Ref ref) => RenameTagUseCase(
  ref.watch(tagRepositoryProvider),
  ref.watch(tagValidatorProvider),
);

@riverpod
MergeTagUseCase mergeTagUseCase(Ref ref) => MergeTagUseCase(
  ref.watch(tagRepositoryProvider),
  ref.watch(tagValidatorProvider),
);

@riverpod
DeleteTagUseCase deleteTagUseCase(Ref ref) =>
    DeleteTagUseCase(ref.watch(tagRepositoryProvider));

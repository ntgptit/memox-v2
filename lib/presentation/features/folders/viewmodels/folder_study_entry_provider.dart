import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../domain/study/usecases/folder_study_entry_usecase.dart';
import '../../../shared/providers/study_revision_providers.dart';

part 'folder_study_entry_provider.g.dart';

/// Folder-scoped study-entry summary (recursive card/due counts + resumable
/// session) used by the Folder Detail study banners. Re-resolves when folder
/// content changes (cards added/removed) or when a study session is
/// created/cancelled/finalized, so the banners stay in sync with the gate.
@riverpod
Future<FolderStudyEntry> folderStudyEntry(Ref ref, String folderId) async {
  ref.watch(contentDataRevisionProvider);
  ref.watch(studySessionDataRevisionProvider);
  return ref.watch(getFolderStudyEntryUseCaseProvider).execute(folderId);
}

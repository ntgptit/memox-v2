import '../../enums/study_enums.dart';
import '../entities/study_models.dart';
import '../ports/study_repo.dart';

/// Read model backing the Folder Detail study-entry banners. Carries the
/// recursive scope counts and the resumable-session id for one folder, so the
/// Folder Detail screen can decide which of the Resume / Today / Study-folder
/// entry points to surface without owning any study query logic itself.
///
/// All values describe the folder *subtree* (folder-owned decks plus every
/// descendant folder's decks). The folder-owned-deck invariant is preserved:
/// counts come from `entry_type=folder` scope queries, never root-level decks.
final class FolderStudyEntry {
  const FolderStudyEntry({
    required this.totalCardCount,
    required this.dueCount,
    required this.resumeSessionId,
  });

  /// Empty scope: no cards, no due cards, no resumable session. Used as the
  /// safe default while data loads or when a folder has no study surface.
  const FolderStudyEntry.empty()
    : totalCardCount = 0,
      dueCount = 0,
      resumeSessionId = null;

  /// Recursive total flashcard count across the folder subtree.
  final int totalCardCount;

  /// Recursive count of cards due on or before the end of today.
  final int dueCount;

  /// Id of the resumable (paused) study session scoped to this folder, or
  /// `null` when none exists.
  final String? resumeSessionId;

  /// Whether the Study-folder CTA may appear (folder has any card).
  bool get hasCards => totalCardCount > 0;

  /// Whether the Today CTA may appear (folder has due cards). The CTA is
  /// hidden at zero per the wireframe rule (never render "Today (0)").
  bool get hasDue => dueCount > 0;

  /// Whether the Resume banner may appear.
  bool get hasResume => resumeSessionId != null;
}

/// Resolves the [FolderStudyEntry] for a folder by reusing the existing study
/// scope-probe and resume-candidate queries. Adds no schema and owns no new
/// persistence: it composes [StudyRepo.countFlashcardsInScope],
/// [StudyRepo.countDueCardsInScope], and [StudyRepo.findResumeCandidate] for an
/// `entry_type=folder` context.
final class GetFolderStudyEntryUseCase {
  const GetFolderStudyEntryUseCase({required StudyRepo repository})
    : _repository = repository;

  final StudyRepo _repository;

  Future<FolderStudyEntry> execute(String folderId) async {
    final context = _folderContext(folderId);
    final totalCardCount = await _repository.countFlashcardsInScope(context);
    final dueCount = await _repository.countDueCardsInScope(context);
    final resume = await _repository.findResumeCandidate(context);
    return FolderStudyEntry(
      totalCardCount: totalCardCount,
      dueCount: dueCount,
      resumeSessionId: resume?.session.id,
    );
  }

  /// Scope-probe context. The scope/resume queries depend only on
  /// `entryType` + `entryRefId`, so the settings/study-type carried here are
  /// inert placeholders and never reach persistence.
  StudyContext _folderContext(String folderId) => StudyContext(
    entryType: StudyEntryType.folder,
    entryRefId: folderId,
    studyType: StudyType.srsReview,
    settings: _probeSettings,
  );
}

const StudySettingsSnapshot _probeSettings = StudySettingsSnapshot(
  batchSize: 0,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: false,
);

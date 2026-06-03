import '../../enums/study_enums.dart';
import '../entities/study_models.dart';
import '../ports/study_repo.dart';

/// Read model backing the Flashcard List deck-level study-entry banners. Carries
/// the deck-scoped counts and the resumable-session id for one deck, so the
/// Flashcard List screen can decide which of the Resume / Today / Study-deck
/// entry points to surface without owning any study query logic itself.
///
/// All values describe a single deck (`entry_type=deck`, `entry_ref_id=deckId`).
/// It never starts a session: it is a read-only projection used by the banners.
final class DeckStudyEntry {
  const DeckStudyEntry({
    required this.totalCardCount,
    required this.dueCount,
    required this.resumeSessionId,
  });

  /// Empty scope: no cards, no due cards, no resumable session. Used as the
  /// safe default while data loads or when a deck has no study surface.
  const DeckStudyEntry.empty()
    : totalCardCount = 0,
      dueCount = 0,
      resumeSessionId = null;

  /// Total flashcard count for the deck.
  final int totalCardCount;

  /// Count of cards due on or before the end of today.
  final int dueCount;

  /// Id of the resumable (paused) study session scoped to this deck, or `null`
  /// when none exists.
  final String? resumeSessionId;

  /// Whether the Study-deck CTA may appear (deck has any card).
  bool get hasCards => totalCardCount > 0;

  /// Whether the Today CTA may appear (deck has due cards). The CTA is hidden
  /// at zero per the wireframe rule (never render "Today (0)").
  bool get hasDue => dueCount > 0;

  /// Whether the Resume banner may appear.
  bool get hasResume => resumeSessionId != null;
}

/// Resolves the [DeckStudyEntry] for a deck by reusing the existing study
/// scope-probe and resume-candidate queries. Adds no schema and owns no new
/// persistence: it composes [StudyRepo.countFlashcardsInScope],
/// [StudyRepo.countDueCardsInScope], and [StudyRepo.findResumeCandidate] for a
/// `entry_type=deck` context.
final class GetDeckStudyEntryUseCase {
  const GetDeckStudyEntryUseCase({required StudyRepo repository})
    : _repository = repository;

  final StudyRepo _repository;

  Future<DeckStudyEntry> execute(String deckId) async {
    final context = _deckContext(deckId);
    final totalCardCount = await _repository.countFlashcardsInScope(context);
    final dueCount = await _repository.countDueCardsInScope(context);
    final resume = await _repository.findResumeCandidate(context);
    return DeckStudyEntry(
      totalCardCount: totalCardCount,
      dueCount: dueCount,
      resumeSessionId: resume?.session.id,
    );
  }

  /// Scope-probe context. The scope/resume queries depend only on
  /// `entryType` + `entryRefId`, so the settings/study-type carried here are
  /// inert placeholders and never reach persistence.
  StudyContext _deckContext(String deckId) => StudyContext(
    entryType: StudyEntryType.deck,
    entryRefId: deckId,
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

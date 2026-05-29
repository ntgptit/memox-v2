// ignore_for_file: experimental_member_use

part of '../app_database.dart';

abstract final class _SchemaIndex {
  const _SchemaIndex._();

  static final Index foldersParentId = Index(
    'idx_folders_parent_id',
    'CREATE INDEX IF NOT EXISTS idx_folders_parent_id ON folders (parent_id)',
  );
  static final Index foldersParentSortOrder = Index(
    'idx_folders_parent_sort_order',
    'CREATE INDEX IF NOT EXISTS idx_folders_parent_sort_order ON folders (parent_id, sort_order)',
  );
  static final Index decksFolderSortOrder = Index(
    'idx_decks_folder_sort_order',
    'CREATE INDEX IF NOT EXISTS idx_decks_folder_sort_order ON decks (folder_id, sort_order)',
  );
  static final Index flashcardsDeckSortOrder = Index(
    'idx_flashcards_deck_sort_order',
    'CREATE INDEX IF NOT EXISTS idx_flashcards_deck_sort_order ON flashcards (deck_id, sort_order)',
  );
  static final Index flashcardProgressDueAt = Index(
    'idx_flashcard_progress_due_at',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_due_at ON flashcard_progress (due_at)',
  );
  static final Index flashcardProgressLastStudiedAt = Index(
    'idx_flashcard_progress_last_studied_at',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_last_studied_at ON flashcard_progress (last_studied_at)',
  );
  static final Index flashcardProgressEligibility = Index(
    'idx_flashcard_progress_eligibility',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_eligibility ON flashcard_progress (is_suspended, buried_until, due_at)',
  );
  static final Index studySessionsStatusStartedAt = Index(
    'idx_study_sessions_status_started_at',
    'CREATE INDEX IF NOT EXISTS idx_study_sessions_status_started_at ON study_sessions (status, started_at DESC)',
  );
  static final Index studySessionsEntryResume = Index(
    'idx_study_sessions_entry_resume',
    'CREATE INDEX IF NOT EXISTS idx_study_sessions_entry_resume ON study_sessions (entry_type, entry_ref_id, status, started_at DESC)',
  );
  static final Index studySessionItemsQueue = Index(
    'idx_study_session_items_queue',
    'CREATE INDEX IF NOT EXISTS idx_study_session_items_queue ON study_session_items (session_id, status, mode_order, round_index, queue_position)',
  );
  static final Index studySessionItemsModeRound = Index(
    'idx_study_session_items_mode_round',
    'CREATE INDEX IF NOT EXISTS idx_study_session_items_mode_round ON study_session_items (session_id, study_mode, mode_order, round_index)',
  );
  static final Index studyAttemptsSessionAnsweredAt = Index(
    'idx_study_attempts_session_answered_at',
    'CREATE INDEX IF NOT EXISTS idx_study_attempts_session_answered_at ON study_attempts (session_id, answered_at DESC)',
  );
  static final Index studyAttemptsItem = Index(
    'idx_study_attempts_item',
    'CREATE INDEX IF NOT EXISTS idx_study_attempts_item ON study_attempts (session_item_id)',
  );
}

final List<Index> _schemaIndexes = <Index>[
  _SchemaIndex.foldersParentId,
  _SchemaIndex.foldersParentSortOrder,
  _SchemaIndex.decksFolderSortOrder,
  _SchemaIndex.flashcardsDeckSortOrder,
  _SchemaIndex.flashcardProgressDueAt,
  _SchemaIndex.flashcardProgressLastStudiedAt,
  _SchemaIndex.flashcardProgressEligibility,
  _SchemaIndex.studySessionsStatusStartedAt,
  _SchemaIndex.studySessionsEntryResume,
  _SchemaIndex.studySessionItemsQueue,
  _SchemaIndex.studySessionItemsModeRound,
  _SchemaIndex.studyAttemptsSessionAnsweredAt,
  _SchemaIndex.studyAttemptsItem,
];

const String _legacyFlashcardProgressResultExpression = '''
CASE last_result
  WHEN 'correct' THEN 'perfect'
  WHEN 'remembered' THEN 'perfect'
  WHEN 'incorrect' THEN 'recovered'
  WHEN 'forgot' THEN 'forgot'
  ELSE last_result
END
''';

const String _legacyStudyAttemptResultExpression = '''
CASE result
  WHEN 'remembered' THEN 'correct'
  WHEN 'forgot' THEN 'incorrect'
  ELSE result
END
''';

const String _migrateLegacyNewStudyPerfectResultsSql = '''
UPDATE flashcard_progress
SET last_result = 'initial_passed'
WHERE last_result = 'perfect'
  AND current_box = 2
  AND due_at IS NOT NULL
  AND EXISTS (
    SELECT 1
    FROM study_attempts AS attempts
    INNER JOIN study_sessions AS sessions
      ON sessions.id = attempts.session_id
    WHERE attempts.flashcard_id = flashcard_progress.flashcard_id
      AND sessions.study_type = 'new'
      AND sessions.status = 'completed'
      AND attempts.new_box = flashcard_progress.current_box
      AND attempts.next_due_at = flashcard_progress.due_at
  )
  AND NOT EXISTS (
    SELECT 1
    FROM study_attempts AS attempts
    INNER JOIN study_sessions AS sessions
      ON sessions.id = attempts.session_id
    WHERE attempts.flashcard_id = flashcard_progress.flashcard_id
      AND sessions.study_type = 'srs_review'
      AND sessions.status = 'completed'
      AND attempts.new_box = flashcard_progress.current_box
      AND attempts.next_due_at = flashcard_progress.due_at
  )
''';

const String _repairMissingFlashcardProgressSql = '''
INSERT INTO flashcard_progress (
  flashcard_id,
  current_box,
  review_count,
  lapse_count,
  last_result,
  last_studied_at,
  due_at,
  created_at,
  updated_at
)
SELECT
  flashcards.id,
  1,
  0,
  0,
  NULL,
  NULL,
  NULL,
  flashcards.created_at,
  flashcards.updated_at
FROM flashcards
LEFT JOIN flashcard_progress
  ON flashcard_progress.flashcard_id = flashcards.id
WHERE flashcard_progress.flashcard_id IS NULL
''';

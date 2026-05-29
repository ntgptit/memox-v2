---
last_updated: 2026-05-26
status: contract
---

# Domain Types Catalog

Single registry for every enum, typedef, value-object, and named tuple in MemoX domain layer. AI agents and humans alike use these exact names — no synonyms, no rephrasings.

## What belongs in this catalog (and what doesn't)

**Catalog-worthy (here):**

- Enums used across multiple features (`AttemptResult`, `StudyMode`, `EntryType`, `ContentMode`, etc.).
- ID typedefs (`FlashcardId`, `DeckId`, `FolderId`, ...).
- Sealed value classes representing a domain concept used cross-feature (`CardState`, `StudyScope`).
- Aggregate types referenced by multiple wireframes or contracts (`LifetimeStats`, `SessionAggregate`).

**NOT catalog-worthy (lives in the use case contract that defines it):**

- Per-feature DTOs: `DashboardState`, `DueCounts`, `ImportPreview`, `ImportResult`, `ImportCommitResult`, `BulkMoveResult`, `BulkTagResult`, `MergeResult`, `RestoreResult`, `CardHistoryPage`, `RootChildren`, `FolderChildren`, `FolderDetail`, `DeckDetail`, `DeckCounts`, `FlashcardDetail`, `FlashcardCreationData`, `FlashcardUpdateData`, `SnapshotInfo`, etc.
- Test fixtures, fake services, mock objects.
- Presentation-only view-models.

**Rule of thumb:** if a type is used by 1 use case and 1 notifier, document it in the use case contract. If used by 2+ unrelated features or by both data + presentation layers without going through a use case, catalog it here.

## Naming rules

- Enum cases: lower_snake_case in storage and ARB, but Dart enum values follow Dart convention: lowerCamelCase.
- Enum class names: UpperCamelCase, no `Enum` suffix.
- Typedef: UpperCamelCase, semantic name (e.g., `BoxNumber`, not `Int8Range`).
- Value objects: freezed classes, UpperCamelCase, immutable.
- One file per logical group under `lib/domain/types/`.

## Current / Target / Migration Required labels

This catalog intentionally documents both current baseline concepts and target architecture.

Use these labels in this file:

- **Current**: safe to treat as implemented/baseline.
- **Target**: desired domain/API concept.
- **Migration Required**: target concept that needs schema, dependency, mapper, generated-code, or test migration before implementation.
- **Future Proposal**: valuable direction but not scheduled for the near sprint.
- **To verify**: needs repo/code confirmation before implementation.

Do not downgrade target concepts just because implementation has not caught up.
Do not implement `Migration Required` concepts unless the task explicitly includes the migration.

## Enums

### AttemptResult

**Status:** Target domain type.

The 4 SRS grading outcomes. **Pass/fail only** (no Hard/Easy variants).

```dart
enum AttemptResult {
  perfect,        // Exact match, first attempt, no recovery needed
  initialPassed,  // Correct on first attempt (used in multi-attempt flows)
  recovered,      // User missed initially but corrected (typo override, close match)
  forgot,         // Wrong answer
}
```

**Current vs target storage:**

- Current implementations may store raw attempt results such as `correct` / `incorrect`.
- Target domain grading uses `AttemptResult` values.
- Do not assume `AttemptResult` is already the current persisted shape of `study_attempts.result`.
- Persisting these values requires mapper/storage alignment and tests.

**Target storage:** `study_attempts.result` TEXT, snake_case (`perfect`, `initial_passed`, `recovered`, `forgot`) after the approved migration/mapper update.

**Target mapping to SRS box change:**

| Result | box_after |
| --- | --- |
| `perfect` | `current + 1` (cap 8) |
| `initialPassed` | `current + 1` (cap 8) |
| `recovered` | `current` (stay) |
| `forgot` | `1` (reset) + `lapse_count++` |

**Box field naming:**

Target docs use `box_before` / `box_after`.
If a current/legacy implementation uses `old_box` / `new_box`, map:

| Current/legacy | Target |
| --- | --- |
| `old_box` | `box_before` |
| `new_box` | `box_after` |

Use target names in new docs. Migration or mapper compatibility is required before writing target field names directly to storage.

Source: `docs/business/srs/srs-review.md`.

### StudyMode

**Status:** Target domain type.

The 5 modes of card interaction.

```dart
enum StudyMode {
  review,   // Both sides shown together on one card; swipe-to-grade (right=perfect, left=forgot)
  match,    // 5-pair board (10 cells); tap-pair to match; per-pair persistence
  guess,    // Front shown; pick correct back from 5 rich option cards (title + description)
  recall,   // Front shown; tap Show answer to reveal; self-grade Forgot / Got it (no text input in v1)
  fill,     // Back shown as hint; type front in plain text input; strict match
}
```

**Ownership / storage rule:**

- Study mode belongs to session planning / session item / queue context.
- Do not assume `study_attempts.study_mode` exists or is required unless a migration explicitly adds it.
- Attempts may reference session items, and session items may own mode/round/queue metadata.

**Direction summary:**

| Mode | Direction |
| --- | --- |
| review, match | Both sides visible (no direction in the recognition sense) |
| guess, recall | front → back (recognition or production) |
| fill | back → front (production: user produces the front) |

Source: `docs/business/study/study-flow.md`.

### EntryType

How a study session was started.

**Current core entries:**

```dart
enum EntryType {
  deck,    // entry_ref_id = deck id
  folder,  // entry_ref_id = folder id (recursive)
  today,   // entry_ref_id = null (global)
}
```

**Target / Future Proposal entry:**

```dart
// Target/Future Proposal: requires tag-study query + storage support.
tag // entry_ref_id = sorted lowercased comma-joined tag names
```

**Storage rule:**

- Current core storage supports `deck`, `folder`, and `today`.
- `tag` is a target/future tag-study entry and must not be treated as current unless the implementation/migration task explicitly adds support.

**entry_ref_id rules:**

- `deck` / `folder`: UUID string.
- `today`: NULL.
- `tag` target behavior: lowercased tag names, sorted alphabetically, joined by comma. Example: `"grammar,weak"` for tags #Weak + #Grammar.

Source: `docs/business/study/study-flow.md`, `docs/business/tags/tag-system.md`.

### StudyType

The intent of a session.

```dart
enum StudyType {
  newCards,    // New learning (cards never studied or in box 1)
  srsReview,   // Due-card review
}
```

**Storage:** `study_sessions.study_type` TEXT, snake_case (`new_cards`, `srs_review`).

### SessionStatus

Lifecycle of a study session.

```dart
enum SessionStatus {
  draft,                // Created but no attempts yet
  inProgress,           // Has at least one attempt, not finalized
  completed,            // All planned items answered + finalized
  cancelled,            // User discarded
  failedToFinalize,     // Items written but summary aggregate failed
}
```

**Storage:** `study_sessions.status` TEXT, snake_case (`draft`, `in_progress`, `completed`, `cancelled`, `failed_to_finalize`).

**Resumable when:** `status IN (draft, inProgress)` AND `started_at > now - 30 days`.

Source: `docs/business/resume/resume-session.md`.

### ContentMode

What a folder is allowed to contain.

```dart
enum ContentMode {
  unlocked,     // Empty, can become subfolders or decks mode
  subfolders,   // Locked to subfolders only
  decks,        // Locked to decks only
}
```

**Storage:** `folders.content_mode` TEXT, lowercase.

Source: `docs/business/folder/folder-management.md`.

### TargetLanguage

The language of a deck's front field. Drives TTS gating.

```dart
enum TargetLanguage {
  korean,
  english,
  unsupported,  // TTS disabled for this deck
}
```

**Storage:** `decks.target_language` TEXT, lowercase. Default `'korean'` (per pending migration).

**TTS gate:** only `korean` and `english` enable TTS UI in study modes.

Source: `docs/business/deck/deck-management.md`, `docs/business/tts/tts-settings.md`.

### TtsLanguageCode

Speech engine language codes (NOT the same as `TargetLanguage` — these are platform engine identifiers).

```dart
enum TtsLanguageCode {
  koKR,  // 'ko-KR'
  enUS,  // 'en-US'
}
```

Mapping: `TargetLanguage.korean → koKR`, `TargetLanguage.english → enUS`, `TargetLanguage.unsupported → no TTS`.

### ValidationCode

See `docs/contracts/error-contract.md` §ValidationFailure subtypes for full enum and meaning.

### NetworkErrorKind, StorageOp

See `docs/contracts/error-contract.md` for definitions.

## Typedefs / value objects

### BoxNumber

```dart
typedef BoxNumber = int;  // 1..8 inclusive
```

Asserted at boundaries (use case input, DAO output). NOT a freezed class for ergonomic reasons; assertion on construction.

### FlashcardId, DeckId, FolderId, TagName, SessionId

```dart
typedef FlashcardId = String;
typedef DeckId = String;
typedef FolderId = String;
typedef TagName = String;     // already-normalized (lowercased, trimmed)
typedef SessionId = String;
```

All UUIDs except `TagName` (which is the lowercased trimmed string itself).

### EntryRefId

```dart
typedef EntryRefId = String?;  // nullable for entry_type=today
```

### DeviceLabel

```dart
typedef DeviceLabel = String;  // user-editable, max 50 chars
```

### Fingerprint

```dart
typedef Fingerprint = String;  // SHA-256 hex of canonical DB content
```

### DailyGoal

```dart
typedef DailyGoal = int;  // 5..200 inclusive, step 5
```

Asserted at SharedPreferences setter.

## Value objects (freezed)

### CardState

Computed at query time, NOT stored. Captures the "show this badge" priority.

```dart
@freezed
sealed class CardState with _$CardState {
  const factory CardState.active() = _Active;
  const factory CardState.due() = _Due;
  const factory CardState.buried(DateTime until) = _Buried;
  const factory CardState.suspended() = _Suspended;
}
```

**Priority** (per `docs/wireframes/06-flashcard-list.md`): Suspended > Buried > Due > Active.

### StudyScope

Resolved scope of a study session.

```dart
@freezed
class StudyScope with _$StudyScope {
  const factory StudyScope({
    required EntryType entryType,
    required EntryRefId entryRefId,
    required StudyType studyType,
  }) = _StudyScope;
}
```

Equality based on all 3 fields. Used by resume matching.

### AttemptResultDetails

Returned by mode-specific grading logic.

```dart
@freezed
class AttemptResultDetails with _$AttemptResultDetails {
  const factory AttemptResultDetails({
    required AttemptResult result,
    required BoxNumber boxBefore,
    required BoxNumber boxAfter,
    String? userInput,  // for recall/fill
    bool overrideApplied,  // true if user used "I knew it" / "Mark correct"
  }) = _AttemptResultDetails;
}
```

### LifetimeStats

Per-card aggregate (read-only).

```dart
@freezed
class LifetimeStats with _$LifetimeStats {
  const factory LifetimeStats({
    required int reviewCount,
    required int lapseCount,
    required double accuracy,  // (reviewCount - lapseCount) / reviewCount
    required BoxNumber currentBox,
    required DateTime? lastStudiedAt,
    required DateTime? lastResetAt,
  }) = _LifetimeStats;
}
```

### SessionAggregate

Used by study result screen.

```dart
@freezed
class SessionAggregate with _$SessionAggregate {
  const factory SessionAggregate({
    required SessionId sessionId,
    required int totalCards,
    required Map<AttemptResult, int> resultCounts,
    required int advancedCount,
    required int stayedCount,
    required int resetCount,
    required int reachedMaxBox,
    required double accuracy,
    required Duration duration,
  }) = _SessionAggregate;
}
```

## Forbidden synonyms

Add forbidden synonym entries only after observed drift in docs, code, or reviews. Do not add speculative bans.

To prevent agent drift, the following are **canonical** — agents MUST NOT introduce variations:

| Canonical | Forbidden synonyms |
| --- | --- |
| `AttemptResult` | `GradingResult`, `AnswerResult`, `Outcome` |
| `StudyMode` | `Mode`, `GameMode`, `StudyKind` |
| `EntryType` | `StudyEntry`, `ScopeType` |
| `StudyType` | `SessionType`, `StudyIntent` |
| `SessionStatus` | `SessionState`, `StudyStatus` |
| `ContentMode` | `FolderMode`, `FolderType` |
| `TargetLanguage` | `Language`, `DeckLanguage`, `FrontLanguage` (legacy) |
| `BoxNumber` | `Box`, `Level`, `SrsBox` |
| `CardState` | `FlashcardStatus`, `CardStatus` |

When in doubt, grep this file. If a name isn't here, propose it via this catalog FIRST before introducing in code.

## Source files

Each enum/typedef/value object lives in:

```
lib/domain/types/
├── attempt_result.dart
├── study_mode.dart
├── entry_type.dart
├── study_type.dart
├── session_status.dart
├── content_mode.dart
├── target_language.dart
├── tts_language_code.dart
├── box_number.dart           (typedef + assertion helpers)
├── ids.dart                  (FlashcardId, DeckId, FolderId, ...)
├── card_state.dart           (freezed sealed)
├── study_scope.dart          (freezed)
├── attempt_result_details.dart
├── lifetime_stats.dart
└── session_aggregate.dart
```

Type imports should always be from `lib/domain/types/` (or its barrel `lib/domain/types/types.dart`), never duplicated per feature.

## Agent rule

- When implementing a use case, repository, or notifier: import enums/typedefs from `lib/domain/types/`, never redeclare.
- When adding a new enum value: update this catalog, update relevant business spec, update relevant ARB keys, update DB serialization mapper, update tests — all in one commit.
- When you find a synonym in code or docs (e.g., `GradingResult` instead of `AttemptResult`): fix it in the same commit and report under "Drift detected".

## Related

**Contracts:**

- `docs/contracts/error-contract.md` — `ValidationCode`, `NetworkErrorKind`, `StorageOp` live there
- `docs/contracts/code-style.md` — naming conventions
- `docs/testing/test-strategy.md` — type usage in tests

**Business specs:**

- Every business spec uses these types; this catalog is the registry.

**Schema:**

- `docs/database/schema-contract.md` — column types map to enums here

**Code paths:**

- `lib/domain/types/**`

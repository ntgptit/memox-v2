---
last_updated: 2026-05-26
applies_to: all areas
---

# Glossary

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Centralized vocabulary for MemoX. When a term appears in any doc, this file defines it.

## Entity terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Folder | Organizes subfolders or decks. Has content_mode. | `docs/business/folder/folder-management.md` |
| Deck | Container of flashcards. Belongs to exactly one folder. | `docs/business/deck/deck-management.md` |
| Flashcard | Learning unit with front/back/optional fields. Belongs to one deck. | `docs/business/flashcard/flashcard-management.md` |
| Flashcard progress | Per-card SRS state (box, due_at, counters). | `docs/business/srs/srs-review.md` |
| Study session | Persisted learning/review session bound to scope. | `docs/business/study/study-flow.md` |
| Study session item | Queued card task within a session. | `docs/business/study/study-flow.md` |
| Study attempt | Single answer attempt within a session item. | `docs/business/study/study-flow.md` |
| TTS settings | Audio/speech preferences. | `docs/business/system/overview.md` |

## Mode/type terms

These four terms are NOT interchangeable. Confusing them is a common bug source.

| Term | Definition | Example values |
| --- | --- | --- |
| Content mode | Lock state of a folder | `unlocked`, `subfolders`, `decks` |
| Entry type | How user starts study | `deck`, `folder`, `today`, `tag` |
| Study type | Nature of the session | `new`, `srs_review` |
| Study flow | Ordered sequence of modes within one session | `new_full_cycle`, `srs_fill_review`, ... |
| Study mode | One interaction style within a flow | `review`, `match`, `guess`, `recall`, `fill` |

Relationship:

```text
User picks entry_type + scope
  → System resolves study_type and study_flow
    → Flow is composed of one or more study_modes
      → Each card is presented in current study_mode
```

## SRS terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Box | Leitner box position (1 to 8) | `docs/business/srs/srs-review.md` |
| Due | Card whose `due_at <= now` and not suspended/buried | `docs/business/srs/srs-review.md` |
| Interval | Time until next due based on current box | `docs/business/srs/srs-review.md` |
| Lapse | Failed review (forgot) | `docs/business/srs/srs-review.md` |
| Result | Outcome of an attempt for SRS computation | `docs/business/srs/srs-review.md` |

## Study action terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Bury | Hide a card from study queues until next local-day midnight | `docs/business/study-actions/bury-suspend.md` |
| Suspend | Hide a card from study queues indefinitely until user unsuspends | `docs/business/study-actions/bury-suspend.md` |
| Resumable session | Study session with status `in_progress` or `draft` | `docs/business/resume/resume-session.md` |
| Continue surface | Dashboard card or screen banner promoting resume | `docs/business/resume/resume-session.md` |
| Auto-expiry | Resumable session older than 30 days auto-cancelled on next open | `docs/business/resume/resume-session.md` |

## Engagement terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Daily goal | Target number of card answers per local-day | `docs/business/engagement/dashboard-engagement.md` |
| Daily progress | Count of answers today against the goal | `docs/business/engagement/dashboard-engagement.md` |
| Streak | Consecutive local-days the user met the goal | `docs/business/engagement/dashboard-engagement.md` |
| Goal-met day | A local-day where progress reached the goal | `docs/business/engagement/dashboard-engagement.md` |
| Day boundary | Local timezone midnight | `docs/business/engagement/dashboard-engagement.md` |
| Reminder | Single optional daily local notification at user-chosen time | `docs/business/engagement/dashboard-engagement.md` |

## Organization terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Tag | Free-form label on a flashcard, global by name, case-insensitive | `docs/business/tags/tag-system.md` |
| Tag filter | Multi-select AND filter on flashcard list / search | `docs/business/tags/tag-system.md` |
| Study-by-tag | `entry_type=tag` study session scoped to one or more tags | `docs/business/tags/tag-system.md` |
| Selection mode | Multi-select state in flashcard list for bulk operations | `docs/business/bulk/bulk-operations.md` |
| Bulk action | Atomic operation on multiple selected cards | `docs/business/bulk/bulk-operations.md` |

## Discovery terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Global search | Library-level search across folders/decks/flashcards/tags | `docs/business/search/global-search.md` |
| Recursive search | Default search behavior: descends into all subfolders/decks under current scope | `docs/business/search/global-search.md` |
| Card history | Per-card timeline of `study_attempts` | `docs/business/history/card-history.md` |
| Progress reset | User action to set `flashcard_progress` back to box=1 while retaining attempts | `docs/business/history/card-history.md` |
| Reset divider | Visual marker in card history timeline separating pre-reset and post-reset attempts | `docs/business/history/card-history.md` |
| `last_reset_at` | Timestamp on `flashcard_progress` marking the most recent reset; null if never reset | `docs/business/history/card-history.md` |
| `box_before` / `box_after` | Per-attempt SRS box values stored on `study_attempts` | `docs/business/history/card-history.md` |

## TTS terms

| Term | Definition | Defined in |
| --- | --- | --- |
| TTS | Text-to-speech | `docs/business/tts/tts-settings.md` |
| TTS language | Speech locale (`korean`/`ko-KR` or `english`/`en-US`) | `docs/business/tts/tts-settings.md` |
| Deck target language | Per-deck language declaration that gates TTS for that deck | `docs/business/deck/deck-management.md` |
| TTS voice | Platform-specific voice id within a language | `docs/business/tts/tts-settings.md` |
| Playback policy | Rule restricting which card side can be spoken (currently only `front`) | `docs/business/tts/tts-settings.md` |
| Auto-play | Toggle to speak prompt automatically on card reveal | `docs/business/tts/tts-settings.md` |
| TTS state | Playback state (`idle`, `speaking`, `paused`, `error`) | `docs/business/tts/tts-settings.md` |

## Export terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Export format | `csv` or `excel` (`.xlsx`) | `docs/business/export/export.md` |
| Export scope | `deck` (all cards in a deck) or `selection` (chosen card IDs) | `docs/business/export/export.md` |
| ExportData | Value object with `fileName`, `mimeType`, `bytes` | `docs/business/export/export.md` |
| Share sheet | Platform output target (via `share_plus`); no fixed file path | `docs/business/export/export.md` |

## Account / Sync terms

| Term | Definition | Defined in |
| --- | --- | --- |
| Cloud account link | Persisted record of a linked Google account | `docs/business/account-sync/account-sync.md` |
| Subject id | Google `sub` claim; stable account identity | `docs/business/account-sync/account-sync.md` |
| Drive AppData scope | OAuth scope for the app's private Drive folder | `docs/business/account-sync/account-sync.md` |
| Drive authorization state | `notRequested`, `authorized`, `authorizationRequired`, `denied` | `docs/business/account-sync/account-sync.md` |
| Account link status | `signedOut`, `signedIn`, `needsDriveAuthorization`, `unconfigured`, `unsupported`, `error` | `docs/business/account-sync/account-sync.md` |
| Account database context | Per-account Drift database file (guest or `{subjectId}`) | `docs/business/account-sync/account-sync.md` |
| Snapshot | Archive of database bytes + settings JSON for Drive upload | `docs/business/account-sync/account-sync.md` |
| Manifest | Metadata describing a snapshot (versions, hashes, device, account) | `docs/business/account-sync/account-sync.md` |
| Fingerprint | Hash-based identity for change detection between local and remote | `docs/business/account-sync/account-sync.md` |
| Device id | Persistent per-device id used for cross-device sync detection | `docs/business/account-sync/account-sync.md` |
| Sync metadata | SharedPreferences record of last successful sync per account | `docs/business/account-sync/account-sync.md` |
| Sync status | Current sync state (`signedOut`, `noRemoteSnapshot`, `ready`, `synced`, ...) | `docs/business/account-sync/account-sync.md` |
| Sync action | User-triggered op (`uploadLocal`, `restoreRemote`, `loadStatus`) | `docs/business/account-sync/account-sync.md` |
| Restore effect | Required post-restore UI step (`refreshDatabaseProvider` or `reloadApp`) | `docs/business/account-sync/account-sync.md` |

## Infrastructure terms

| Term | Definition | Defined in |
| --- | --- | --- |
| DAO | Data Access Object, only layer touching Drift | `docs/architecture/clean-architecture-contract.md` |
| Repository | Domain-facing data layer, returns `Either<Failure, T>` | `docs/architecture/clean-architecture-contract.md` |
| Use case | Single business operation, orchestrates repositories | `docs/architecture/clean-architecture-contract.md` |
| Notifier | Riverpod action controller, mutates state | `docs/state/state-management-contract.md` |
| ViewModel | UI-facing state holder for a screen | `docs/state/state-management-contract.md` |
| Revision | Counter to invalidate cached UI lists after mutation | `docs/database/storage-boundaries.md` |
| Source of truth | Local Drift database for persistent data | `docs/database/storage-boundaries.md` |
| Shared widget | `Mx*` widget in `lib/presentation/shared/**` | `docs/ui-ux/ui-ux-contract.md` |

## Status terms (study session lifecycle)

| Status | Meaning |
| --- | --- |
| `draft` | Created but not started |
| `in_progress` | User is actively studying |
| `ready_to_finalize` | All items answered, awaiting commit |
| `completed` | Finalized successfully |
| `failed_to_finalize` | Finalize failed, recoverable |
| `cancelled` | User exited before completion |

## Result terms (per-attempt SRS outcome)

| Result | Meaning |
| --- | --- |
| `initial_passed` | Correct on first try |
| `perfect` | Correct without any retry within current cycle |
| `recovered` | Correct after retry |
| `forgot` | Failed, will lapse |

## Agent rule

When introducing a new term, add it here before using it in any other doc.

When a doc uses ambiguous wording, refer here instead of redefining locally.

## Related

This glossary is referenced by every business spec, decision table, and wireframe.

**Wireframes:**

- `docs/wireframes/index.md` — every wireframe assumes glossary terms

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` — uses terms defined here

**Schema:**

- `docs/database/schema-contract.md` — column names are aligned to glossary terms (e.g., `entry_ref_id`, `box_before`, `last_reset_at`)

**Maintenance rule:**

- When renaming a term, run `grep -rn "{old_term}" docs/` and update ALL refs in the same commit, including this glossary. Per `CLAUDE.md` §Doc-code parity rule.

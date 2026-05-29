---
last_updated: 2026-05-26
status: contract
---

# Performance Contract

Concrete budgets per screen / operation.

> **Status: target, not baseline.** Numbers below are product expectations derived from typical Flutter app norms, not measured against the current MemoX implementation (which does not yet exist). When implementation begins, measure on the reference device (Pixel 6) and add a **measured baseline** column. Until then, treat these as upper bounds for design choices, not pass/fail gates.
>
> When a measurement contradicts a target, do NOT silently lower the target. Either: (a) update the target with a written reason (in this file), or (b) optimize the code.

Reference device: Pixel 6 emulator, release mode, fresh app state.

## Frame & rebuild budget

| Target | Value |
| --- | --- |
| Frame budget | 16ms (60fps); 8ms (120fps where supported) |
| Cold start to Dashboard interactive | < 800ms on mid-range Android (Pixel 6) |
| Tab switch (Dashboard ↔ Library ↔ Progress ↔ Settings) | < 100ms perceived |
| Pull-to-refresh latency | < 500ms to start showing data |
| Skeleton-to-content transition | smooth, no layout shift |

## Per-screen budgets

| Screen | Cold open | Warm open | Notes |
| --- | --- | --- | --- |
| Dashboard | < 600ms | < 200ms | Parallel queries; skeleton per card |
| Library (50 items) | < 200ms | < 100ms | Stream-based list, virtualized |
| Library (1000 items) | < 500ms | < 200ms | `ListView.builder` mandatory |
| Folder detail | < 300ms | < 150ms | Recursive count cached 30s |
| Flashcard list (100 cards) | < 200ms | < 100ms | |
| Flashcard list (1000 cards) | < 400ms | < 200ms | Virtualized, sort+filter indexed |
| Flashcard list (10000 cards) | < 800ms | < 400ms | Same with proper indexes |
| Study session card transition | < 100ms | n/a | Pre-fetch next card during grade |
| Study result | < 300ms | n/a | Single aggregate query |
| Settings hub | < 200ms | < 100ms | Subtitles lazy |
| Library search (per keystroke after 300ms debounce) | < 300ms | n/a | 4 parallel section queries |
| Card history (page of 50) | < 250ms | < 150ms | Cursor pagination |

## Database query budget

| Operation | Target | Index requirement |
| --- | --- | --- |
| Any single index lookup | < 5ms | Required |
| Any single full scan up to 10k rows | < 50ms | Acceptable for one-off |
| Recurring full scan in stream | NOT acceptable | Add index |
| Bulk transaction (1000 cards) | < 2s | Chunked acceptable |
| Migration step | < 5s on 50k-row DB | Tested on fixture |
| Fingerprint computation (full DB) | < 1s on 10k-card DB | Streaming hash |

### Index requirements (already specified in schema-contract.md)

- `flashcard_progress(is_suspended, buried_until, due_at)` — for due queries
- `flashcard_tags(LOWER(tag), flashcard_id)` — for case-insensitive tag lookup
- `study_attempts(flashcard_id, attempted_at DESC)` — for card history pagination
- `study_attempts(box_after)` — for box distribution aggregate
- `study_sessions(entry_type, entry_ref_id, status, started_at DESC)` — for resumable lookup
- `flashcards(deck_id)` — implicit FK index

If a feature requires a query the existing indexes cannot serve efficiently, add the index (with migration) in the same commit.

## Async / parallel patterns

| Pattern | When |
| --- | --- |
| `Future.wait([...])` | When 2+ independent IOs needed before render. Dashboard, study entry gate. |
| Background isolate | Heavy parse (import > 1000 rows), fingerprint compute |
| Stream debounce | Search input (300ms), slider (auto-save 500ms) |
| Riverpod `keepAlive` | Sparingly. Default = auto-dispose. Streak/goal aggregates are good candidates. |
| Pagination | Card history (cursor), large lists |

## TTS latency

| Operation | Target |
| --- | --- |
| TTS engine init at session start | < 200ms (lazy if possible) |
| First-play latency after engine ready | < 300ms |
| Subsequent plays | < 200ms |
| Stop playback | < 50ms |

If engine init blocks UI in study session, agent MUST move it to background and gate the 🔊 button.

## Sync operations

| Operation | Target |
| --- | --- |
| Upload to Drive (10MB DB) | < 5s on broadband |
| Fetch manifest | < 1s |
| Download DB (10MB) | < 5s |
| Snapshot creation (10MB DB) | < 500ms |
| Restore replace (10MB DB) | < 1s after download complete |

## Memory budget

| Metric | Target |
| --- | --- |
| Resident memory (idle Dashboard) | < 80MB |
| Resident memory (study session active) | < 150MB |
| Resident memory (1000-card flashcard list) | < 120MB |
| Resident memory (import 10000 cards preview) | < 200MB, prefer streaming parse |

## Widget rebuild rules

- Watch providers at the SMALLEST reasonable scope. Don't watch a high-level provider in `Scaffold` if only `Text` needs it.
- Use `Consumer` widget locally instead of making the whole widget a `ConsumerWidget`.
- Use `select` to subscribe to a single field of a complex state.
- `ListView.builder` for any list > 10 items.
- `const` constructors wherever the widget is static.
- Avoid `setState` cascades from deeply nested widgets — propagate state via Riverpod.

## Forbidden patterns

- ❌ `flashcards.where(...).map(...).toList()` inside `build()`. Move to notifier or memoized selector.
- ❌ DB read in `initState` of any widget. Notifier owns this.
- ❌ `Future` not awaited in async use case (unintended fire-and-forget).
- ❌ `Future.delayed` for "wait for animation" in production. Use animation completion.
- ❌ Per-card DB query in a list (N+1 problem). Always JOIN at repository.
- ❌ Repeated `MediaQuery.of(context)` in a single build. Read once at top.
- ❌ Unbounded `ListView` (without `.builder`).
- ❌ Synchronous file IO on main isolate.
- ❌ Unscoped `keepAlive` (don't pin every provider).

## Required patterns

- ✅ Profile mode test for any new screen on first implementation. Record baseline.
- ✅ Trace event for use case start/end if perf-sensitive.
- ✅ Background isolate for compute > 100ms.
- ✅ Bulk transaction chunked at 500 rows max (SQLite param limit safety).
- ✅ Skeleton states < 200ms blink — show data when ready, don't hold skeleton longer than data.

## Measurement

- DevTools profile recording attached to PR for any screen budget claim.
- Add `--profile` build to CI on tagged releases (future).
- For now: spot-check via `flutter run --profile` on Pixel 6 emulator or physical device.

## Agent rule

- When implementing a screen, check the budget row above. If estimated exceed, design alternative (cache, paginate, index) BEFORE writing.
- When a query joins multiple tables, verify indexes cover the WHERE clauses.
- When a feature claims "instant" (e.g., undo toast), it's < 100ms latency.

## Related

**Repo-level:**

- `CLAUDE.md` — Doc-code parity, performance budget changes require update here

**Contracts:**

- `docs/contracts/code-style.md` — widget rebuild rules
- `docs/contracts/repository-contracts/index.md` — transaction requirements

**Database:**

- `docs/database/schema-contract.md` — index list
- `docs/database/migration-contract.md` — adding indexes via migration

**Wireframes:**

- All — each wireframe has a Performance section that should align with budgets here

**Code paths:**

- `lib/core/perf/**` — trace helpers (planned)

---
last_updated: 2026-05-30
status: contract
---

# Agent Task Template

Template for giving a coding task to an AI agent (Claude Code, Cursor, etc.). Copy-paste, fill in, submit. Reduces variance across sessions.

---

## Read first (always)

- `CLAUDE.md` — top-level agent rules, especially Doc-code parity
- `AGENTS.md` — responsibilities, reporting
- `docs/business/index.md` — business spec map
- `docs/business/glossary.md` — domain terms

## Read for this task

- `docs/wireframes/{N-screen}.md` — UI contract for the screen
- `docs/business/{feature}/{spec}.md` — business behavior
- `docs/contracts/usecase-contracts/{entity}.md` — use case contracts
- `docs/contracts/repository-contracts/{entity}-repository.md` — data layer contract
- `docs/contracts/error-contract.md` — failure types
- `docs/contracts/types-catalog.md` — enums and value objects
- `docs/contracts/code-style.md` — naming, structure
- `docs/testing/test-strategy.md` — test layer mapping
- `docs/decision-tables/memox-core-decision-table.md` — rows: {LIST_RELEVANT_ROW_IDS}

(Add others as needed: state-management-contract.md, performance-contract.md, observability-contract.md, l10n-copy-contract.md.)

---

## Task

**Title:** {one-line task name}

**Type:** feature | fix | refactor | docs

**Description:**

{What needs to happen. Reference the business spec section and the decision rows. Keep this short — the docs above hold the detail.}

---

## Scope

**Allowed to change:**
- `lib/{specific paths}`
- `test/{specific paths}`
- `docs/{specific paths}` (per Doc-code parity — update if behavior changes)

**Not allowed to change:**
- {any out-of-scope files}
- Generated files (`*.g.dart`, `*.freezed.dart`)
- Schema (unless task is explicitly a migration)
- Top-level routes (unless task is explicitly routing)

---

## Expected behavior

- {bullet list of observable behaviors after this task is done, each ideally tied to a decision row or wireframe state}

---

## Out of scope / leave for later

- {explicit non-goals to prevent agent from scope-creeping}

---

## Verification

Run these commands and ensure they pass:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test {targeted_test_paths}
python code-verification-guard/guard/run.py check --project . --ruleset memox   # if guard present in repo; else skip and note in report
```

For UI-touching tasks, also run a profile-mode build on Pixel 6 emulator and verify the perf budget from `docs/quality/performance-contract.md`.

---

## UI Density Gate (required for UI tasks)

Before finishing any task that adds or changes buttons, CTAs, or card actions,
report against `docs/ui-ux/action-hierarchy-contract.md`:

- [ ] **Compact mobile review** — checked at 360dp; no overflow, no hero block in cards.
- [ ] **Dominant primary count** — exactly one visually dominant primary action per screen (state the count).
- [ ] **Full-width buttons added** — list each, with the allowed context (bottom action / footer / empty state / onboarding / specified study submit) or a `// guard:full-width-action-reviewed <reason>` comment.
- [ ] **Large buttons added** — list each `MxButtonSize.large`, with the allowed context.
- [ ] **No card-level violation** — verified no card/list/dashboard widget uses `large` or `fullWidth` outside the allowed contexts.
- [ ] **Semantic preference** — used `MxActionButton` / `MxCardActions` rather than raw `MxPrimaryButton` / `MxSecondaryButton` where applicable.

If any box cannot be ticked, stop and explain why instead of shipping.

---

## Output required

Reply with the report format from `docs/checklist/implementation-checklist.md` §Final report template. At minimum:

- **Summary** — 1-3 sentences
- **Changed code files** — paths
- **Changed doc files** — paths (or explicit "no docs needed because: …")
- **Doc-code parity check** — 8 ticks from `CLAUDE.md` §Pre-commit parity check
- **Drift detected during task** — any legacy mismatches found
- **Business impact** — what user sees that's different
- **Route impact** — routes added/changed
- **Persistence impact** — schema/storage changes
- **UI impact** — screens/widgets changed
- **Decision table/test impact** — row IDs touched, tests added
- **Verification result** — pass/fail per command above
- **Skipped checks or risks** — explicit, with reason

If the task cannot be completed safely without violating a hard rule, stop and report instead of working around it.

---

## Example fill-in

> **Title:** Implement Dashboard resume card
>
> **Type:** feature
>
> **Description:**  
> Implement the Resume Card on `/home` per `docs/wireframes/01-dashboard.md` §Resume card. Surface most recent resumable session with Continue and Discard actions. Hide when no resumable session exists.
>
> **Read for this task:**  
> - `docs/wireframes/01-dashboard.md`  
> - `docs/business/resume/resume-session.md`  
> - `docs/contracts/usecase-contracts/study.md` §FindResumableSessionUseCase, §CancelSessionUseCase  
> - `docs/contracts/repository-contracts/study-repository.md`  
> - `docs/decision-tables/memox-core-decision-table.md` rows: S-resume-1, S-resume-2, S-resume-3
>
> **Scope:**  
> - `lib/presentation/features/dashboard/widgets/resume_card.dart` (new)  
> - `lib/presentation/features/dashboard/notifiers/dashboard_notifier.dart` (extend)  
> - `lib/domain/usecases/study/find_resumable_session_usecase.dart` (verify exists; create if missing)  
> - `test/presentation/features/dashboard/resume_card_test.dart` (new)  
> - `lib/l10n/app_en.arb` (add `dashboard_resume_card_title`, `dashboard_resume_card_subtitle` if missing)
>
> **Not allowed to change:**  
> - Other Dashboard widgets (streak, goal, today CTA)  
> - Repository implementations
>
> **Expected behavior:**  
> - Visible iff ≥1 row in `study_sessions` matches resumable filter.  
> - Subtitle format: "{deckName} · {answered} / {total} cards · {timeAgo}".  
> - Tap Continue → navigate via `push` to `/library/study/session/{id}`.  
> - Tap Discard → show `MxDialogDiscardSession` → on confirm: `CancelSessionUseCase`.  
> - When ≥2 paused sessions: show "{n-1} more paused sessions" link → opens §paused-sessions sheet.

---

## Anti-patterns to call out in task

If you suspect the agent may go off-rails, explicitly forbid in task:

- "Do not extend repository signature beyond methods listed in contract."
- "Do not introduce a new Failure subtype."
- "Do not add new top-level route."
- "Do not change SRS interval table."
- "Do not modify schema."
- "Do not log card content."

## Related

**Repo-level:**
- `CLAUDE.md`, `AGENTS.md`

**Process:**
- `docs/checklist/implementation-checklist.md` — full report template
- `docs/checklist/recursive-agent-review.md` — review checklist

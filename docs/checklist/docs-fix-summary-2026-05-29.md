---
last_updated: 2026-05-29
author: technical lead
status: completed docs fix summary
purpose: Summarize the documentation cleanup applied before repackaging docs.
---

# Docs Fix Summary — 2026-05-29

## Fixed

1. Clarified that this archive is the `docs/` subtree only.
   - `CLAUDE.md` and `AGENTS.md` live at project root intentionally.
   - Updated `docs/MANIFEST.md` and `docs/README.md` accordingly.

2. Added V1 scope guard.
   - New file: `docs/checklist/v1-implementation-scope-2026-05-29.md`.
   - Agents must read it before picking work from the screen/function matrix.

3. Resolved the three formerly pending product decisions.
   - Flashcard History: Future Proposal for V1.
   - Global Search screen: Future Proposal for V1; inline/scope-local search remains V1 guideline.
   - Full Onboarding flow: Future Proposal for V1; zero-content empty-state CTAs are V1 scope.

4. Updated implementation coordination files.
   - `docs/checklist/product-decisions-pending-2026-05-29.md` now records resolved decisions.
   - `docs/checklist/screen-function-task-matrix.md` adds `Future` status and retags affected rows.
   - `docs/checklist/wireframe-code-parity-assessment.md` updated to Rev 4 for scope-resolution.

5. Updated affected business/wireframe/contract docs.
   - `docs/wireframes/09-flashcard-history.md`
   - `docs/business/history/card-history.md`
   - `docs/contracts/usecase-contracts/history.md`
   - `docs/wireframes/11-library-search.md`
   - `docs/business/search/global-search.md`
   - `docs/contracts/usecase-contracts/search.md`
   - `docs/wireframes/23-onboarding.md`
   - `docs/business/system/overview.md`

6. Added migration gate note.
   - `docs/database/schema-contract.md` now separates pending columns from implementation approval.

7. Added acceptance criteria placeholder folder.
   - New file: `docs/acceptance-criteria/README.md`.

8. Updated mock design mapping.
   - Flashcard History, Library Search and Onboarding mock variants are now marked as future visual references where appropriate.

## Result

The docs are now safer for AI-agent implementation because complete target specs no longer imply V1 approval.

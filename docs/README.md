# MemoX

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.


MemoX is a local-first Flutter flashcard learning app.

The app helps users organize learning content into folders, decks, and flashcards, then study and review cards through persisted learning sessions and spaced repetition.

## Stack

- Flutter, Dart 3
- Material 3
- Riverpod annotation v3
- Drift SQLite
- GoRouter
- fpdart Either (Target; requires approved dependency/API migration before implementation if not adopted)
- freezed
- ARB localization
- MemoX Design System
- code-verification-guard

## Main areas

- Dashboard
- Library
- Folder management
- Deck management
- Flashcard management
- Study session
- SRS review
- Progress
- Settings
- Audio/speech settings
- Optional account/backup

## Documentation map

| Area | Document |
| --- | --- |
| Agent entry | `CLAUDE.md` |
| Agent contract | `AGENTS.md` |
| Business index | `docs/business/index.md` |
| Glossary | `docs/business/glossary.md` |
| Product overview | `docs/business/system/overview.md` |
| Navigation | `docs/business/navigation/navigation-flow.md` |
| Folder | `docs/business/folder/folder-management.md` |
| Deck | `docs/business/deck/deck-management.md` |
| Flashcard | `docs/business/flashcard/flashcard-management.md` |
| Study | `docs/business/study/study-flow.md` |
| SRS | `docs/business/srs/srs-review.md` |
| Bury / suspend | `docs/business/study-actions/bury-suspend.md` |
| Resume session | `docs/business/resume/resume-session.md` |
| Tag system | `docs/business/tags/tag-system.md` |
| Bulk operations | `docs/business/bulk/bulk-operations.md` |
| Global search | `docs/business/search/global-search.md` |
| Card history | `docs/business/history/card-history.md` |
| Daily engagement | `docs/business/engagement/dashboard-engagement.md` |
| Export (CSV/Excel) | `docs/business/export/export.md` |
| TTS / audio | `docs/business/tts/tts-settings.md` |
| Account + Drive sync | `docs/business/account-sync/account-sync.md` |
| Database schema | `docs/database/schema-contract.md` |
| Storage boundary | `docs/database/storage-boundaries.md` |
| Migration | `docs/database/migration-contract.md` |
| Architecture | `docs/architecture/clean-architecture-contract.md` |
| UI/UX | `docs/ui-ux/ui-ux-contract.md` |
| System design / mock design | `docs/system-design/MemoX Design System/README.md` |
| State management | `docs/state/state-management-contract.md` |
| Decision table | `docs/decision-tables/memox-core-decision-table.md` |
| Implementation checklist | `docs/checklist/implementation-checklist.md` |
| Recursive review | `docs/checklist/recursive-agent-review.md` |

## Agent instruction

Before implementation, read in order:

1. `CLAUDE.md` (entry point)
2. `AGENTS.md` (agent contract)
3. `docs/business/index.md` and `docs/business/glossary.md`
4. Related docs under `docs/business/**`
5. Related docs under `docs/database/**`
6. Related architecture/UI/state docs
7. Related decision table
8. Related source files

Do not implement from assumption when repo contracts already exist.

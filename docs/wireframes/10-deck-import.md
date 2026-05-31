---
last_updated: 2026-05-28
route: /library/deck/:deckId/import
source_specs:
  - ../business/flashcard/flashcard-management.md (import section)
---

# 10 — Deck Import

## V1 verification status (2026-05-31, Prompt 17)

This screen is **partially Current**. The data model, parsers, duplicate policy, and commit transaction below are verified by code and tests. The **UI shape actually shipped in V1 is a single-screen inline bulk-add (Design mock `05d`), NOT the 3-step configure → preview → result flow drawn in the layout mocks below.** The richer flow is **Future**. Do NOT mark the whole screen Current and do NOT implement the 3-step flow as part of ordinary feature work (no visual redesign).

**Verified Current (behaviour + tests):**

- Route `/library/deck/:deckId/import` opens `DeckImportScreen`; reached only via the Flashcard List Import action (`pushDeckImport`). Shell navigation hidden (`test/app/router/app_router_test.dart` DT2).
- Close (✕) pops to the Flashcard List (fallback `goFlashcardList`). The import screen owns no Flashcard List row/bulk actions and exposes no Global Search, History, Drive sync, AI import, OCR import, or tag-scoped study.
- Invalid/missing `deckId` fails safely: `prepareImport` / `commitImport` surface a typed `NotFoundException` (`FailureType.notFound`) via snackbar, no crash, and no rows are written (`content_repository_test.dart` DT10/DT11).
- Source modes via top `MxTabBar`: **Text** (paste) and **File** (`.csv` / `.xlsx`, ≤ 10 MB, first sheet only for Excel + "first row is header" toggle).
- Formats Current: `ImportSourceFormat.csv`, `ImportSourceFormat.structuredText`, `ImportSourceFormat.excel` (DIY xlsx parser — single sheet, no formulas; see §Excel parser scope). Tested in `flashcard_import_support_test.dart` (DT1–DT8) + auto-detect cases.
- Separator: parser auto-detects tab/comma/slash/pipe/semicolon/colon and `Front:`/`Back:` blocks. **The UI surfaces only Tab / Comma / Pipe pills** (`_separatorLabels`); the other separators are reachable only via auto-detect, not an explicit control.
- Validation: front+back required; blank rows skipped; bad rows surfaced as `Line {n}` / `Row {n}` issues; `canCommit = previewItems.isNotEmpty && issues.isEmpty`. Commit button disabled otherwise.
- Duplicate policy Current: `skipExactDuplicates` only (trim + case-insensitive on front+back). In-file vs in-deck source recorded on each skipped item and surfaced as an aggregate **count badge** (`content_repository_test.dart` DT8/DT9).
- Commit: single transaction, inserts importable previewItems only, assigns `sort_order` after existing cards, initialises default SRS progress (box 1, no due). No partial insert when issues exist (`content_repository_test.dart` DT3/DT7). On success: deferred success snackbar + pop to Flashcard List.

**Future (Specified, not exposed in V1):**

- Separate 3-step flow with a standalone Preview route and a standalone **Result/confirmation screen** (step 3 mock). V1 uses an inline Paste/Preview pill and a footer commit, then returns to the list with a snackbar.
- Format **radio** (3 explicit options) + full **7-way separator dropdown** (Auto / Colon / Slash / Semicolon as explicit controls).
- Per-row **Skipped duplicates list** with In file / In deck badges (V1 shows an aggregate count badge only).
- Additional duplicate policies (merge / overwrite). Only skip-exact is Current.
- Discard-import confirm dialog on back/cancel (V1 ✕ pops directly).
- "Show all" pagination for > 50 rows, virtualized 10k list, background-isolate parse for > 1000 rows, and chunked-transaction inserts for > 500 rows (V1 uses one un-chunked transaction).
- AI import, OCR / image import, cloud file picker — out of V1 scope.

> The "Layout — step 1/2/3", "States", "Actions", and "Forbidden" sections below describe the **Future target flow**. Where they conflict with the implemented bulk-add, this status section is authoritative for V1.

## Purpose

Import flashcards from CSV, Excel, or pasted structured text. Two-step flow: configure source → preview → commit.

## Layout — step 1: configure source

```
┌───────────────────────────────────────┐
│ ←   Import to Korean N5         ⋮     │
├───────────────────────────────────────┤
│                                       │
│ SOURCE FORMAT                         │
│ ┌───────────────────────────────────┐ │
│ │ ◉ Structured text (paste)         │ │
│ │ ○ CSV file                        │ │
│ │ ○ Excel file                      │ │
│ └───────────────────────────────────┘ │
│                                       │
│ STRUCTURED TEXT OPTIONS               │  ← Shown only for structured text
│ Separator: [Auto ▾]                   │
│  options: Auto / Tab / Comma /        │
│  Colon / Slash / Semicolon / Pipe     │
│                                       │
│ EXCEL OPTIONS                         │  ← Shown only for Excel
│ ☑ First row is header                 │
│                                       │
│ DUPLICATE POLICY                      │
│ ◉ Skip exact duplicates (default)     │
│ (only policy supported)               │
│                                       │
│ PASTE CONTENT (structured text)       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요   Hello                 │ │  ← Large multi-line text area
│ │ 감사합니다   Thank you             │ │
│ │ 사랑해요    I love you             │ │
│ │ ...                                │ │
│ └───────────────────────────────────┘ │
│                                       │
│ [Load file...]                        │  ← Replaces paste for csv/excel
│ Korean-vocab.xlsx (loaded)            │  ← Shown after load
│                                       │
│                                       │
│  [    Preview    ]                    │  ← Primary CTA
│                                       │
└───────────────────────────────────────┘
```

## Layout — step 2: preview

```
┌───────────────────────────────────────┐
│ ←   Preview import                ⋮   │
├───────────────────────────────────────┤
│                                       │
│ SUMMARY                               │
│ ┌───────────────────────────────────┐ │
│ │ ✓ Will import:        18 cards    │ │
│ │ ⊘ Skipped duplicates:  3 cards    │ │
│ │ ⚠ Validation issues:   2          │ │
│ └───────────────────────────────────┘ │
│                                       │
│ VALIDATION ISSUES (2)                 │  ← Section only if > 0
│ ┌───────────────────────────────────┐ │
│ │ Line 5: back is required.         │ │
│ │ Line 12: back exceeds 500 chars.  │ │
│ └───────────────────────────────────┘ │
│ ⓘ Fix in source and re-import.        │
│                                       │
│ SKIPPED DUPLICATES (3)                │  ← Section only if > 0
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요 — Hello   [In deck]    │ │  ← Badge: In file / In deck
│ │ 감사합니다 — Thank you [In deck]  │ │
│ │ 사랑해요 — I love you [In file]   │ │
│ └───────────────────────────────────┘ │
│                                       │
│ CARDS TO IMPORT (18)                  │
│ ┌───────────────────────────────────┐ │
│ │ 1. 만나서 — Nice to meet           │ │
│ │ 2. 잘 가요 — Goodbye               │ │
│ │ ... (showing 1-50 of 18 if > 50)  │ │
│ │ [Show all]                        │ │
│ └───────────────────────────────────┘ │
│                                       │
│  [    Import 18 cards    ]            │  ← Primary; disabled if issues > 0
│  [        Cancel         ]            │
│                                       │
└───────────────────────────────────────┘
```

## Layout — step 3: result

```
┌───────────────────────────────────────┐
│     Import complete                   │
├───────────────────────────────────────┤
│                                       │
│            ✓                           │
│                                       │
│      Imported 18 cards                │
│                                       │
│   Skipped duplicates:  3              │
│   In file: 1   In deck: 2             │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ Done                         │   │
│   └──────────────────────────────┘   │
│                                       │
│   [Import more from another file]     │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | destination deck |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Deck name (header context) | `decks` lookup | once |
| Existing fronts in deck (for duplicate detection) | `SELECT lower(trim(front)), lower(trim(back)) FROM flashcards WHERE deck_id = :deckId` | once at preview time |
| Imported file content | file system / paste buffer | once on Load |
| Parsed preview (cards + issues + skipped duplicates) | computed in isolate for files > 1000 rows | on Preview tap |

## Forbidden

- ❌ Inline edit cards in preview. Force back-to-source.
- ❌ Commit when `issues.length > 0`. Import button MUST be disabled.
- ❌ Silently strip invalid rows. List them in issues section.
- ❌ Apply user-set separator when "Auto" is selected. Run frequency analysis.
- ❌ Keep loaded file after format change to incompatible type.
- ❌ Run commit on main isolate for > 1000 rows.
- ❌ Single transaction with > 500 inserts. Chunk to respect SQLite param limit.
- ❌ Merge in-file duplicates silently. List them with `In file` badge.

## Components

| Component | Spec |
| --- | --- |
| Format radio | 3 options (Structured text / CSV / Excel). Mutually exclusive. Changes form below. |
| Separator dropdown | Visible only for structured text. 7 options. Default Auto. |
| Excel header toggle | Visible only for Excel. Default checked. |
| Paste area | Multi-line text. Resizes to content. |
| Load file button | Visible for CSV/Excel. Opens file picker. After load shows filename + "Replace" button. |
| Preview CTA | Disabled when source is empty (no paste content / no file loaded). |
| Summary card | Counts of import / skipped / issues. |
| Validation issues list | Each = `Line {n}: {message}`. |
| Skipped duplicates list | Each = `{front} — {back}` with badge (In file / In deck). |
| Cards-to-import list | First 50 with "Show all" link. |
| Import button | Primary. Disabled when `canCommit = false` (issues exist OR empty). |
| Result screen | Standalone screen after commit. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Configure | Initial | Source format picker + appropriate form. |
| Source empty | Format picked but no content | Preview disabled. |
| Source loaded | Paste or file present | Preview enabled. |
| Previewing | Tap Preview | Spinner; parse + validate. |
| Preview ready | Parsed | Step 2 layout. |
| Preview with issues | `issues.length > 0` | Import button disabled; issues section visible. |
| Preview clean | Zero issues, has preview items | Import button enabled. |
| Committing | Tap Import | Spinner; cancel disabled. |
| Committed | Success | Step 3 layout. |
| Commit failed | Transaction error | Banner "Import failed. Try again." Stays on step 2 with full state retained. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap format radio | Tap | Switch form below. Clear loaded file/paste if format incompatible. |
| Change separator | Tap | Persist in draft state; re-preview required. |
| Toggle Excel header | Tap | Persist; re-preview required. |
| Type in paste area | Type | Live; preview will use current value. |
| Tap Load file | Tap | OS file picker. Restrict to .csv/.xlsx based on format. |
| Tap Preview | Tap | Parse + validate → step 2. |
| Tap Edit source (from step 2) | Tap | Return to step 1 keeping current source. |
| Tap Import | Tap | Run commit transaction → step 3. |
| Tap Cancel (step 2) | Tap | Show "Discard import?" confirm if source non-empty. |
| Tap Done (step 3) | Tap | Return to flashcard list. |
| Tap Import more (step 3) | Tap | Reset to step 1, blank source. |
| Tap back (step 1) | Back | Show discard confirm if source non-empty. |

## Dialogs and bottom-sheets used

- Discard import dialog — `docs/wireframes/24-shared-dialogs.md` §discard-changes (variant).

## Navigation in

- FAB action sheet → Import (after picking deck if from Library).
- Empty state of flashcard list → "Import from CSV / Excel".
- Onboarding → Import.

## Navigation out

- Done → flashcard list (deck shows new cards via stream).
- Back → flashcard list (with confirm).

## Responsive

- ≥600dp: configure side-by-side with paste area on the right.
- Preview: summary fixed top; lists in scroll column.

## Performance

- Parse runs in background isolate if file is large (> 1000 rows).
- Commit transaction: chunked inserts to respect SQLite param limit. Each chunk in same transaction.
- Preview rendering: virtualized list for cards-to-import (handle 10k rows gracefully).

## Accessibility

- Validation issues list announces total count first, then iterates.
- Skipped duplicate badge included in row accessibility label.
- Progress during commit announces "Importing... {n}%".

## Rules

- Inline edit in preview is NOT supported. User must edit source and re-import.
- `canCommit = previewItems.isNotEmpty AND issues.isEmpty`. Import button enabled iff true.
- Skipped duplicates appear with explicit source: `importFile` (within paste/file) or `deck` (existing in deck).
- File can come from any account; import is account-scoped to the active account database.
- Duplicate detection: trim + case-insensitive on front+back match.
- Commit MUST be a single transaction (chunked if needed for SQLite limit).

## Agent rule

- Do NOT add inline edit in preview. Force back-to-source.
- Do NOT silently commit when issues > 0; button MUST be disabled.
- Result screen MUST distinguish in-file vs in-deck duplicates so user understands.
- Changing format MUST clear incompatible source (e.g., switching from Excel to paste clears loaded file).
- "Auto" separator MUST run frequency analysis on first non-empty line; never trust user-set separator silently.

## Implementation refs

**Business specs:**

- `docs/business/flashcard/flashcard-management.md` (import section)

**Decision rows:**

- Import section (canCommit rule, duplicate detection, format change clears source, chunked transaction)

**Schema / storage:**

- INSERT `flashcards` (+ optional `flashcard_tags`) in chunked transactions
- Duplicate detection: trim + case-insensitive on (front, back)

**Contracts:** `docs/contracts/usecase-contracts/flashcard.md` §ImportFlashcardsUseCase, `docs/contracts/repository-contracts/flashcard-repository.md` §importChunked

**Code paths (verified 2026-05-28):**

- Screen: `lib/presentation/features/flashcards/screens/deck_import_screen.dart` (registered at `lib/presentation/features/flashcards/routes/flashcard_routes.dart` → `RouteNames.deckImport`).
- Format enum: `lib/domain/value_objects/content_actions.dart` → `enum ImportSourceFormat { csv, excel, structuredText }` + `enum ImportStructuredTextSeparator { auto, tab, comma, colon, slash, semicolon, pipe }` + `enum FlashcardImportDuplicatePolicy { skipExactDuplicates }` + `enum FlashcardImportDuplicateSource { importFile, deck }`.
- Parser dispatcher: `lib/data/repositories/flashcard_import_support.dart` → `FlashcardImportSupport.parse({format, rawContent, sourceBytes, excelHasHeader, structuredTextSeparator})`. Switches on `format` to `_parseCsv`, `FlashcardExcelImportParser.parse`, or `_parseStructuredText`.
- CSV / structured-text parsers: inline in `flashcard_import_support.dart` (`_parseCsv`, `_parseStructuredText`).
- Excel parser: `lib/data/repositories/flashcard_excel_import_parser.dart` — **custom DIY xlsx reader** built on `package:archive` (zip) + `package:xml`. **Does NOT depend on the `excel` pub package.** Reads the first worksheet only (resolves via `xl/workbook.xml` + relationships, falls back to `xl/worksheets/sheet1.xml`). Supports inline strings (`t="inlineStr"`), shared-string table (`xl/sharedStrings.xml`), boolean (`t="b"`), and numeric cells. Columns mapped positionally: col 0 = `front`, col 1 = `back`, col 2 = `note` (optional). Blank rows skipped. Row number preserved for issue reporting.
- Use cases: `lib/domain/usecases/flashcard_usecases.dart` → `PrepareFlashcardImportUseCase` (parses + validates + dedupes against deck, returns `FlashcardImportPreparation`) and `CommitFlashcardImportUseCase` (chunked transaction insert).
- Repository: `lib/data/repositories/flashcard_repository_impl.dart` (chunked insert).
- Route constant: `lib/app/router/route_names.dart` → `RouteNames.deckImport`.

**Excel parser scope (current limitations, surface to user if extending):**

- Single worksheet only (first one defined in the workbook). Multi-sheet xlsx → only sheet 1 is read.
- No formula evaluation; numeric cells return their stored raw value.
- No date-format inference; dates appear as their underlying numeric string.
- No cell-style awareness (bold/italic/etc.). Plain text only.
- Encrypted / password-protected xlsx → parser throws, surfaces as `"Excel file must be a valid .xlsx workbook."` issue on row 1.

**Related wireframes:**

- `docs/wireframes/06-flashcard-list.md` (caller), `docs/wireframes/23-onboarding.md` (import path)
- `docs/wireframes/24-shared-dialogs.md` §discard-changes (variant)

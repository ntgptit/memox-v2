# MemoX — Mobile UI Kit

An interactive click-through gallery of MemoX mobile screens, built in HTML/JSX as a
visual reference for the Flutter implementation.

`index.html` renders every screen as a static phone frame on one scrollable stage, with a
**Light / Dark** toggle in the header (dark mode is the scoped *Tokyo Nebula* theme). Screens
are visual-only — `go()` is a no-op, so frames don't navigate; each frame just shows one state.

## Scope and status labels

This UI kit is a visual gallery, not the V1 implementation scope. A screen or state appearing
in `index.html` does not authorize implementation by itself.

Behavior source of truth remains:

- `docs/checklist/v1-release-readiness-cutline.md`
- `docs/checklist/v1-post-rc-backlog.md`
- `docs/checklist/implementation-ledger.md`
- the relevant `docs/wireframes/**`, `docs/business/**`, `docs/contracts/**`, and Flutter code contracts

Status labels used below:

| Label | Meaning |
|---|---|
| `Current` | Implemented for the stated scope and safe to use as a visual reference for that scope. |
| `Partial` | Some current code exists, but visual states include target/future placeholders or unimplemented edge cases. |
| `Future` | Planned or exploratory. Do not implement from the mock unless promoted by the cutline/backlog/ledger. |
| `Rejected` | Explicitly out of scope. Do not implement. |
| `Visual-only target` | Design exploration for look and feel only; not a behavior contract. |

Future, Rejected, and Visual-only target states must not be implemented only because they
appear in this gallery.

## Final visual density freeze

The redesigned mobile density is frozen for Flutter theme/shared-widget alignment before
feature implementation:

| Mock selector | Frozen value |
|---|---|
| `.pill-btn` | `height: 40px`, `padding: 0 18px`, `border-radius: 10px`, `font-size: 13px`, `font-weight: 600` |
| `.icon-btn` | `36px × 36px`, icon `20px` |
| `.card` | `border-radius: 12px`, `padding: 12px` |
| `.appbar` / `.appbar-lg` | `48px` / `56px` |
| `.bottom-nav` | `64px` |

Flutter keeps `MxButtonSize.medium` at `48dp` for form, dialog, and bottom action
contexts. Card/study actions use compact `40dp` visual height through
`MxActionButton` intents. This is a visual-density freeze only; it does not promote
visual-only states to Current and does not change feature behavior.

## Screens

The gallery is ordered by **user journey** — first-run → home → browse → manage a deck →
study → result → insights → settings — and numbered `01`–`23` in that flow. Most screens ship
several labelled **state variants** so every empty / loading / error / overlay case is visible
side by side.

| # | Screen | Status | States shown |
|---|--------|--------|--------------|
| **1 · First run** | | | |
| 01 | **Onboarding** | Future / Visual-only target | welcome · zero state · create deck · deck for import · signing in · restore prompt · restoring · restore failed · import handoff |
| **2 · Home** | | | |
| 02 | **Dashboard** | Partial / Visual-only target states included | loaded · loading · onboarding · goal off · resume only · streak broken · error · multi resume |
| **3 · Library** | | | |
| 03 | **Library overview** | Current for folders-only Library root; root-level decks are Rejected / Out of Scope | loaded · loading · empty · error · search · overflow sheet |
| 04 | **Folder detail** | Current for folder-owned decks | decks · subfolders · unlocked · search empty · loading · error · delete · move sheet |
| 05 | **Library search** | Future for global/root search; scope-local search remains Current inside owner screens | empty · loading · results · no results · error |
| **4 · Deck & cards** | | | |
| 06 | **Flashcard list** | Current for V1 deck-owned list scope | loaded · empty · search empty · loading · error · delete card · delete deck · reorder |
| 07 | **Flashcard create** | Current for shared editor create scope | empty · valid · details open · validation · saving · save failed |
| 08 | **Flashcard edit** | Current for shared editor edit scope; history/progress reset remain Future | loaded · loading · load error · validation · saving · save failed · delete |
| 09 | **Flashcard history** | Future / Visual-only target | loaded · empty · loading · error · partial |
| 10 | **Deck import** | Current for inline V1 import scope; multi-step/result states are visual targets | empty · file selected · parsing · preview all · preview mixed · importing · success · partial · failed |
| 11 | **Tag management** | Current for tag management; tag-scoped study remains Future/Blocked | loaded · loading · empty · search empty · action sheet · rename · rename→merge · merge sheet · delete · busy · op error |
| **5 · Study** | | | |
| 12 | **Study · Review** | Current for core learning loop | term + meaning, swipe-to-next |
| 13 | **Study · Match** | Current for core learning loop | pair fronts & backs |
| 14 | **Study · Guess** | Current for core learning loop | multiple choice A–E |
| 15 | **Study · Recall** | Current for core learning loop | hidden · revealed |
| 16 | **Study · Fill** | Current for core learning loop | input · wrong |
| 17 | **Study result** | Current for V1 result scope; goal/tough-card engagement states are Future / Visual-only target | loaded · loading · goal off · save failed · defensive · tough empty |
| **6 · Insights** | | | |
| 18 | **Stats** | Visual-only target / legacy visual reference | weekly chart + per-deck mastery |
| 19 | **Progress** | Current for V1 overview + active-session recovery; analytics expansions are Future | week · month · loading · empty · insufficient · partial · error |
| **7 · Settings** | | | |
| 20 | **Settings** | Partial / Current for route/action-safe hub | populated · loading · signed out · signing in · sync error |
| 21 | **Account sync** | Current for Prompt 41 restore warning and current sync actions | signed out · signing in · failed · no backup · ready · uploading · restore warn · restoring · token expired |
| 22 | **Learning settings** | Partial; daily goal/reminder/engagement controls are Future / Visual-only target | goal on/off · reminder on · perm denied · saving |
| 23 | **Audio & speech** | Current for global/front-language settings; independent per-language tabs are Future | Korean · English · loading · no voices · engine error · playing · saving |

## Conventions

- `StatusBar`, `BottomNav`, `Breadcrumb`, `StudyTopBar` and `Ic` are shared layout/icon
  primitives; everything else is a screen-level component that takes a `state` prop.
- `masteryColor(pct)` maps a 0–1 mastery value to a card-status token (learning → reviewing → mastered).
- `Phone` wraps each frame; `App` builds the `screens` array and the theme toggle.
- Icons via the Lucide CDN (substitute for Flutter's Material Symbols).
- All colour / spacing / radius / type values come from `../../colors_and_type.css`. Dark mode is
  applied through the scoped `.memox-dark` block in `index.html` (the in-page Light/Dark toggle),
  which mirrors the Tokyo Nebula dark tokens from the shared stylesheet.

## Source mapping

Each screen mirrors current Flutter architecture paths, not old `lib/features/**` paths:

- Presentation screens and widgets: `lib/presentation/features/**`
- Shared presentation primitives: `lib/presentation/shared/**`
- Domain behavior and contracts: `lib/domain/**`
- Data, repositories, DAOs, migrations, and sync: `lib/data/**`
- Routing and app boot: `lib/app/**`

Before coding from this mock design, agents must check
`docs/checklist/v1-release-readiness-cutline.md`,
`docs/checklist/v1-post-rc-backlog.md`,
`docs/checklist/implementation-ledger.md`, and the relevant wireframe/business docs.
Use the Flutter feature folders and docs as the source of truth for behaviour; this kit only
fixes the visual language.

Business invariant locked for this kit: Library root contains folders only, Folder Detail
contains decks, each deck belongs to exactly one folder, root-level decks are Rejected /
Out of Scope, and nullable deck parent migration is Rejected / Not Applicable.

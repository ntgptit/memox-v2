---
last_updated: 2026-06-01
route: /settings/learning/tags
source_specs:
  - docs/business/tags/tag-system.md
---

# 22 — Settings: Tag Management

## Purpose

Global view of all tags across all decks. Current V1 inspects usage and supports rename, merge, and delete. Tag-scoped study remains Blocked on `StudyEntryType.tag`; global tag-filtered card lists remain Future / Global Search ownership.

## V1 status

| Area | Current V1 status |
| --- | --- |
| Route | Current: `/settings/learning/tags` opens `SettingsTagManagementScreen`; direct route hides shell navigation. |
| Learning Settings entry | Current: Learning Settings only routes to this screen; it does not own tag CRUD. |
| List / count | Current: all distinct lowercased tags with card usage counts. |
| Empty / loading / error | Current: loading surface, true-empty state with Library CTA, and safe generic load error surface. |
| Search | Current: local in-memory substring filter only; no global search route/use case. |
| Sort | Current: in-memory `Most cards`, `A→Z`, `Z→A`; `Recently used` is Future because `flashcard_tags` has no last-used signal. Sort is screen-local UI state, not persisted. |
| Rename | Current: shared name dialog; validation and normalization happen in `RenameTagUseCase`; collision prompts merge confirmation. |
| Merge | Current: destination picker + confirmation; repository transaction dedupes per-card rows and removes source tag. |
| Delete | Current: confirmation required; removes tag rows only and keeps flashcards. |
| Study cards with this tag | Blocked: requires `StudyEntryType.tag` and tag-scope study query. Not exposed in V1 context sheet. |
| View cards | Future: belongs to a future global tag-filtered list / Global Search surface. Not exposed in V1 context sheet. |

## Layout — populated

```
┌───────────────────────────────────────┐
│ ←   Manage tags                       │
├───────────────────────────────────────┤
│                                       │
│ ┌─ 🔍 Search tags... ────────────────┐ │
│ └───────────────────────────────────┘ │
│                                       │
│ 42 tags                  Sort: Most ▾ │  ← Total count + sort
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ #verb              80 cards    ⋮ │ │  ← Tag row
│ ├───────────────────────────────────┤ │
│ │ #N5                60 cards    ⋮ │ │
│ ├───────────────────────────────────┤ │
│ │ #greet             42 cards    ⋮ │ │
│ ├───────────────────────────────────┤ │
│ │ #adj               30 cards    ⋮ │ │
│ ├───────────────────────────────────┤ │
│ │ #weak              12 cards    ⋮ │ │
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Layout — empty state

```
┌───────────────────────────────────────┐
│ ←   Manage tags                       │
├───────────────────────────────────────┤
│                                       │
│              🏷                        │
│                                       │
│      No tags yet                      │
│                                       │
│   Tags are added when you create or   │
│   edit flashcards. Open a card to     │
│   add your first tag.                 │
│                                       │
│   [ Go to library ]                   │
│                                       │
└───────────────────────────────────────┘
```

## Layout — tag row context (overflow ⋮ sheet)

```
┌───────────────────────────────────────┐
│  #verb                                │
│  80 cards across 5 decks              │
├───────────────────────────────────────┤
│  ✏ Rename                              │
│  🔗 Merge into another tag             │
│  🗑 Delete tag (keeps cards)          │
│  ✕ Cancel                             │
└───────────────────────────────────────┘
```

## Layout — rename dialog

```
┌───────────────────────────────────────┐
│  Rename tag                           │
├───────────────────────────────────────┤
│  Current: #verb                       │
│                                       │
│  ┌─────────────────────────────────┐  │
│  │ #verbs                          │  │  ← Text input
│  └─────────────────────────────────┘  │
│  Renames the tag on all 80 cards.     │
│                                       │
│  [ Cancel ]              [ Rename ]   │
└───────────────────────────────────────┘
```

Current V1 uses the shared name dialog. If the submitted name collides with an existing tag, the rename use case returns a conflict and the screen opens the merge confirmation dialog before mutating data. The live inline collision warning/count preview is Target.

## Layout — merge into another tag

```
┌───────────────────────────────────────┐
│  Merge #verb into...                  │
├───────────────────────────────────────┤
│  Pick the destination tag.            │
│                                       │
│  ┌─ 🔍 Search... ──────────────────┐  │
│  └─────────────────────────────────┘  │
│                                       │
│  Suggested                            │
│   ○ #verbs        22 cards            │
│   ○ #verb-past    15 cards            │
│                                       │
│  All tags                             │
│   ○ #adj          30 cards            │
│   ○ #greet        42 cards            │
│   ○ ...                               │
│                                       │
│  ⓘ All 80 cards tagged #verb will be  │
│    re-tagged with the destination     │
│    tag. The tag #verb will be         │
│    deleted.                           │
│                                       │
│  [ Cancel ]              [ Merge ]    │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| All tags with usage count | `SELECT LOWER(tag), COUNT(DISTINCT flashcard_id) FROM flashcard_tags GROUP BY LOWER(tag)` | watch |
| Filtered list (when search active) | in-memory filter | live |
| Sort mode | screen-local provider state | user changes sort |
| Merge destination candidates | watched tag list excluding source tag | when merge sheet opens |

## Forbidden

- ❌ Allow rename to bypass validation (no comma, max 50 chars).
- ❌ Silently merge on rename collision. Require explicit confirmation in dialog.
- ❌ Merge without deduping per card. A card already tagged with both source and destination keeps one row.
- ❌ Delete tag rows by tag NAME only without case-normalization (tag is global case-insensitive).
- ❌ Expose "View cards" in Current V1. It belongs to a future global tag-filtered list / Global Search surface.
- ❌ Expose "Study cards with this tag" in Current V1. It is blocked until `StudyEntryType.tag` and the canonical `entry_ref_id` path are implemented.

## Components

| Component | Spec |
| --- | --- |
| Search bar | Filters tag list live. Same min-2-char rule as global search not applied — tag count is small enough for live filter. |
| Total + sort | "42 tags" left; sort dropdown right (Current: Most cards / A→Z / Z→A). Recently used is Future. |
| Tag row | Tag name with `#` prefix + usage count + overflow ⋮. Whole row tappable → opens context sheet. |
| Tag context sheet | Current V1: Rename / Merge / Delete + cancel. Study/View actions are not exposed. |
| Rename dialog | Current: shared text input + Rename CTA; collision opens merge confirmation after submit. Live conflict warning/count preview is Target. |
| Merge sheet | Current: destination picker list + local search; selecting a destination opens merge confirmation. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton rows. |
| Empty | Zero tags across all decks | Empty state layout. |
| Populated | Tags exist | List visible. |
| Search active | Search non-empty | Filtered list; "No matching tags" inline state when zero results. |
| Renaming | Rename dialog submit | Current: dialog closes, transaction runs, success/error snackbar follows watched list refresh. Inline saving spinner is Target. |
| Rename conflict resolved (merge) | Confirm merged rename | Transaction merges tags; both rows update. |
| Deleting | Delete confirmed | Current: confirmed transaction runs, success/error snackbar follows watched list refresh. Inline row progress is Target. |
| Merging | Merge confirmed | Current: confirmed transaction runs, success/error snackbar follows watched list refresh. Inline spinner is Target. |
| Error | Transaction failure | Toast + revert UI. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Type in search | Type | Filter live. |
| Tap sort dropdown | Tap | Pick screen-local sort mode. Persistence is Future if product needs it. |
| Tap tag row | Tap | Open context sheet. |
| Tap "Study cards with this tag" | Future/Blocked | Not exposed in V1. When promoted, navigate to tag-scoped study through the canonical tag entry path. |
| Tap "View cards" | Future | Not exposed in V1. When promoted, navigate to a global tag-filtered flashcard list / Global Search-owned surface. |
| Tap "Rename" | Tap | Open rename dialog. |
| Tap "Merge" | Tap | Open merge sheet. |
| Tap "Delete tag" | Tap | Confirm dialog: "Delete tag #verb? Cards keep their other tags." On confirm: remove `flashcard_tags` rows for this tag. |
| Submit Rename | Tap | If name = existing tag → confirm as merge. Else: standard rename transaction. |
| Submit Merge | Tap | Replace all `flashcard_tags(tag=source)` with `flashcard_tags(tag=destination)`, deduping per card. Delete source tag rows. |

## Dialogs and bottom-sheets used

- Tag row context sheet — defined here.
- Rename dialog — defined here (custom because of conflict warning).
- Merge sheet — defined here.
- Delete tag confirm — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.

## Validation

| Rule | Inline message |
| --- | --- |
| New name empty | "Tag name is required." |
| New name contains comma | "Tags cannot contain commas." |
| New name > 50 chars | "Tag too long (max 50 chars)." |
| New name = current (case-insensitive) | "Already that name." (Rename button disabled.) |
| New name = another existing tag | Show merge warning; Rename CTA becomes "Merge" verbiage. |

## Navigation in

- Settings hub → Manage tags row.
- Settings → Learning → Manage tags row.

## Navigation out

- Back → caller.
- Study cards with tag → Blocked/Future, not exposed in V1.
- View cards → Future global tag-filtered list, not exposed in V1.

## Responsive

- ≥600dp: 2-column tag grid. Context sheet still appears as bottom-sheet.

## Performance

- Tag list query aggregates `flashcard_tags` count per tag in one query.
- Rename / merge / delete = single transaction each, atomic.
- Live search filters in-memory (small dataset).

## Accessibility

- Tag rows announce "Tag {name}, {count} cards".
- Context sheet items labeled clearly with destructive distinction.
- Merge warning text included in dialog accessibility tree.

## Rules

- Tag uniqueness is case-insensitive globally.
- Rename collision = automatic merge with user confirmation.
- Delete tag does NOT delete cards — only the `flashcard_tags` rows.
- All operations atomic.
- Tag name validation reuses rules from `docs/business/tags/tag-system.md` (no commas, max 50, case-insensitive).

## Agent rule

- Do NOT allow renames that bypass validation rules.
- Do NOT silently merge on rename collision — require explicit user confirmation in dialog.
- Merge MUST be atomic and dedupe per card (a card already tagged with both source and destination keeps a single dest row).
- Do NOT expose Study/View tag actions in Current V1. Study remains blocked on `StudyEntryType.tag`; View cards belongs to a future global tag-filtered list / Global Search surface.

## Implementation refs

**Business specs:**

- `docs/business/tags/tag-system.md`

**Decision rows:**

- Tag section: TG7 (delete keeps cards), TG9 (no comma), TG10 (max 50), rename collision = merge with confirmation, merge dedup per card

**Schema / storage:**

- READ aggregate count from `flashcard_tags` GROUP BY tag
- UPDATE: rename = single-tag UPDATE; merge = atomic delete-source + dedup-insert
- DELETE tag = remove `flashcard_tags` rows; cards untouched

**Contracts:** `docs/contracts/usecase-contracts/tag.md`, `docs/contracts/repository-contracts/tag-repository.md`

**Code paths:**

- `lib/presentation/features/settings/screens/tag_management_screen.dart`
- `lib/presentation/features/settings/providers/tag_management_notifier.dart`
- `lib/domain/usecases/tag_usecases.dart`
- `lib/data/repositories/tag_repository_impl.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settingsLearningTags`

**Related wireframes:**

- `docs/wireframes/04-settings-hub.md`, `docs/wireframes/20-settings-learning.md` (entries)
- `docs/wireframes/06-flashcard-list.md`, `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker (other tag UIs)

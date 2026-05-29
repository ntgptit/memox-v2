---
last_updated: 2026-05-26
route: /settings/learning/tags
source_specs:
  - docs/business/tags/tag-system.md
---

# 22 — Settings: Tag Management

## Purpose

Global view of all tags across all decks. Inspect usage, rename, merge, delete, or jump to study/view cards for a tag.

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
│  ▶ Study cards with this tag          │
│  📚 View cards                        │
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
│  ⚠ A tag named "#verbs" already       │  ← Conflict warning if exists
│    exists. Renaming will MERGE the    │
│    two tags. 80 + 22 = 102 cards.     │
│                                       │
│  [ Cancel ]              [ Rename ]   │
└───────────────────────────────────────┘
```

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
| Sort preference | SharedPreferences `tags.sort` | watch |
| Merge collision suggestions (when typing in rename/merge) | tag-prefix matcher | live debounced |

## Forbidden

- ❌ Allow rename to bypass validation (no comma, max 50 chars).
- ❌ Silently merge on rename collision. Require explicit confirmation in dialog.
- ❌ Merge without deduping per card. A card already tagged with both source and destination keeps one row.
- ❌ Delete tag rows by tag NAME only without case-normalization (tag is global case-insensitive).
- ❌ "View cards" navigates to a per-deck list. It MUST navigate to a global tag-filtered list.
- ❌ "Study cards with this tag" uses anything other than the canonical `entry_ref_id` format (sorted, lowercased, comma-joined).

## Components

| Component | Spec |
| --- | --- |
| Search bar | Filters tag list live. Same min-2-char rule as global search not applied — tag count is small enough for live filter. |
| Total + sort | "42 tags" left; sort dropdown right (Most cards / A→Z / Z→A / Recently used). |
| Tag row | Tag name with `#` prefix + usage count + overflow ⋮. Whole row tappable → opens context sheet. |
| Tag context sheet | 5 actions per tag + cancel. |
| Rename dialog | Text input + conflict warning + Rename CTA. |
| Merge sheet | Destination tag picker (radio) + search + merge CTA. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton rows. |
| Empty | Zero tags across all decks | Empty state layout. |
| Populated | Tags exist | List visible. |
| Search active | Search non-empty | Filtered list; "No matching tags" inline state when zero results. |
| Renaming | Rename dialog submit | Disable inputs; show spinner; transaction runs. |
| Rename conflict resolved (merge) | Confirm merged rename | Transaction merges tags; both rows update. |
| Deleting | Delete confirmed | Show progress; row disappears on success. |
| Merging | Merge confirmed | Spinner; transaction runs. |
| Error | Transaction failure | Toast + revert UI. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Type in search | Type | Filter live. |
| Tap sort dropdown | Tap | Pick sort; persist preference. |
| Tap tag row | Tap | Open context sheet. |
| Tap "Study cards with this tag" | Tap | Navigate to `/library/study/tag/{lowercased,comma-joined}` (for single tag this is just the tag itself). |
| Tap "View cards" | Tap | Navigate to a global tag-filtered flashcard list view. |
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
- Study cards with tag → study entry gate.
- View cards → flashcard list (tag-filtered, global).

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
- "View cards" for a tag opens a GLOBAL filtered list, not a per-deck one (tag is account-scoped).

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

- `lib/presentation/features/settings/tag_management/screens/tag_management_screen.dart`
- `lib/presentation/features/settings/tag_management/notifiers/tag_management_notifier.dart`
- `lib/domain/usecases/tag/rename_tag_usecase.dart`
- `lib/domain/usecases/tag/merge_tag_usecase.dart`
- `lib/domain/usecases/tag/delete_tag_usecase.dart`
- `lib/data/repositories/tag_repository.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settingsLearningTags` (NEW, see navigation-flow.md)

**Related wireframes:**

- `docs/wireframes/04-settings-hub.md`, `docs/wireframes/20-settings-learning.md` (entries)
- `docs/wireframes/06-flashcard-list.md`, `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker (other tag UIs)

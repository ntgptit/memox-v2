---
last_updated: 2026-05-26
route: /settings
source_specs:
  - docs/business/navigation/navigation-flow.md
  - docs/business/account-sync/account-sync.md
---

# 04 — Settings Hub

## Purpose

Entry point to all settings sub-screens. Plain list, no settings live here directly except a few status indicators.

## V1 verification status

Prompt 21 (2026-05-31) verified Settings Hub as a navigation owner, not a settings mutation owner.

| Aspect | V1 status | Notes |
| --- | --- | --- |
| `/settings` route + shell navigation | Current | `/settings` renders `SettingsScreen` inside the app shell. |
| Account, Learning, Audio/Speech, Tags navigation | Current | Rows push named settings sub-routes; sub-screens hide shell navigation; back returns to the hub when entered from the hub. |
| Appearance / Language rows | Current (disabled Future rows) | Render as disabled rows with a Soon badge; no route is exposed. |
| About row | Current (dialog) / Target (bottom-sheet) | Current code opens Flutter's `AboutDialog`. The About bottom-sheet remains release-polish target behavior. |
| Hub-owned mutation | Current absent | Hub rows navigate only. Account/Drive, study defaults, TTS, and tag mutation live in their sub-screens/viewmodels. |
| Subtitle source | Partial | Account status uses account/sync state. Learning, Audio/Speech, and Tags overview subtitles are V1 summaries, not full live aggregates. |
| Async state | Current | Provider-backed rows keep rows visible and use row-level skeleton/error states; the hub has no full-screen empty state. |

## Layout

```
┌───────────────────────────────────────┐
│ Settings                              │
├───────────────────────────────────────┤
│                                       │
│  ACCOUNT                              │  ← Section header
│  ┌───────────────────────────────────┐│
│  │ 👤 Account & Sync           ▸     ││  → /settings/account
│  │    Signed in as giap@gmail.com    ││     subtitle dynamic
│  │    ✓ Synced 2h ago                ││
│  └───────────────────────────────────┘│
│                                       │
│  STUDY                                │
│  ┌───────────────────────────────────┐│
│  │ 📚 Learning                  ▸    ││  → /settings/learning
│  │    Daily goal: 20 cards           ││
│  ├───────────────────────────────────┤│
│  │ 🔊 Audio & Speech            ▸    ││  → /settings/audio-speech
│  │    Korean voice (default)         ││
│  ├───────────────────────────────────┤│
│  │ 🏷  Manage tags              ▸    ││  → /settings/learning/tags
│  │    42 tags                        ││
│  └───────────────────────────────────┘│
│                                       │
│  APP                                  │
│  ┌───────────────────────────────────┐│
│  │ 🎨 Appearance                ▸    ││  → /settings/appearance (future)
│  │    System default                 ││
│  ├───────────────────────────────────┤│
│  │ 🌐 Language                  ▸    ││  → /settings/locale (future)
│  │    English                        ││
│  └───────────────────────────────────┘│
│                                       │
│  ABOUT                                │
│  ┌───────────────────────────────────┐│
│  │ ℹ️  About MemoX               ▸   ││
│  │    Version 1.0.0                  ││
│  └───────────────────────────────────┘│
│                                       │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Progress  ⚙️  │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | hub does not accept params |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Account sign-in state (email, signed-in/out) | `AuthService` + SharedPreferences | watch |
| Last sync result (success/failed/never) | SharedPreferences | watch |
| Daily goal (for subtitle) | SharedPreferences | watch |
| TTS default voice label | SharedPreferences | watch |
| Total tag count | `flashcard_tags` aggregate `COUNT(DISTINCT tag)` | watch |
| App version | `package_info_plus` | once at boot |

Subtitles populate independently; rows render immediately, subtitles fill in.

## Forbidden

- ❌ Host actual settings on this screen (no toggles, no sliders here).
- ❌ Hide the Account row when signed out. Show "Not signed in — tap to set up backup."
- ❌ Display a stale subtitle. If data is loading, show "—" or skeleton.
- ❌ Show unimplemented rows (Appearance, Language) as enabled.

## Components

| Component | Spec |
| --- | --- |
| Section header | All caps, small font, theme-secondary color. |
| Row | Icon + title + dynamic subtitle + chevron. Whole row tappable. |
| Account row subtitle | Reflects sign-in + sync state: "Not signed in" / "Signed in as {email}" + sync status. |
| Learning row subtitle | Target: "Daily goal: {n} cards" if goal enabled; "Goal off" if disabled. Current V1: study-defaults summary. |
| Audio row subtitle | Target: "{Korean|English} voice (default)". Current V1: global front-language / speech summary. |
| Tags row subtitle | Target: "{n} tags" total across user data. Current V1: static management summary; live count belongs to the Tags sub-screen. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial open | Skeletons for subtitles only; rows visible immediately. |
| Signed out | No cloud account | Account subtitle: "Not signed in — Tap to set up backup." |
| Sign-in in progress | Token refresh / OAuth flow | Account subtitle: "Signing in..." with spinner. |
| Sync error | Last sync failed | Account row shows error indicator + subtitle "Sync failed — Tap to review." |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap any row | Tap | `push` to corresponding sub-screen. |
| Tap About | Tap | Current V1: open app About dialog with version/legal copy. Target: About bottom-sheet (`docs/wireframes/25-shared-bottom-sheets.md` §about) showing version, licenses, links. |

## Dialogs and bottom-sheets used

- Current V1: Flutter About dialog.
- Target/release polish: About bottom-sheet (`docs/wireframes/25-shared-bottom-sheets.md` §about).

## Navigation in

- Bottom nav tap Settings (gear icon ⚙️).
- App bar settings icon from Dashboard or Library.

## Navigation out

- Each row → its sub-screen.

## Responsive

- Standard list scales naturally; no column changes.

## Performance

- Subtitles fetched lazily; each row's subtitle has its own subscription so failures isolated.

## Accessibility

- Section headers announced as headings.
- Row subtitle MUST be included in accessibility label so screen reader announces both.

## Rules

- Settings hub MUST NOT host actual settings (no toggles, no sliders).
- Subtitles MUST reflect current state (not stale).
- Future-planned rows (Appearance, Language) MAY be hidden if not implemented.

## Agent rule

- Do NOT inline settings UI here. Each setting category gets its own screen.
- Do NOT hide the Account row when signed out; show "Not signed in" prompt instead.
- About bottom-sheet content (licenses, attributions) is required at release; can be a stub during development.

## Implementation refs

**Business specs:**

- `docs/business/navigation/navigation-flow.md` (settings routes)
- `docs/business/account-sync/account-sync.md` (subtitle reflects sync state)

**Decision rows:**

- Navigation section (settings sub-screens push from hub)

**Schema / storage:**

- Live aggregates: deck count, tag count, sync manifest fetch

**Contracts:** `docs/contracts/usecase-contracts/account-sync.md`, `docs/contracts/usecase-contracts/engagement.md`, `docs/contracts/usecase-contracts/tts.md`, `docs/contracts/usecase-contracts/tag.md`

**Code paths:**

- `lib/presentation/features/settings/screens/settings_screen.dart`
- `lib/presentation/features/settings/widgets/settings_overview_groups.dart`
- `lib/presentation/features/settings/widgets/settings_group.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settings`

**Related wireframes:**

- `docs/wireframes/19-settings-account.md`, `docs/wireframes/20-settings-learning.md`, `docs/wireframes/21-settings-audio-speech.md`, `docs/wireframes/22-settings-tag-management.md`
- `docs/wireframes/25-shared-bottom-sheets.md` §about

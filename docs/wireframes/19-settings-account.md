---
last_updated: 2026-05-26
route: /settings/account
source_specs:
  - docs/business/account-sync/account-sync.md
---

# 19 — Settings: Account & Drive Sync

## Purpose

Manage Google account link and Google Drive backup. Single source of truth for sync status, manual upload/restore controls, and account switching. Account is account-scoped (per `docs/business/account-sync/account-sync.md`); all data lives in the active account's database.

## Layout — signed out

```
┌───────────────────────────────────────┐
│ ←   Account & Sync                    │
├───────────────────────────────────────┤
│                                       │
│              ☁️                        │
│                                       │
│   Sign in to back up your data        │
│                                       │
│   Your decks and progress will sync   │
│   to your Google Drive App Folder.    │
│   Only this app can see them.         │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ 🔑 Sign in with Google       │   │
│   └──────────────────────────────┘   │
│                                       │
│   You can keep using MemoX without    │
│   signing in. Your data stays on      │
│   this device only.                   │
│                                       │
└───────────────────────────────────────┘
```

## Layout — signed in

```
┌───────────────────────────────────────┐
│ ←   Account & Sync                ⋮   │
├───────────────────────────────────────┤
│                                       │
│ ACCOUNT                               │
│ ┌───────────────────────────────────┐ │
│ │ 👤 giap@gmail.com                 │ │
│ │ Signed in · Google                │ │
│ └───────────────────────────────────┘ │
│                                       │
│ THIS DEVICE                           │
│ ┌───────────────────────────────────┐ │
│ │ Device label                      │ │
│ │ Pixel 8 Pro            [Edit]     │ │  ← Tap → rename dialog
│ ├───────────────────────────────────┤ │
│ │ Local fingerprint                 │ │
│ │ a1b2c3...e7f8 · 2026-05-26 14:32  │ │  ← Read-only
│ └───────────────────────────────────┘ │
│                                       │
│ DRIVE BACKUP                          │
│ ┌───────────────────────────────────┐ │
│ │ Last upload                       │ │
│ │ Pixel 8 Pro · 2h ago · 12.4 MB    │ │  ← from manifest
│ │ Fingerprint matches this device ✓ │ │
│ ├───────────────────────────────────┤ │
│ │ ⬆ Upload to Drive             ▸  │ │  ← Manual upload
│ ├───────────────────────────────────┤ │
│ │ ⬇ Restore from Drive          ▸  │ │  ← Manual restore (warning)
│ └───────────────────────────────────┘ │
│                                       │
│ DANGER ZONE                           │
│ ┌───────────────────────────────────┐ │
│ │ 🚪 Sign out                       │ │  ← Local data preserved
│ ├───────────────────────────────────┤ │
│ │ 🗑 Switch / remove account        │ │  ← Wipes local DB after confirm
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Layout — restore warning (fingerprint mismatch)

When user taps Restore and the Drive manifest's `device_label` / fingerprint differs from current:

```
┌───────────────────────────────────────┐
│  ⚠  Restore from a different device?  │
├───────────────────────────────────────┤
│                                       │
│  This backup was made on:             │
│    Pixel 8 Pro · 2025-12-01           │
│                                       │
│  Your local data (last edited today)  │
│  will be REPLACED. This cannot be     │
│  undone.                              │
│                                       │
│  We recommend uploading your local    │
│  data first.                          │
│                                       │
│  ┌──────────────────────────────┐    │
│  │ ⬆ Upload local first         │    │  ← Primary (safe)
│  └──────────────────────────────┘    │
│                                       │
│  [ Restore anyway ]                   │  ← Secondary, requires 2nd tap
│  [ Cancel ]                           │
│                                       │
└───────────────────────────────────────┘
```

This is `docs/wireframes/24-shared-dialogs.md` §restore-warning. The 2nd-tap confirmation requirement is enforced even when "Restore anyway" is tapped — see dialog spec.

## Layout — pre-restore snapshot notice

```
┌───────────────────────────────────────┐
│  📸  Creating safety snapshot...      │
├───────────────────────────────────────┤
│                                       │
│  Before replacing your data, we're    │
│  saving a snapshot of your current    │
│  database. You can restore it from    │
│  Drive if needed.                     │
│                                       │
│  ████████░░░░░  60%                   │
│                                       │
│  If this fails, restore is cancelled  │
│  and your data is not touched.        │
│                                       │
└───────────────────────────────────────┘
```

Snapshot is mandatory. If snapshot fails for any reason, the entire restore aborts; original data untouched.

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Auth state (signed in/out, email, provider) | `AuthService` | watch |
| Device label | SharedPreferences `account.deviceLabel` | watch |
| Local fingerprint + timestamp | computed from canonical DB content | on screen open + after any data change (debounced) |
| Drive manifest (uploaded_at, size, device_label, fingerprint) | Drive App Folder fetch | once on open, refresh on demand |
| In-flight operation state (uploading / restoring / snapshotting) | `AccountNotifier` | watch |
| Last sync result + error | SharedPreferences + notifier | watch |

## Forbidden

- ❌ Auto-restore on sign-in. Restore is always manual.
- ❌ Auto-upload on data change without an explicit user setting.
- ❌ Skip pre-restore snapshot. Snapshot is mandatory.
- ❌ Continue restore if snapshot fails. Abort.
- ❌ Trigger restore on a single "Restore anyway" tap when fingerprint differs. Require second tap with 5s timeout.
- ❌ Wipe local data on sign-out. Only "Switch / remove account" does that.
- ❌ Store OAuth tokens in SharedPreferences. Use `flutter_secure_storage`.
- ❌ Log access tokens, refresh tokens, or fingerprints to console/file logs.

## Components

| Component | Spec |
| --- | --- |
| Signed-out empty state | Icon + heading + explanation + Sign in button + privacy reassurance. |
| Account row | Email, provider. Read-only. |
| Device label row | Editable. Tap → rename dialog. Default = OS device name. |
| Local fingerprint row | Read-only. Shows hash prefix + last modified timestamp. |
| Last upload row | Shows device that uploaded, time, size. Fingerprint match indicator (✓ matches / ⚠ differs / — no backup). |
| Upload button | Primary action. Disabled during in-flight upload. |
| Restore button | Triggers restore warning dialog first. |
| Sign out button | Preserves local DB; clears tokens. |
| Switch / remove account | Destructive. Wipes local DB after confirm. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Signed out | No cloud account linked | Show signed-out layout. |
| Signing in | OAuth flow in progress | Disable Sign in button; show spinner. |
| Signed in, no backup yet | Linked but no manifest on Drive | Last upload row: "No backup yet". Restore button disabled. |
| Signed in, backup matches | Manifest fingerprint matches local | Show ✓. Restore button enabled but triggers warning. |
| Signed in, backup differs | Manifest fingerprint differs OR newer | Show ⚠. Restore triggers full warning dialog. |
| Uploading | Manual upload in flight | Inline progress in Upload row. |
| Restoring (snapshot phase) | After user confirms restore | Show snapshot notice modal. |
| Restoring (download/replace phase) | After snapshot succeeded | Show progress; app effectively offline until done. |
| Restore aborted | Snapshot failed | Show error toast "Snapshot failed — restore cancelled." Local data untouched. |
| Sign in failed | OAuth error | Show inline error; keep signed-out layout. |
| Token expired | Background refresh failed | Show banner top: "Sign in expired. Tap to reconnect." |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap "Sign in with Google" | Tap | Launch OAuth flow; on success populate account + fetch manifest. |
| Tap account row | Tap | No-op (read-only). |
| Tap Edit device label | Tap | Open rename dialog (`docs/wireframes/24-shared-dialogs.md` §rename). |
| Tap "Upload to Drive" | Tap | Run upload use case; show progress inline. |
| Tap "Restore from Drive" | Tap | Fetch manifest; show restore warning dialog. On confirm → snapshot phase → replace phase. |
| Tap "Sign out" | Tap | Confirm dialog: "Sign out? Your local data stays on this device." On confirm: clear tokens, return to signed-out layout. |
| Tap "Switch / remove account" | Tap | Strong destructive dialog: "Remove this account and erase all data on this device?" On confirm: wipe local DB, return to signed-out. |
| Tap overflow ⋮ | Tap | Menu: View Drive folder (web link), Refresh manifest, Help. |

## Dialogs and bottom-sheets used

- Restore warning dialog — `docs/wireframes/24-shared-dialogs.md` §restore-warning.
- Pre-restore snapshot notice (modal progress) — inline above, defined here.
- Rename device label — `docs/wireframes/24-shared-dialogs.md` §rename.
- Sign out confirm — generic confirm.
- Switch/remove account confirm — `docs/wireframes/24-shared-dialogs.md` §delete-confirm (destructive variant with typed confirmation).

## Navigation in

- Settings hub → Account & Sync.
- Onboarding "Sign in to restore from Drive" flow.

## Navigation out

- Back → Settings hub.
- After sign-out → stays here in signed-out state.
- After switch/remove → returns to Settings hub with rebuilt DB (empty).

## Responsive

- ≥600dp: standard list; no column changes (settings are linear).

## Performance

- Manifest fetch on screen open; cached for 60s.
- Upload progress streamed via use case state.
- Snapshot file written before any destructive op; on failure, restore aborts immediately.

## Accessibility

- Destructive actions announced as "Destructive, double-tap to confirm" pattern.
- Fingerprint string presented as truncated label with "View full" expandable for debug.

## Rules

- Account is account-scoped: switching account swaps the SQLite database file path.
- Backup stored in Drive App Folder (only this app sees it).
- Pre-restore snapshot MUST succeed before any data replacement.
- "Upload local first" MUST be the primary button on restore warning when fingerprint differs.
- "Restore anyway" requires a second tap; cannot be a single tap.
- Sign out keeps local data; only Switch / remove account wipes data.

## Agent rule

- Do NOT auto-restore on sign-in. Restore is manual only.
- Do NOT auto-upload on data change without explicit user setting (this is opt-in via future setting; for now manual only).
- Pre-restore snapshot creation MUST be atomic. If app dies mid-snapshot, no destructive op has happened.
- Drive manifest schema MUST include `device_label`, `fingerprint`, `uploaded_at`, `size_bytes`, `schema_version`.
- Token refresh failures MUST surface as a banner, not silently expire.

## Implementation refs

**Business specs:**

- `docs/business/account-sync/account-sync.md`

**Decision rows:**

- Account/Sync: pre-snapshot abort, fingerprint mismatch warning, two-tier confirm, token refresh

**Schema / storage:**

- Account-scoped DB file path switch on account change
- Drive manifest (remote): `device_label`, `fingerprint`, `uploaded_at`, `size_bytes`, `schema_version`
- SharedPreferences: `account.deviceLabel`, `account.lastSyncAt`, `account.lastSyncFingerprint`

**Contracts:** `docs/contracts/usecase-contracts/account-sync.md`, `docs/contracts/repository-contracts/sync-repository.md`

**Code paths:**

- `lib/presentation/features/settings/account/screens/account_settings_screen.dart`
- `lib/presentation/features/settings/account/notifiers/account_settings_notifier.dart`
- `lib/data/sync/drive_upload_service.dart`
- `lib/data/sync/drive_restore_service.dart`
- `lib/data/sync/local_snapshot_service.dart` (pre-restore snapshot)
- `lib/data/sync/manifest.dart`
- `lib/core/auth/google_auth.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settingsAccount`

**Related wireframes:**

- `docs/wireframes/04-settings-hub.md` (entry), `docs/wireframes/23-onboarding.md` (sign-in path)
- `docs/wireframes/24-shared-dialogs.md` §restore-warning, §rename (device label), §delete-confirm (strong variant)

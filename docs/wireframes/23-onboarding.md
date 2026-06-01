---
last_updated: 2026-05-29
status: V1 thin zero-content guidance; full onboarding flow is Future Proposal
route: no dedicated onboarding route in V1
source_specs:
  - docs/business/system/overview.md
  - docs/business/account-sync/account-sync.md
  - docs/business/engagement/dashboard-engagement.md
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# 23 — Onboarding / Zero-Content Guidance

## V1 decision

V1 does **not** implement a dedicated onboarding feature folder, first-launch welcome screen, or onboarding route.

V1 onboarding means: **strong empty states when the app has zero content**, with clear CTAs to create, import, or restore data.

## Prompt 26 V1 honesty sweep — 2026-06-01

- Full onboarding is still **Future Proposal**: no `/onboarding` route, no `lib/presentation/features/onboarding/**`, no first-launch preference gate, and no multi-step wizard.
- Current V1 uses existing owner surfaces only. Library true-empty owns its local Create folder CTA; Folder Detail owns mode-appropriate New subfolder / New deck CTAs; Flashcard List owns Add flashcard and deck Import entry points; Account Settings owns sign-in, manual Drive upload, and manual Drive restore.
- Restore guidance must navigate or point to Account Settings. It must not imply a standalone onboarding restore wizard, auto-restore after sign-in, or the full restore-protection target as Current.
- Dashboard zero-content onboarding remains Target/Future unless a dedicated Dashboard task implements code, tests, and docs.

## V1 purpose

A new or freshly restored user should immediately understand the next useful action:

1. Create the first deck.
2. Import cards from CSV/Excel.
3. Restore from Google Drive backup.

## V1 entry conditions

| Condition | Surface | Behavior |
| --- | --- | --- |
| `decks.count == 0 AND flashcards.count == 0` | Library empty state | Show zero-content guidance and CTAs. |
| `decks.count == 0 AND flashcards.count == 0` | Dashboard empty state, if Dashboard is visible | Show zero-content guidance and CTAs. |
| User is signed out | Empty state | Restore CTA first leads to sign-in, then user can restore manually/through account flow. |
| User is signed in | Empty state | Restore CTA opens restore flow or Settings/Account restore entry. |

V1 should preserve current route behavior unless a separate navigation task changes it.

## V1 layout — zero-content empty state

```text
┌───────────────────────────────────────┐
│ Library                               │
├───────────────────────────────────────┤
│                                       │
│             MemoX                     │
│                                       │
│      Start building your memory       │
│      system with your first deck.     │
│                                       │
│   [ Create first deck ]               │
│   [ Import CSV / Excel ]              │
│   [ Restore from Google Drive ]       │
│                                       │
│   You can use MemoX offline. Backup   │
│   is optional and can be enabled later│
│   in Settings.                        │
│                                       │
└───────────────────────────────────────┘
```

## V1 CTA behavior

| CTA | Behavior |
| --- | --- |
| Create first deck | Opens existing deck-create dialog/bottom sheet. |
| Import CSV / Excel | If no deck exists, first create/select destination deck using existing deck creation flow, then open import. |
| Restore from Google Drive | If signed out, start Google sign-in or navigate to Settings/Account. If signed in, open restore entry point. Do not auto-restore. |

## V1 states

| State | Trigger | Behavior |
| --- | --- | --- |
| Zero content | No deck and no flashcard | Show create/import/restore CTAs. |
| Create in progress | Create deck action active | Use existing dialog state/loading/error behavior. |
| Import handoff | Import selected with no deck | Require destination deck before import. |
| Restore handoff | Restore selected | Go through account/restore flow; no automatic overwrite. |
| Non-empty content | At least one deck or flashcard exists | Hide zero-content onboarding copy. |

## V1 forbidden behavior

- Do not create `lib/presentation/features/onboarding/**`.
- Do not add an onboarding route.
- Do not add a multi-step tutorial carousel.
- Do not add a first-launch welcome screen in V1.
- Do not block app usage behind sign-in.
- Do not auto-trigger restore after sign-in.
- Do not overwrite local data without the existing restore safety flow.

## Future Proposal — full onboarding flow

The full onboarding flow may be promoted later if product wants a stronger first-run experience.

Future scope may include:

- A one-time welcome screen controlled by `firstLaunchCompletedAt`.
- A richer create/import/restore handoff.
- A lightweight restore prompt when Drive backup is detected and local DB is empty.
- Dedicated onboarding state/notifier.
- Mock variants `28a`–`28i` from the design kit.

Future promotion requires updating:

- `docs/checklist/v1-implementation-scope-2026-05-29.md`
- `docs/checklist/screen-function-task-matrix.md`
- `docs/checklist/wireframe-code-parity-assessment.md`
- State/use case contracts for onboarding.

## Agent rule

During V1, implement only zero-content empty-state improvements and restore CTA routing. Do not create a standalone onboarding feature or route.

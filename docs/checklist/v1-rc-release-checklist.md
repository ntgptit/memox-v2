---
last_updated: 2026-06-02
status: rc release prep ready
source: docs/checklist/v1-rc-release-notes.md
---

# V1 RC Release Checklist

- [x] Confirm clean working tree before release-prep edits.
- [x] Confirm Prompt 35 ledger status is `RC_READY_WITH_KNOWN_FUTURE_GAPS`.
- [x] Confirm release notes generated in `docs/checklist/v1-rc-release-notes.md`.
- [x] Confirm current commit hash: `48e0476b817165ee6441619cc2e957264210966c`.
- [x] Confirm no existing duplicate tag for `v1.0.0-rc.*` or `v1.0.0*`.
- [ ] Create annotated tag.
- [ ] Push tag.
- [ ] Create GitHub Release draft if desired.
- [ ] Paste release notes from `docs/checklist/v1-rc-release-notes.md`.
- [ ] Attach artifacts only if project has build artifact workflow.
- [ ] Do not include Future features in release description.

## Selected tag

`v1.0.0-rc.1`

## Tag policy note

This repository workflow did not explicitly allow automatic tag creation or push during Prompt 36. Keep the tag unchecked until the release-prep docs are committed, the working tree is clean, and the release owner runs the tag commands from `docs/checklist/v1-rc-release-notes.md`.

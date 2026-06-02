---
last_updated: 2026-06-02
status: rc tag target ready
source: docs/checklist/v1-rc-release-notes.md
---

# V1 RC Release Checklist

- [x] Confirm clean working tree before release-prep edits.
- [x] Confirm Prompt 35 ledger status is `RC_READY_WITH_KNOWN_FUTURE_GAPS`.
- [x] Confirm release notes generated in `docs/checklist/v1-rc-release-notes.md`.
- [x] Confirm release-prep commit hash: `ce60f64068ee9cac06e9694a16fedcfe48743c88`.
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

This repository workflow did not explicitly allow automatic tag creation or push during Prompt 36. Prompt 37 may create and push the tag only after the tag-target docs commit is current, the working tree is clean, verification passes, and no local or remote duplicate tag exists.

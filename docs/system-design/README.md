# MemoX System Design

This folder owns the design-system documentation for MemoX.

## Trusted Design Source

`docs/system-design/MemoX Design System/` is the trusted design source for:

- brand foundations
- visual language
- design token meaning
- UI kit references
- component composition intent
- content voice and microcopy style
- marketing, deck, mock, and prototype direction

Read `docs/system-design/MemoX Design System/README.md` first for any UI, theme, shared widget, visual QA, presentation, marketing, mock, or prototype work.

For agent workflows, use `docs/system-design/MemoX Design System/SKILL.md` as the MemoX design skill.

## Implementation Boundary

The Design System defines what MemoX should look and feel like. Flutter code implements it through:

- `lib/core/theme/**` for tokens, theme extensions, schemes, responsive layout, and component themes
- `lib/presentation/shared/**` for reusable UI primitives and composed widgets
- `lib/l10n/*.arb` for user-facing copy

Do not introduce standalone palettes, typography scales, component styles, or copy tone outside those implementation layers.

## Legacy References

`docs/system-design/v0-memox-prompts-v2.md` is legacy prompt reference. It may be used for historical screen intent, but it must not override:

- `docs/system-design/MemoX Design System/`
- root `AGENTS.md`
- repository guards
- current Flutter theme/shared-widget contracts

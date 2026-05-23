---
name: memox-design
description: Use this skill to generate well-branded interfaces and assets for MemoX, a personal flashcard learning app built in Flutter with Material 3, Plus Jakarta Sans, and a strict tokenized design language. Use for production Flutter UI, marketing pages, decks, mocks, or throwaway prototypes.
user-invocable: true
---

Read the `README.md` file within this skill, and explore the other available files (`colors_and_type.css`, `preview/`, `ui_kits/mobile/`, `assets/`).

Key MemoX rules to carry forward:
- One font family: **Plus Jakarta Sans**. Collapsed type scale: 48 / 32 / 24 / 20 / 16 / 14 / 12. Nothing in between.
- Seeded primary: deep indigo `#24389C`. Mastery/success uses green `#004E1A`. Streak uses orange `#F97316`. No emoji, ever.
- Cards are white (`surface-container-lowest`) with a **ghost border** (1px at 15% of outline-variant) and 16px radius. Shadows cap at 6% opacity — prefer surface-container tiers over shadows.
- Copy is calm, sentence-case, second-person, and always offers the next action.
- M3 tonal surfaces, no bluish-purple gradients, no bouncy/elastic easing, no raw Material defaults in feature UI.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out of this folder and create static HTML files for the user to view. Use `colors_and_type.css` as the starting stylesheet. Use the UI kit in `ui_kits/mobile/` as a reference for component composition.

If working on production Flutter code, read `README.md` + the source links it points to (e.g. `lib/core/theme/tokens/**` in the memox repo) to become an expert in designing with this brand.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions (audience, platform, surface, variations, tone), and act as an expert designer who outputs HTML artifacts or production Flutter code, depending on the need.

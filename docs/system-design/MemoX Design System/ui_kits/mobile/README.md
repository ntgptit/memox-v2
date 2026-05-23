# MemoX — Mobile UI Kit

An interactive click-through recreation of the MemoX mobile app, built in HTML/JSX as a reference for the Flutter implementation in `lib/features/**`.

## Screens

1. **Home** — greeting, due-now CTA, streak + mastered counters, "pick up where you left off" deck list.
2. **Library** — filter chips, deck cards with inline mastery bars, FAB for "New deck."
3. **Deck detail** — 5-mode selector (Review / Match / Guess / Recall / Fill), mastery ring, card status breakdown.
4. **Study (Review)** — card front/back flip with example sentence, 4-way rating row (Again / Hard / Good / Easy), inline undo toast.
5. **Stats** — reviews today + retention stat cards, weekly bar chart, per-deck mastery bars.

## Conventions

- `StatusBar`, `BottomNav`, `Ic` are shared layout/icon primitives; everything else is screen-level.
- Icons via Lucide CDN (substitute for Flutter's Material Symbols).
- All color/spacing/radius/type values come from `../../colors_and_type.css`.
- Screens are visually-only; they don't share navigation state (kit-showcase, not a connected prototype).

## Source mapping

- `HomeScreen` → `lib/features/home/presentation/pages/home_page.dart`
- `LibraryScreen` → `lib/features/library/presentation/pages/library_page.dart`
- `DeckScreen` → `lib/features/decks/presentation/pages/deck_detail_page.dart`
- `StudyScreen` → `lib/features/study/presentation/pages/review_study_page.dart`
- `StatsScreen` → `lib/features/stats/presentation/pages/stats_page.dart`

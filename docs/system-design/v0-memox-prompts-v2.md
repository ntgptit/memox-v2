# 🎯 Bộ Prompt UI cho Flutter — App "Spaced Learning" (Phiên bản tối ưu)

> **Triết lý thiết kế**: Đẹp trong sự tiết chế. Mỗi element đều có lý do tồn tại.
> Lấy cảm hứng từ Apple Notes, Google Keep, Duolingo — đơn giản nhưng tinh tế.

---

## 📐 Nguyên tắc thiết kế xuyên suốt

Dán đoạn này vào đầu MỌI prompt để giữ consistency:

```
GLOBAL DESIGN PRINCIPLES (apply to ALL screens):

PHILOSOPHY: "Calm Technology" — the app should feel like a quiet, 
well-organized library, not a noisy arcade. Every pixel earns its place.

VISUAL HIERARCHY:
- Maximum 2 levels of visual emphasis per screen
- Only ONE primary action per screen (single FAB or single CTA)
- No more than 3 colors visible at any time (primary + surface + one semantic accent from the app theme)
- Text: maximum 3 font sizes per screen (title, body, caption)

SPACING & BREATHING ROOM:
- Generous whitespace — never let elements feel cramped
- Consistent 16dp base grid, 24dp section spacing
- Cards have 16dp internal padding minimum
- Touch targets: minimum 48dp height (M3 standard)

THEME SOURCE OF TRUTH:
- Do NOT invent a standalone color palette for these prompts
- Use the app theme as the only color source:
  + `lib/core/theme/tokens/color_tokens.dart`
  + `lib/core/theme/color_schemes/app_color_scheme.dart`
  + `lib/core/theme/color_schemes/custom_colors.dart`
  + `lib/core/theme/app_theme.dart`
- For Flutter output, consume the app theme through `Theme.of(context).colorScheme` and theme extensions, not one-off hex colors
- Use semantic roles everywhere: `primary`, `surface`, `surfaceContainer*`, `onSurface`, `onSurfaceVariant`, `success`, `warning`, `error`, `masteryLow`, `masteryMid`, `masteryHigh`
- If a screen needs category accents, derive them from the app theme seed palette already defined by the repo
- All colors should remain soft and cohesive within the app theme system — no neon, no harsh contrasts

FLUTTER IMPLEMENTATION TARGET:
- Output Flutter/Dart directly — do NOT generate React, HTML, CSS, Tailwind, or web-only component code
- Use Material 3 (`useMaterial3: true`)
- Respect the repository structure and existing shared UI/theme foundation
- Prefer app theme tokens, shared widgets, and semantic color roles over hardcoded values
- Use Riverpod for state and GoRouter for navigation when interaction or flow is involved
- Keep the result mobile-first and tuned for a phone viewport around 390x844 logical pixels

AGENTIC EXECUTION MODE:
- You are explicitly allowed to use subagents / parallel workers for non-trivial tasks when the model or toolchain supports it
- Delegate only bounded, concrete subtasks with clear ownership, then integrate the results back into one coherent Flutter implementation
- Use subagents when they materially help with multi-screen work, theme alignment, widget extraction, verification, or test authoring
- Perform recursive review before finalizing:
  + first-pass implementation
  + self-review for theme, layout, state, navigation, and repository alignment
  + targeted fixes
  + at least one more review pass until no significant issues remain
- Treat recursive review as mandatory for substantial outputs, not optional polish

TYPOGRAPHY:
- Use "Plus Jakarta Sans" for all text (clean, geometric, friendly)
- Headings: 600 weight, generous letter-spacing (-0.02em)
- Body: 400 weight, 1.5 line-height for readability
- Never use ALL CAPS except for tiny labels (12sp)
- Maximum 60 characters per line for readability

COMPONENTS STYLE:
- Cards: 16dp radius, subtle 1dp border using theme `outline`/`outlineVariant`, NO heavy shadows
- Buttons: Rounded (24dp radius), medium weight text, no uppercase
- Icons: Outlined style only (not filled), 24dp, consistent stroke width
- Chips: 8dp radius, outlined variant, subtle background on selected
- Transitions: 300ms ease-out, no bouncy/spring animations
- No gradients on interactive elements
- No blur/glassmorphism effects

ANTI-PATTERNS (strictly avoid):
- ❌ Overlapping elements or layered cards
- ❌ More than one floating action button
- ❌ Decorative illustrations that don't serve function
- ❌ Animated backgrounds or moving textures
- ❌ Color-coding more than 4 categories simultaneously
- ❌ Nested scrollable areas
- ❌ Information density higher than Google Keep
- ❌ Skeleton screens with more than 3 placeholder blocks
- ❌ Pure white backgrounds — always use app theme surface tones
- ❌ Drop shadows darker than 8% opacity
```

---

## PROMPT 1 — Library Overview

```
[Paste GLOBAL DESIGN PRINCIPLES above first]

Design the LIBRARY OVERVIEW screen of the "Spaced Learning" app.

LAYOUT STRUCTURE (top to bottom):
1. TOP BAR — Simple, not a full Material App Bar
   - Left: "Spaced Learning" in Plus Jakarta Sans, 600 weight, 22sp
   - Right: Search icon (outlined) + circular avatar (32dp)
   - No background color — just content on surface
   - Subtle bottom divider (1dp, 6% opacity)

2. GREETING SECTION — Personal, minimal
   - "Good morning, Alex" — 16sp, 400 weight, secondary text color
   - "You have 12 items due today" — 14sp, with app theme success/progress emphasis on "12"
   - Small "Study now →" text link (not a button)
   - Total height: ~64dp, no card/container, just text

3. FOLDER LIST — The main content
   - Section label: "Folders" — 14sp, 500 weight, uppercase, 
     letter-spacing 0.08em, secondary color
   - Simple vertical list (NOT grid) — one folder per row
   - Each folder row:
     + Left: Rounded square icon (40dp) using a tonal color derived from the app theme
       (20% opacity background + same-tone icon)
     + Center: Folder name (16sp, 500 weight) on first line
       Subtitle on second line: "5 decks · 128 items" in 13sp caption color
     + Right: Circular progress indicator (32dp, 2dp stroke, 
       app theme primary) showing mastery %
     + No shadow, no border — just clean row with 56dp height
     + Divider between rows: 1dp, 4% opacity, indented to align with text
   - Rows have subtle hover/press state (4% primary overlay)

4. BOTTOM NAVIGATION — 4 tabs, clean
   - Icons only (no labels until selected)
   - Selected: filled icon + label (12sp) + app theme primary
   - Unselected: outlined icon only, secondary color
   - Tabs: Home, Library, Progress, Settings
   - Subtle top divider, no shadow

5. FAB — Single, restrained
   - Standard FAB (not extended), bottom-right
   - "+" icon only, app theme primary container
   - 56dp, 16dp radius (M3)
   - Only FAB on the entire screen

EMPTY STATE (when no folders):
- Center-aligned vertically
- Simple line-art icon of an open folder (64dp, secondary color)
- "No folders yet" — 18sp, 500 weight
- "Create your first folder to start building your library" — 14sp, caption
- One outlined button: "Create Folder"
- No heavy illustrations, no mascots

DATA: Show 5 sample folders with realistic names like 
"Japanese N5", "Daily Vocabulary", "Grammar Basics", "Kanji Practice", 
"Conversation Phrases". Varying mastery percentages.

Generate as a Flutter screen in Dart for a phone viewport around 390x844.
Use Material 3, the existing app theme, and repo-aligned shared UI patterns.
Prioritize readability and calm aesthetics.
```

---

## PROMPT 2 — Folder Detail Screen

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design the FOLDER DETAIL SCREEN for the "Spaced Learning" app.

CRITICAL BUSINESS RULE:
A folder can contain EITHER subfolders OR decks — never both.
- If subfolders exist → cannot create decks (and vice versa)
- Only the deepest folder level can contain decks
- The UI must make this constraint feel natural, not restrictive

LAYOUT:

1. TOP SECTION — Contextual header
   - Back arrow (←) + Folder name (20sp, 600 weight)
   - Below name: breadcrumb path in 13sp caption 
     ("Library → Japanese N5")
   - Right: overflow menu (⋮) for Edit, Delete, Reorder
   - Clean, no colored background — just surface

2. FOLDER STATUS INDICATOR — Subtle, informative
   - If folder has subfolders: 
     Small info row with folder icon: "Contains 3 subfolders"
   - If folder has decks: 
     Small info row with deck icon: "Contains 5 decks · 234 items"
   - Styled as a quiet info bar (surface-variant background, 
     8dp radius, 12dp vertical padding)
   - This tells users what this folder holds without being loud

3a. SUBFOLDER VIEW (when folder contains subfolders):
   - Same row style as the Library Overview folder rows
   - Each row: icon using a tone derived from the app theme + subfolder name + content count + arrow (→)
   - FAB: "+" creates new subfolder
   - If user taps FAB, show simple dialog:
     "Create Subfolder" with name field + Create button

3b. DECK VIEW (when folder is a leaf — contains decks):
   - Deck cards in vertical list (NOT grid — easier to scan)
   - Each deck card (subtle outlined card, 12dp radius):
     + Deck name (16sp, 500 weight)
     + Item count + due count: "42 items · 8 due today"
     + Thin mastery progress bar (4dp height, full width, rounded)
       Colors: `surfaceContainerHighest` track, gradient from `masteryLow` → `masteryMid` → `masteryHigh` from the app theme
     + Row of small chips if tagged: "Grammar", "Kanji"
     + Entire card is tappable — no separate "Study" button on the card
   - FAB: "+" creates new deck

4. CONSTRAINT MESSAGING — Friendly, not blocking
   When folder already has subfolders and user might wonder about decks:
   - Bottom of list, subtle text: 
     "To add decks here, organize them in a subfolder"
   - NOT a warning banner — just helpful guidance text (13sp, caption color)

TRANSITIONS:
- Entering screen: content slides up gently (200ms, ease-out)
- No hero animations — keep it simple

DATA: Show a folder "Japanese N5" with 3 subfolders: 
"Vocabulary", "Grammar", "Kanji". 
Also prepare the deck view for "Vocabulary" subfolder with 4 decks.

Generate as an interactive Flutter screen in Dart.
Include a demo toggle to switch between subfolder view and deck view.
Use Material 3 and the existing app theme.
```

---

## PROMPT 3 — Deck Detail & Study Mode Selection

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design the DECK DETAIL SCREEN for the "Spaced Learning" app.
This is where users see their study items and choose how to study.

LAYOUT:

1. HEADER — Informative but compact
   - Back arrow + Deck name (20sp, 600 weight)
   - Subtitle: "Japanese N5 → Vocabulary" (breadcrumb, 13sp)
   - Right: Edit icon + overflow menu

2. STUDY SUMMARY — Quick glance stats
   - Single row of 4 stat items, evenly spaced
   - Each item: number (20sp, 600 weight) + label below (12sp, caption)
   - Items: "42 Total" | "8 Due" | "28 Known" | "6 New"
   - Due count uses the app theme warning/accent role if > 0
   - Contained in a surface-variant row (no card, just background strip)
   - Total height: ~72dp

3. PRIMARY ACTION — Start studying
   - Full-width button, 52dp height, app theme primary, 12dp radius
   - Text: "Study 8 due items" (or "Start studying" if no due items)
   - Below button: "or choose a study mode" — 13sp, tappable, 
     secondary text color
   - Tapping this text OR the main button opens the MODE SELECTOR

4. STUDY MODE SELECTOR — Clean bottom sheet
   - Bottom sheet with handle bar at top
   - Title: "Choose study mode" (18sp, 600 weight)
   - 5 modes as simple list rows (NOT fancy cards):

     📖 Review
        "Review study items with spaced repetition"
     
     🔗 Match  
        "Pair terms with definitions"
     
     🤔 Guess
        "Multiple choice from definitions"
     
     🧠 Recall
        "Type what you remember"
     
     ✏️ Fill
        "Complete the missing word"

   - Each row: 56dp height
     Left: emoji (24dp) in a 40dp circle (surface-variant bg)
     Center: Mode name (15sp, 500 weight) + description (13sp, caption)
     Right: Arrow (→)
   - No color coding per mode — keep it uniform and calm
   - No difficulty badges — don't overwhelm with info
   - Selected mode has subtle app theme primary left border (3dp)

5. CARD LIST — Below the study button
   - Section label: "All Items" + count + sort dropdown
   - Sort options: Recently added, Alphabetical, Due date
   - Card rows (compact, 52dp):
     + Front text (15sp, truncated to 1 line)
     + Small status dot using app theme `statusMastered`, `statusLearning`, `statusNew`
     + Tap to expand showing front + back inline
   - No swipe actions — keep interaction simple
   - Floating "+" button at bottom-right to add a new item

INTERACTIONS:
- Bottom sheet slides up smoothly (300ms, ease-out)
- Tapping outside or swiping down closes sheet
- Card rows expand/collapse with gentle animation (200ms)

DATA: Deck "Core Vocabulary" with 12 sample Japanese-English 
study items. Mix of new, learning, and known statuses.

Generate as an interactive Flutter screen in Dart with a working `showModalBottomSheet`.
Phone viewport around 390x844.
```

---

## PROMPT 4 — Review Mode (Flip Card)

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design the REVIEW MODE (flip card study) for the "Spaced Learning" app.
This is the CORE study experience — it must feel focused and distraction-free.

DESIGN GOAL: "One item, one decision." Nothing else competes for attention.

LAYOUT:

1. TOP BAR — Minimal, informational
   - Left: Close button (×) — not back arrow (this is a session)
   - Center: "4 / 20" progress text (14sp, secondary color)
   - Right: Settings gear icon (for session settings)
   - Below: thin progress bar (3dp, rounded, app theme primary on `surfaceContainerHighest` track)
   - Total top section height: ~48dp

2. THE STUDY CARD — Center stage
   - Centered vertically with equal top/bottom space
   - Card dimensions: ~340dp wide × ~400dp tall (adapts to content)
   - Styling: 
     + Surface color background
     + 16dp corner radius
     + Subtle border (1dp, 8% opacity)
     + Gentle shadow (0 4dp 12dp rgba(0,0,0,0.06))
     + NO colored borders or accents on the card
   
   FRONT SIDE:
   - Content centered both horizontally and vertically
   - Term: 22sp, 600 weight, centered
   - If content is long: 18sp, left-aligned, with scroll
   - Bottom of card: "Tap to flip" hint (12sp, 20% opacity)
     This hint fades away after the user's first flip in the session
   
   BACK SIDE:
   - Definition: 17sp, 400 weight, centered or left-aligned if long
   - If there's an example: italicized, 14sp, secondary color, 
     separated by a thin divider
   - If there's a hint: shown as a small chip at bottom

   FLIP ANIMATION:
   - 3D flip on Y-axis, 350ms, ease-in-out
   - Slight scale down to 0.96 at midpoint, back to 1.0
   - Card content crossfades during flip (no visible reverse text)

3. RATING AREA — Appears only AFTER flipping
   - Fades in smoothly below the card (200ms delay after flip)
   - 4 buttons in a single row, evenly spaced:
   
     [Again]  [Hard]  [Good]  [Easy]
   
   - Button styling:
     + 72dp wide × 48dp tall, 12dp radius
     + "Again": outlined, using app theme `ratingAgain`
     + "Hard": outlined, using app theme `ratingHard`
     + "Good": filled tonal using app theme `ratingGood`/primary — this is the DEFAULT
     + "Easy": outlined, using app theme `ratingEasy`
   - Below each button: next review time in 11sp caption
     "1m"    "10m"    "1d"     "4d"
   - "Good" is visually emphasized as the most common choice
   - No icons in buttons — just text. Keep it clean

4. GESTURE SUPPORT (visual feedback only):
   - Swipe right on card → app theme success overlay fades in + "Good" label
   - Swipe left → app theme error overlay + "Again" label
   - Release completes the action
   - Overlay max opacity: 15% — subtle, not dramatic
   - NO swipe up/down — only two directions to keep it simple

5. SESSION COMPLETE:
   - Simple, centered layout:
     + Checkmark in a circle (64dp, app theme success tone, outlined)
     + "Session complete" (20sp, 600 weight)
     + 3 stat rows: "20 items reviewed" / "85% correct" / "12 min"
       Each row: icon (16dp) + text (15sp), vertically stacked
     + Primary button: "Done" → returns to deck
     + Text link below: "Study more items"
   - NO confetti, no celebration animation — keep it calm and satisfying

Generate as a fully interactive Flutter screen in Dart with:
- 5 sample study items with front/back content
- Working flip animation
- Rating buttons that advance to next card
- Progress tracking
- Session complete screen at the end
Phone viewport around 390x844.
```

---

## PROMPT 5 — Match Mode

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design MATCH MODE for the "Spaced Learning" app.
A term-definition matching game that's engaging but NOT overwhelming.

DESIGN GOAL: "Playful focus" — game-like engagement without visual chaos.

LAYOUT:

1. TOP BAR:
   - Close (×) + "Match" title (16sp, 500 weight) + Timer
   - Timer: simple text "1:24" (16sp, monospace feel), no dramatic countdown bar
   - Below: pairs remaining "4 pairs left" (13sp, caption)

2. GAME AREA — Two-column layout:
   - LEFT column: Terms (word/phrase)
   - RIGHT column: Definitions
   - Show 4-5 pairs at a time (not 6 — less overwhelming)
   
   ITEM STYLING:
   - Each item: outlined card, 12dp radius
   - Compact: 14sp text, 12dp padding, auto-height based on content
   - Unselected: surface background, secondary text
   - Selected: app theme primary tonal background, primary text, 
     subtle scale-up (1.02) — no glow, no border animation
   - Items have adequate spacing (8dp gap)

   MATCH ANIMATIONS:
   - Correct pair: both items get an app theme success checkmark overlay (✓),
     then smoothly fade out and collapse (300ms)
     Remaining items reposition with 200ms ease
   - Wrong pair: both items briefly show an app theme error border (200ms), 
     then shake horizontally (gentle, 4dp amplitude, 300ms)
     Then reset to unselected state
   - Keep animations SUBTLE — no particles, no connection lines

3. COMPLETION:
   - Clean summary card (centered):
     + "All matched!" (18sp, 600 weight)
     + Time taken: "1:24"
     + Mistakes: "2 wrong attempts"
     + Simple star rating: ★★★ (filled/outlined, 32dp, app theme warning/achievement tone)
       3 stars = 0 mistakes, 2 = 1-2 mistakes, 1 = 3+ mistakes
     + "Play again" outlined button + "Done" filled button
   - No confetti, no dramatic animations

INTERACTION FLOW:
1. Tap a term → it highlights (selected state)
2. Tap a definition → check match
3. If correct → both disappear
4. If wrong → both shake, deselect
5. Tapping a selected item deselects it
6. Cannot select two items from the same column

DATA: 5 pairs of Japanese vocabulary (term → English definition).

Generate as a fully playable Flutter screen in Dart.
Phone viewport around 390x844. Keep the visual energy calm but engaging.
```

---

## PROMPT 6 — Guess Mode

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design GUESS MODE for the "Spaced Learning" app.
See a definition, choose the correct term from 4 options.

LAYOUT:

1. TOP BAR:
   - Close (×) + Progress "5/20" + Streak counter
   - Streak: small flame emoji + number, only visible when streak ≥ 2
     Styled as a small chip (surface-variant bg), not prominent
   - Progress bar below (3dp, same as Review mode)

2. QUESTION CARD — Takes upper 40% of content area:
   - Surface-variant background, 16dp radius, 20dp padding
   - Label at top: "What is this?" (12sp, caption, secondary)
   - Definition text: 18sp, 400 weight, centered
   - Card height adapts to content but minimum ~160dp
   - No decorative elements — just the question text

3. ANSWER OPTIONS — 4 choices below the card:
   - 4 full-width outlined buttons, stacked vertically
   - 8dp gap between each
   - Each button: 52dp height, 12dp radius, left-aligned text (15sp)
   - Letter prefix: "A.", "B.", "C.", "D." in secondary color

   ANSWER FEEDBACK:
   Correct:
   - Selected button: fills with app theme success background + on-success checkmark right
   - Other buttons: fade to 40% opacity
   - Brief pause (1s) then auto-advance to next question
   - No text overlay, no popup

   Wrong:
   - Selected button: fills with app theme error background + on-error × icon right
   - Correct button: fills with app theme success background + checkmark
   - "Tap to continue" text appears below options (13sp)
   - User must tap to proceed (forced review moment)

4. BOTTOM AREA:
   - "Skip →" text button, secondary color (13sp)
   - Skipped items go back into the queue

SESSION COMPLETE:
- Same calm style as Review mode completion
- Stats: "16/20 correct (80%)" + "Best streak: 7"
- "Try again" + "Done" buttons

DATA: 8 sample questions using Japanese N5 vocabulary.
Mix of correct and showing wrong-answer feedback.

Generate as an interactive Flutter screen in Dart.
Phone viewport around 390x844.
```

---

## PROMPT 7 — Recall Mode

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design RECALL MODE for the "Spaced Learning" app.
Free recall — the hardest and most effective study method.

DESIGN GOAL: "Deep focus" — a blank canvas that forces the brain to work.
This mode intentionally shows MINIMAL information to maximize recall effort.
The screen should feel like a clean notebook page, not a quiz show.

LAYOUT:

1. TOP BAR — Consistent with other study modes:
   - Close (×) + "Recall" title (16sp, 500 weight) + progress "3/15"
   - Thin progress bar below (3dp, app theme primary on `surfaceContainerHighest` track)
   - Total height: ~48dp

2. PROMPT CARD — Deliberately sparse:
   - Positioned in the upper third of the content area
   - Surface-variant background, 16dp radius, 20dp padding
   - Small label at top: "What do you know about:" (12sp, caption, 
     secondary color, uppercase, letter-spacing 0.06em)
   - Term/topic below: 22sp, 600 weight, app theme `onSurface`, centered
   - Optional context hint: tiny chip below the term showing category
     e.g. "Grammar" or "Vocabulary" — 11sp, outlined, secondary
   - Card total height: ~120dp
   - NO definition, NO hints, NO multiple choice — just the term
   - This emptiness is intentional and should feel clean, not broken

3. WRITING AREA — The main interaction:
   - M3 outlined text field, multiline
   - Height: 4 visible lines (~140dp), expandable as user types
   - Label (floating): "Your answer"
   - Placeholder: "Write everything you remember..."
   - 16sp text, 1.6 line-height for comfortable writing
   - Character counter bottom-right: subtle, 11sp, only appears 
     after 50+ characters typed
   - Soft keyboard pushes content up naturally

4. ACTION BUTTON:
   - Below text field, 16dp gap
   - Full-width outlined button, 48dp height, 12dp radius
   - Text: "Show answer" with eye icon (outlined, 20dp)
   - Disabled state (40% opacity) until user types at least 1 character
   - This prevents peeking without trying

5. AFTER REVEAL — Comparison view (replaces input area):
   - Smooth transition: input area fades out (150ms), 
     comparison fades in (200ms, slight slide-up)
   
   YOUR ANSWER card:
   - Label: "Your answer" (12sp, caption, above card)
   - Surface card, 12dp radius, 16dp padding
   - User's typed text in 15sp, preserved exactly as typed
   - Left border accent: 3dp, app theme neutral/outline tone
   
   CORRECT ANSWER card:
   - Label: "Complete answer" (12sp, caption, above card)
   - Surface-variant card, 12dp radius, 16dp padding
   - Full definition/answer in 15sp
   - Left border accent: 3dp, app theme primary
   - If answer is long: max height 200dp with scroll
   
   Gap between cards: 12dp
   Both cards have equal width, stacked vertically

6. SELF-ASSESSMENT — The rating step:
   - Below the comparison, 20dp gap
   - Label: "How well did you recall?" (13sp, caption, centered)
   - M3 segmented button, full width, 3 segments:
     
     "Missed"  |  "Partial"  |  "Got it"
   
   - Default: none selected (all neutral surface color)
   - On selection:
     + "Missed" → segment fills with app theme `selfMissed`
     + "Partial" → segment fills with app theme `selfPartial`
     + "Got it" → segment fills with app theme `selfGotIt`
   - After selection: 800ms pause, then smooth transition to next card
   - Selection is the ONLY way to proceed — no skip button here
     (forces honest self-assessment)

7. SESSION COMPLETE:
   - Same calm completion screen as other modes
   - Stats specific to recall:
     + "15 items recalled"
     + "Got it: 8 · Partial: 5 · Missed: 2"
     + Average self-rating as a simple label
   - "Done" filled button + "Review missed items" text link

MICRO-INTERACTIONS:
- Prompt card enters with gentle fade + slight scale (0.97 → 1.0, 200ms)
- Text field gets focus automatically after card animation completes
- "Show answer" button has subtle press state (scale 0.98)
- Self-assessment segments have gentle press feedback

DATA: 6 sample study items using Japanese N5 vocabulary.
Terms like "食べる", "天気", "勉強", "電車", "友達", "病院"
with corresponding full definitions and example sentences.

Generate as a fully interactive Flutter screen in Dart with:
- Working text input
- Show/hide answer toggle
- Self-assessment that advances to next card
- Progress tracking through all 6 items
- Session complete screen
Phone viewport around 390x844.
```

---

## PROMPT 8 — Fill Mode

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design FILL MODE for the "Spaced Learning" app.
Type the missing word — tests spelling, accuracy, and active production.

DESIGN GOAL: "Precision practice" — clean, focused, keyboard-first.
Like a minimalist typing test. The blank draws the eye, 
the input captures the fingers, everything else stays quiet.

LAYOUT:

1. TOP BAR — Consistent with other study modes:
   - Close (×) + "Fill" title (16sp, 500 weight) + progress "7/20"
   - Thin progress bar below (3dp, app theme primary on `surfaceContainerHighest` track)
   - Streak indicator: appears after 3+ correct in a row
     Small chip at right of progress text: "🔥 5" (12sp)
     Fades in gently, no dramatic animation
   - Total height: ~48dp

2. QUESTION CARD — The sentence with a blank:
   - Surface-variant background, 16dp radius, 24dp padding
   - Positioned in the upper 40% of content area
   - Sentence text: 18sp, 400 weight, 1.6 line-height
   - The blank is rendered as: ________
     + Underline: 2dp thick, app theme primary, width matches answer length
       (approximate, e.g. ~80dp for short words, ~140dp for longer)
     + Gentle pulse animation on the underline (opacity 60% → 100%, 
       1.5s cycle, ease-in-out) — draws attention to where to type
     + The blank is inline with the sentence text, not on a separate line
   - Example sentences:
     "The Japanese word for 'water' is ________"
     "________ means 'to eat' in English"
     "The past tense of 食べる is ________"
   - If there's a hint available: small text link below the card
     "Show hint" (13sp, secondary) → reveals first letter + blanks
     e.g. "m _ _ _" — only appears if card has a hint configured
   - Card adapts height to content, minimum ~100dp

3. INPUT AREA — Keyboard-first design:
   - 20dp below the question card
   - Single-line M3 outlined text field, 52dp height, 12dp radius
   - Auto-focused: keyboard opens immediately on screen enter
   - Label (floating): "Your answer"
   - Placeholder: "Type your answer..."
   - Text: 17sp, centered within the field
   - Right side of text field: "Check" button integrated into field
     + Filled tonal style, compact (fits inside the text field outline)
     + 36dp height, 8dp radius, app theme primary tonal color
     + Icon: arrow-right (→) 20dp, no text label
     + Disabled state until user types at least 1 character
   - Pressing Enter on keyboard = same as tapping Check
   - Input is NOT case-sensitive for matching (but display preserves case)

4. FEEDBACK STATES — Clear, immediate, respectful:

   ✅ CORRECT:
   - Input field: border transitions to app theme success (200ms)
   - Inside field: text turns to app theme success, small checkmark appears left of text
   - In the question card: the blank fills in with the correct answer
     + Answer text appears in the app theme success color where the blank was
     + Underline animation stops, becomes solid app theme success
     + Gentle scale pulse on the filled word (1.0 → 1.05 → 1.0, 300ms)
   - Auto-advance to next card after 1.2s
   - No popup, no overlay — the card itself shows success

   🟡 CLOSE (fuzzy match — e.g. minor typo, accent missing):
   - Input field: border transitions to app theme warning (200ms)
   - Below input field, 8dp gap:
     + Surface card with app theme warning left border (3dp):
       "Almost! Correct spelling:"
       Correct answer in 16sp, 500 weight
       Difference highlighted: wrong characters in app theme error, 
       correct characters in app theme success (inline diff)
     + Two text buttons side by side:
       "Accept anyway" (app theme success text) | "Mark as wrong" (app theme error text)
     + Default: neither selected, user must choose
   - Fuzzy match threshold: Levenshtein distance ≤ 2 
     OR only difference is capitalization/accents

   ❌ WRONG:
   - Input field: border transitions to app theme error (200ms)
   - Below input field, 8dp gap:
     + Surface card with app theme error left border (3dp):
       "The correct answer is:"
       Correct answer in 16sp, 500 weight, primary text
   - Input field clears after 500ms
   - Placeholder changes to: "Type the correct answer to continue"
   - User MUST type the correct answer to proceed
     + This reinforcement step is key to the learning method
     + When they type it correctly: border turns to app theme success, 
       brief checkmark, then auto-advance after 800ms
   - "Skip" text button appears after 2 failed attempts at retyping
     (13sp, secondary, bottom of screen)

5. BETWEEN CARDS — Transition:
   - Current card content crossfades out (150ms)
   - New card content crossfades in (200ms)
   - Input field clears and refocuses
   - Progress bar advances smoothly
   - No slide animations — crossfade keeps it calm

6. SESSION COMPLETE:
   - Same calm completion screen as other modes
   - Stats specific to fill mode:
     + "20 items completed"
     + "14 correct first try (70%)"
     + "4 close matches accepted"
     + "2 needed retry"
     + Longest streak: "🔥 8"
   - "Done" filled button + "Practice mistakes" text link
   - Mistakes list: expandable section showing items 
     that were wrong on first attempt

KEYBOARD CONSIDERATIONS:
- Input auto-focuses on every new card
- Keyboard type adapts: text for most, 
  number keyboard if answer is numeric
- IME support for Japanese/CJK input 
  (important since this is a language learning app)
- On iOS: "Done" keyboard button = submit answer
- Text field scrolls into view if keyboard covers it

DATA: 8 sample fill-in-the-blank items for Japanese N5:
- "The Japanese word for 'water' is ________" → みず (mizu)
- "________ means 'train' in English" → 電車 (densha)  
- "The て-form of 飲む is ________" → 飲んで
- "________ is the counter for small animals" → 匹 (hiki)
- "'Beautiful' in Japanese is ________" → 美しい (utsukushii)
- "The opposite of 大きい is ________" → 小さい (chiisai)
- "________ means 'library'" → 図書館 (toshokan)
- "The polite form of する is ________" → します (shimasu)

Generate as a fully interactive Flutter screen in Dart with:
- Working text input with auto-focus
- Check button and Enter key submission
- All 3 feedback states (correct, close, wrong)
- Retry mechanic for wrong answers
- Streak counter
- Progress through all 8 items
- Session complete with stats
Phone viewport around 390x844.
```

---

## PROMPT 9 — Learning Progress Screen

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design the STATISTICS/PROGRESS SCREEN for the "Spaced Learning" app.
Accessible from the bottom navigation "Progress" tab.

DESIGN GOAL: Motivational at a glance, detailed on demand.
Must NOT look like a complex dashboard — it's a learning app, not analytics software.

LAYOUT (single scrollable screen):

1. HEADER:
   - "Your Progress" (20sp, 600 weight)
   - Period selector as 3 text tabs: "Week · Month · All time"
     Active tab: app theme primary + underline (2dp)
     Inactive: secondary color
   - Clean, no background, just text

2. STREAK & TODAY — Hero section
   - Large streak number: "14" (48sp, 600 weight, app theme primary)
   - Below: "day streak 🔥" (15sp, secondary)
   - Next to it (or below on small screens):
     "Today: 23 items · 18 min" (14sp, caption)
   - Contained in a subtle surface-variant card, 16dp radius
   - No elaborate streak visualizations

3. WEEKLY ACTIVITY — Simple bar chart
   - 7 bars for Mon-Sun, current day highlighted with app theme primary
   - Other days: surface-variant color (tonal)
   - Bar height = relative study items completed that day
   - Day labels below: "M T W T F S S" (12sp)
   - Above each bar on hover/tap: count "23"
   - Chart height: ~120dp max
   - No axis lines, no grid — just bars and labels

4. MASTERY OVERVIEW — Donut chart
   - Simple donut (3 segments only):
     + Known (app theme success/mastery) — largest segment ideally
     + Learning (app theme warning)
     + New (app theme neutral)
   - Center of donut: total item count (24sp, 600 weight)
   - Legend below: 3 items in a row, each with color dot + label + count
   - Donut size: ~160dp diameter
   - Smooth segment animation on load

5. STUDY MODES — Usage breakdown
   - Section title: "Study modes" (14sp, 500 weight, uppercase label)
   - Simple horizontal bar chart (5 bars, one per mode):
     Review  ████████████  45%
     Match   ██████        22%
     Guess   █████         18%
     Recall  ███           10%
     Fill    ██             5%
   - Bars use app theme primary (same color, different lengths)
   - Mode name left, percentage right, bar in between
   - Compact: each row ~36dp height

6. TOUGH ITEMS — Optional helpful section
   - Section title: "Items to focus on" 
   - 3-5 items with lowest mastery, shown as simple rows:
     + Term (15sp) + accuracy percentage (14sp, app theme error if <50%)
   - "Practice these" text button at bottom
   - Collapsible section (starts collapsed with "Show" toggle)

VISUAL RULES FOR THIS SCREEN:
- All charts use only app theme primary + tonal variants (no rainbow)
- Numbers animate counting up on screen load (400ms)
- No heavy chart libraries look — charts should feel hand-crafted
- Adequate spacing between sections (32dp)
- Each section can be mentally separated at a glance

Generate as a Flutter screen in Dart.
Build the charts with Flutter-native widgets or lightweight custom painting patterns, not web chart libraries.
Phone viewport around 390x844. Include realistic sample data 
that tells a story (a student studying consistently with 
some natural variation).
```

---

## PROMPT 10 — Study Item Create/Edit & Settings

```
[Paste GLOBAL DESIGN PRINCIPLES first]

Design two utility screens for "Spaced Learning": Study Item Editor and Settings.
These are functional screens — clarity and speed are top priorities.

--- SCREEN 1: CREATE / EDIT STUDY ITEM ---

LAYOUT (full-screen dialog):
1. Top bar:
   - Left: "Cancel" text button
   - Center: "New Item" (16sp, 500 weight) or "Edit Item"
   - Right: "Save" text button (app theme primary, 500 weight)
     Disabled state when fields are empty

2. Form fields (generous vertical spacing, 20dp between fields):
   
   FRONT (required):
   - Label: "Front" (13sp, caption, above field)
   - M3 outlined text field, multiline, 3 lines visible
   - Placeholder: "Term, question, or prompt"
   - Character count bottom-right: "0/500" (11sp)

   BACK (required):
   - Label: "Back"
   - M3 outlined text field, multiline, 4 lines visible
   - Placeholder: "Definition, answer, or explanation"

   OPTIONAL FIELDS (collapsed by default):
   - "Add more details +" tappable text (14sp, app theme primary)
   - Expands to reveal:
     + Hint field (single line): "Optional hint for studying"
     + Example field (2 lines): "Usage example or context"
     + Tags: chip input with autocomplete suggestions
   - Smooth expand animation (200ms)

3. Bottom area:
   - "Add another" switch with label (keep dialog open after save)
   - Keyboard-aware: form scrolls up when keyboard appears

BATCH MODE (toggle at top):
- Toggle: "Single" | "Batch" (M3 segmented button, compact)
- Batch view:
  + Large text area (10 lines visible)
  + Placeholder: "Enter one item per line\nFront | Back"
  + Separator selector: small chips "Tab · | · ,"
  + Preview below: "4 items detected" with validity indicator
  + If parsing errors: "Line 3: missing separator" (app theme error, 12sp)

--- SCREEN 2: SETTINGS ---

Clean preference list, grouped by section:

Section headers: 12sp, uppercase, letter-spacing 0.08em, 
  secondary color, 32dp top margin

APPEARANCE
- Theme → System / Light / Dark 
  (3 small tappable cards with sun/moon/auto icon, 
  selected has app theme primary border)
- App color → 6 color circles (40dp, tappable, 
  selected has checkmark):
  Indigo, Teal, Rose, Amber, Slate, Sage

STUDYING
- Daily goal → "20 items/day" with stepper (−/+)
- Session limit → "15 minutes" with stepper
- Auto-advance delay → "1.5s" dropdown
  
NOTIFICATIONS
- Study reminder → Toggle + time selector
- Streak reminder → Toggle

DATA
- Export study items (JSON) → tappable row with export icon
- Import from file → tappable row with import icon
- Clear study history → tappable row, app theme error text, 
  with confirmation dialog

Each setting row: 52dp height, no borders between items 
(section headers provide separation). Toggle switches use 
M3 switch style. Tappable rows have subtle press state.

Generate BOTH screens as Flutter screens/widgets in Dart with tabs or segmented switching.
Phone viewport around 390x844.
```

---

## 💡 Hướng dẫn sử dụng

### Thứ tự dùng prompt:
1. **Prompt 1** (Library Overview) → Thiết lập design language cơ bản
2. **Prompt 4** (Review Mode) → Core experience, phải đẹp nhất
3. **Prompt 3** (Deck Detail) → Hub trung tâm của app
4. **Prompt 2** (Folder Detail) → Navigation structure
5. **Prompt 5** (Match) → Game mode đầu tiên
6. **Prompt 6** (Guess) → Multiple choice mode
7. **Prompt 7** (Recall) → Free recall — deep learning mode
8. **Prompt 8** (Fill) → Typing precision mode
9. **Prompt 9** (Stats) → Data visualization
10. **Prompt 10** (Create/Settings) → Utility screens cuối cùng

### Khi dùng model sinh code, thêm các ràng buộc sau:
```
Hãy generate trực tiếp Flutter/Dart cho app Spaced Learning, giữ nguyên:
- Chính xác spacing, sizing, radius, colors
- Typography: dùng Google Fonts "Plus Jakarta Sans"
- Animations: dùng flutter_animate package
- Tuân thủ Material 3 (useMaterial3: true)
- State management: Riverpod
- Navigation: GoRouter
- Dùng đúng vocabulary của repo hiện tại: Library, Folder, Deck, Progress, Due Today
- Dùng app theme hiện có qua `Theme.of(context).colorScheme` và theme extensions
- Không dùng React, HTML, CSS, Tailwind, Recharts
- Ưu tiên shared widgets/patterns hiện có trong `lib/presentation/shared/**`
- Được phép dùng subagents/parallel workers cho tác vụ không tầm thường khi hệ thống hỗ trợ
- Bắt buộc recursive review trước khi chốt output: implement -> self-review -> fix -> review lại đến khi không còn vấn đề đáng kể

[Paste prompt/context màn hình ở đây]
```

### Iterate trên model:
Nếu output quá rối, gửi:
> "Simplify the layout. Remove [specific element]. 
> More whitespace. Maximum 3 visual weights on screen."

Nếu output quá đơn điệu:
> "Add subtle micro-interactions on button press. 
> Use the app theme primary role for the primary CTA. 
> Add a gentle enter animation for the main content."

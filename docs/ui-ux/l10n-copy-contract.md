---
last_updated: 2026-05-26
status: contract
---

# L10n & Microcopy Contract

Source language is English (`lib/l10n/app_en.arb`). All user-facing text lives in ARB files. Voice follows the MemoX Design System: calm, direct, no emoji.

## Rules

| Rule | Enforcement |
| --- | --- |
| User-facing text MUST be in ARB | code review + grep on PR |
| No emoji anywhere (including icons-in-string) | grep blocklist |
| Sentence case (NOT Title Case) for buttons, headings, body | review |
| Calm and direct tone | review |
| No hype words ("Awesome!", "Yay!", "Boom!") | blocklist |
| Error messages must be actionable | review |
| Empty states must explain the next action | review |
| Tag-prefix `#` only in display, not in stored data | code |
| Use sentence-ending period in body text, not in labels | review |
| Plurals via ICU `plural` | required |
| Date/time/number via `intl` package, locale-aware | required |

## Key naming convention

```
{feature}_{screen_or_section}_{element}_{purpose}
```

The keys listed below are **suggested examples** illustrating the convention. The actual ARB file (`lib/l10n/app_en.arb`) is the source of truth once it exists. When implementing a feature, agents MAY adjust key names to better fit context, as long as the naming pattern is preserved. Once a key is in the ARB file, it MUST NOT be renamed without coordinated update of all references.

Examples:

| Key | Value (en) |
| --- | --- |
| `dashboard_welcome_morning` | Good morning |
| `dashboard_welcome_evening` | Good evening |
| `dashboard_resume_card_title` | Continue studying |
| `dashboard_resume_card_subtitle` | {deckName} · {answered} / {total} cards · {timeAgo} |
| `dashboard_today_cta_label` | Start today's review |
| `dashboard_today_cta_subtitle` | {count} cards due across {deckCount} decks |
| `library_empty_title` | Nothing here yet |
| `library_empty_body` | Create a folder to organize, or a deck to start adding cards. |
| `library_fab_new_folder` | New folder |
| `library_fab_new_deck` | New deck |
| `library_fab_import` | Import from file |
| `flashcard_create_front_label` | Front |
| `flashcard_create_back_label` | Back |
| `flashcard_create_field_required` | {field} is required. |
| `study_recall_show_answer` | Show answer |
| `study_recall_grade_forgot` | Forgot |
| `study_recall_grade_got_it` | Got it |
| `study_fill_button_hint` | Hint |
| `study_fill_button_check` | Check |
| `study_fill_button_mark_correct` | Mark correct |
| `study_fill_button_try_again` | Try again |
| `study_review_swipe_hint` | Swipe left for the next card |
| `study_guess_prompt_caption` | WHAT IS THIS? |
| `study_guess_next_card_in` | Next card in {seconds}s |
| `study_match_board_indicator` | Board {n} of {total} · {pairs} pairs left |
| `study_match_mistake_count` | {count, plural, =1{1 mistake} other{{count} mistakes}} |
| `study_mode_pill_review` | REVIEW |
| `study_mode_pill_match` | MATCH |
| `study_mode_pill_guess` | GUESS |
| `study_mode_pill_recall` | RECALL |
| `study_mode_pill_fill` | FILL |
| `study_result_celebrate_title` | Session complete! |
| `settings_account_signed_out_title` | Sign in to back up your data |
| `error_storage_save_failed` | Couldn't save changes. Please try again. |
| `error_validation_tag_comma` | Tags cannot contain commas. |
| `error_validation_tag_too_long` | Tag too long (max {max} chars). |
| `dialog_delete_folder_body` | Folder "{name}" and its {n} subfolders and {m} decks will be deleted. All flashcards inside will be deleted too. |
| `dialog_delete_confirm_action` | Delete |
| `sheet_tag_picker_create_new` | + Create "{tag}" |

## Forbidden patterns

- ❌ Hardcoded English string anywhere in `lib/` (except code-style violations file paths and similar).
- ❌ String concatenation for sentences. Use ICU placeholders.
- ❌ `Text("Save")` — use `Text(AppLocalizations.of(context).button_save)`.
- ❌ Emoji in any string ("✓", "🎉", "🔥"). Use icons via `Icons.*` separately.
- ❌ Title Case ("Save Changes" → "Save changes").
- ❌ Marketing voice ("Sweet!", "Awesome work!").
- ❌ Generic "Something went wrong." when specific reason is known.
- ❌ Trailing period in single-word buttons ("Save." → "Save").

## Required patterns

- ✅ Every string has an ARB key.
- ✅ Use `@key` annotations in ARB for descriptions to translators.
- ✅ Use ICU plural:

  ```json
  {
    "library_deck_count": "{count, plural, =0{No decks} =1{1 deck} other{{count} decks}}",
    "@library_deck_count": {
      "placeholders": { "count": { "type": "int" } }
    }
  }
  ```

- ✅ Use ICU select for gender/role variations (not applicable in MemoX v1, but reserve pattern).
- ✅ Date formatting via `DateFormat` from `intl`.

## Pluralization

Always plural-aware:

- "1 card" / "0 cards" / "2 cards" → ICU plural.
- "1 deck" / "N decks".
- "1 minute ago" / "N minutes ago" / "yesterday" / "{date}" — use a `RelativeTime` helper.

## Date/time

- Date: `DateFormat.yMMMd(locale)` for "May 26, 2026" / locale equivalent.
- Time: `DateFormat.Hm(locale)` for "14:32".
- Relative time: custom helper in `lib/core/utils/relative_time.dart` mapping (now, x minutes/hours/days ago, yesterday, x days ago, dd MMM, dd MMM yyyy).

## Languages planned

| Locale | Status |
| --- | --- |
| en | Source (always present, all keys) |
| vi | Planned. Translation file `app_vi.arb`. |
| ko | Planned. Translation file `app_ko.arb`. |

## Voice examples (DO vs DON'T)

| Context | DO | DON'T |
| --- | --- | --- |
| Empty deck CTA | Add your first flashcard to start studying. | 🎉 Let's add some cards! |
| Save failure | Couldn't save changes. Please try again. | Sorry, sorry, something went wrong! Please try again later. |
| Delete confirm | This will delete all nested content. | Are you ABSOLUTELY sure? This cannot be undone!!! |
| Today goal met | Daily goal met. Keep going! | 🔥🔥🔥 You're on fire! Crushing it! |
| Onboarding welcome | Build vocabulary with spaced repetition. | Welcome to the most amazing flashcard app! |

## Codegen

- Source: `lib/l10n/app_en.arb`
- Generation: `flutter gen-l10n` (configured in `pubspec.yaml`)
- Output: `lib/l10n/generated/app_localizations*.dart` (checked into git, never hand-edited)

## Agent rule

- When adding any user-facing string: ARB first, then code references the key.
- When changing copy: update ARB, regenerate l10n, update any wireframe that includes example copy.
- When adding feature in another language (future), translate ALL keys; missing translation = code does not compile.

## Related

**Repo-level:**

- `CLAUDE.md` §Doc-code parity — l10n updates count as docs
- `docs/contracts/code-style.md` — forbids hardcoded strings

**Contracts:**

- `docs/contracts/error-contract.md` — error_* keys catalog
- `../wireframes/**` — every wireframe example copy

**Code paths:**

- `lib/l10n/app_en.arb`
- `lib/l10n/generated/**`
- `lib/core/utils/relative_time.dart`

# Decision Tables: flashcard_flow_test

Test file: `integration_test/cases/flashcard_flow_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-001 deck has zero flashcards | folder `Korean` contains deck `Daily Words` with no cards | user opens `Daily Words` | `No flashcards yet` and `Add` are visible | C0+C1 |
| DT2 | TC-FLASHCARD-002 deck list uses manual `sort_order` | deck `Daily Words` has `사과` at order 0 and `학교` at order 1 | user opens the deck | card rows show `사과` before `학교` | C0+C1 |
| DT3 | TC-FLASHCARD-003 deck list is scoped to the opened deck | deck `A` has `사과` and deck `B` has `학교` | user opens deck `A` | `사과` is visible and `학교` is absent | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-004 valid front and back create one flashcard | user is in empty deck `Daily Words` | user opens add, enters `사과` / `quả táo`, and saves | editor closes and `사과` appears in the deck | C0+C1 |
| DT2 | TC-FLASHCARD-005 optional note is saved with the new flashcard | user is in deck `Daily Words` | user creates `먹다` / `ăn` with note `Động từ bất quy tắc không đặc biệt` | `먹다` appears, and opening edit/detail shows the note text | C0+C1 |
| DT3 | TC-FLASHCARD-006 blank note is accepted | user is in deck `Daily Words` | user creates `학교` / `trường học` and leaves Note empty | `학교` appears in the deck | C0+C1 |
| DT4 | TC-FLASHCARD-007 front text is empty | user opens new flashcard editor | user leaves Front empty, enters Back, and saves | validation message `front and back are required.` is visible and the editor stays open | C0+C1 |
| DT5 | TC-FLASHCARD-008 back text is empty | user opens new flashcard editor | user enters Front, leaves Back empty, and saves | validation message `front and back are required.` is visible and the editor stays open | C0+C1 |
| DT6 | TC-FLASHCARD-009 front text has only whitespace | user opens new flashcard editor | user enters spaces for Front, enters Back, and saves | validation message `front and back are required.` is visible and the editor stays open | C0+C1 |
| DT7 | TC-FLASHCARD-010 back text has only whitespace | user opens new flashcard editor | user enters Front, enters spaces for Back, and saves | validation message `front and back are required.` is visible and the editor stays open | C0+C1 |
| DT8 | TC-FLASHCARD-011 front, back, and note contain surrounding whitespace | user opens new flashcard editor | user enters padded Front, Back, and Note, then saves | list shows `사과`, and edit/detail fields show `quả táo` and `danh từ` without padding | C0+C1 |
| DT9 | TC-FLASHCARD-039 CSV import has only valid rows | deck `Daily Words` is open | user imports CSV rows `A`, `B`, and `C` and confirms | imported flashcards appear in the deck | C0+C1 |
| DT10 | TC-FLASHCARD-040 CSV import contains a row missing back text | deck `Daily Words` is open | user previews CSV with one valid row and one invalid row | preview shows `1 valid · 1 issues`, the line error is visible, and no Import action is available | C0+C1 |
| DT11 | TC-FLASHCARD-041 CSV import row order is valid | deck `Daily Words` is open | user imports CSV rows `A`, `B`, and `C` | deck rows show `A`, `B`, `C` in import order | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-012 row tap opens the current flashcard edit/detail surface | deck has card `사과` / `quả táo` | user taps card row `사과` | `Edit flashcard` opens with Front `사과` and Back `quả táo` | C0+C1 |
| DT2 | TC-FLASHCARD-013 flashcard has no note | deck has card `사과` with `note=null` | user opens edit/detail for `사과` | Note field is empty and no stale note text is shown | C0+C1 |
| DT3 | TC-FLASHCARD-014 flashcard content is long and multiline | deck has long front and multiline back/note | user opens edit/detail and scrolls | long content is reachable with no widget overflow exception | C0+C1 |
| DT4 | TC-FLASHCARD-034 deck has at least one flashcard | deck `Daily Words` has card `사과` | user taps `Study this deck` and starts the default study flow | study session opens and shows `사과` | C0+C1 |
| DT5 | TC-FLASHCARD-035 deck has no flashcards | deck `Empty Deck` has zero cards | user opens the deck | `Study this deck` is disabled and the no-cards study helper is visible | C0+C1 |
| DT6 | TC-FLASHCARD-036 flashcard was just created in the deck | user creates `학교` / `trường học` | user starts study from the same deck | study session can show `학교` | C0+C1 |
| DT7 | TC-FLASHCARD-037 one of two flashcards was deleted before study | deck has `사과` and `학교`, then user deletes `사과` | user starts study from that deck | study session shows `학교` and does not show `사과` | C0+C1 |
| DT8 | TC-FLASHCARD-038 flashcard content was edited before study | deck has `사과` / `quả táo`, then user edits front to `빨간 사과` | user starts study from that deck | study session shows `빨간 사과` and not exact old text `사과` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-015 front and back edits are valid | deck has card `사과` / `quả táo` | user edits it to `빨간 사과` / `quả táo đỏ` and saves | list shows `빨간 사과`, exact old front is absent, and edit/detail shows new back | C0+C1 |
| DT2 | TC-FLASHCARD-016 note edit is valid | card `먹다` has note `old note` | user changes Note to `new note` and saves | edit/detail shows `new note` | C0+C1 |
| DT3 | TC-FLASHCARD-017 note is cleared | card `먹다` has note `ghi chú cũ` | user clears Note and saves | edit/detail shows an empty Note field and old note text is absent | C0+C1 |
| DT4 | TC-FLASHCARD-018 edit front is empty | existing card `사과` is open in edit mode | user clears Front and saves | validation message `front and back are required.` is visible and edit stays open | C0+C1 |
| DT5 | TC-FLASHCARD-019 edit back is empty | existing card `사과` is open in edit mode | user clears Back and saves | validation message `front and back are required.` is visible and edit stays open | C0+C1 |
| DT6 | TC-FLASHCARD-020 edit is cancelled | existing card `사과` / `quả táo` is open in edit mode | user changes Front to `수박` and taps Back | list still shows `사과` and not `수박` | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-021 delete confirmation is cancelled | deck has card `사과` | user opens card actions, chooses Delete, and taps Cancel | `사과` remains visible | C0+C1 |
| DT2 | TC-FLASHCARD-022 delete confirmation is accepted | deck has card `사과` and another card | user confirms deletion of `사과` | `사과` disappears and the other card remains visible | C0+C1 |
| DT3 | TC-FLASHCARD-023 the deleted card is the last card in the deck | deck `Daily Words` has only card `사과` | user confirms deletion | deck returns to `No flashcards yet` with `Add` visible | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-024 manual reorder moves the third card to the top | deck has `사과`, `학교`, `먹다` in manual order | user enters Reorder, drags `먹다` to top, and saves | rows show `먹다`, `사과`, `학교` | C0+C1 |
| DT2 | TC-FLASHCARD-025 saved manual order survives leaving and reopening the deck | user has saved order `먹다`, `사과`, `학교` | user goes back to the folder and opens the deck again | rows still show `먹다`, `사과`, `학교` | C0+C1 |
| DT3 | TC-FLASHCARD-026 saved manual order survives app restart | file-backed database stores deck reordered to `먹다`, `사과`, `학교` | user restarts the app and reopens the deck | rows still show `먹다`, `사과`, `학교` | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-027 search term matches front text | deck has `사과`, `학교`, and `먹다` | user searches for `사과` | only `사과` remains visible | C0+C1 |
| DT2 | TC-FLASHCARD-028 search term matches back text | deck has card `사과` / `quả táo` | user searches for `táo` | `사과` remains visible | C0+C1 |
| DT3 | TC-FLASHCARD-029 search term matches no card | deck has card `사과` | user searches for `xyz-not-found` | empty search rendering is visible and `사과` is absent while filtered | C0+C1 |
| DT4 | TC-FLASHCARD-030 search is cleared | deck is filtered by `사과` | user clears search | all deck flashcards are visible again in deck order | C0+C1 |

## Decision table: onExternalChange

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-FLASHCARD-031 created flashcard persists in a file-backed database | user creates `사과` / `quả táo` in `Daily Words` | app restarts and user reopens the deck | `사과` is still visible | C0+C1 |
| DT2 | TC-FLASHCARD-032 edited flashcard persists in a file-backed database | user edits `사과` to `빨간 사과` | app restarts and user reopens the deck | `빨간 사과` is visible | C0+C1 |
| DT3 | TC-FLASHCARD-033 deleted flashcard stays deleted in a file-backed database | user deletes `사과` from `Daily Words` | app restarts and user reopens the deck | `사과` is still absent | C0+C1 |

# Decision Tables: shared_primitives_test

Test file: `test/presentation/shared/shared_primitives_test.dart`

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | action sheet item with value `delete` is tapped | bottom sheet contains Edit and Delete actions and `selectedAction` starts null | user opens sheet and taps `Delete` | bottom sheet closes and selected value becomes `delete` | C0+C1 |
| DT2 | adaptive segmented control is too narrow for segmented buttons | segmented control width is 180 with three options and selected value `{1}` | user taps `Three` in fallback list | `SegmentedButton` is absent, three `RadioListTile<int>` controls are visible, and selected value becomes `{3}` | C0+C1 |
| DT3 | search-sort toolbar has a selected sort option with icon | toolbar selected sort is `recent` and option icon is schedule | toolbar renders selected chip | `FilterChip.selected` is true, checkmark is hidden, and avatar is an icon | C0+C1 |
| DT4 | bulk action bar has label, subtitle, secondary action, and primary action | action bar label is `3 selected` and actions mutate `moveTapped` and `archiveTapped` | user taps `Move` and `Archive` | label and subtitle are visible, and both callbacks are called | C0+C1 |
| DT5 | term row is selected and has a tap callback | row has term `Hello`, definition `Xin chao`, caption `2 examples`, and selected state true | user taps the term text | row text and selected icon are visible, and tap callback is called | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | destination picker search narrows options and selected option should be returned | destinations are Algebra and Biology | user opens picker, enters `alg`, and taps `Algebra` | `Algebra` remains visible, `Biology` is hidden, and selected destination becomes `folder-a` | C0+C1 |
| DT2 | search-sort toolbar receives search input and sort menu selection | toolbar has search callback and sort options A-Z and Recently updated | user enters `kanji`, opens Sort, and selects `Recently updated` | search callback receives `kanji`, no legacy popup menu exists, and sort callback receives `recent` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | answer option card has long selected text and another disabled option | first option is selected with long label, second option is disabled | user taps the selected option and then the disabled option | long text wraps visibly, selected check icon appears, enabled tap count increments once, and disabled tap count remains zero | C0+C1 |

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard face contains content too long for fixed card height | `MxFlashcard` is built at width 240 with long content and aspect ratio 0.7 | flashcard renders | `Scrollbar`, `SingleChildScrollView`, and full long content are present | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | reorderable list builder receives three keyed items | item list is `One`, `Two`, `Three` and builder assigns `ValueKey` per item | `MxReorderableList.builder` renders | all three item labels are visible | C0+C1 |

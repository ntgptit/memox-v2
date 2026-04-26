# Decision Tables: string_utils_test

Test file: `test/core/utils/string_utils_test.dart`

## Decision table: normalize

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | value has outer whitespace and uppercase characters | input is `  HeLLo  ` | `normalizedForComparison` and `normalizedForSearch` evaluate the value | both methods return `hello`, preserving the app-wide trim plus lowercase contract | C0+C1 |
| DT2 | optional value is null or blank | optional input is `null`, spaces, or an empty string | `isBlank`, `isNotBlank`, and `trimToNull` evaluate each value | blank checks return true for null/spaces/empty, not-blank returns false, and trim-to-null returns null | C0+C1 |
| DT3 | optional value contains nonblank text with outer whitespace | optional input is `  MemoX  ` | `isNotBlank`, `trim`, `trimToEmpty`, and `trimToNull` evaluate the value | not-blank returns true, nullable trim returns `MemoX`, trim-to-empty returns `MemoX`, and trim-to-null returns `MemoX` | C0+C1 |
| DT4 | text contains repeated whitespace inside the value | input is `  MemoX   study\tflow  ` | `normalizedWhitespace` and `normalizeSpace` evaluate the value | repeated whitespace collapses to single spaces and outer whitespace is removed | C0+C1 |
| DT5 | value needs app-wide uppercase formatting | input is `mx` | `uppercased`, `upperCase`, and `upperCaseToEmpty` evaluate the value | all uppercase helpers return `MX` without callers using `toUpperCase()` directly | C0+C1 |
| DT6 | nullable transform receives null | input is `null` | nullable and to-empty transform helpers evaluate the value | nullable helpers return null and to-empty helpers return an empty string, matching Commons-style null handling | C0+C1 |

## Decision table: match

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | normalized values are equal despite casing and outer whitespace | left is ` Front ` and right is `front` | `equalsNormalized` compares both values | comparison returns true | C0+C1 |
| DT2 | normalized source contains normalized query | source is `MemoX Flashcard Library` and query is ` flashcard ` | `containsNormalized` evaluates the pair | result is true | C0+C1 |
| DT3 | normalized source does not contain normalized query | source is `MemoX Flashcard Library` and query is `progress` | `containsNormalized` evaluates the pair | result is false | C0+C1 |
| DT4 | query is blank | source is `MemoX Flashcard Library` and query is spaces | `containsNormalized` evaluates the pair | result is true so empty search terms do not filter out rows | C0+C1 |
| DT5 | source is null | source is `null` and query is `memo` | `containsNormalized` evaluates the pair | result is false because null source is not searchable text | C0+C1 |
| DT6 | both compared values are null | left is `null` and right is `null` | `equalsNormalized` compares both values | comparison returns true without throwing | C0+C1 |
| DT7 | one compared value is null | left is `null` and right is an empty string | `equalsNormalized` compares both values | comparison returns false so null does not collapse into blank text for equality | C0+C1 |

## Decision table: sort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | left normalized value sorts before right normalized value | left is ` alpha ` and right is `Beta` | `compareNormalized` compares both values | result is less than zero | C0+C1 |
| DT2 | normalized values are equal despite casing | left is `Deck` and right is `deck` | `compareNormalized` compares both values | result is zero | C0+C1 |
| DT3 | both sort values are null | left is `null` and right is `null` | `compareNormalized` compares both values | result is zero | C0+C1 |
| DT4 | left sort value is null | left is `null` and right is `alpha` | `compareNormalized` compares both values | result is less than zero so null sorts first | C0+C1 |
| DT5 | right sort value is null | left is `alpha` and right is `null` | `compareNormalized` compares both values | result is greater than zero so non-null text sorts after null | C0+C1 |

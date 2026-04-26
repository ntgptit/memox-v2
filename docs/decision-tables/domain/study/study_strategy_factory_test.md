# Decision Tables: study_strategy_factory_test

Test file: `test/domain/study/study_strategy_factory_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | strategy factory receives each supported study type | strategy registry contains implementations for the supported study types | factory selects a strategy for each type | returned strategy matches the requested study type | C0+C1 |
| DT2 | strategy entry support is queried for v1 entry points | new-study and SRS-review strategies are registered | supported entry points are inspected | New Study supports deck/folder only, while SRS Review also supports today | C0+C1 |
| DT3 | mode strategy factory receives each supported study mode | mode strategy registry contains Review, Match, Guess, Recall, and Fill implementations | factory selects a strategy for each mode | returned mode strategy matches the requested mode and exposes mode-specific hooks such as Match batch size and feedback delays | C0+C1 |

## Decision table: selectStrategy

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | registry contains duplicate strategies for the same study type | two strategy instances advertise the same study type | factory is constructed or selection map is built | duplicate registration throws instead of silently overriding a strategy | C0+C1 |
| DT2 | no strategy is registered for a requested study type | registry omits SRS Review | factory is constructed | construction throws a missing strategy error before any selection happens | C0+C1 |
| DT3 | registry contains duplicate strategies for the same study mode | two mode strategy instances advertise Review | mode strategy factory is constructed | duplicate registration throws instead of silently overriding a strategy | C0+C1 |
| DT4 | no strategy is registered for a supported study mode | registry omits Fill | mode strategy factory is constructed | construction throws a missing strategy error before any mode selection happens | C0+C1 |

## Decision table: normalizeUiResult

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | mode strategy normalizes UI-only results | Review receives viewed/correct/incorrect/remembered/forgot/timeout/help; Match, Guess, Recall, and Fill receive the same UI result set | each strategy normalizes the UI result | persisted grade is always `correct` or `incorrect`; Review maps every viewed-card outcome to `correct`; other modes map success-like results to `correct` and failure/help/timeout results to `incorrect` | C0+C1 |
| DT2 | mode strategy builds a full-round submission plan | Match pending set has two items and submitted grades include both ids | submission plan is built | plan keeps both `correct` and `incorrect` grades, retries only `incorrect`, and rejects a partial item id set | C0+C1 |

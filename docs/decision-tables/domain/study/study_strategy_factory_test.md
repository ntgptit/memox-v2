# Decision Tables: study_strategy_factory_test

Test file: `test/domain/study/study_strategy_factory_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | strategy factory receives each supported study type | strategy registry contains implementations for the supported study types | factory selects a strategy for each type | returned strategy matches the requested study type | C0+C1 |
| DT2 | strategy entry support is queried for v1 entry points | new-study and SRS-review strategies are registered | supported entry points are inspected | New Study supports deck/folder only, while SRS Review also supports today | C0+C1 |

## Decision table: selectStrategy

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | registry contains duplicate strategies for the same study type | two strategy instances advertise the same study type | factory is constructed or selection map is built | duplicate registration throws instead of silently overriding a strategy | C0+C1 |
| DT2 | no strategy is registered for a requested study type | factory is constructed without an SRS Review strategy | factory selects SRS Review | selection throws a missing strategy error | C0+C1 |

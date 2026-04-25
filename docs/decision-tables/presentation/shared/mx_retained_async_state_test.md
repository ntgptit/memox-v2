# Decision Tables: mx_retained_async_state_test

Test file: `test/presentation/shared/mx_retained_async_state_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | first load has no retained data and no skeleton builder | `MxRetainedAsyncState` is built with `isLoading=true`, no data, and only a data builder | widget renders first-load state | `MxLoadingState` is visible and loaded value is absent | C0+C1 |
| DT2 | first load has no retained data but a skeleton builder is provided | `MxRetainedAsyncState` is built with `isLoading=true` and skeleton text `Skeleton` | widget renders first-load state | `Skeleton` is visible and `MxLoadingState` is absent | C0+C1 |
| DT3 | first load fails before any retained data exists | `MxRetainedAsyncState` is built with `error=StateError('boom')` and no data | widget renders first-load failure | `MxErrorState` is visible and `MxLoadingState` is absent | C0+C1 |

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | retained data exists and provider starts a refresh future | initial query has value `Loaded value`, then controller swaps to a pending future | widget pumps the refresh frame | retained text stays visible and `mx_retained_async_refresh_bar` appears | C0+C1 |
| DT2 | retained data exists and refresh future completes with error | initial query has value `Loaded value`, then refresh future throws `StateError('refresh failed')` | widget pumps after the failed refresh | retained text stays visible, `MxErrorState` is absent, snackbar appears, and message is `Something went wrong.` | C0+C1 |

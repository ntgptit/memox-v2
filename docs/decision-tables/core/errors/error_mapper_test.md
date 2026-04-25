# Decision Tables: error_mapper_test

Test file: `test/core/errors/error_mapper_test.dart`

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | mapper receives a timeout exception and should classify it as retryable network failure | a timeout exception is passed to `ErrorMapper.map` | mapper converts the error | returned failure is network-related and retryable | C0+C1 |

## Decision table: mapError

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | mapper receives a configuration exception with metadata | configuration exception contains a code or invalid value payload | mapper converts the error | returned failure preserves configuration metadata | C0+C1 |

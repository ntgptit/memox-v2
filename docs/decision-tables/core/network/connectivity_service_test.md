# Decision Tables: connectivity_service_test

Test file: `test/core/network/connectivity_service_test.dart`

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | manual refresh probes connectivity and applies the returned status immediately | fake connectivity probe is configured with a known online or offline status | service `refresh` is called | current service status equals the probed status | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | watcher emits initial status and debounces subsequent status changes | connectivity service starts with an initial status and receives a later status update | consumer listens to `watch` | stream emits the current status followed by the debounced update | C0+C1 |

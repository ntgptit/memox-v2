# Decision Tables: route_guards_test

Test file: `test/app/router/route_guards_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | requested path is `/`, so route guard redirects to configured initial location | route guard receives root path and initial location is configured | `redirectLocationFor` evaluates the path | returned redirect location is the configured initial location | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | requested path is not `/`, so route guard leaves navigation unchanged | route guard receives a non-root path | `redirectLocationFor` evaluates the path | returned redirect location is `null` | C0+C1 |

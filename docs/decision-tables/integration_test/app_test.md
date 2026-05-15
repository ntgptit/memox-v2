# Decision Tables: app_test app shell

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | integration binding boots the real `MemoxApp` with test config, in-memory Drift database, deterministic ids, and no-op TTS | `pumpTestApp` creates the app wrapper for the default library route | the integration test pumps the app and waits for the shell | one `MaterialApp`, one router, and no widget exception are present | C0+C1 |
| DT2 | compact sizing boots the same app shell through the native desktop window instead of fake-shrinking only the Flutter surface | Windows integration test is launched with `MEMOX_E2E_WINDOW_SIZE=412x915`, and the Windows runner creates the native app window at the Samsung Galaxy S20 Ultra logical size before Flutter renders the default library route | the integration test pumps the app and waits for the shell | one `MaterialApp`, one router, and no widget exception are present on the compact native window | C0+C1 |
| DT8 | unknown initial route is routed through the app-level router error surface | `pumpTestApp` starts with `/unknown-route` and exposes internal route details in test config | the router resolves the initial location | `Navigation error` and `Something went wrong.` are rendered without an uncaught widget exception | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT2 | top-level shell destinations are reachable from the compact navigation surface | the app starts on the library route with an empty in-memory database and compact native window | the user navigates Library → Home → Progress → Settings → Library through shell destination labels | each destination renders expected above-the-fold screen content and the library route is restored without widget exceptions | C0+C1 |

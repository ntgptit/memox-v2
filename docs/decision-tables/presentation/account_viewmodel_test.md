# Decision Tables: account_viewmodel_test

Test file: `test/presentation/account_viewmodel_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | OAuth config is missing on a non-Android platform | no linked account exists, Google client IDs are blank, and the platform is Windows | account settings controller builds | state is `unconfigured` and sign-in is disabled | C0+C1 |
| DT2 | stored account is Drive-ready | account store contains Google account metadata with `drive.appdata` scope | account settings controller builds | state is `signedIn` with the stored email | C0+C1 |
| DT3 | web runtime session is missing for stored Drive-ready account | account store contains Google account metadata with `drive.appdata`, auth restore returns `signedOut`, and auth service requires the platform Google button | account settings controller builds | state is `needsDriveAuthorization`, keeps the stored email, marks runtime reconnect required, and does not show `signedIn` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | sign-in succeeds with Drive scope | fake Google auth returns account profile and `drive.appdata` scope | `signIn` is requested | controller state becomes `signedIn` and store persists the scope | C0+C1 |
| DT2 | sign-in is canceled | fake Google auth returns `canceled` | `signIn` is requested | controller stays signed out and store remains empty | C0+C1 |
| DT3 | Drive authorization is denied | fake Google auth returns account profile without Drive scope | `signIn` is requested | controller stores the account and state becomes `needsDriveAuthorization` | C0+C1 |
| DT4 | reconnect succeeds after Drive scope was missing | store has account without Drive scope and fake auth returns authorized scope | `reconnectDrive` is requested | controller state becomes `signedIn` and store contains `drive.appdata` | C0+C1 |
| DT5 | account reconnect must refresh Drive sync status | store has account without Drive scope, Drive Sync controller has already loaded stale reconnect-required status, and fake auth returns authorized scope | `reconnectDrive` is requested and Drive Sync state is read again | Drive Sync repository load count increases because account controller invalidates the sync status provider | C0+C1 |
| DT6 | access token request has no cached token | store has linked account but fake auth returns reauthorization required | Drive access-token use case is requested | result is `reauthorizationRequired` and SharedPreferences does not contain token material | C0+C1 |
| DT7 | Google-rendered web button emits authentication event | account controller is signed out and fake auth emits a Drive-ready event while account persistence is still pending | authentication event is received from `authenticationEvents` | controller enters `isBusy` before persistence completes, then becomes `signedIn` after persistence finishes | C0+C1 |
| DT8 | duplicate Drive-ready authentication event | account controller and Drive Sync controller are already loaded for the same Drive-ready Google account | the same Google account is emitted again from `authenticationEvents` | account remains `signedIn` and Drive Sync status is not invalidated again | C0+C1 |
| DT9 | platform sign-out authentication event | account controller is displaying a linked Google account | `authenticationEvents` emits `signedOut` | account state becomes `signedOut` and the stored account link is cleared | C0+C1 |
| DT10 | Google-rendered web reconnect succeeds after runtime session was missing | account controller starts as `needsDriveAuthorization` from a stored Drive-ready account and Drive Sync status has loaded once | `authenticationEvents` emits the same account with `drive.appdata` | account becomes `signedIn` and Drive Sync status is invalidated for a fresh token-backed load | C0+C1 |
| DT11 | Google-rendered web auth returns runtime account without Drive scope | account controller starts as `needsDriveAuthorization` with runtime reconnect required | `authenticationEvents` emits the same account without `drive.appdata` | account remains `needsDriveAuthorization`, keeps the link, and clears the runtime reconnect flag so a user-initiated Drive authorization action can run | C0+C1 |
| DT12 | retained Web state predates the runtime reconnect field | an older hot-reload retained account state has `requiresRuntimeReconnect` as null | `copyWith` is used while entering busy state | the runtime reconnect getter falls back to false and copy does not throw | C0+C1 |
| DT13 | Google auth service provider rebuilds with a new service instance | account controller has listened to one auth service and the provider dependency changes to another service | stale service emits a Drive-ready event, then the current service emits the same event | stale event is ignored because its subscription was canceled, and only the current service moves account state to `signedIn` | C0+C1 |
| DT14 | sign-in fails before account metadata is available | fake Google auth returns failure with a network diagnostic | `signIn` is requested | state becomes `error`, sign-in failed message and technical diagnostic are retained, and account store remains empty | C0+C1 |
| DT15 | duplicate sign-in taps arrive while the first Google auth flow is still running | account controller has entered busy state after the first `signIn` call | `signIn` is requested again before the first flow completes | Google auth service is called once and the completed result moves state to `signedIn` | C0+C1 |
| DT16 | explicit local sign-out runs from a linked account | account store has a Drive-ready account and unrelated local study settings exist | `signOut` is requested | account link is cleared, state becomes `signedOut`, and local study settings remain unchanged | C0+C1 |

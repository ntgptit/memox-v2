# Decision Tables: account_viewmodel_test

Test file: `test/presentation/account_viewmodel_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | OAuth config is missing | no linked account exists and Google client IDs are blank | account settings controller builds | state is `unconfigured` and sign-in is disabled | C0+C1 |
| DT2 | stored account is Drive-ready | account store contains Google account metadata with `drive.appdata` scope | account settings controller builds | state is `signedIn` with the stored email | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | sign-in succeeds with Drive scope | fake Google auth returns account profile and `drive.appdata` scope | `signIn` is requested | controller state becomes `signedIn` and store persists the scope | C0+C1 |
| DT2 | sign-in is canceled | fake Google auth returns `canceled` | `signIn` is requested | controller stays signed out and store remains empty | C0+C1 |
| DT3 | Drive authorization is denied | fake Google auth returns account profile without Drive scope | `signIn` is requested | controller stores the account and state becomes `needsDriveAuthorization` | C0+C1 |
| DT4 | reconnect succeeds after Drive scope was missing | store has account without Drive scope and fake auth returns authorized scope | `reconnectDrive` is requested | controller state becomes `signedIn` and store contains `drive.appdata` | C0+C1 |
| DT5 | access token request has no cached token | store has linked account but fake auth returns reauthorization required | Drive access-token use case is requested | result is `reauthorizationRequired` and SharedPreferences does not contain token material | C0+C1 |

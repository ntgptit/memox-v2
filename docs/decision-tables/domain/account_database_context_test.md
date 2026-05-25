# Decision Tables: account_database_context_test

Test file: `test/domain/account_database_context_test.dart`

## Decision table: resolve

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no Google account is linked | account link is null | database context is resolved | context is guest-owned and uses `memox_guest` | C0+C1 |
| DT2 | account A is linked | account link has Google subject id `google-user-a` | database context is resolved | context is Google-account-owned and uses `memox_google-user-a` | C0+C1 |
| DT3 | account B is linked after account A existed | account A context and account B context are both resolved from their own subject ids | ownership is checked across both contexts | account B context belongs only to account B and account A context rejects account B | C0+C1 |
| DT4 | account A signs in again after account B | account A context is resolved, account B context is resolved, then account A context is resolved again | database names are compared | account A returns to the same account-scoped DB name and does not reuse account B's DB | C0+C1 |

## Decision table: resolveGuestSignIn

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | user chooses to attach guest data | guest data exists and account A signs in | guest sign-in transition is resolved with `attachGuestData` | transition targets account A DB and marks guest data for attach | C0+C1 |
| DT2 | user chooses a fresh account DB | guest data exists and account A signs in | guest sign-in transition is resolved with `createFreshAccountDatabase` | transition targets account A DB and does not attach guest data | C0+C1 |

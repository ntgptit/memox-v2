# Decision Tables: button_label_contract_test

Test file: `test/presentation/button_label_contract_test.dart`

## Decision table: inspectL10n

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | an ARB key ending in `Action` is added without being classified | English l10n messages include visible button action keys and one non-button error-message exception | the l10n button-label contract scans action keys | every `*Action` key is listed as a visible button label or as a deliberate non-button exception | C0+C1 |
| DT2 | registered visible button labels become too wordy in any supported locale | visible button label registry is checked against English and Vietnamese ARB files | semantic words are counted after placeholders and punctuation are ignored | every registered visible button label stays under the locale word budget | C0+C1 |
| DT3 | visible English action labels repeat context nouns that should live in surrounding UI copy | registered visible button label values come from the English template ARB | label endings are compared against redundant context terms such as `session`, `flashcard`, `deck`, and `progress` | no visible button action label ends with a redundant context noun | C0+C1 |

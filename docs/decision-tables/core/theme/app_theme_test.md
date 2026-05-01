# Decision Tables: app_theme_test

Test file: `test/core/theme/app_theme_test.dart`

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | light theme builder maps Tokyo Pure Light palette to Material color roles | `AppTheme.light` is built | test reads the resulting `ColorScheme` | background, surface, primary, text, and semantic colors match the light Tokyo-adapted tokens | C0+C1 |
| DT2 | dark theme builder maps Tokyo Nebula palette to Material color roles | `AppTheme.dark` is built | test reads the resulting `ColorScheme` | background, surface, primary, text, and semantic colors match the dark Tokyo-adapted tokens | C0+C1 |
| DT3 | light theme typography must use Plus Jakarta Sans across theme surfaces | `AppTheme.light` is built | test reads text theme and component text styles | font family is Plus Jakarta Sans for light text roles and controls | C0+C1 |
| DT4 | dark theme typography must use Plus Jakarta Sans across theme surfaces | `AppTheme.dark` is built | test reads text theme and component text styles | font family is Plus Jakarta Sans for dark text roles and controls | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | component theme builders should use the soft MemoX radius language | app theme is built with shared component themes | test reads semantic radius mappings plus button, card, input, dialog, bottom sheet, FAB, snackbar, menu, and tooltip shapes | component radii match the shared soft shape tokens without introducing new radius tokens | C0+C1 |

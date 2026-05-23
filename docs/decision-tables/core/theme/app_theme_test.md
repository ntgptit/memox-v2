# Decision Tables: app_theme_test

Test file: `test/core/theme/app_theme_test.dart`

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | light theme builder maps the mobile UI kit root Tokyo Pure Light palette to Material color roles | `AppTheme.light` is built | test reads the resulting `ColorScheme`, card theme, and `MxColorsExtension.light` semantic colors | page, dim surface, surface ladder, primary/on-primary, text, cool-indigo outlines, card paper, success, mastery, streak, and rating colors match the mobile UI kit light tokens | C0+C1 |
| DT2 | dark theme builder maps the mobile UI kit `.memox-dark` Tokyo Nebula palette to Material color roles | `AppTheme.dark` is built | test reads the resulting `ColorScheme`, card theme, and `MxColorsExtension.dark` semantic colors | page, dim surface, paper-card surface, primary/on-primary, text, faded-indigo outlines, mastery, and streak match the mobile UI kit dark tokens | C0+C1 |
| DT5 | light theme foreground/background roles must meet normal-text WCAG AA contrast | `AppTheme.light` is built with its `ColorScheme` and `MxColorsExtension.light` semantic colors | test computes contrast ratios for `onPrimary`, `onSurface`, `onSurfaceVariant`, `onError`, `onSuccess`, `onWarning`, and `onInfo` against their paired backgrounds | each measured foreground/background pair is at least `4.5:1` | C0+C1 |
| DT6 | dark theme foreground/background roles must meet normal-text WCAG AA contrast | `AppTheme.dark` is built with its `ColorScheme` and `MxColorsExtension.dark` semantic colors | test computes contrast ratios for `onPrimary`, `onSurface`, `onSurfaceVariant`, `onError`, `onSuccess`, `onWarning`, and `onInfo` against their paired backgrounds | each measured foreground/background pair is at least `4.5:1` | C0+C1 |
| DT3 | light theme typography must use Plus Jakarta Sans across theme surfaces | `AppTheme.light` is built | test reads text theme and component text styles | font family is Plus Jakarta Sans for light text roles and controls | C0+C1 |
| DT4 | dark theme typography must use Plus Jakarta Sans across theme surfaces | `AppTheme.dark` is built | test reads text theme and component text styles | font family is Plus Jakarta Sans for dark text roles and controls | C0+C1 |
| DT7 | Material 3 text scale must remain fixed and centralized | `AppTypography.textTheme` is read | test compares every role from `displayLarge` through `labelSmall` with its matching `AppTypography` token | each role keeps the expected font family, font size, font weight, line height, and letter spacing | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | component theme builders should use the soft MemoX radius language | app theme is built with shared component themes | test reads semantic radius mappings plus button, card, input, dialog, bottom sheet, FAB, snackbar, menu, and tooltip shapes | component radii match the shared soft shape tokens without introducing new radius tokens | C0+C1 |
| DT2 | button variants should expose M3 border, shape, and overlay contracts | app theme is built with filled, tonal, outlined, and text button themes | test resolves each button `ButtonStyle` for default, hovered, focused, and pressed states | filled, tonal, and text buttons have no side border; outlined has an outline side; all variants use `AppRadius.button` and non-null state overlays | C0+C1 |
| DT3 | input theme should separate relaxed labels from focused border emphasis | app theme is built with shared input decoration theme | test reads label styles, content padding, and outline borders | label and floating label stay regular weight, padding uses spacing tokens, enabled border is subtle, focused border is primary and thicker, and radius is `AppRadius.input` | C0+C1 |
| DT4 | app chrome themes should avoid hard-coded heights while preserving M3 tokens | app theme is built with card, app bar, navigation bar, and dialog themes | test reads surface tint, app bar spacing/height, navigation label behavior/height, and dialog inset padding | card tint uses `surfaceTint`, app bar/nav heights are unset, labels always show, and dialog inset padding uses spacing tokens | C0+C1 |

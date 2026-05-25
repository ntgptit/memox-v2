# Decision Tables: app_layout_test

Test file: `test/core/theme/app_layout_test.dart`

## Decision table: pagePadding

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | compact mobile density requests top-level page padding | compact window size with compact-mobile density enabled | `AppLayout.pagePadding` resolves the gutter | horizontal page gutter stays at the standard 16 dp edge inset | C0+C1 |
| DT2 | compact window without compact-mobile density requests top-level page padding | compact window size with compact-mobile density disabled | `AppLayout.pagePadding` resolves the gutter | horizontal page gutter stays at the standard 16 dp edge inset | C0+C1 |
| DT3 | medium window requests top-level page padding | medium window size | `AppLayout.pagePadding` resolves the gutter | horizontal page gutter uses the medium 20 dp edge inset | C0+C1 |
| DT4 | expanded-or-larger window requests top-level page padding | expanded window size | `AppLayout.pagePadding` resolves the gutter | horizontal page gutter uses the wide 24 dp edge inset | C0+C1 |

# Decision Tables: mx_text_test

Test file: `test/presentation/shared/mx_text_test.dart`

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxTextRole.pageTitle` should resolve from active theme title style | material theme provides `textTheme.titleLarge` and `colorScheme.onSurface` | `MxText('Library', role: pageTitle)` renders | rendered `Text.style` font size, weight, and color match the expected theme-derived style | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | explicit color override should win over semantic role color | `MxText` is built with breadcrumb role and `Colors.deepOrange` override | text renders | rendered `Text.style.color` equals the override color | C0+C1 |
| DT2 | `MxSection` should render title and subtitle through semantic `MxText` roles | section has title `Folders` and subtitle `Manage your folder tree` | section renders | title uses `MxTextRole.sectionTitle` and subtitle uses `MxTextRole.sectionSubtitle` | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxStudySetTile` should render title and meta through semantic `MxText` roles | tile has title `Vitamin B1` and meta `1 cards · 0 due today` | tile renders | title uses `MxTextRole.tileTitle` and meta uses `MxTextRole.tileMeta` | C0+C1 |

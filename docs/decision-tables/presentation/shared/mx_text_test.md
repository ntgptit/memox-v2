# Decision Tables: mx_text_test

Test file: `test/presentation/shared/mx_text_test.dart`

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxTextRole.pageTitle` should resolve from active theme title style | material theme provides `textTheme.titleLarge` and `colorScheme.onSurface` | `MxText('Library', role: pageTitle)` renders | rendered `Text.style` font size, weight, and color match the expected theme-derived style | C0+C1 |
| DT2 | `MxTextRole.guessPrompt` should resolve smaller than display typography | material theme provides `textTheme.headlineMedium`, `textTheme.displayMedium`, and `colorScheme.onSurface` | `MxText('상식', role: guessPrompt)` renders | rendered `Text.style` uses headline-medium sizing, medium weight, and stays below display-medium sizing | C0+C1 |
| DT3 | Recall front and back roles should keep fixed hierarchy | material theme provides `headlineMedium`, `bodyLarge`, and `colorScheme.onSurface` | `MxText` renders Recall front and back roles together | front text is larger with medium weight, back text is regular weight, and both use `onSurface` | C0+C1 |
| DT4 | Fill input/result roles should keep semantic hierarchy and colors | material theme provides `headlineMedium`, `titleLarge`, `bodyLarge`, `colorScheme.error`, and `colorScheme.onSurface` | `MxText` renders Fill prompt, input, incorrect input, and correct answer roles together | prompt uses body text, input is larger than prompt, incorrect input uses error color, and correct answer uses on-surface color | C0+C1 |
| DT5 | Sheet and action-sheet roles should stay below page-title typography | material theme provides `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `colorScheme.onSurface`, and `colorScheme.onSurfaceVariant` | `MxText` renders sheet title, action item, and action subtitle roles together | sheet title resolves from `titleMedium` below page-title sizing, action item resolves from body-large, and action subtitle resolves from body-medium variant color | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | explicit color override should win over semantic role color | `MxText` is built with breadcrumb role and `Colors.deepOrange` override | text renders | rendered `Text.style.color` equals the override color | C0+C1 |
| DT2 | `MxSection` should render title and subtitle through semantic `MxText` roles | section has title `Folders` and subtitle `Manage your folder tree` | section renders | title uses `MxTextRole.sectionTitle` and subtitle uses `MxTextRole.sectionSubtitle` | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxStudySetTile` should render title and meta through semantic `MxText` roles | tile has title `Vitamin B1` and meta `1 cards · 0 due today` | tile renders | title uses `MxTextRole.tileTitle` and meta uses `MxTextRole.tileMeta` | C0+C1 |

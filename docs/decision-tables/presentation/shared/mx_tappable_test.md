# Decision Tables: mx_tappable_test

Test file: `test/presentation/shared/mx_tappable_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxTappable` receives a `StadiumBorder` shape | widget is built with a stadium shape and tap callback | `MxTappable` is pumped into the test app | nested `Material.shape` and `InkWell.customBorder` are both `StadiumBorder`, with anti-alias clipping | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxFolderTile` should route row tap through `MxTappable` | folder tile has name `Japanese` and tap callback mutates `tapped` | user taps `Japanese` | one `MxTappable` is present and `tapped` becomes true | C0+C1 |
| DT2 | `MxStudySetTile` content layout should keep large icon-content gap | study set tile has title `Vitamin B1` and meta text | tile renders | descendant `MxGap` with `AppSpacing.lg` exists | C0+C1 |
| DT3 | `MxPageDots` has a tap callback and should make each dot a shaped tap target | page dots have count 3, active index 1, and callback storing tapped index | user taps the third `MxTappable` | three tap targets exist, first target meets minimum interactive size, and tapped index becomes 2 | C0+C1 |

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxAvatar` has initials and a badge label | avatar is built with initials `MX` and badge `Plus` | avatar renders | descendant `MxGap` with `AppSpacing.sm` separates avatar and badge | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxPageDots` has no tap callback and active dot should be selected but not a button | page dots have count 3 and active index 1 | semantics tree is inspected | selected dot semantic node is selected and not marked as button | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxPageDots` has a tap callback and active dot should remain selected while becoming a button | page dots have count 3, active index 1, and `onDotTap` callback | semantics tree is inspected | selected dot semantic node is selected and marked as button | C0+C1 |

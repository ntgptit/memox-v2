# Decision Tables: shared_widget_contract_test

Test file: `test/presentation/shared/shared_widget_contract_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | every cataloged shared widget is built with only required data | minimal builders cover each public shared widget surface that extends `StatelessWidget` or `StatefulWidget` | each widget is pumped inside the MemoX `MaterialApp` with `AppTheme.light()` and generated localizations | no Flutter exception is thrown and the widget's constructor key is findable | C0+C1 |
| DT2 | every cataloged shared widget is built with optional data enabled | full builders provide optional labels, icons, callbacks, selections, actions, or populated lists for each cataloged widget | each widget is pumped inside the MemoX `MaterialApp` with `AppTheme.light()` and generated localizations | no Flutter exception is thrown and the widget's constructor key is findable | C0+C1 |
| DT3 | shared widgets render under supported theme and viewport variants | cataloged widgets have their full-data builders, MemoX light theme, MemoX dark theme, large text scale, and compact phone surface | each widget is pumped once per variant | no Flutter exception is thrown for light, dark, large text, or compact viewport rendering | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | shared widget rebuild receives equivalent inputs | each cataloged widget uses the same full-data builder, key, theme, and surface size for two consecutive pumps | the widget is pumped, measured, pumped again, and measured again | the keyed subject remains present and its rendered size is unchanged between rebuilds | C0+C1 |

## Decision table: onLayout

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | shared widget padding, margin, or gap declarations bypass spacing tokens | scanner reads every widget-bearing shared Dart file | stripped source is matched for numeric `EdgeInsets` and numeric `MxGap` or `MxSliverGap` arguments | no raw spacing declaration is found unless it uses `AppSpacing`, `MxSpace`, or zero spacing | C0+C1 |
| DT2 | important interactive shared controls must expose a Material-sized tap target | touch-target catalog includes custom tappables, buttons, navigation dots, tiles, FABs, and study actions | each control is pumped in the MemoX theme wrapper and measured by its key | every measured control is at least `kMinInteractiveDimension` wide and tall | C0+C1 |
| DT3 | long shared-widget content is rendered on compact width | long labels, messages, terms, titles, captions, and flashcard content are pumped at compact width with increased text scale | each long-content case renders inside the MemoX theme wrapper | no overflow or Flutter exception is thrown, answer text wraps, and flashcard content remains scrollable | C0+C1 |
| DT4 | shared widget layout uses unreviewed fixed dimensions or arbitrary viewport scaling | scanner reads every widget-bearing shared Dart file with comments preserved for reviewed raw sizes | source is matched for raw width/height constraints without `guard:raw-size-reviewed` and for viewport-width proportional scaling | no unreviewed raw fixed dimension or arbitrary scaling shortcut is found | C0+C1 |
| DT5 | shared layout shells must keep explicit alignment and bounded constraints | `MxContentShell` is rendered with a reading-width role inside the MemoX theme wrapper | descendant layout primitives are inspected | content is aligned to the top center and constrained by a finite positive max width | C0+C1 |

## Decision table: onVisualStyle

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | shared widget visual declarations bypass design tokens or active theme | scanner reads every widget-bearing shared Dart file | stripped source is matched for raw colors, typography construction, radius factories, elevation literals, shadow construction, numeric icon sizes, and numeric divider or border thickness | no visual style primitive is found outside theme or token usage | C0+C1 |
| DT2 | representative surfaces, text, icons, dividers, tiles, options, and skeletons resolve from MemoX theme or tokens | `MxCard`, `MxText`, `MxIconButton`, `MxDivider`, `MxAnswerOptionCard`, `MxStudySetTile`, and `MxSkeleton` render inside the MemoX `MaterialApp` wrapper | descendant Material, decoration, and text widgets are inspected after layout | background, border color, soft radius, elevation, typography, icon size, divider style, tile icon radius, and skeleton radius match the active theme or token contract | C0+C1 |
| DT3 | disabled and error visual states use themed state colors | disabled destructive `MxPrimaryButton` and error-role `MxText` render inside the MemoX theme wrapper | button state properties and rendered text style are resolved | disabled foreground/background use `ColorScheme.onSurface` with `AppOpacity` tokens and error text uses `ColorScheme.error` | C0+C1 |
| DT4 | focus, pressed, and hover overlays use shared focus theme | interactive `MxTappable` renders with the default overlay base color | the descendant `InkWell` overlay is resolved for hovered, focused, and pressed widget states | every state layer matches `AppFocus.overlay` against the active `ColorScheme.onSurface` | C0+C1 |

## Decision table: onInteraction

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | enabled shared action controls receive a pointer tap | tap-callback catalog includes buttons, icon button, FAB, tappable surfaces, card, chip, tiles, page dots, study action, term row, and toggle | each keyed control is tapped once inside the MemoX theme wrapper | the supplied callback is invoked exactly once and no Flutter exception is thrown | C0+C1 |
| DT2 | disabled shared controls receive a pointer tap | disabled catalog includes buttons, icon button, FAB, disabled tappable, disabled answer card, and disabled select field | each keyed control is tapped once | the supplied callback is not invoked and no Flutter exception is thrown | C0+C1 |
| DT3 | loading shared buttons receive a pointer tap | loading catalog includes primary and secondary buttons with `isLoading: true` and non-null callbacks | each keyed loading button is tapped once | the supplied callback is not invoked while loading | C0+C1 |
| DT4 | pressed state is active on shared surfaces | pressed-layout catalog includes primary button, answer card, tappable, and interactive card | each keyed control is measured, held down, measured during press, released, and measured again | size remains unchanged before, during, and after the pressed state | C0+C1 |
| DT5 | text field and button focus states are requested | `MxTextField` receives a `FocusNode` and `MxPrimaryButton` renders after it | the text field is tapped, then the button's focus node is requested and Enter is sent | the text field gains focus, the button gains focus, and the focused button activates once from keyboard input | C0+C1 |
| DT6 | shared input widgets receive keyboard text and submit actions | `MxTextField` and `MxSearchField` render with controllers, change callbacks, submit callbacks, and search clear callback | text is entered, the matching text-input action is received, and the search clear icon is tapped | controllers, change callbacks, submit callbacks, and clear callback reflect the entered or cleared value | C0+C1 |
| DT7 | child shared gesture is nested under a parent gesture detector | parent gesture surface wraps a centered `MxAnswerOptionCard` child with a separate callback | the child is tapped, then the parent area outside the child is tapped | child tap invokes only the child callback and parent-only area invokes only the parent callback | C0+C1 |
| DT8 | interactive shared hit areas must expose a Material-sized hit target | hit-area catalog includes tappable, icon button, FAB, large buttons, tiles, study action inner tappable, page-dot inner tappable, and toggle | each target finder is measured after rendering inside the MemoX theme wrapper | every measured interactive hit area is at least `kMinInteractiveDimension` wide and tall | C0+C1 |

## Decision table: onButton

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | labeled shared buttons receive labels, optional icons, and icon-label gaps | `MxPrimaryButton` and `MxSecondaryButton` render with leading icons, trailing icons, and labels | each button is pumped inside the MemoX theme wrapper | labels and icons are visible, icon sizes use `AppIconSizes.md`, and each icon-label gap uses `AppSpacing.sm` | C0+C1 |
| DT2 | enabled shared buttons receive a pointer tap | enabled primary, secondary, and icon-only buttons receive non-null callbacks | each keyed button is tapped once | each supplied callback is invoked exactly once | C0+C1 |
| DT3 | disabled or loading shared buttons receive a pointer tap | disabled primary, secondary, and icon-only buttons have null callbacks, while loading primary and secondary buttons have non-null callbacks but `isLoading: true` | each disabled and loading keyed button is tapped once | disabled Material button callbacks resolve to null and loading callbacks are not invoked | C0+C1 |
| DT4 | shared button geometry and typography resolve from tokens | primary, secondary outlined, secondary tonal, secondary text, and icon-only buttons render inside the MemoX theme wrapper | button styles and rendered sizes are inspected | min height is at least `kMinInteractiveDimension`, padding uses spacing tokens, radius uses `AppRadius.button`, text style uses `AppTypography.labelLarge`, and icon-only size is at least `kMinInteractiveDimension` | C0+C1 |
| DT5 | shared button loading state replaces content with a spinner | normal and loading primary and secondary buttons render with the same width constraints | rendered heights and loading descendants are inspected | loading indicators are present and loading buttons keep the same height as their normal counterpart | C0+C1 |
| DT6 | shared button labels are longer than compact width | primary and secondary buttons render long labels inside a narrow width | each button is pumped inside the MemoX theme wrapper | no overflow is thrown and each label text uses one-line ellipsis | C0+C1 |
| DT7 | icon-only shared buttons rely on tooltip semantics | `MxIconButton` renders with an icon, tooltip label, and callback | semantics are enabled and the widget renders inside the MemoX theme wrapper | the icon is visible, the hit area is Material-sized, and screen-reader semantics expose the tooltip label | C0+C1 |
| DT8 | normal shared button composition has a visual baseline | deterministic normal samples build enabled primary, secondary, text, tonal, and icon-only buttons | the widget is pumped in the golden harness and compared to `goldens/shared_button_normal.png` | the rendered pixels match the committed normal button golden | C0+C1 |
| DT9 | disabled and loading shared button composition has a visual baseline | deterministic state samples build disabled primary, secondary, icon-only buttons and loading primary and secondary buttons | the widget is pumped in the golden harness and compared to `goldens/shared_button_states.png` | the rendered pixels match the committed loading/disabled button golden | C0+C1 |

## Decision table: onCard

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | shared card renders its child with default padding | `MxCard` receives a keyed child and default padding | the card is pumped inside the MemoX theme wrapper | the child is visible and the internal padding equals `AppSpacing.card` | C0+C1 |
| DT2 | shared card variants resolve visual tokens from theme | filled, elevated, and outlined `MxCard` variants render in the active MemoX theme | each descendant Material `Card` is inspected | background uses `ColorScheme.surfaceContainerLow`, radius uses `AppRadius.card`, elevation uses `AppElevation.card` or `AppElevation.cardRaised`, and outlined border uses `ColorScheme.outlineVariant` | C0+C1 |
| DT3 | shared card clickable state is determined by tap handlers | one `MxCard` has no tap handler and another has `onTap` | both cards are pumped and tapped | the static card has no `MxTappable`, the clickable card has one `MxTappable`/`InkWell`, and only the clickable card invokes its callback once | C0+C1 |
| DT4 | shared card receives long dynamic content on compact width | a long text child renders inside `MxCard` with compact parent width | the card is pumped at phone width `320` | no Flutter exception or overflow is thrown and the long text remains visible inside the card | C0+C1 |
| DT5 | shared card follows parent width instead of imposing its own width | the same `MxCard` content is wrapped by parent widths `160` and `280` | each card is pumped and measured | the rendered Material card width matches the current parent width in both cases | C0+C1 |
| DT6 | shared card golden covers supported visual card states | deterministic card sample data builds filled, outlined-clickable, and elevated variants; `MxCard` exposes no selected API | the card composition is pumped in the golden harness and compared to `goldens/shared_card_variants.png` | rendered pixels match the committed card golden for normal and clickable variants | C0+C1 |

## Decision table: onTextField

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | shared text field receives label, hint, prefix icon, and suffix icon | `MxTextField` renders with label, hint, `prefixIcon`, and `suffixIcon` | the field is pumped inside the MemoX theme wrapper | label, hint, prefix icon, and suffix icon are present in the resolved `InputDecoration` and widget tree | C0+C1 |
| DT2 | shared text field receives text input and submit action | `MxTextField` renders with a controller, `onChanged`, `onSubmitted`, and `TextInputAction.done` | text is entered and the done action is received | controller text, change callback, and submit callback all receive the entered value | C0+C1 |
| DT3 | shared text field error and border states resolve from theme | `MxTextField` renders with `errorText` inside the MemoX theme wrapper | the field decoration and active `InputDecorationTheme` are inspected | error text is visible, focus border uses `ColorScheme.primary`, error borders use `ColorScheme.error`, and all outline radii use `AppRadius.input` | C0+C1 |
| DT4 | shared text field disabled and read-only states are configured | disabled and read-only `MxTextField` instances render with focus nodes | each field is tapped and descendant `TextField` configuration is inspected | disabled field stays unfocused and has `enabled: false`, while read-only field can focus and has `readOnly: true` | C0+C1 |
| DT5 | shared search field clear affordance is available after text input | `MxSearchField` renders with a controller, `onChanged`, and `onClear` | text is entered and the clear icon is tapped | clear icon appears, controller text is cleared, `onChanged` receives an empty value, and `onClear` is called once | C0+C1 |
| DT6 | password and keyboard configuration is passed through | `MxTextField` renders with `obscureText`, `TextInputType.emailAddress`, and `TextInputAction.next` | descendant `TextField` configuration is inspected | password text is obscured, max lines are forced to one, keyboard type is email address, and text input action is next | C0+C1 |
| DT7 | shared text field height and content padding use Material/token contract | `MxTextField` renders inside the MemoX theme wrapper | rendered size and `InputDecorationTheme.contentPadding` are inspected | field height is at least `kMinInteractiveDimension` and content padding uses `AppSpacing.lg`/`AppSpacing.md` tokens | C0+C1 |
| DT8 | shared text field receives long text on compact width | `MxTextField` renders with long controller text in a compact parent width | the field is pumped at phone width `320` | no Flutter exception or overflow is thrown and the keyed field remains visible | C0+C1 |
| DT9 | shared search field must not bypass the input radius contract | `MxSearchField` renders inside the MemoX theme wrapper | descendant `TextField` decoration borders are inspected | normal, enabled, and focused outlines all use `AppRadius.input` instead of pill-only radius | C0+C1 |

## Decision table: onDialog

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | shared dialog opens in the MemoX app wrapper | a host button calls `MxDialog.show` with title, content, primary action, and secondary action | the dialog is opened, the primary action is tapped, then the dialog is reopened and the secondary action is tapped | title and content render, the primary callback runs once, the secondary callback runs once, and each action closes the dialog | C0+C1 |
| DT2 | shared dialog barrier dismiss behavior is configured | one `MxDialog.show` call uses `barrierDismissible: false` and another uses `barrierDismissible: true` | each dialog is opened and the modal barrier is tapped | the locked dialog remains open until its close action is tapped, while the dismissible dialog closes from the barrier tap | C0+C1 |
| DT3 | shared bottom sheet opens in the MemoX app wrapper | a host button calls `MxBottomSheet.show` with title, content, trailing close button, primary action, and secondary action | the sheet is opened for primary, secondary, and close flows | title and content render, primary callback runs once, secondary callback runs once, trailing close callback runs once, and each closes the sheet | C0+C1 |
| DT4 | shared bottom sheet barrier dismiss behavior is configured | one `MxBottomSheet.show` call uses `isDismissible: false` and another uses `isDismissible: true` | each sheet is opened and the modal barrier is tapped | the locked sheet remains open until closed explicitly, while the dismissible sheet closes from the barrier tap | C0+C1 |
| DT5 | shared dialog and bottom sheet use theme/token geometry | `MxDialog` and `MxBottomSheet` render directly inside the MemoX theme wrapper | padding descendants and active theme shapes are inspected | dialog padding uses `AppSpacing.xxl`, sheet padding uses `AppSpacing.sheet`, dialog radius uses `AppRadius.dialog`, and bottom sheet radius uses `AppRadius.bottomSheet` | C0+C1 |
| DT6 | shared dialog receives content taller than a small viewport | `MxDialog` renders many content rows at compact height | the dialog is pumped and its scroll view is dragged | no overflow is thrown, content remains inside a `SingleChildScrollView`, and the scroll position changes | C0+C1 |
| DT7 | shared bottom sheet receives content taller than a small viewport | `MxBottomSheet` renders many content rows at compact height | the sheet is pumped and its scroll view is dragged | no overflow is thrown, content remains inside a `SingleChildScrollView`, and the scroll position changes | C0+C1 |
| DT8 | shared bottom sheet responds to keyboard insets | `MxBottomSheet` renders an important input while `MediaQuery.viewInsets.bottom` is non-zero | the sheet is pumped inside the MemoX wrapper | the animated bottom padding equals the keyboard inset so the input area is lifted above the keyboard | C0+C1 |

## Decision table: onState

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | retained async state has non-null data and is not loading | `MxRetainedAsyncState` receives data, `isLoading: false`, and a data builder | the widget renders inside the MemoX theme wrapper | the data child is visible and no retained refresh bar or error state is present | C0+C1 |
| DT2 | shared loading state and retained refresh state are active | `MxLoadingState` receives a message and `MxRetainedAsyncState` receives cached data with `isLoading: true` | both widgets render inside the MemoX theme wrapper | the loading message and spinner render, cached data remains visible, and the retained refresh bar is present | C0+C1 |
| DT3 | shared controls are disabled | disabled `MxPrimaryButton` and disabled `MxAnswerOptionCard` render together | descendants are inspected after layout | the button has no enabled callback, disabled answer text remains visible, and the answer card exposes no tap `InkWell` | C0+C1 |
| DT4 | error state has message, retry action, and hidden details | `MxErrorState` receives title, message, details, retry label, and retry callback | it renders and the details toggle is tapped | title, message, and retry label are visible first; details are hidden first and visible after the toggle | C0+C1 |
| DT5 | empty state has optional action with a leading icon | `MxEmptyState` receives title, message, default icon, action label, action leading icon, and action callback | it renders inside the MemoX theme wrapper | title, message, state icon, action label, and action leading icon are visible without overflow | C0+C1 |
| DT6 | selected and unselected option states render differently | selected and unselected `MxAnswerOptionCard` widgets render in the same surface | descendants are inspected after layout | selected state shows the check icon and unselected state does not show the check icon while preserving its own leading icon | C0+C1 |
| DT7 | active and inactive indicator states render differently | `MxPageDots` receives three dots with the middle dot active | descendant dot containers are inspected after layout | exactly one dot uses the active width token and two dots use the inactive width token | C0+C1 |
| DT8 | important stateful widget values change | `MxStudyProgressAction` renders with mastery and badge-count state held by a parent `StatefulBuilder` | mastery and count change to the maximum display values and the parent rebuilds | the outer action size stays unchanged and the visible percent and badge update | C0+C1 |
| DT9 | retained async state receives new data on rebuild | `MxRetainedAsyncState` renders data from a parent `StatefulBuilder` | parent state changes from one data value to another and rebuilds | the previous text disappears and the new text is visible | C0+C1 |

## Decision table: onFeedbackState

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loading state receives an optional message and large progress role | `MxLoadingState` receives a generic message and `MxProgressSize.large` | the widget renders inside the MemoX theme wrapper | a circular indicator renders at the large progress size, the message is visible, and the indicator-message gap uses `AppSpacing.lg` | C0+C1 |
| DT2 | empty state receives title, message, and icon data | `MxEmptyState` receives generic empty copy and an icon | the widget renders inside the MemoX theme wrapper | title and message are visible, text is centered, the illustration icon uses `AppIconSizes.xl`, the illustration circle uses the reviewed state size, and title/message gaps use spacing tokens | C0+C1 |
| DT3 | error state receives message and retry callback | `MxErrorState` receives generic error copy, retry label, retry callback, and icon | the widget renders and the retry button is tapped once | title and message are visible, text is centered, the illustration icon uses `AppIconSizes.xl`, state gaps use spacing tokens, and the retry callback runs exactly once | C0+C1 |
| DT4 | feedback state content renders on a short compact viewport | loading, empty, and error state widgets receive generic compact-screen data, with the error state carrying retry and details actions | each widget is pumped at width `320` and short height | no overflow is thrown and each state content column remains below the compact viewport height budget | C0+C1 |
| DT5 | feedback state source embeds feature-specific message text | shared state widget source files are scanned after comments are stripped | source is matched for feature-domain message words such as deck, card, flashcard, review, study, folder, session, or SRS | no feature-specific message text is embedded in shared loading, empty, or error state widgets | C0+C1 |

## Decision table: onAccessibility

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | icon-only shared actions rely on tooltip semantics | `MxIconButton` and `MxSpeakButton` render with tooltip labels and non-null callbacks | semantics are enabled and the widgets render inside the MemoX theme wrapper | screen-reader semantics expose the supplied labels | C0+C1 |
| DT2 | theme text color pairs are used on their matching surfaces | MemoX light and dark themes provide standard `ColorScheme` pairs and semantic `MxColorsExtension` pairs | contrast ratio is calculated for each foreground/background pair used by shared text surfaces | primary text pairs meet the normal text contrast floor and supporting text pairs meet the supporting contrast floor | C0+C1 |
| DT3 | buttons and inputs must expose accessible touch targets | `MxTextField`, `MxSearchField`, `MxPrimaryButton`, and `MxIconButton` render in the MemoX theme wrapper | each keyed target is measured after layout | every target is at least `kMinInteractiveDimension` tall and has a positive width | C0+C1 |
| DT4 | selected or active state must not be communicated only by color | selected `MxAnswerOptionCard` and active `MxPageDots` render together | descendant state cues are inspected after layout | the selected option has a check icon and the active dot differs in width from inactive dots | C0+C1 |
| DT5 | important widgets render at moderate accessibility text scale | important shared controls and state widgets render on compact width with text scale `1.2` | each case is pumped in the MemoX theme wrapper | no Flutter exception is thrown and the keyed widget remains findable | C0+C1 |
| DT6 | important widgets remain acceptable at larger accessibility text scale | important shared controls and state widgets render on compact width with text scale `1.5` | each case is pumped in the MemoX theme wrapper | no Flutter exception is thrown and the keyed widget remains findable | C0+C1 |
| DT7 | keyboard focus moves through input and actions in visual order | `MxTextField`, `MxPrimaryButton`, and `MxSecondaryButton` render in a `FocusTraversalGroup` | Tab is sent through the group and Enter is sent on each action | focus reaches the text field first, then primary action, then secondary action, and each focused action activates once | C0+C1 |
| DT8 | primary content must be available to screen readers | `MxEmptyState` renders with title, message, and action label | semantics are enabled and the widget renders inside the MemoX theme wrapper | screen-reader semantics expose the title, message, and action label | C0+C1 |

## Decision table: onResponsive

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | important shared widgets render across compact phone widths | responsive catalog includes search, toolbar, bulk action, study set tile, folder tile, streak card, term row, and error state | every catalog item is pumped at widths `320`, `360`, `390`, and `430` inside the MemoX theme wrapper | no Flutter exception is thrown and every keyed widget remains findable | C0+C1 |
| DT2 | shared widget source uses fixed heights for dynamic content without review | scanner reads every widget-bearing shared Dart file with comments preserved for reviewed geometry | source is matched for numeric `height`, `minHeight`, and `maxHeight` declarations without `guard:raw-size-reviewed` | no unreviewed fixed dynamic height declaration is found | C0+C1 |
| DT3 | shared widget source uses fixed widths for main layout without review | scanner reads every widget-bearing shared Dart file with comments preserved for reviewed geometry | source is matched for numeric `width`, `minWidth`, and `maxWidth` declarations without review and for arbitrary viewport scaling | no unreviewed fixed main-layout width or arbitrary viewport scaling declaration is found | C0+C1 |
| DT4 | long shared-widget data renders on the smallest supported width | long-data responsive catalog includes toolbar, bulk action, study set tile, folder tile, term row, and streak card | every case is pumped at width `320` with compact content width | no RenderFlex overflow or Flutter exception is thrown and every keyed widget remains findable | C0+C1 |
| DT5 | compact layout preserves content hierarchy | `MxStudySetTile` renders at width `320` with icon, title, owner row, metadata, and tap behavior | descendant positions are measured after layout | the icon remains before the text column and the title remains above the metadata line | C0+C1 |

## Decision table: onGolden

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | normal shared-widget composition renders in light theme | deterministic normal sample data builds study set, progress, answer, and CTA widgets inside the MemoX golden harness | the widget is pumped at the standard mobile golden surface and compared to `goldens/shared_widget_normal_light.png` | the rendered pixels match the committed light-theme normal golden | C0+C1 |
| DT2 | important non-normal states render in light theme | deterministic disabled, loading, and error sample data builds important shared states with ticker animations disabled | the widget is pumped at the standard mobile golden surface and compared to `goldens/shared_widget_states_light.png` | the rendered pixels match the committed light-theme state golden | C0+C1 |
| DT3 | normal shared-widget composition renders in dark theme | the same deterministic normal sample data builds under `AppTheme.dark()` | the widget is pumped at the standard mobile golden surface and compared to `goldens/shared_widget_normal_dark.png` | the rendered pixels match the committed dark-theme normal golden | C0+C1 |
| DT4 | mobile text scale golden remains stable | deterministic long-ish sample data builds at mobile size with `textScaleFactor` `1.2` | the widget is pumped at the standard mobile golden surface and compared to `goldens/shared_widget_text_scale_12.png` | the rendered pixels match the committed scaled-text mobile golden | C0+C1 |
| DT5 | golden test inputs avoid nondeterminism | scanner reads the shared widget contract test source that owns the golden builders | source is matched for `DateTime.now`, random, network image, online URL, HTTP client, and delayed timer patterns | no nondeterministic golden input source is present and the golden harness disables ticker animations | C0+C1 |

## Decision table: onMinimumCoverage

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | a public shared widget class is not in the render catalog | scanner reads public `Mx*` widget classes under `lib/presentation/shared/**` and the render catalog in the contract test | class names and catalog names are compared | every public shared widget class has render coverage through `_sharedWidgetCases` and no stale catalog entry points at a missing class | C0+C1 |
| DT2 | a callback-capable shared widget lacks interaction coverage | callback-capable shared widgets are declared in the minimum interaction coverage registry | the registry is compared with the widget names covered by interaction suites or targeted command tests | every callback-capable widget has an interaction test entry or targeted command coverage entry | C0+C1 |
| DT3 | a shared widget with disabled, loading, error, selected, or retained state lacks state coverage | stateful shared widgets and state-capable controls are declared in the minimum state coverage registry | the registry is compared with state, feedback-state, button, text-field, card, and accessibility state test coverage entries | every state-capable widget has an executable state test entry | C0+C1 |
| DT4 | a shared widget lacks layout or theme/token coverage | the render catalog, layout source scans, rebuild stability tests, compact render tests, and theme/token source scans are all part of the same contract file | catalog names are compared against the layout and theme coverage sets | every cataloged shared widget is covered by layout constraint checks and theme/token style checks | C0+C1 |
| DT5 | a shared widget with icon, button, or input semantics lacks accessibility coverage | accessibility-required shared widgets are declared in the minimum accessibility coverage registry | the registry is compared with accessibility, button semantics, text-field, and feedback-state coverage entries | every accessibility-required widget has semantics, focus, touch-target, text-scale, or non-color-state coverage | C0+C1 |
| DT6 | an important primitive shared widget lacks golden coverage | golden-required primitive widgets are declared in the minimum golden coverage registry | the registry is compared with widgets included in normal, state, text-scale, and card golden builders | every golden-required primitive appears in at least one committed golden scenario | C0+C1 |

## Decision table: inspectSource

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | widget-bearing shared source imports or calls feature, provider, API, use case, repository, or data infrastructure | scanner reads every Dart file under `lib/presentation/shared/**` that declares a public widget class | stripped source is matched against forbidden layer and infrastructure patterns | no forbidden coupling pattern is found | C0+C1 |
| DT2 | widget-bearing shared source bypasses theme or token styling | scanner reads every Dart file under `lib/presentation/shared/**` that declares a public widget class | stripped source is matched for raw colors, raw typography construction, raw radius factories, and numeric `EdgeInsets` arguments | no raw color, typography, radius, or spacing primitive is found outside theme or token usage | C0+C1 |

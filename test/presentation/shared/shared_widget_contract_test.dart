import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/component_themes/focus_theme.dart';
import 'package:memox/core/theme/extensions/theme_extensions.dart';
import 'package:memox/core/theme/responsive/app_layout.dart';
import 'package:memox/core/theme/tokens/app_elevation.dart';
import 'package:memox/core/theme/tokens/app_icon_sizes.dart';
import 'package:memox/core/theme/tokens/app_opacity.dart';
import 'package:memox/core/theme/tokens/app_radius.dart';
import 'package:memox/core/theme/tokens/app_spacing.dart';
import 'package:memox/core/theme/tokens/app_typography.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_action_sheet_list.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_destination_picker_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_banner.dart';
import 'package:memox/presentation/shared/layouts/mx_adaptive_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_section.dart';
import 'package:memox/presentation/shared/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/states/mx_error_state.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/states/mx_offline_state.dart';
import 'package:memox/presentation/shared/states/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/widgets/mx_animated_switcher.dart';
import 'package:memox/presentation/shared/widgets/mx_answer_option_card.dart';
import 'package:memox/presentation/shared/widgets/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/mx_badge.dart';
import 'package:memox/presentation/shared/widgets/mx_breadcrumb_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_bulk_action_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_chip.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/mx_flashcard.dart';
import 'package:memox/presentation/shared/widgets/mx_folder_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_inline_toggle.dart';
import 'package:memox/presentation/shared/widgets/mx_list_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_page_dots.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_progress_indicator.dart';
import 'package:memox/presentation/shared/widgets/mx_progress_ring.dart';
import 'package:memox/presentation/shared/widgets/mx_reorderable_list.dart';
import 'package:memox/presentation/shared/widgets/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/mx_search_sort_toolbar.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_section_header.dart';
import 'package:memox/presentation/shared/widgets/mx_segmented_control.dart';
import 'package:memox/presentation/shared/widgets/mx_select_field.dart';
import 'package:memox/presentation/shared/widgets/mx_shake_transition.dart';
import 'package:memox/presentation/shared/widgets/mx_slider.dart';
import 'package:memox/presentation/shared/widgets/mx_sort_menu_chip.dart';
import 'package:memox/presentation/shared/widgets/mx_speak_button.dart';
import 'package:memox/presentation/shared/widgets/mx_streak_card.dart';
import 'package:memox/presentation/shared/widgets/mx_study_progress_action.dart';
import 'package:memox/presentation/shared/widgets/mx_study_set_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_toggle.dart';

void main() {
  testWidgets(
    'DT1 onDisplay: renders minimal shared widget data in app theme wrapper',
    (tester) async {
      for (final entry in _sharedWidgetCases) {
        await _pumpCatalogEntry(tester, entry, _CatalogVariant.minimal);
      }
    },
  );

  testWidgets(
    'DT2 onDisplay: renders full shared widget data in app theme wrapper',
    (tester) async {
      for (final entry in _sharedWidgetCases) {
        await _pumpCatalogEntry(tester, entry, _CatalogVariant.full);
      }
    },
  );

  testWidgets(
    'DT3 onDisplay: supports light dark large text and compact surfaces',
    (tester) async {
      final scenarios = <_RenderScenario>[
        const _RenderScenario(label: 'light', themeMode: ThemeMode.light),
        const _RenderScenario(label: 'dark', themeMode: ThemeMode.dark),
        const _RenderScenario(label: 'text-scale', textScaleFactor: 1.8),
        const _RenderScenario(label: 'compact', surfaceSize: Size(320, 568)),
      ];

      for (final scenario in scenarios) {
        for (final entry in _sharedWidgetCases) {
          await _pumpCatalogEntry(
            tester,
            entry,
            _CatalogVariant.full,
            scenario: scenario,
          );
        }
      }
    },
  );

  testWidgets('DT1 onUpdate: preserves subject size across rebuilds', (
    tester,
  ) async {
    for (final entry in _sharedWidgetCases) {
      final key = ValueKey<String>('shared-widget-rebuild-${entry.name}');
      final before = await _pumpEntryWithKey(
        tester,
        entry,
        _CatalogVariant.full,
        key,
      );
      final after = await _pumpEntryWithKey(
        tester,
        entry,
        _CatalogVariant.full,
        key,
      );

      expect(find.byKey(key), findsOneWidget, reason: entry.name);
      if (before != null && after != null) {
        expect(after, before, reason: entry.name);
      }
    }
  });

  test(
    'DT1 onLayout: keeps padding margin and gap declarations token based',
    () {
      final violations = <String>[];

      for (final file in _sharedWidgetSourceFiles()) {
        final source = _stripComments(file.readAsStringSync());
        violations.addAll(_findRawEdgeInsets(file, source));
        violations.addAll(_findRawGapUsage(file, source));
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );

  testWidgets(
    'DT2 onLayout: keeps important interactive controls at material touch size',
    (tester) async {
      for (final entry in _touchTargetCases) {
        final key = ValueKey<String>('touch-target-${entry.name}');

        await _pumpLayoutWidget(tester, entry.build(key));

        final size = tester.getSize(find.byKey(key));
        expect(
          size.width,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: entry.name,
        );
        expect(
          size.height,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: entry.name,
        );
      }
    },
  );

  testWidgets('DT3 onLayout: handles long content on compact width', (
    tester,
  ) async {
    const longText =
        'This shared widget layout receives deliberately long content that '
        'must wrap, ellipsize, or scroll instead of overflowing a compact '
        'phone width when text scaling is increased.';
    final longContentCases = <_LayoutCase>[
      _LayoutCase(
        'MxAnswerOptionCard',
        (key) => MxAnswerOptionCard(
          key: key,
          label: longText,
          selected: true,
          onPressed: _noop,
        ),
      ),
      _LayoutCase(
        'MxBanner',
        (key) => MxBanner(
          key: key,
          title: 'Sync paused while offline',
          message: longText,
          primaryActionLabel: 'Retry sync',
          primaryAction: _noop,
          onDismiss: _noop,
        ),
      ),
      _LayoutCase(
        'MxBulkActionBar',
        (key) => MxBulkActionBar(
          key: key,
          label: '12 selected flashcards with long names',
          subtitle: longText,
          actions: [
            MxSecondaryButton(label: 'Move selected cards', onPressed: _noop),
            MxPrimaryButton(label: 'Archive selected cards', onPressed: _noop),
          ],
        ),
      ),
      _LayoutCase(
        'MxFlashcard',
        (key) => MxFlashcard(
          key: key,
          content: longText,
          language: 'en',
          onFullscreen: _noop,
        ),
      ),
      _LayoutCase(
        'MxFolderTile',
        (key) => MxFolderTile(
          key: key,
          name: longText,
          icon: Icons.folder_outlined,
          caption: longText,
          masteryPercent: 76,
        ),
      ),
      _LayoutCase(
        'MxInlineToggle',
        (key) => MxInlineToggle(
          key: key,
          label: 'Automatically play pronunciation after each transition',
          subtitle: longText,
          leadingIcon: Icons.volume_up,
          value: true,
          onChanged: (_) {},
        ),
      ),
      _LayoutCase(
        'MxStudySetTile',
        (key) => MxStudySetTile(
          key: key,
          title: longText,
          icon: Icons.style_outlined,
          metaLine: longText,
          ownerInitials: 'MX',
          ownerLabel: longText,
          onTap: _noop,
        ),
      ),
      _LayoutCase(
        'MxTermRow',
        (key) => MxTermRow(
          key: key,
          term: longText,
          definition: longText,
          caption: longText,
          selected: true,
        ),
      ),
      _LayoutCase(
        'MxStreakCard',
        (key) => MxStreakCard(
          key: key,
          streakCount: 120,
          streakUnit: 'consecutive learning days',
          encouragement: longText,
          weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          weekDates: const [24, 25, 26, 27, 28, 29, 30],
          activeIndices: const {0, 1, 3, 6},
        ),
      ),
    ];

    for (final entry in longContentCases) {
      final key = ValueKey<String>('long-content-${entry.name}');
      await _pumpLayoutWidget(
        tester,
        entry.build(key),
        scenario: _RenderScenario(
          label: 'long-content-${entry.name}',
          textScaleFactor: 1.6,
          surfaceSize: const Size(320, 568),
        ),
        maxWidth: 288,
      );
    }

    await _pumpLayoutWidget(
      tester,
      SizedBox(
        width: 288,
        child: MxAnswerOptionCard(
          key: const ValueKey('long-content-answer-inspect'),
          label: longText,
          selected: true,
          onPressed: _noop,
        ),
      ),
      scenario: const _RenderScenario(
        label: 'long-content-answer-inspect',
        textScaleFactor: 1.6,
        surfaceSize: Size(320, 568),
      ),
    );
    final answerText = tester.widget<Text>(find.text(longText));
    expect(answerText.softWrap, isTrue);
    expect(answerText.maxLines, greaterThan(1));

    await _pumpLayoutWidget(
      tester,
      SizedBox(
        width: 288,
        child: MxFlashcard(
          key: const ValueKey('long-content-flashcard-inspect'),
          content: longText,
        ),
      ),
      scenario: const _RenderScenario(
        label: 'long-content-flashcard-inspect',
        textScaleFactor: 1.6,
        surfaceSize: Size(320, 568),
      ),
    );
    final flashcardFinder = find.byKey(
      const ValueKey('long-content-flashcard-inspect'),
    );
    expect(
      find.descendant(
        of: flashcardFinder,
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: flashcardFinder, matching: find.byType(Scrollbar)),
      findsOneWidget,
    );
  });

  test(
    'DT4 onLayout: rejects unreviewed fixed dimensions and viewport scaling',
    () {
      final violations = <String>[];

      for (final file in _sharedWidgetSourceFiles()) {
        final source = file.readAsStringSync();
        final strippedSource = _stripComments(source);
        violations.addAll(_findUnreviewedFixedDimensions(file, source));
        violations.addAll(_findArbitraryViewportScaling(file, strippedSource));
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );

  testWidgets(
    'DT5 onLayout: preserves explicit alignment and bounded constraints',
    (tester) async {
      const key = ValueKey('content-shell-layout-contract');

      await _pumpLayoutWidget(
        tester,
        const MxContentShell(
          key: key,
          width: MxContentWidth.reading,
          child: Text('Reading body'),
        ),
        scenario: const _RenderScenario(
          label: 'content-shell-layout',
          surfaceSize: Size(900, 700),
        ),
      );

      final align = tester.widget<Align>(
        find.descendant(of: find.byKey(key), matching: find.byType(Align)),
      );
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(ConstrainedBox),
        ),
      );

      expect(align.alignment, Alignment.topCenter);
      expect(constrainedBox.constraints.maxWidth.isFinite, isTrue);
      expect(constrainedBox.constraints.maxWidth, greaterThan(0));
    },
  );

  test('DT1 onVisualStyle: keeps visual style declarations token based', () {
    final violations = <String>[];
    final rules = <_SourceRule>[
      _SourceRule(
        'raw visual color',
        RegExp(r'\bColors\.|\bColor\s*\(\s*0x|Color\.from(?:ARGB|RGBO)'),
      ),
      _SourceRule(
        'raw typography construction',
        RegExp(r'\bTextStyle\s*\(|\bfontSize\s*:\s*\d'),
      ),
      _SourceRule(
        'raw radius factory',
        RegExp(r'\b(?:BorderRadius|Radius)\.circular\s*\('),
      ),
      _SourceRule('raw elevation literal', RegExp(r'\belevation\s*:\s*\d')),
      _SourceRule('raw shadow construction', RegExp(r'\bBoxShadow\s*\(')),
    ];

    for (final file in _sharedWidgetSourceFiles()) {
      final source = _stripComments(file.readAsStringSync());
      for (final rule in rules) {
        if (rule.pattern.hasMatch(source)) {
          violations.add('${_relativePath(file)}: ${rule.label}');
        }
      }
      violations.addAll(_findRawIconSizes(file, source));
      violations.addAll(_findRawBorderThickness(file, source));
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  testWidgets(
    'DT2 onVisualStyle: resolves theme surfaces text icons and dividers',
    (tester) async {
      const cardKey = ValueKey('visual-card');
      const iconButtonKey = ValueKey('visual-icon-button');
      const dividerKey = ValueKey('visual-divider');

      await _pumpLayoutWidget(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MxCard(
              key: cardKey,
              variant: MxCardVariant.outlined,
              child: MxText('Theme text', role: MxTextRole.tileTitle),
            ),
            MxIconButton(
              key: iconButtonKey,
              icon: Icons.search,
              onPressed: _noop,
            ),
            const MxDivider(key: dividerKey),
          ],
        ),
      );

      final context = tester.element(find.byKey(cardKey));
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final card = tester.widget<Card>(
        find.descendant(of: find.byKey(cardKey), matching: find.byType(Card)),
      );
      final shape = card.shape! as RoundedRectangleBorder;
      final text = tester.widget<Text>(find.text('Theme text'));
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(iconButtonKey),
          matching: find.byIcon(Icons.search),
        ),
      );
      final divider = tester.widget<Divider>(
        find.descendant(
          of: find.byKey(dividerKey),
          matching: find.byType(Divider),
        ),
      );

      expect(card.color, scheme.surfaceContainerLow);
      expect(card.elevation, AppElevation.card);
      expect(shape.borderRadius, AppRadius.card);
      expect(shape.side.color, scheme.outlineVariant);
      expect(text.style?.fontSize, theme.textTheme.titleMedium?.fontSize);
      expect(text.style?.color, scheme.onSurface);
      expect(icon.size, AppIconSizes.md);
      expect(divider.color, isNull);
      expect(divider.thickness, isNull);
      expect(theme.dividerTheme.color, scheme.outlineVariant);
      expect(theme.dividerTheme.thickness, isNotNull);
    },
  );

  testWidgets(
    'DT3 onVisualStyle: resolves disabled and error states from theme',
    (tester) async {
      const disabledKey = ValueKey('visual-disabled-button');

      await _pumpLayoutWidget(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxPrimaryButton(
              key: disabledKey,
              label: 'Delete',
              tone: MxPrimaryButtonTone.danger,
              onPressed: null,
            ),
            MxText('Wrong answer', role: MxTextRole.fillIncorrectInput),
          ],
        ),
      );

      final context = tester.element(find.byKey(disabledKey));
      final scheme = Theme.of(context).colorScheme;
      final disabledStates = <WidgetState>{WidgetState.disabled};
      final button = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(disabledKey),
          matching: find.byType(ElevatedButton),
        ),
      );
      final errorText = tester.widget<Text>(find.text('Wrong answer'));

      expect(
        button.style?.backgroundColor?.resolve(disabledStates),
        scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface),
      );
      expect(
        button.style?.foregroundColor?.resolve(disabledStates),
        scheme.onSurface.withValues(alpha: AppOpacity.disabled),
      );
      expect(errorText.style?.color, scheme.error);
    },
  );

  testWidgets(
    'DT4 onVisualStyle: resolves focus pressed hover overlays from theme',
    (tester) async {
      const tappableKey = ValueKey('visual-tappable');

      await _pumpLayoutWidget(
        tester,
        MxTappable(
          key: tappableKey,
          shape: const StadiumBorder(),
          onTap: _noop,
          child: const SizedBox(
            width: kMinInteractiveDimension,
            height: kMinInteractiveDimension,
          ),
        ),
      );

      final context = tester.element(find.byKey(tappableKey));
      final scheme = Theme.of(context).colorScheme;
      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(tappableKey),
          matching: find.byType(InkWell),
        ),
      );

      expect(
        inkWell.overlayColor?.resolve({WidgetState.hovered}),
        AppFocus.overlay(scheme.onSurface, {WidgetState.hovered}),
      );
      expect(
        inkWell.overlayColor?.resolve({WidgetState.focused}),
        AppFocus.overlay(scheme.onSurface, {WidgetState.focused}),
      );
      expect(
        inkWell.overlayColor?.resolve({WidgetState.pressed}),
        AppFocus.overlay(scheme.onSurface, {WidgetState.pressed}),
      );
    },
  );

  testWidgets(
    'DT1 onInteraction: invokes enabled shared action callback once per tap',
    (tester) async {
      for (final entry in _tapCallbackCases) {
        var calls = 0;
        final key = ValueKey<String>('tap-callback-${entry.name}');

        await _pumpLayoutWidget(tester, entry.build(key, () => calls++));
        await tester.tap(find.byKey(key));
        await tester.pump();

        expect(calls, 1, reason: entry.name);
        expect(tester.takeException(), isNull, reason: entry.name);
      }
    },
  );

  testWidgets('DT2 onInteraction: suppresses callbacks for disabled controls', (
    tester,
  ) async {
    for (final entry in _disabledInteractionCases) {
      var calls = 0;
      final key = ValueKey<String>('disabled-interaction-${entry.name}');

      await _pumpLayoutWidget(tester, entry.build(key, () => calls++));
      await tester.tap(find.byKey(key), warnIfMissed: false);
      await tester.pump();

      expect(calls, 0, reason: entry.name);
      expect(tester.takeException(), isNull, reason: entry.name);
    }
  });

  testWidgets('DT3 onInteraction: suppresses callbacks while loading', (
    tester,
  ) async {
    for (final entry in _loadingInteractionCases) {
      var calls = 0;
      final key = ValueKey<String>('loading-interaction-${entry.name}');

      await _pumpLayoutWidget(tester, entry.build(key, () => calls++));
      await tester.tap(find.byKey(key), warnIfMissed: false);
      await tester.pump();

      expect(calls, 0, reason: entry.name);
      expect(tester.takeException(), isNull, reason: entry.name);
    }
  });

  testWidgets('DT4 onInteraction: keeps layout stable while pressed', (
    tester,
  ) async {
    for (final entry in _pressedLayoutCases) {
      final key = ValueKey<String>('pressed-layout-${entry.name}');

      await _pumpLayoutWidget(tester, entry.build(key));
      final before = tester.getSize(find.byKey(key));

      final gesture = await tester.press(find.byKey(key));
      await tester.pump(const Duration(milliseconds: 80));
      final during = tester.getSize(find.byKey(key));

      await gesture.up();
      await tester.pumpAndSettle();
      final after = tester.getSize(find.byKey(key));

      expect(during, before, reason: entry.name);
      expect(after, before, reason: entry.name);
      expect(tester.takeException(), isNull, reason: entry.name);
    }
  });

  testWidgets(
    'DT5 onInteraction: supports focus state for text fields and buttons',
    (tester) async {
      final fieldFocusNode = FocusNode();
      addTearDown(fieldFocusNode.dispose);
      const fieldKey = ValueKey('interaction-focus-field');
      const buttonKey = ValueKey('interaction-focus-button');
      var buttonCalls = 0;

      await _pumpLayoutWidget(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxTextField(
              key: fieldKey,
              label: 'Answer',
              focusNode: fieldFocusNode,
              textInputAction: TextInputAction.next,
            ),
            const MxGap(AppSpacing.md),
            MxPrimaryButton(
              key: buttonKey,
              label: 'Continue',
              onPressed: () => buttonCalls++,
            ),
          ],
        ),
      );

      await tester.tap(find.byKey(fieldKey));
      await tester.pump();
      expect(fieldFocusNode.hasFocus, isTrue);

      final buttonFocusFinder = find
          .descendant(of: find.byKey(buttonKey), matching: find.byType(Focus))
          .last;
      final buttonFocusState = tester.state(buttonFocusFinder) as dynamic;
      final buttonFocusNode = buttonFocusState.focusNode as FocusNode;
      buttonFocusNode.requestFocus();
      await tester.pump();

      expect(fieldFocusNode.hasFocus, isFalse);
      expect(buttonFocusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(buttonCalls, 1);
    },
  );

  testWidgets('DT6 onInteraction: accepts keyboard input and submit actions', (
    tester,
  ) async {
    final textController = TextEditingController();
    addTearDown(textController.dispose);
    const textFieldKey = ValueKey('interaction-keyboard-text-field');
    var textChanged = '';
    var textSubmitted = '';

    await _pumpLayoutWidget(
      tester,
      MxTextField(
        key: textFieldKey,
        label: 'Answer',
        controller: textController,
        textInputAction: TextInputAction.done,
        onChanged: (value) => textChanged = value,
        onSubmitted: (value) => textSubmitted = value,
      ),
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(textFieldKey),
        matching: find.byType(EditableText),
      ),
      'memo',
    );
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(textController.text, 'memo');
    expect(textChanged, 'memo');
    expect(textSubmitted, 'memo');

    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    const searchFieldKey = ValueKey('interaction-keyboard-search-field');
    var searchChanged = '';
    var searchSubmitted = '';
    var clearCalls = 0;

    await _pumpLayoutWidget(
      tester,
      MxSearchField(
        key: searchFieldKey,
        controller: searchController,
        hintText: 'Search',
        onChanged: (value) => searchChanged = value,
        onSubmitted: (value) => searchSubmitted = value,
        onClear: () => clearCalls++,
      ),
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(searchFieldKey),
        matching: find.byType(EditableText),
      ),
      'deck',
    );
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(searchController.text, 'deck');
    expect(searchChanged, 'deck');
    expect(searchSubmitted, 'deck');

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(searchController.text, isEmpty);
    expect(searchChanged, isEmpty);
    expect(clearCalls, 1);
  });

  testWidgets(
    'DT7 onInteraction: keeps child gestures isolated from parent gestures',
    (tester) async {
      const parentKey = ValueKey('interaction-parent-gesture');
      const childKey = ValueKey('interaction-child-gesture');
      var parentCalls = 0;
      var childCalls = 0;

      await _pumpLayoutWidget(
        tester,
        GestureDetector(
          key: parentKey,
          behavior: HitTestBehavior.opaque,
          onTap: () => parentCalls++,
          child: SizedBox(
            width: 240,
            height: 120,
            child: Align(
              child: SizedBox(
                width: 200,
                child: MxAnswerOptionCard(
                  key: childKey,
                  label: 'Choice',
                  onPressed: () => childCalls++,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(childKey));
      await tester.pump();
      expect(childCalls, 1);
      expect(parentCalls, 0);

      final parentTopLeft = tester.getTopLeft(find.byKey(parentKey));
      await tester.tapAt(parentTopLeft + const Offset(8, 8));
      await tester.pump();

      expect(childCalls, 1);
      expect(parentCalls, 1);
    },
  );

  testWidgets(
    'DT8 onInteraction: keeps interactive hit areas at least material size',
    (tester) async {
      for (final entry in _hitAreaCases) {
        final key = ValueKey<String>('interaction-hit-area-${entry.name}');

        await _pumpLayoutWidget(tester, entry.build(key));

        final size = tester.getSize(entry.finder(key));
        expect(
          size.width,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: entry.name,
        );
        expect(
          size.height,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: entry.name,
        );
      }
    },
  );

  testWidgets('DT1 onButton: renders labels icons and token gaps', (
    tester,
  ) async {
    const primaryKey = ValueKey('button-label-primary');
    const secondaryKey = ValueKey('button-label-secondary');

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxPrimaryButton(
            key: primaryKey,
            label: 'Continue',
            leadingIcon: Icons.play_arrow,
            trailingIcon: Icons.arrow_forward,
            onPressed: _noop,
          ),
          const MxGap(AppSpacing.md),
          MxSecondaryButton(
            key: secondaryKey,
            label: 'Cancel',
            leadingIcon: Icons.close,
            trailingIcon: Icons.undo,
            onPressed: _noop,
          ),
        ],
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(
      _buttonIcon(tester, primaryKey, Icons.play_arrow).size,
      AppIconSizes.md,
    );
    expect(
      _buttonIcon(tester, primaryKey, Icons.arrow_forward).size,
      AppIconSizes.md,
    );
    expect(
      _buttonIcon(tester, secondaryKey, Icons.close).size,
      AppIconSizes.md,
    );
    expect(_buttonIcon(tester, secondaryKey, Icons.undo).size, AppIconSizes.md);
    expect(_buttonGapSizes(tester, primaryKey), [AppSpacing.sm, AppSpacing.sm]);
    expect(_buttonGapSizes(tester, secondaryKey), [
      AppSpacing.sm,
      AppSpacing.sm,
    ]);
  });

  testWidgets('DT2 onButton: invokes enabled callbacks once', (tester) async {
    const primaryKey = ValueKey('button-enabled-primary');
    const secondaryKey = ValueKey('button-enabled-secondary');
    const iconKey = ValueKey('button-enabled-icon');
    var primaryCalls = 0;
    var secondaryCalls = 0;
    var iconCalls = 0;

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxPrimaryButton(
            key: primaryKey,
            label: 'Continue',
            onPressed: () => primaryCalls++,
          ),
          const MxGap(AppSpacing.md),
          MxSecondaryButton(
            key: secondaryKey,
            label: 'Cancel',
            onPressed: () => secondaryCalls++,
          ),
          const MxGap(AppSpacing.md),
          MxIconButton(
            key: iconKey,
            icon: Icons.search,
            tooltip: 'Search',
            onPressed: () => iconCalls++,
          ),
        ],
      ),
    );

    await tester.tap(find.byKey(primaryKey));
    await tester.tap(find.byKey(secondaryKey));
    await tester.tap(find.byKey(iconKey));
    await tester.pump();

    expect(primaryCalls, 1);
    expect(secondaryCalls, 1);
    expect(iconCalls, 1);
  });

  testWidgets('DT3 onButton: suppresses disabled and loading callbacks', (
    tester,
  ) async {
    const disabledPrimaryKey = ValueKey('button-disabled-primary');
    const disabledSecondaryKey = ValueKey('button-disabled-secondary');
    const disabledIconKey = ValueKey('button-disabled-icon');
    const loadingPrimaryKey = ValueKey('button-loading-primary');
    const loadingSecondaryKey = ValueKey('button-loading-secondary');
    var loadingPrimaryCalls = 0;
    var loadingSecondaryCalls = 0;

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MxPrimaryButton(
            key: disabledPrimaryKey,
            label: 'Continue',
            onPressed: null,
          ),
          const MxGap(AppSpacing.md),
          const MxSecondaryButton(
            key: disabledSecondaryKey,
            label: 'Cancel',
            onPressed: null,
          ),
          const MxGap(AppSpacing.md),
          const MxIconButton(
            key: disabledIconKey,
            icon: Icons.search,
            tooltip: 'Search',
            onPressed: null,
          ),
          const MxGap(AppSpacing.md),
          MxPrimaryButton(
            key: loadingPrimaryKey,
            label: 'Continue',
            isLoading: true,
            onPressed: () => loadingPrimaryCalls++,
          ),
          const MxGap(AppSpacing.md),
          MxSecondaryButton(
            key: loadingSecondaryKey,
            label: 'Cancel',
            isLoading: true,
            onPressed: () => loadingSecondaryCalls++,
          ),
        ],
      ),
    );

    expect(_elevatedButton(tester, disabledPrimaryKey).onPressed, isNull);
    expect(_outlinedButton(tester, disabledSecondaryKey).onPressed, isNull);
    expect(_iconButton(tester, disabledIconKey).onPressed, isNull);
    expect(_elevatedButton(tester, loadingPrimaryKey).onPressed, isNull);
    expect(_outlinedButton(tester, loadingSecondaryKey).onPressed, isNull);

    await tester.tap(find.byKey(disabledPrimaryKey));
    await tester.tap(find.byKey(disabledSecondaryKey));
    await tester.tap(find.byKey(disabledIconKey));
    await tester.tap(find.byKey(loadingPrimaryKey));
    await tester.tap(find.byKey(loadingSecondaryKey));
    await tester.pump();

    expect(loadingPrimaryCalls, 0);
    expect(loadingSecondaryCalls, 0);
  });

  testWidgets('DT4 onButton: resolves geometry typography and tokens', (
    tester,
  ) async {
    for (final entry in _buttonStyleCases) {
      final key = ValueKey<String>('button-style-${entry.name}');

      await _pumpLayoutWidget(tester, entry.build(key));

      final buttonFinder = entry.findButton(key);
      final size = tester.getSize(buttonFinder);
      expect(
        size.height,
        greaterThanOrEqualTo(kMinInteractiveDimension),
        reason: entry.name,
      );
      _expectSharedButtonStyle(
        entry.style(tester, buttonFinder),
        entry.expectedPadding,
        entry.name,
      );
    }

    const iconKey = ValueKey('button-style-icon');
    await _pumpLayoutWidget(
      tester,
      const MxIconButton(
        key: iconKey,
        icon: Icons.search,
        tooltip: 'Search',
        onPressed: _noop,
      ),
    );

    final iconSize = tester.getSize(_iconButtonFinder(iconKey));
    expect(iconSize.width, greaterThanOrEqualTo(kMinInteractiveDimension));
    expect(iconSize.height, greaterThanOrEqualTo(kMinInteractiveDimension));
  });

  testWidgets('DT5 onButton: keeps loading indicator height stable', (
    tester,
  ) async {
    const normalPrimaryKey = ValueKey('button-loading-normal-primary');
    const loadingPrimaryKey = ValueKey('button-loading-active-primary');
    const normalSecondaryKey = ValueKey('button-loading-normal-secondary');
    const loadingSecondaryKey = ValueKey('button-loading-active-secondary');

    await _pumpLayoutWidget(
      tester,
      const SizedBox(
        width: 220, // guard:raw-size-reviewed button fixture width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxPrimaryButton(
              key: normalPrimaryKey,
              label: 'Continue',
              fullWidth: true,
              onPressed: _noop,
            ),
            MxGap(AppSpacing.md),
            MxPrimaryButton(
              key: loadingPrimaryKey,
              label: 'Continue',
              fullWidth: true,
              isLoading: true,
              onPressed: _noop,
            ),
            MxGap(AppSpacing.lg),
            MxSecondaryButton(
              key: normalSecondaryKey,
              label: 'Cancel',
              fullWidth: true,
              onPressed: _noop,
            ),
            MxGap(AppSpacing.md),
            MxSecondaryButton(
              key: loadingSecondaryKey,
              label: 'Cancel',
              fullWidth: true,
              isLoading: true,
              onPressed: _noop,
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(loadingPrimaryKey)).height,
      tester.getSize(find.byKey(normalPrimaryKey)).height,
    );
    expect(
      tester.getSize(find.byKey(loadingSecondaryKey)).height,
      tester.getSize(find.byKey(normalSecondaryKey)).height,
    );
    expect(
      find.descendant(
        of: find.byKey(loadingPrimaryKey),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(loadingSecondaryKey),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DT6 onButton: handles long labels without overflow', (
    tester,
  ) async {
    const primaryKey = ValueKey('button-long-primary');
    const secondaryKey = ValueKey('button-long-secondary');
    const longLabel =
        'Continue studying the very long vocabulary collection today';

    await _pumpLayoutWidget(
      tester,
      const SizedBox(
        width: 160, // guard:raw-size-reviewed compact button fixture width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxPrimaryButton(
              key: primaryKey,
              label: longLabel,
              fullWidth: true,
              onPressed: _noop,
            ),
            MxGap(AppSpacing.md),
            MxSecondaryButton(
              key: secondaryKey,
              label: longLabel,
              fullWidth: true,
              onPressed: _noop,
            ),
          ],
        ),
      ),
      scenario: const _RenderScenario(
        label: 'button-long-label',
        surfaceSize: Size(320, 568),
      ),
    );

    final primaryText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(primaryKey),
        matching: find.text(longLabel),
      ),
    );
    final secondaryText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(secondaryKey),
        matching: find.text(longLabel),
      ),
    );

    expect(primaryText.overflow, TextOverflow.ellipsis);
    expect(primaryText.maxLines, 1);
    expect(secondaryText.overflow, TextOverflow.ellipsis);
    expect(secondaryText.maxLines, 1);
  });

  testWidgets('DT7 onButton: exposes icon only semantics label', (
    tester,
  ) async {
    const iconKey = ValueKey('button-semantics-icon');
    final semantics = tester.ensureSemantics();

    try {
      await _pumpLayoutWidget(
        tester,
        const MxIconButton(
          key: iconKey,
          icon: Icons.search,
          tooltip: 'Search cards',
          onPressed: _noop,
        ),
      );

      final size = tester.getSize(_iconButtonFinder(iconKey));
      expect(
        find.descendant(
          of: find.byKey(iconKey),
          matching: find.byIcon(Icons.search),
        ),
        findsOneWidget,
      );
      expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(find.bySemanticsLabel('Search cards'), findsAtLeastNWidgets(1));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('DT8 onButton: matches normal button golden', (tester) async {
    await _expectGoldenMatches(
      tester,
      _buildButtonNormalGoldenContent(),
      'goldens/shared_button_normal.png',
      surfaceSize: const Size(390, 520),
    );
  });

  testWidgets('DT9 onButton: matches loading and disabled button golden', (
    tester,
  ) async {
    await _expectGoldenMatches(
      tester,
      _buildButtonStateGoldenContent(),
      'goldens/shared_button_states.png',
      surfaceSize: const Size(390, 520),
    );
  });

  testWidgets('DT1 onCard: renders child with token padding', (tester) async {
    const cardKey = ValueKey('card-child-padding');
    const childKey = ValueKey('card-child');

    await _pumpLayoutWidget(
      tester,
      const MxCard(
        key: cardKey,
        child: SizedBox(key: childKey, height: kMinInteractiveDimension),
      ),
    );

    final paddings = tester
        .widgetList<Padding>(
          find.descendant(
            of: find.byKey(cardKey),
            matching: find.byType(Padding),
          ),
        )
        .map((padding) => padding.padding);

    expect(find.byKey(childKey), findsOneWidget);
    expect(paddings, contains(AppSpacing.card));
  });

  testWidgets('DT2 onCard: resolves visual tokens for card variants', (
    tester,
  ) async {
    for (final entry in _cardVisualCases) {
      final key = ValueKey<String>('card-visual-${entry.name}');

      await _pumpLayoutWidget(
        tester,
        MxCard(key: key, variant: entry.variant, child: const Text('Card')),
      );

      final context = tester.element(find.byKey(key));
      final scheme = Theme.of(context).colorScheme;
      final card = _materialCard(tester, key);
      final shape = _cardShape(card);

      expect(card.color, scheme.surfaceContainerLow, reason: entry.name);
      expect(card.elevation, entry.elevation, reason: entry.name);
      expect(shape.borderRadius, AppRadius.card, reason: entry.name);
      if (entry.variant == MxCardVariant.outlined) {
        expect(shape.side.color, scheme.outlineVariant, reason: entry.name);
        expect(shape.side.width, 1);
      } else {
        expect(shape.side, BorderSide.none, reason: entry.name);
      }
    }
  });

  testWidgets('DT3 onCard: separates static and clickable state', (
    tester,
  ) async {
    const staticKey = ValueKey('card-static');
    const clickableKey = ValueKey('card-clickable');
    var tapCalls = 0;

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MxCard(key: staticKey, child: Text('Static card')),
          const MxGap(AppSpacing.md),
          MxCard(
            key: clickableKey,
            onTap: () => tapCalls++,
            child: const Text('Clickable card'),
          ),
        ],
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(staticKey),
        matching: find.byType(MxTappable),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(clickableKey),
        matching: find.byType(MxTappable),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(clickableKey),
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(staticKey));
    await tester.tap(find.byKey(clickableKey));
    await tester.pump();

    expect(tapCalls, 1);
  });

  testWidgets('DT4 onCard: handles long content on compact width', (
    tester,
  ) async {
    const cardKey = ValueKey('card-long-content');
    const longText =
        'A shared card can receive long dynamic copy from a feature surface '
        'and should let the child wrap instead of forcing a RenderFlex overflow.';

    await _pumpLayoutWidget(
      tester,
      const SizedBox(
        width: 160, // guard:raw-size-reviewed compact card fixture width
        child: MxCard(key: cardKey, child: Text(longText)),
      ),
      scenario: const _RenderScenario(
        label: 'card-long-content',
        surfaceSize: Size(320, 568),
      ),
    );

    expect(find.byKey(cardKey), findsOneWidget);
    expect(find.text(longText), findsOneWidget);
    expect(tester.getSize(_cardFinder(cardKey)).width, 160);
  });

  testWidgets('DT5 onCard: follows parent width constraints', (tester) async {
    const widths = <double>[160, 280];

    for (final width in widths) {
      final key = ValueKey<String>('card-width-${width.round()}');

      await _pumpLayoutWidget(
        tester,
        SizedBox(
          width: width,
          child: MxCard(key: key, child: const Text('Width-aware card')),
        ),
      );

      expect(tester.getSize(_cardFinder(key)).width, width);
    }
  });

  testWidgets('DT6 onCard: matches normal and clickable card golden', (
    tester,
  ) async {
    await _expectGoldenMatches(
      tester,
      _buildCardGoldenContent(),
      'goldens/shared_card_variants.png',
      surfaceSize: const Size(390, 640),
    );
  });

  testWidgets('DT1 onTextField: renders label hint prefix and suffix icons', (
    tester,
  ) async {
    const fieldKey = ValueKey('text-field-label-icons');

    await _pumpLayoutWidget(
      tester,
      const MxTextField(
        key: fieldKey,
        label: 'Email',
        hintText: 'name@example.com',
        prefixIcon: Icons.mail_outline,
        suffixIcon: Icon(Icons.check_circle_outline),
      ),
    );

    final decoration = _sharedTextField(tester, fieldKey).decoration!;

    expect(decoration.labelText, 'Email');
    expect(decoration.hintText, 'name@example.com');
    expect(decoration.prefixIcon, isA<Icon>());
    expect(decoration.suffixIcon, isA<Icon>());
    expect(
      find.descendant(
        of: find.byKey(fieldKey),
        matching: find.byIcon(Icons.mail_outline),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(fieldKey),
        matching: find.byIcon(Icons.check_circle_outline),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DT2 onTextField: updates controller and callbacks on input', (
    tester,
  ) async {
    const fieldKey = ValueKey('text-field-input');
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var changedValue = '';
    var submittedValue = '';

    await _pumpLayoutWidget(
      tester,
      MxTextField(
        key: fieldKey,
        label: 'Answer',
        controller: controller,
        textInputAction: TextInputAction.done,
        onChanged: (value) => changedValue = value,
        onSubmitted: (value) => submittedValue = value,
      ),
    );

    await tester.enterText(find.byKey(fieldKey), 'kanji');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(controller.text, 'kanji');
    expect(changedValue, 'kanji');
    expect(submittedValue, 'kanji');
  });

  testWidgets('DT3 onTextField: resolves error and border theme states', (
    tester,
  ) async {
    const fieldKey = ValueKey('text-field-error');

    await _pumpLayoutWidget(
      tester,
      const MxTextField(
        key: fieldKey,
        label: 'Password',
        errorText: 'Password is required',
      ),
    );

    final context = tester.element(find.byKey(fieldKey));
    final scheme = Theme.of(context).colorScheme;
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final decoration = _sharedTextField(tester, fieldKey).decoration!;
    final focusedBorder = _outlineInputBorder(inputTheme.focusedBorder);
    final errorBorder = _outlineInputBorder(inputTheme.errorBorder);
    final focusedErrorBorder = _outlineInputBorder(
      inputTheme.focusedErrorBorder,
    );

    expect(decoration.errorText, 'Password is required');
    expect(find.text('Password is required'), findsOneWidget);
    expect(focusedBorder.borderRadius, AppRadius.input);
    expect(focusedBorder.borderSide.color, scheme.primary);
    expect(focusedBorder.borderSide.width, 2);
    expect(errorBorder.borderRadius, AppRadius.input);
    expect(errorBorder.borderSide.color, scheme.error);
    expect(errorBorder.borderSide.width, 1);
    expect(focusedErrorBorder.borderRadius, AppRadius.input);
    expect(focusedErrorBorder.borderSide.color, scheme.error);
    expect(focusedErrorBorder.borderSide.width, 2);
  });

  testWidgets('DT4 onTextField: configures disabled and read only states', (
    tester,
  ) async {
    const disabledKey = ValueKey('text-field-disabled');
    const readOnlyKey = ValueKey('text-field-readonly');
    final disabledFocus = FocusNode();
    final readOnlyFocus = FocusNode();
    addTearDown(disabledFocus.dispose);
    addTearDown(readOnlyFocus.dispose);

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxTextField(
            key: disabledKey,
            label: 'Disabled',
            enabled: false,
            focusNode: disabledFocus,
          ),
          const MxGap(AppSpacing.md),
          MxTextField(
            key: readOnlyKey,
            label: 'Read only',
            readOnly: true,
            focusNode: readOnlyFocus,
          ),
        ],
      ),
    );

    await tester.tap(find.byKey(disabledKey));
    await tester.pump();
    expect(disabledFocus.hasFocus, isFalse);
    expect(_sharedTextField(tester, disabledKey).enabled, isFalse);

    await tester.tap(find.byKey(readOnlyKey));
    await tester.pump();
    expect(readOnlyFocus.hasFocus, isTrue);
    expect(_sharedTextField(tester, readOnlyKey).readOnly, isTrue);
  });

  testWidgets('DT5 onTextField: clears search field content', (tester) async {
    const searchKey = ValueKey('text-field-search-clear');
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var changedValue = '';
    var clearCalls = 0;

    await _pumpLayoutWidget(
      tester,
      MxSearchField(
        key: searchKey,
        controller: controller,
        hintText: 'Search cards',
        onChanged: (value) => changedValue = value,
        onClear: () => clearCalls++,
      ),
    );

    await tester.enterText(find.byKey(searchKey), 'deck');
    await tester.pump();
    expect(controller.text, 'deck');
    expect(changedValue, 'deck');
    expect(
      find.descendant(
        of: find.byKey(searchKey),
        matching: find.byIcon(Icons.close),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(searchKey),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changedValue, isEmpty);
    expect(clearCalls, 1);
  });

  testWidgets('DT6 onTextField: passes password keyboard and action config', (
    tester,
  ) async {
    const fieldKey = ValueKey('text-field-password-config');

    await _pumpLayoutWidget(
      tester,
      const MxTextField(
        key: fieldKey,
        label: 'Password',
        obscureText: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        maxLines: 3,
      ),
    );

    final textField = _sharedTextField(tester, fieldKey);

    expect(textField.obscureText, isTrue);
    expect(textField.maxLines, 1);
    expect(textField.keyboardType, TextInputType.emailAddress);
    expect(textField.textInputAction, TextInputAction.next);
  });

  testWidgets('DT7 onTextField: uses token padding and material height', (
    tester,
  ) async {
    const fieldKey = ValueKey('text-field-padding-height');

    await _pumpLayoutWidget(
      tester,
      const MxTextField(key: fieldKey, label: 'Deck name'),
    );

    final inputTheme = Theme.of(
      tester.element(find.byKey(fieldKey)),
    ).inputDecorationTheme;

    expect(
      tester.getSize(find.byKey(fieldKey)).height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
    );
    expect(
      inputTheme.contentPadding,
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  });

  testWidgets('DT8 onTextField: handles long text on compact width', (
    tester,
  ) async {
    const fieldKey = ValueKey('text-field-long-content');
    const longText =
        'A very long answer should stay inside the shared text field layout '
        'without forcing compact screens to overflow horizontally.';
    final controller = TextEditingController(text: longText);
    addTearDown(controller.dispose);

    await _pumpLayoutWidget(
      tester,
      SizedBox(
        width: 160, // guard:raw-size-reviewed compact text field fixture width
        child: MxTextField(
          key: fieldKey,
          label: 'Long answer',
          controller: controller,
          maxLines: 3,
        ),
      ),
      scenario: const _RenderScenario(
        label: 'text-field-long-content',
        surfaceSize: Size(320, 568),
      ),
    );

    expect(find.byKey(fieldKey), findsOneWidget);
    expect(controller.text, longText);
  });

  testWidgets('DT1 onDialog: opens dialog and invokes action callbacks', (
    tester,
  ) async {
    const openKey = ValueKey('dialog-open');
    const primaryKey = ValueKey('dialog-primary');
    const secondaryKey = ValueKey('dialog-secondary');
    var primaryCalls = 0;
    var secondaryCalls = 0;

    await _pumpLayoutWidget(
      tester,
      Builder(
        builder: (context) {
          return MxPrimaryButton(
            key: openKey,
            label: 'Open dialog',
            onPressed: () {
              MxDialog.show<String>(
                context: context,
                title: 'Delete deck',
                child: const Text('This action removes the selected deck.'),
                actions: [
                  Builder(
                    builder: (dialogContext) => MxSecondaryButton(
                      key: secondaryKey,
                      label: 'Cancel',
                      onPressed: () {
                        secondaryCalls++;
                        Navigator.of(dialogContext).pop('cancel');
                      },
                    ),
                  ),
                  Builder(
                    builder: (dialogContext) => MxPrimaryButton(
                      key: primaryKey,
                      label: 'Delete',
                      onPressed: () {
                        primaryCalls++;
                        Navigator.of(dialogContext).pop('delete');
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    expect(find.text('Delete deck'), findsOneWidget);
    expect(find.text('This action removes the selected deck.'), findsOneWidget);

    await tester.tap(find.byKey(primaryKey));
    await tester.pumpAndSettle();
    expect(primaryCalls, 1);
    expect(find.text('Delete deck'), findsNothing);

    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(secondaryKey));
    await tester.pumpAndSettle();

    expect(secondaryCalls, 1);
    expect(find.text('Delete deck'), findsNothing);
  });

  testWidgets('DT2 onDialog: respects dialog barrier dismiss setting', (
    tester,
  ) async {
    const openLockedKey = ValueKey('dialog-open-locked');
    const openDismissibleKey = ValueKey('dialog-open-dismissible');
    const closeLockedKey = ValueKey('dialog-close-locked');

    await _pumpLayoutWidget(
      tester,
      Builder(
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxPrimaryButton(
                key: openLockedKey,
                label: 'Open locked dialog',
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Locked dialog',
                    barrierDismissible: false,
                    child: const Text('Barrier taps should do nothing.'),
                    actions: [
                      Builder(
                        builder: (dialogContext) => MxSecondaryButton(
                          key: closeLockedKey,
                          label: 'Close',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const MxGap(AppSpacing.md),
              MxPrimaryButton(
                key: openDismissibleKey,
                label: 'Open dismissible dialog',
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Dismissible dialog',
                    child: const Text('Barrier taps should close this dialog.'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    await tester.tap(find.byKey(openLockedKey));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Locked dialog'), findsOneWidget);

    await tester.tap(find.byKey(closeLockedKey));
    await tester.pumpAndSettle();
    expect(find.text('Locked dialog'), findsNothing);

    await tester.tap(find.byKey(openDismissibleKey));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Dismissible dialog'), findsNothing);
  });

  testWidgets('DT3 onDialog: opens bottom sheet and invokes controls', (
    tester,
  ) async {
    const openKey = ValueKey('sheet-open');
    const primaryKey = ValueKey('sheet-primary');
    const secondaryKey = ValueKey('sheet-secondary');
    const closeKey = ValueKey('sheet-close');
    var primaryCalls = 0;
    var secondaryCalls = 0;
    var closeCalls = 0;

    await _pumpLayoutWidget(
      tester,
      Builder(
        builder: (context) {
          return MxPrimaryButton(
            key: openKey,
            label: 'Open sheet',
            onPressed: () {
              MxBottomSheet.show<String>(
                context: context,
                title: 'Move cards',
                trailing: Builder(
                  builder: (sheetContext) => IconButton(
                    key: closeKey,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      closeCalls++;
                      Navigator.of(sheetContext).pop('close');
                    },
                  ),
                ),
                child: Builder(
                  builder: (sheetContext) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Choose where these cards should move.'),
                      const MxGap(AppSpacing.md),
                      MxSecondaryButton(
                        key: secondaryKey,
                        label: 'Cancel',
                        onPressed: () {
                          secondaryCalls++;
                          Navigator.of(sheetContext).pop('cancel');
                        },
                      ),
                      const MxGap(AppSpacing.md),
                      MxPrimaryButton(
                        key: primaryKey,
                        label: 'Move',
                        onPressed: () {
                          primaryCalls++;
                          Navigator.of(sheetContext).pop('move');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    expect(find.text('Move cards'), findsOneWidget);
    expect(find.text('Choose where these cards should move.'), findsOneWidget);
    await tester.tap(find.byKey(primaryKey));
    await tester.pumpAndSettle();
    expect(primaryCalls, 1);

    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(secondaryKey));
    await tester.pumpAndSettle();
    expect(secondaryCalls, 1);

    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(closeKey));
    await tester.pumpAndSettle();
    expect(closeCalls, 1);
    expect(find.text('Move cards'), findsNothing);
  });

  testWidgets('DT4 onDialog: respects bottom sheet barrier dismiss setting', (
    tester,
  ) async {
    const openLockedKey = ValueKey('sheet-open-locked');
    const openDismissibleKey = ValueKey('sheet-open-dismissible');
    const closeLockedKey = ValueKey('sheet-close-locked');

    await _pumpLayoutWidget(
      tester,
      Builder(
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxPrimaryButton(
                key: openLockedKey,
                label: 'Open locked sheet',
                onPressed: () {
                  MxBottomSheet.show<void>(
                    context: context,
                    title: 'Locked sheet',
                    isDismissible: false,
                    enableDrag: false,
                    trailing: Builder(
                      builder: (sheetContext) => IconButton(
                        key: closeLockedKey,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                    child: const Text('Barrier taps should do nothing.'),
                  );
                },
              ),
              const MxGap(AppSpacing.md),
              MxPrimaryButton(
                key: openDismissibleKey,
                label: 'Open dismissible sheet',
                onPressed: () {
                  MxBottomSheet.show<void>(
                    context: context,
                    title: 'Dismissible sheet',
                    child: const Text('Barrier taps should close this sheet.'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    await tester.tap(find.byKey(openLockedKey));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Locked sheet'), findsOneWidget);

    await tester.tap(find.byKey(closeLockedKey));
    await tester.pumpAndSettle();
    expect(find.text('Locked sheet'), findsNothing);

    await tester.tap(find.byKey(openDismissibleKey));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Dismissible sheet'), findsNothing);
  });

  testWidgets('DT5 onDialog: uses dialog and sheet token geometry', (
    tester,
  ) async {
    const dialogKey = ValueKey('dialog-geometry');
    const sheetKey = ValueKey('sheet-geometry');

    await _pumpLayoutWidget(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxDialog(key: dialogKey, title: 'Geometry', child: Text('Dialog')),
          MxGap(AppSpacing.lg),
          SizedBox(
            height: 220, // guard:raw-size-reviewed bounded sheet fixture
            child: MxBottomSheet(
              key: sheetKey,
              title: 'Geometry sheet',
              child: Text('Sheet'),
            ),
          ),
        ],
      ),
      scrollableHost: false,
    );

    final theme = Theme.of(tester.element(find.byKey(dialogKey)));
    final dialogShape = theme.dialogTheme.shape;
    final sheetShape = theme.bottomSheetTheme.shape;
    final dialogPaddings = _paddingValues(tester, dialogKey);
    final sheetPaddings = _paddingValues(tester, sheetKey);

    expect(dialogPaddings, contains(const EdgeInsets.all(AppSpacing.xxl)));
    expect(sheetPaddings, contains(AppSpacing.sheet));
    expect(dialogShape, isA<RoundedRectangleBorder>());
    expect(
      (dialogShape! as RoundedRectangleBorder).borderRadius,
      AppRadius.dialog,
    );
    expect(sheetShape, isA<RoundedRectangleBorder>());
    expect(
      (sheetShape! as RoundedRectangleBorder).borderRadius,
      AppRadius.bottomSheet,
    );
  });

  testWidgets('DT6 onDialog: scrolls long dialog content', (tester) async {
    const dialogKey = ValueKey('dialog-long-content');

    await _pumpLayoutWidget(
      tester,
      MxDialog(
        key: dialogKey,
        title: 'Long dialog',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _longContentRows('Dialog row', 40),
        ),
      ),
      scenario: const _RenderScenario(
        label: 'dialog-long-content',
        surfaceSize: Size(320, 420),
      ),
      scrollableHost: false,
    );

    final scrollable = _scrollableInside(dialogKey);
    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    await tester.drag(scrollable, const Offset(0, -180));
    await tester.pump();
    final after = tester.state<ScrollableState>(scrollable).position.pixels;

    expect(find.byKey(dialogKey), findsOneWidget);
    expect(after, greaterThan(before));
  });

  testWidgets('DT7 onDialog: scrolls long bottom sheet content', (
    tester,
  ) async {
    const sheetKey = ValueKey('sheet-long-content');

    await _pumpLayoutWidget(
      tester,
      MxBottomSheet(
        key: sheetKey,
        title: 'Long sheet',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _longContentRows('Sheet row', 40),
        ),
      ),
      scenario: const _RenderScenario(
        label: 'sheet-long-content',
        surfaceSize: Size(320, 420),
      ),
      scrollableHost: false,
    );

    final scrollable = _scrollableInside(sheetKey);
    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    await tester.drag(scrollable, const Offset(0, -180));
    await tester.pump();
    final after = tester.state<ScrollableState>(scrollable).position.pixels;

    expect(find.byKey(sheetKey), findsOneWidget);
    expect(after, greaterThan(before));
  });

  testWidgets('DT8 onDialog: lifts bottom sheet above keyboard insets', (
    tester,
  ) async {
    const sheetKey = ValueKey('sheet-keyboard');
    const inputKey = ValueKey('sheet-keyboard-input');
    const keyboardInset = 240.0;

    await _pumpLayoutWidget(
      tester,
      const MediaQuery(
        data: MediaQueryData(
          size: Size(390, 600),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: MxBottomSheet(
          key: sheetKey,
          title: 'Rename deck',
          child: MxTextField(key: inputKey, label: 'Deck name'),
        ),
      ),
      scenario: const _RenderScenario(
        label: 'sheet-keyboard',
        surfaceSize: Size(390, 600),
      ),
      scrollableHost: false,
    );

    final animatedPadding = tester.widget<AnimatedPadding>(
      find.descendant(
        of: find.byKey(sheetKey),
        matching: find.byType(AnimatedPadding),
      ),
    );

    expect(
      animatedPadding.padding,
      const EdgeInsets.only(bottom: keyboardInset),
    );
    expect(find.byKey(inputKey), findsOneWidget);
  });

  testWidgets('DT1 onState: renders normal data state', (tester) async {
    const stateKey = ValueKey('state-normal-retained');

    await _pumpLayoutWidget(
      tester,
      MxRetainedAsyncState<String>(
        key: stateKey,
        data: 'Ready',
        isLoading: false,
        dataBuilder: (_, data) => Text('Data: $data'),
      ),
    );

    expect(find.text('Data: Ready'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(stateKey),
        matching: find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(stateKey),
        matching: find.byType(MxErrorState),
      ),
      findsNothing,
    );
  });

  testWidgets('DT2 onState: renders loading and retained refresh states', (
    tester,
  ) async {
    const loadingKey = ValueKey('state-loading');
    const retainedKey = ValueKey('state-retained-loading');

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MxLoadingState(key: loadingKey, message: 'Loading cards'),
          const MxGap(AppSpacing.lg),
          MxRetainedAsyncState<String>(
            key: retainedKey,
            data: 'Cached cards',
            isLoading: true,
            dataBuilder: (_, data) => Text(data),
          ),
        ],
      ),
    );

    expect(find.text('Loading cards'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(loadingKey),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.text('Cached cards'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(retainedKey),
        matching: find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DT3 onState: renders disabled controls as non-interactive', (
    tester,
  ) async {
    const buttonKey = ValueKey('state-disabled-button');
    const answerKey = ValueKey('state-disabled-answer');

    await _pumpLayoutWidget(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxPrimaryButton(key: buttonKey, label: 'Continue', onPressed: null),
          MxGap(AppSpacing.md),
          MxAnswerOptionCard(
            key: answerKey,
            label: 'Unavailable answer',
            enabled: false,
            onPressed: _noop,
          ),
        ],
      ),
    );

    final button = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(ElevatedButton),
      ),
    );

    expect(button.onPressed, isNull);
    expect(find.text('Unavailable answer'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(answerKey),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });

  testWidgets('DT4 onState: renders error state with details branch', (
    tester,
  ) async {
    const errorKey = ValueKey('state-error');
    const details = 'Stack trace hidden until requested';

    await _pumpLayoutWidget(
      tester,
      MxErrorState(
        key: errorKey,
        title: 'Could not load',
        message: 'Try again later',
        details: details,
        retryLabel: 'Retry now',
        onRetry: _noop,
      ),
    );

    expect(find.text('Could not load'), findsOneWidget);
    expect(find.text('Try again later'), findsOneWidget);
    expect(find.text('Retry now'), findsOneWidget);
    expect(find.text(details), findsNothing);

    await tester.tap(
      find
          .descendant(
            of: find.byKey(errorKey),
            matching: find.byType(MxSecondaryButton),
          )
          .last,
    );
    await tester.pump();

    expect(find.text(details), findsOneWidget);
  });

  testWidgets('DT5 onState: renders empty state with optional action', (
    tester,
  ) async {
    const emptyKey = ValueKey('state-empty');

    await _pumpLayoutWidget(
      tester,
      const MxEmptyState(
        key: emptyKey,
        title: 'No cards yet',
        message: 'Create the first flashcard.',
        actionLabel: 'Create card',
        actionLeadingIcon: Icons.add,
        onAction: _noop,
      ),
    );

    expect(find.text('No cards yet'), findsOneWidget);
    expect(find.text('Create the first flashcard.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(emptyKey),
        matching: find.byIcon(Icons.inbox_outlined),
      ),
      findsOneWidget,
    );
    expect(find.text('Create card'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('DT6 onState: renders selected and unselected states', (
    tester,
  ) async {
    const selectedKey = ValueKey('state-selected-answer');
    const unselectedKey = ValueKey('state-unselected-answer');

    await _pumpLayoutWidget(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxAnswerOptionCard(
            key: selectedKey,
            label: 'Selected answer',
            selected: true,
          ),
          MxGap(AppSpacing.md),
          MxAnswerOptionCard(
            key: unselectedKey,
            label: 'Unselected answer',
            leadingIcon: Icons.radio_button_unchecked,
          ),
        ],
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(selectedKey),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(unselectedKey),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(unselectedKey),
        matching: find.byIcon(Icons.radio_button_unchecked),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DT7 onState: renders active and inactive states', (
    tester,
  ) async {
    const dotsKey = ValueKey('state-active-dots');

    await _pumpLayoutWidget(
      tester,
      MxPageDots(key: dotsKey, count: 3, activeIndex: 1, onDotTap: (_) {}),
    );

    final dotFinder = find.descendant(
      of: find.byKey(dotsKey),
      matching: find.byType(AnimatedContainer),
    );
    final widths = List<double>.generate(
      dotFinder.evaluate().length,
      (index) => tester.getSize(dotFinder.at(index)).width,
    );

    expect(widths, hasLength(3));
    expect(widths.where((width) => width == AppSpacing.sm), hasLength(1));
    expect(widths.where((width) => width == AppSpacing.xs), hasLength(2));
  });

  testWidgets('DT8 onState: preserves important size across state changes', (
    tester,
  ) async {
    const actionKey = ValueKey('state-size-study-action');
    late StateSetter updateState;
    var masteryPercent = 12;
    var cardCount = 9;

    await _pumpLayoutWidget(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          updateState = setState;
          return MxStudyProgressAction(
            key: actionKey,
            masteryPercent: masteryPercent,
            cardCount: cardCount,
            tooltip: 'Study',
            onPressed: _noop,
          );
        },
      ),
    );
    final before = tester.getSize(find.byKey(actionKey));

    updateState(() {
      masteryPercent = 100;
      cardCount = 120;
    });
    await tester.pump();
    final after = tester.getSize(find.byKey(actionKey));

    expect(after, before);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('DT9 onState: updates rendered UI after rebuild with new state', (
    tester,
  ) async {
    const stateKey = ValueKey('state-rebuild-retained');
    late StateSetter updateState;
    var data = 'Alpha';

    await _pumpLayoutWidget(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          updateState = setState;
          return MxRetainedAsyncState<String>(
            key: stateKey,
            data: data,
            isLoading: false,
            dataBuilder: (_, value) => Text('Current: $value'),
          );
        },
      ),
    );

    expect(find.text('Current: Alpha'), findsOneWidget);

    updateState(() => data = 'Beta');
    await tester.pump();

    expect(find.text('Current: Alpha'), findsNothing);
    expect(find.text('Current: Beta'), findsOneWidget);
  });

  testWidgets(
    'DT1 onFeedbackState: renders loading indicator message and token gap',
    (tester) async {
      const loadingKey = ValueKey('feedback-loading');

      await _pumpLayoutWidget(
        tester,
        const MxLoadingState(
          key: loadingKey,
          message: 'Preparing content',
          progressSize: MxProgressSize.large,
        ),
      );

      final indicatorFinder = find.descendant(
        of: find.byKey(loadingKey),
        matching: find.byType(CircularProgressIndicator),
      );

      expect(indicatorFinder, findsOneWidget);
      expect(tester.getSize(indicatorFinder), const Size(40, 40));
      expect(find.text('Preparing content'), findsOneWidget);
      expect(_gapSizes(tester, loadingKey), contains(AppSpacing.lg));
    },
  );

  testWidgets(
    'DT2 onFeedbackState: renders empty message illustration and centered text',
    (tester) async {
      const emptyKey = ValueKey('feedback-empty');

      await _pumpLayoutWidget(
        tester,
        const MxEmptyState(
          key: emptyKey,
          title: 'Nothing available',
          message: 'Use the action when content exists.',
          icon: Icons.search_off,
        ),
      );

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(emptyKey),
          matching: find.byIcon(Icons.search_off),
        ),
      );
      final illustrationFinder = find
          .descendant(
            of: find.byKey(emptyKey),
            matching: find.byType(Container),
          )
          .first;

      expect(find.text('Nothing available'), findsOneWidget);
      expect(find.text('Use the action when content exists.'), findsOneWidget);
      expect(
        _mxTextInside(tester, emptyKey, 'Nothing available').textAlign,
        TextAlign.center,
      );
      expect(
        _mxTextInside(
          tester,
          emptyKey,
          'Use the action when content exists.',
        ).textAlign,
        TextAlign.center,
      );
      expect(icon.size, AppIconSizes.xl);
      expect(
        tester.getSize(illustrationFinder),
        const Size(_stateIllustrationSize, _stateIllustrationSize),
      );
      expect(
        _gapSizes(tester, emptyKey),
        containsAll(<double>[AppSpacing.xl, AppSpacing.sm]),
      );
    },
  );

  testWidgets('DT3 onFeedbackState: renders error message and invokes retry', (
    tester,
  ) async {
    const errorKey = ValueKey('feedback-error');
    var retryCalls = 0;

    await _pumpLayoutWidget(
      tester,
      MxErrorState(
        key: errorKey,
        title: 'Action unavailable',
        message: 'Please try again.',
        retryLabel: 'Retry now',
        icon: Icons.warning_amber_outlined,
        onRetry: () => retryCalls++,
      ),
    );

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(errorKey),
        matching: find.byIcon(Icons.warning_amber_outlined),
      ),
    );

    expect(find.text('Action unavailable'), findsOneWidget);
    expect(find.text('Please try again.'), findsOneWidget);
    expect(
      _mxTextInside(tester, errorKey, 'Action unavailable').textAlign,
      TextAlign.center,
    );
    expect(
      _mxTextInside(tester, errorKey, 'Please try again.').textAlign,
      TextAlign.center,
    );
    expect(icon.size, AppIconSizes.xl);
    expect(
      _gapSizes(tester, errorKey),
      containsAll(<double>[AppSpacing.xl, AppSpacing.sm]),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(errorKey),
        matching: find.byType(MxSecondaryButton),
      ),
    );
    await tester.pump();

    expect(retryCalls, 1);
  });

  testWidgets(
    'DT4 onFeedbackState: keeps state content compact on small screens',
    (tester) async {
      final cases = <_LayoutCase>[
        _LayoutCase(
          'loading',
          (key) => MxLoadingState(key: key, message: 'Preparing content'),
        ),
        _LayoutCase(
          'empty',
          (key) => MxEmptyState(
            key: key,
            title: 'Nothing available',
            message: 'Use the action when content exists.',
          ),
        ),
        _LayoutCase(
          'error',
          (key) => MxErrorState(
            key: key,
            title: 'Action unavailable',
            message: 'Please try again.',
            retryLabel: 'Retry',
            onRetry: _noop,
          ),
        ),
      ];

      for (final entry in cases) {
        final key = ValueKey<String>('feedback-compact-${entry.name}');

        await _pumpLayoutWidget(
          tester,
          entry.build(key),
          scenario: _RenderScenario(
            label: 'feedback-compact-${entry.name}',
            surfaceSize: const Size(320, 360),
          ),
          scrollableHost: false,
        );

        expect(
          _stateContentColumnSize(tester, key).height,
          lessThanOrEqualTo(320),
          reason: entry.name,
        );
      }
    },
  );

  test('DT5 onFeedbackState: keeps state sources free of feature messages', () {
    final violations = <String>[];
    final featureMessagePattern = RegExp(
      r'\b(?:deck|decks|card|cards|flashcard|flashcards|review|reviews|study|folder|folders|session|srs)\b',
      caseSensitive: false,
    );

    for (final file in _sharedStateSourceFiles()) {
      final source = _stripComments(file.readAsStringSync());
      if (featureMessagePattern.hasMatch(source)) {
        violations.add(
          '${_relativePath(file)}: feature-specific state message',
        );
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  testWidgets(
    'DT1 onAccessibility: exposes semantics labels for icon only actions',
    (tester) async {
      final semantics = tester.ensureSemantics();
      const iconButtonKey = ValueKey('accessibility-icon-button');
      const speakButtonKey = ValueKey('accessibility-speak-button');

      try {
        await _pumpLayoutWidget(
          tester,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxIconButton(
                key: iconButtonKey,
                icon: Icons.search,
                tooltip: 'Search cards',
                onPressed: _noop,
              ),
              const MxGap(AppSpacing.md),
              MxSpeakButton(
                key: speakButtonKey,
                tooltip: 'Speak term',
                onPressed: _noop,
              ),
            ],
          ),
        );

        expect(find.bySemanticsLabel('Search cards'), findsAtLeastNWidgets(1));
        expect(find.bySemanticsLabel('Speak term'), findsAtLeastNWidgets(1));
      } finally {
        semantics.dispose();
      }
    },
  );

  test(
    'DT2 onAccessibility: keeps text contrast above accessibility floor',
    () {
      final themes = <String, ThemeData>{
        'light': AppTheme.light(),
        'dark': AppTheme.dark(),
      };

      for (final MapEntry(:key, :value) in themes.entries) {
        final scheme = value.colorScheme;
        final mx = value.extension<MxColorsExtension>()!;
        final pairs = <_ContrastPair>[
          _ContrastPair('onSurface/surface', scheme.onSurface, scheme.surface),
          _ContrastPair(
            'onSurfaceVariant/surface',
            scheme.onSurfaceVariant,
            scheme.surface,
            minimumRatio: _minimumSupportingTextContrast,
          ),
          _ContrastPair('onPrimary/primary', scheme.onPrimary, scheme.primary),
          _ContrastPair('onError/error', scheme.onError, scheme.error),
          _ContrastPair(
            'onErrorContainer/errorContainer',
            scheme.onErrorContainer,
            scheme.errorContainer,
          ),
          _ContrastPair(
            'onSecondaryContainer/secondaryContainer',
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
          ),
          _ContrastPair('onSuccess/success', mx.onSuccess, mx.success),
          _ContrastPair('onWarning/warning', mx.onWarning, mx.warning),
          _ContrastPair('onInfo/info', mx.onInfo, mx.info),
        ];

        for (final pair in pairs) {
          expect(
            _contrastRatio(pair.foreground, pair.background),
            greaterThanOrEqualTo(pair.minimumRatio),
            reason: '$key ${pair.name}',
          );
        }
      }
    },
  );

  testWidgets(
    'DT3 onAccessibility: keeps button and input touch targets material sized',
    (tester) async {
      final cases = <_HitAreaCase>[
        _HitAreaCase(
          'MxTextField',
          (key) => MxTextField(key: key, label: 'Answer'),
        ),
        _HitAreaCase(
          'MxSearchField',
          (key) => MxSearchField(key: key, hintText: 'Search'),
        ),
        _HitAreaCase(
          'MxPrimaryButton',
          (key) =>
              MxPrimaryButton(key: key, label: 'Continue', onPressed: _noop),
        ),
        _HitAreaCase(
          'MxIconButton',
          (key) => MxIconButton(
            key: key,
            icon: Icons.search,
            tooltip: 'Search',
            onPressed: _noop,
          ),
        ),
      ];

      for (final entry in cases) {
        final key = ValueKey<String>('accessibility-touch-${entry.name}');

        await _pumpLayoutWidget(tester, entry.build(key), maxWidth: 288);

        final size = tester.getSize(entry.finder(key));
        expect(
          size.height,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: entry.name,
        );
        expect(size.width, greaterThan(0), reason: entry.name);
      }
    },
  );

  testWidgets('DT4 onAccessibility: exposes non color state cues', (
    tester,
  ) async {
    const selectedKey = ValueKey('accessibility-selected-answer');
    const dotsKey = ValueKey('accessibility-active-dots');

    await _pumpLayoutWidget(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MxAnswerOptionCard(
            key: selectedKey,
            label: 'Selected answer',
            selected: true,
          ),
          const MxGap(AppSpacing.lg),
          MxPageDots(key: dotsKey, count: 3, activeIndex: 1),
        ],
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(selectedKey),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );

    final dotFinder = find.descendant(
      of: find.byKey(dotsKey),
      matching: find.byType(AnimatedContainer),
    );
    final widths = List<double>.generate(
      dotFinder.evaluate().length,
      (index) => tester.getSize(dotFinder.at(index)).width,
    );

    expect(widths.where((width) => width == AppSpacing.sm), hasLength(1));
    expect(widths.where((width) => width == AppSpacing.xs), hasLength(2));
  });

  testWidgets(
    'DT5 onAccessibility: keeps important widgets stable at text scale 1.2',
    (tester) async {
      for (final entry in _accessibilityTextScaleCases) {
        final key = ValueKey<String>('accessibility-scale-12-${entry.name}');

        await _pumpLayoutWidget(
          tester,
          entry.build(key),
          scenario: _RenderScenario(
            label: 'accessibility-scale-12-${entry.name}',
            textScaleFactor: 1.2,
            surfaceSize: const Size(320, 568),
          ),
          maxWidth: 288,
        );

        expect(find.byKey(key), findsOneWidget, reason: entry.name);
      }
    },
  );

  testWidgets(
    'DT6 onAccessibility: keeps important widgets acceptable at text scale 1.5',
    (tester) async {
      for (final entry in _accessibilityTextScaleCases) {
        final key = ValueKey<String>('accessibility-scale-15-${entry.name}');

        await _pumpLayoutWidget(
          tester,
          entry.build(key),
          scenario: _RenderScenario(
            label: 'accessibility-scale-15-${entry.name}',
            textScaleFactor: 1.5,
            surfaceSize: const Size(320, 568),
          ),
          maxWidth: 288,
        );

        expect(find.byKey(key), findsOneWidget, reason: entry.name);
      }
    },
  );

  testWidgets('DT7 onAccessibility: follows keyboard focus order', (
    tester,
  ) async {
    final fieldFocusNode = FocusNode();
    addTearDown(fieldFocusNode.dispose);
    const fieldKey = ValueKey('accessibility-focus-field');
    const primaryKey = ValueKey('accessibility-focus-primary');
    const secondaryKey = ValueKey('accessibility-focus-secondary');
    var primaryCalls = 0;
    var secondaryCalls = 0;

    await _pumpLayoutWidget(
      tester,
      FocusTraversalGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxTextField(
              key: fieldKey,
              label: 'Answer',
              focusNode: fieldFocusNode,
            ),
            const MxGap(AppSpacing.md),
            MxPrimaryButton(
              key: primaryKey,
              label: 'Continue',
              onPressed: () => primaryCalls++,
            ),
            const MxGap(AppSpacing.md),
            MxSecondaryButton(
              key: secondaryKey,
              label: 'Cancel',
              onPressed: () => secondaryCalls++,
            ),
          ],
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(fieldFocusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(primaryCalls, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(secondaryCalls, 1);
  });

  testWidgets(
    'DT8 onAccessibility: exposes primary content to screen readers',
    (tester) async {
      final semantics = tester.ensureSemantics();

      try {
        await _pumpLayoutWidget(
          tester,
          const MxEmptyState(
            title: 'No cards yet',
            message: 'Create the first flashcard.',
            actionLabel: 'Create card',
            onAction: _noop,
          ),
        );

        expect(find.bySemanticsLabel('No cards yet'), findsAtLeastNWidgets(1));
        expect(
          find.bySemanticsLabel('Create the first flashcard.'),
          findsAtLeastNWidgets(1),
        );
        expect(find.bySemanticsLabel('Create card'), findsAtLeastNWidgets(1));
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('DT1 onResponsive: renders important widgets at compact widths', (
    tester,
  ) async {
    const widths = <double>[320, 360, 390, 430];

    for (final width in widths) {
      for (final entry in _responsiveWidthCases) {
        final key = ValueKey<String>(
          'responsive-width-${width.round()}-${entry.name}',
        );

        await _pumpLayoutWidget(
          tester,
          entry.build(key),
          scenario: _RenderScenario(
            label: 'responsive-width-${width.round()}-${entry.name}',
            surfaceSize: Size(width, 700),
          ),
          maxWidth: width - (AppSpacing.lg * 2),
        );

        expect(find.byKey(key), findsOneWidget, reason: entry.name);
      }
    }
  });

  test('DT2 onResponsive: rejects unreviewed fixed dynamic heights', () {
    final violations = <String>[];

    for (final file in _sharedWidgetSourceFiles()) {
      final source = file.readAsStringSync();
      violations.addAll(
        _findUnreviewedFixedAxisDimensions(file, source, 'height'),
      );
      violations.addAll(
        _findUnreviewedFixedAxisDimensions(file, source, 'minHeight'),
      );
      violations.addAll(
        _findUnreviewedFixedAxisDimensions(file, source, 'maxHeight'),
      );
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('DT3 onResponsive: rejects unreviewed fixed main layout widths', () {
    final violations = <String>[];

    for (final file in _sharedWidgetSourceFiles()) {
      final source = file.readAsStringSync();
      final strippedSource = _stripComments(source);
      violations.addAll(
        _findUnreviewedFixedAxisDimensions(file, source, 'width'),
      );
      violations.addAll(
        _findUnreviewedFixedAxisDimensions(file, source, 'minWidth'),
      );
      violations.addAll(
        _findUnreviewedFixedAxisDimensions(file, source, 'maxWidth'),
      );
      violations.addAll(_findArbitraryViewportScaling(file, strippedSource));
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  testWidgets(
    'DT4 onResponsive: keeps long data from overflowing at width 320',
    (tester) async {
      for (final entry in _responsiveLongDataCases) {
        final key = ValueKey<String>('responsive-long-320-${entry.name}');

        await _pumpLayoutWidget(
          tester,
          entry.build(key),
          scenario: _RenderScenario(
            label: 'responsive-long-320-${entry.name}',
            surfaceSize: const Size(320, 700),
          ),
          maxWidth: 288,
        );

        expect(find.byKey(key), findsOneWidget, reason: entry.name);
      }
    },
  );

  testWidgets(
    'DT5 onResponsive: preserves compact hierarchy for important content',
    (tester) async {
      const tileKey = ValueKey('responsive-hierarchy-study-set');
      const title = 'Deck title priority line';
      const metaLine = '120 cards due today';

      await _pumpLayoutWidget(
        tester,
        const MxStudySetTile(
          key: tileKey,
          title: title,
          icon: Icons.style_outlined,
          metaLine: metaLine,
          ownerInitials: 'MX',
          ownerLabel: 'MemoX',
          onTap: _noop,
        ),
        scenario: const _RenderScenario(
          label: 'responsive-hierarchy',
          surfaceSize: Size(320, 700),
        ),
        maxWidth: 288,
      );

      final iconLeft = tester.getTopLeft(find.byIcon(Icons.style_outlined)).dx;
      final titleTopLeft = tester.getTopLeft(find.text(title));
      final metaTopLeft = tester.getTopLeft(find.text(metaLine));

      expect(iconLeft, lessThan(titleTopLeft.dx));
      expect(titleTopLeft.dy, lessThan(metaTopLeft.dy));
      expect(find.text(title), findsOneWidget);
      expect(find.text(metaLine), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onGolden: matches normal shared widget golden in light theme',
    (tester) async {
      await _expectGoldenMatches(
        tester,
        _buildNormalGoldenContent(),
        'goldens/shared_widget_normal_light.png',
      );
    },
  );

  testWidgets('DT2 onGolden: matches important state golden in light theme', (
    tester,
  ) async {
    await _expectGoldenMatches(
      tester,
      _buildStateGoldenContent(),
      'goldens/shared_widget_states_light.png',
    );
  });

  testWidgets(
    'DT3 onGolden: matches normal shared widget golden in dark theme',
    (tester) async {
      await _expectGoldenMatches(
        tester,
        _buildNormalGoldenContent(),
        'goldens/shared_widget_normal_dark.png',
        themeMode: ThemeMode.dark,
      );
    },
  );

  testWidgets(
    'DT4 onGolden: matches mobile text scale golden with deterministic data',
    (tester) async {
      await _expectGoldenMatches(
        tester,
        _buildTextScaleGoldenContent(),
        'goldens/shared_widget_text_scale_12.png',
        textScaleFactor: 1.2,
      );
    },
  );

  test('DT5 onGolden: rejects nondeterministic golden inputs', () {
    final violations = _findGoldenNondeterminism();

    expect(_goldenTickerModeEnabled, isFalse);
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('DT1 onMinimumCoverage: catalogs every shared widget render test', () {
    final classNames = _sharedWidgetClassNames();
    final catalogNames = _sharedWidgetCatalogNames();

    expect(
      _missingCoverage(classNames, catalogNames),
      isEmpty,
      reason: 'Missing render catalog entries',
    );
    expect(
      _missingCoverage(catalogNames, classNames),
      isEmpty,
      reason: 'Stale render catalog entries',
    );
  });

  test(
    'DT2 onMinimumCoverage: registers interaction tests for callback widgets',
    () {
      expect(
        _missingCoverage(
          _widgetsRequiringInteractionCoverage,
          _interactionCoverageWidgetNames(),
        ),
        isEmpty,
      );
    },
  );

  test('DT3 onMinimumCoverage: registers state variant tests', () {
    expect(
      _missingCoverage(
        _widgetsRequiringStateCoverage,
        _stateCoverageWidgetNames(),
      ),
      isEmpty,
    );
  });

  test('DT4 onMinimumCoverage: covers layout and theme contracts', () {
    final catalogNames = _sharedWidgetCatalogNames();

    expect(
      _missingCoverage(catalogNames, _layoutCoverageWidgetNames()),
      isEmpty,
    );
    expect(
      _missingCoverage(catalogNames, _themeCoverageWidgetNames()),
      isEmpty,
    );
  });

  test(
    'DT5 onMinimumCoverage: registers accessibility coverage for semantic widgets',
    () {
      expect(
        _missingCoverage(
          _widgetsRequiringAccessibilityCoverage,
          _accessibilityCoverageWidgetNames(),
        ),
        isEmpty,
      );
    },
  );

  test('DT6 onMinimumCoverage: registers golden coverage for primitives', () {
    expect(
      _missingCoverage(
        _widgetsRequiringGoldenCoverage,
        _goldenCoverageWidgetNames,
      ),
      isEmpty,
    );
  });

  test(
    'DT1 inspectSource: rejects feature data provider and infrastructure coupling',
    () {
      final violations = <String>[];
      final rules = <_SourceRule>[
        _SourceRule(
          'feature import',
          RegExp(r"import\s+'package:memox/presentation/features/"),
        ),
        _SourceRule('data import', RegExp(r"import\s+'package:memox/data/")),
        _SourceRule(
          'domain use case or repository import',
          RegExp(r"import\s+'package:memox/domain/(?:usecases|repositories)/"),
        ),
        _SourceRule('Riverpod widget dependency', RegExp(r'flutter_riverpod')),
        _SourceRule(
          'Riverpod consumer type',
          RegExp(r'\b(?:ConsumerWidget|ConsumerStatefulWidget|WidgetRef)\b'),
        ),
        _SourceRule('Riverpod ref access', RegExp(r'\bref\.(?:read|watch)\b')),
        _SourceRule(
          'repository or use case reference',
          RegExp(r'\b(?:Repository|UseCase|DataSource|Datasource)\b'),
        ),
        _SourceRule(
          'API or client construction',
          RegExp(r'\b(?:Dio|ApiClient|SharedPreferences)\b|\bClient\s*\('),
        ),
      ];

      for (final file in _sharedWidgetSourceFiles()) {
        final source = _stripComments(file.readAsStringSync());
        for (final rule in rules) {
          if (rule.pattern.hasMatch(source)) {
            violations.add('${_relativePath(file)}: ${rule.label}');
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );

  test(
    'DT2 inspectSource: rejects raw color spacing radius and typography primitives',
    () {
      final violations = <String>[];
      final rules = <_SourceRule>[
        _SourceRule(
          'raw color',
          RegExp(r'\bColors\.|\bColor\s*\(\s*0x|Color\.from(?:ARGB|RGBO)'),
        ),
        _SourceRule(
          'raw text style or font size',
          RegExp(r'\bTextStyle\s*\(|\bfontSize\s*:\s*\d'),
        ),
        _SourceRule(
          'raw radius factory',
          RegExp(r'\b(?:BorderRadius|Radius)\.circular\s*\('),
        ),
      ];

      for (final file in _sharedWidgetSourceFiles()) {
        final source = _stripComments(file.readAsStringSync());
        for (final rule in rules) {
          if (rule.pattern.hasMatch(source)) {
            violations.add('${_relativePath(file)}: ${rule.label}');
          }
        }
        violations.addAll(_findRawEdgeInsets(file, source));
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );
}

Future<void> _pumpCatalogEntry(
  WidgetTester tester,
  _SharedWidgetCase entry,
  _CatalogVariant variant, {
  _RenderScenario scenario = const _RenderScenario(label: 'default'),
}) async {
  final key = ValueKey<String>(
    'shared-widget-${scenario.label}-${entry.name}-${variant.name}',
  );
  await _pumpEntryWithKey(tester, entry, variant, key, scenario: scenario);
}

Future<Size?> _pumpEntryWithKey(
  WidgetTester tester,
  _SharedWidgetCase entry,
  _CatalogVariant variant,
  Key key, {
  _RenderScenario scenario = const _RenderScenario(label: 'default'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = scenario.surfaceSize;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    _AppHarness(
      host: entry.host,
      scrollableHost: entry.scrollableHost,
      themeMode: scenario.themeMode,
      textScaleFactor: scenario.textScaleFactor,
      surfaceSize: scenario.surfaceSize,
      child: entry.build(variant, key),
    ),
  );
  await tester.pump();

  expect(
    tester.takeException(),
    isNull,
    reason: '${entry.name} ${variant.name} ${scenario.label}',
  );
  expect(
    find.byKey(key),
    findsOneWidget,
    reason: '${entry.name} ${variant.name} ${scenario.label}',
  );

  final renderObject = tester.renderObject(find.byKey(key));
  return renderObject is RenderBox ? renderObject.size : null;
}

enum _CatalogVariant { minimal, full }

enum _WidgetHost { scaffold, home }

typedef _SharedWidgetBuilder = Widget Function(Key key);

class _SharedWidgetCase {
  const _SharedWidgetCase({
    required this.name,
    required this.minimal,
    required this.full,
    this.host = _WidgetHost.scaffold,
    this.scrollableHost = true,
  });

  final String name;
  final _SharedWidgetBuilder minimal;
  final _SharedWidgetBuilder full;
  final _WidgetHost host;
  final bool scrollableHost;

  Widget build(_CatalogVariant variant, Key key) {
    return switch (variant) {
      _CatalogVariant.minimal => minimal(key),
      _CatalogVariant.full => full(key),
    };
  }
}

class _LayoutCase {
  const _LayoutCase(this.name, this.build);

  final String name;
  final _SharedWidgetBuilder build;
}

typedef _InteractionWidgetBuilder =
    Widget Function(Key key, VoidCallback onAction);

class _InteractionCase {
  const _InteractionCase(this.name, this.build);

  final String name;
  final _InteractionWidgetBuilder build;
}

class _HitAreaCase {
  const _HitAreaCase(this.name, this.build, {this.targetFinder});

  final String name;
  final _SharedWidgetBuilder build;
  final Finder Function(Key key)? targetFinder;

  Finder finder(Key key) => targetFinder?.call(key) ?? find.byKey(key);
}

class _ContrastPair {
  const _ContrastPair(
    this.name,
    this.foreground,
    this.background, {
    this.minimumRatio = _minimumNormalTextContrast,
  });

  final String name;
  final Color foreground;
  final Color background;
  final double minimumRatio;
}

class _RenderScenario {
  const _RenderScenario({
    required this.label,
    this.themeMode = ThemeMode.light,
    this.textScaleFactor = 1,
    this.surfaceSize = const Size(390, 800),
  });

  final String label;
  final ThemeMode themeMode;
  final double textScaleFactor;
  final Size surfaceSize;
}

Future<void> _pumpLayoutWidget(
  WidgetTester tester,
  Widget child, {
  _RenderScenario scenario = const _RenderScenario(label: 'layout'),
  double? maxWidth,
  bool scrollableHost = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = scenario.surfaceSize;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    _AppHarness(
      host: _WidgetHost.scaffold,
      scrollableHost: scrollableHost,
      themeMode: scenario.themeMode,
      textScaleFactor: scenario.textScaleFactor,
      surfaceSize: scenario.surfaceSize,
      child: maxWidth == null ? child : SizedBox(width: maxWidth, child: child),
    ),
  );
  await tester.pump();

  expect(tester.takeException(), isNull, reason: scenario.label);
}

Icon _buttonIcon(WidgetTester tester, Key key, IconData icon) {
  return tester.widget<Icon>(
    find.descendant(of: find.byKey(key), matching: find.byIcon(icon)),
  );
}

List<double> _buttonGapSizes(WidgetTester tester, Key key) {
  return _gapSizes(tester, key);
}

List<double> _gapSizes(WidgetTester tester, Key key) {
  return tester
      .widgetList<MxGap>(
        find.descendant(of: find.byKey(key), matching: find.byType(MxGap)),
      )
      .map((gap) => gap.size)
      .toList();
}

MxText _mxTextInside(WidgetTester tester, Key key, String data) {
  return tester.widget<MxText>(
    find.descendant(
      of: find.byKey(key),
      matching: find.byWidgetPredicate(
        (widget) => widget is MxText && widget.data == data,
      ),
    ),
  );
}

Size _stateContentColumnSize(WidgetTester tester, Key key) {
  return tester.getSize(
    find.descendant(of: find.byKey(key), matching: find.byType(Column)).first,
  );
}

ElevatedButton _elevatedButton(WidgetTester tester, Key key) {
  return tester.widget<ElevatedButton>(_elevatedButtonFinder(key));
}

OutlinedButton _outlinedButton(WidgetTester tester, Key key) {
  return tester.widget<OutlinedButton>(_outlinedButtonFinder(key));
}

IconButton _iconButton(WidgetTester tester, Key key) {
  return tester.widget<IconButton>(_iconButtonFinder(key));
}

Finder _elevatedButtonFinder(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(ElevatedButton),
  );
}

Finder _outlinedButtonFinder(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(OutlinedButton),
  );
}

Finder _filledButtonFinder(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(FilledButton),
  );
}

Finder _textButtonFinder(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextButton),
  );
}

Finder _iconButtonFinder(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(IconButton),
  );
}

void _expectSharedButtonStyle(
  ButtonStyle? style,
  EdgeInsetsGeometry expectedPadding,
  String reason,
) {
  final states = <WidgetState>{};
  expect(style, isNotNull, reason: reason);
  final resolvedStyle = style!;
  expect(
    resolvedStyle.minimumSize?.resolve(states)?.height,
    greaterThanOrEqualTo(kMinInteractiveDimension),
    reason: reason,
  );
  expect(
    resolvedStyle.padding?.resolve(states),
    expectedPadding,
    reason: reason,
  );

  final shape = resolvedStyle.shape?.resolve(states);
  expect(shape, isA<RoundedRectangleBorder>(), reason: reason);
  expect(
    (shape! as RoundedRectangleBorder).borderRadius,
    AppRadius.button,
    reason: reason,
  );
  expect(
    resolvedStyle.textStyle?.resolve(states),
    AppTypography.labelLarge,
    reason: reason,
  );
}

class _ButtonStyleCase {
  const _ButtonStyleCase({
    required this.name,
    required this.build,
    required this.findButton,
    required this.style,
    required this.expectedPadding,
  });

  final String name;
  final _SharedWidgetBuilder build;
  final Finder Function(Key key) findButton;
  final ButtonStyle? Function(WidgetTester tester, Finder finder) style;
  final EdgeInsetsGeometry expectedPadding;
}

final List<_ButtonStyleCase> _buttonStyleCases = [
  _ButtonStyleCase(
    name: 'MxPrimaryButton',
    build: (key) =>
        MxPrimaryButton(key: key, label: 'Continue', onPressed: _noop),
    findButton: _elevatedButtonFinder,
    style: (tester, finder) => tester.widget<ElevatedButton>(finder).style,
    expectedPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    ),
  ),
  _ButtonStyleCase(
    name: 'MxSecondaryButton.outlined',
    build: (key) =>
        MxSecondaryButton(key: key, label: 'Cancel', onPressed: _noop),
    findButton: _outlinedButtonFinder,
    style: (tester, finder) => tester.widget<OutlinedButton>(finder).style,
    expectedPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    ),
  ),
  _ButtonStyleCase(
    name: 'MxSecondaryButton.tonal',
    build: (key) => MxSecondaryButton(
      key: key,
      label: 'Maybe',
      variant: MxSecondaryVariant.tonal,
      onPressed: _noop,
    ),
    findButton: _filledButtonFinder,
    style: (tester, finder) => tester.widget<FilledButton>(finder).style,
    expectedPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    ),
  ),
  _ButtonStyleCase(
    name: 'MxSecondaryButton.text',
    build: (key) => MxSecondaryButton(
      key: key,
      label: 'Skip',
      variant: MxSecondaryVariant.text,
      onPressed: _noop,
    ),
    findButton: _textButtonFinder,
    style: (tester, finder) => tester.widget<TextButton>(finder).style,
    expectedPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  ),
];

Finder _cardFinder(Key key) {
  return find.descendant(of: find.byKey(key), matching: find.byType(Card));
}

Card _materialCard(WidgetTester tester, Key key) {
  return tester.widget<Card>(_cardFinder(key));
}

RoundedRectangleBorder _cardShape(Card card) {
  final shape = card.shape;
  expect(shape, isA<RoundedRectangleBorder>());
  return shape! as RoundedRectangleBorder;
}

class _CardVisualCase {
  const _CardVisualCase({
    required this.name,
    required this.variant,
    required this.elevation,
  });

  final String name;
  final MxCardVariant variant;
  final double elevation;
}

const List<_CardVisualCase> _cardVisualCases = [
  _CardVisualCase(
    name: 'filled',
    variant: MxCardVariant.filled,
    elevation: AppElevation.card,
  ),
  _CardVisualCase(
    name: 'elevated',
    variant: MxCardVariant.elevated,
    elevation: AppElevation.cardRaised,
  ),
  _CardVisualCase(
    name: 'outlined',
    variant: MxCardVariant.outlined,
    elevation: AppElevation.card,
  ),
];

TextField _sharedTextField(WidgetTester tester, Key key) {
  return tester.widget<TextField>(
    find.descendant(of: find.byKey(key), matching: find.byType(TextField)),
  );
}

OutlineInputBorder _outlineInputBorder(InputBorder? border) {
  expect(border, isA<OutlineInputBorder>());
  return border! as OutlineInputBorder;
}

List<EdgeInsetsGeometry> _paddingValues(WidgetTester tester, Key key) {
  return tester
      .widgetList<Padding>(
        find.descendant(of: find.byKey(key), matching: find.byType(Padding)),
      )
      .map((padding) => padding.padding)
      .toList();
}

List<Widget> _longContentRows(String label, int count) {
  return List<Widget>.generate(
    count,
    (index) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text('$label ${index + 1}'),
    ),
  );
}

Finder _scrollableInside(Key key) {
  expect(
    find.descendant(
      of: find.byKey(key),
      matching: find.byType(SingleChildScrollView),
    ),
    findsOneWidget,
  );
  return find
      .descendant(of: find.byKey(key), matching: find.byType(Scrollable))
      .first;
}

const Size _goldenMobileSurface = Size(390, 844);
const Key _goldenSurfaceKey = ValueKey('shared-widget-golden-surface');
const Key _goldenTickerModeKey = ValueKey('shared-widget-golden-ticker-mode');
const bool _goldenTickerModeEnabled = false;
const double _stateIllustrationSize =
    72; // guard:raw-size-reviewed shared state illustration size

const Set<String> _widgetsRequiringInteractionCoverage = {
  'MxActionSheetList',
  'MxAdaptiveScaffold',
  'MxAnswerOptionCard',
  'MxAvatar',
  'MxBanner',
  'MxBottomSheet',
  'MxBreadcrumbBar',
  'MxCard',
  'MxChip',
  'MxDestinationPickerSheet',
  'MxDialog',
  'MxEmptyState',
  'MxErrorState',
  'MxFab',
  'MxFlashcard',
  'MxFolderTile',
  'MxIconButton',
  'MxInlineToggle',
  'MxListTile',
  'MxNameDialog',
  'MxOfflineState',
  'MxPageDots',
  'MxPrimaryButton',
  'MxReorderableList',
  'MxSearchField',
  'MxSearchSortToolbar',
  'MxSecondaryButton',
  'MxSectionHeader',
  'MxSegmentedControl',
  'MxSelectField',
  'MxSlider',
  'MxSortMenuChip',
  'MxSpeakButton',
  'MxStudyProgressAction',
  'MxStudySetTile',
  'MxTappable',
  'MxTermRow',
  'MxTextField',
  'MxToggle',
};

const Set<String> _dedicatedInteractionCoverageWidgetNames = {
  'MxActionSheetList',
  'MxAdaptiveScaffold',
  'MxAvatar',
  'MxBanner',
  'MxBottomSheet',
  'MxBreadcrumbBar',
  'MxDestinationPickerSheet',
  'MxDialog',
  'MxEmptyState',
  'MxErrorState',
  'MxFlashcard',
  'MxInlineToggle',
  'MxNameDialog',
  'MxOfflineState',
  'MxReorderableList',
  'MxSearchField',
  'MxSearchSortToolbar',
  'MxSectionHeader',
  'MxSegmentedControl',
  'MxSelectField',
  'MxSlider',
  'MxSortMenuChip',
  'MxSpeakButton',
  'MxTextField',
};

const Set<String> _widgetsRequiringStateCoverage = {
  'MxAnswerOptionCard',
  'MxCard',
  'MxEmptyState',
  'MxErrorState',
  'MxIconButton',
  'MxLoadingState',
  'MxOfflineState',
  'MxPageDots',
  'MxPrimaryButton',
  'MxRetainedAsyncState',
  'MxSearchField',
  'MxSecondaryButton',
  'MxSelectField',
  'MxSpeakButton',
  'MxStudyProgressAction',
  'MxTextField',
};

const Set<String> _dedicatedStateCoverageWidgetNames = {
  'MxAnswerOptionCard',
  'MxCard',
  'MxEmptyState',
  'MxErrorState',
  'MxLoadingState',
  'MxOfflineState',
  'MxPageDots',
  'MxRetainedAsyncState',
  'MxSearchField',
  'MxSpeakButton',
  'MxStudyProgressAction',
  'MxTextField',
};

const Set<String> _widgetsRequiringAccessibilityCoverage = {
  'MxAnswerOptionCard',
  'MxEmptyState',
  'MxErrorState',
  'MxFab',
  'MxFolderTile',
  'MxIconButton',
  'MxInlineToggle',
  'MxPageDots',
  'MxPrimaryButton',
  'MxSearchField',
  'MxSecondaryButton',
  'MxSegmentedControl',
  'MxSelectField',
  'MxSlider',
  'MxSortMenuChip',
  'MxSpeakButton',
  'MxStudyProgressAction',
  'MxStudySetTile',
  'MxTextField',
  'MxToggle',
};

const Set<String> _dedicatedAccessibilityCoverageWidgetNames = {
  'MxEmptyState',
  'MxFab',
  'MxFolderTile',
  'MxIconButton',
  'MxInlineToggle',
  'MxPageDots',
  'MxSearchField',
  'MxSecondaryButton',
  'MxSegmentedControl',
  'MxSelectField',
  'MxSlider',
  'MxSortMenuChip',
  'MxSpeakButton',
  'MxStudyProgressAction',
  'MxToggle',
};

const Set<String> _widgetsRequiringGoldenCoverage = {
  'MxAnswerOptionCard',
  'MxCard',
  'MxErrorState',
  'MxIconButton',
  'MxLinearProgress',
  'MxLoadingState',
  'MxPrimaryButton',
  'MxSecondaryButton',
  'MxStudySetTile',
};

const Set<String> _goldenCoverageWidgetNames = {
  'MxAnswerOptionCard',
  'MxCard',
  'MxErrorState',
  'MxIconButton',
  'MxLinearProgress',
  'MxLoadingState',
  'MxPrimaryButton',
  'MxSecondaryButton',
  'MxStudySetTile',
};

Future<void> _expectGoldenMatches(
  WidgetTester tester,
  Widget child,
  String goldenFile, {
  ThemeMode themeMode = ThemeMode.light,
  double textScaleFactor = 1,
  Size surfaceSize = _goldenMobileSurface,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = surfaceSize;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    _AppHarness(
      host: _WidgetHost.home,
      scrollableHost: false,
      themeMode: themeMode,
      textScaleFactor: textScaleFactor,
      surfaceSize: surfaceSize,
      child: _GoldenHost(surfaceSize: surfaceSize, child: child),
    ),
  );
  await tester.pump(const Duration(milliseconds: 16));

  expect(tester.takeException(), isNull, reason: goldenFile);
  expect(
    tester.widget<TickerMode>(find.byKey(_goldenTickerModeKey)).enabled,
    isFalse,
  );
  await expectLater(
    find.byKey(_goldenSurfaceKey),
    matchesGoldenFile(goldenFile),
  );
}

class _GoldenHost extends StatelessWidget {
  const _GoldenHost({required this.surfaceSize, required this.child});

  final Size surfaceSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final contentWidth = surfaceSize.width - (AppSpacing.lg * 2);

    return RepaintBoundary(
      key: _goldenSurfaceKey,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: contentWidth,
                  child: TickerMode(
                    key: _goldenTickerModeKey,
                    enabled: _goldenTickerModeEnabled,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNormalGoldenContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      MxStudySetTile(
        key: ValueKey('golden-normal-study-set'),
        title: 'Japanese vocabulary',
        icon: Icons.style_outlined,
        metaLine: '24 cards - 8 due today',
        ownerInitials: 'MX',
        ownerLabel: 'MemoX',
        ownerBadge: 'Core',
        trailing: Icon(Icons.chevron_right),
        onTap: _noop,
      ),
      MxGap(AppSpacing.md),
      MxCard(
        key: ValueKey('golden-normal-progress-card'),
        variant: MxCardVariant.outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MxText('Today progress', role: MxTextRole.tileTitle),
            MxGap(AppSpacing.md),
            MxLinearProgress(
              value: 0.68,
              label: 'Mastery',
              showPercentage: true,
              size: MxProgressSize.large,
            ),
          ],
        ),
      ),
      MxGap(AppSpacing.md),
      MxAnswerOptionCard(
        key: ValueKey('golden-normal-answer'),
        label: 'Translate the prompt before revealing the answer.',
        leadingIcon: Icons.menu_book_outlined,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      MxPrimaryButton(
        key: ValueKey('golden-normal-primary-button'),
        label: 'Start review',
        leadingIcon: Icons.play_arrow,
        trailingIcon: Icons.arrow_forward,
        fullWidth: true,
        onPressed: _noop,
      ),
    ],
  );
}

Widget _buildButtonNormalGoldenContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      MxPrimaryButton(
        key: ValueKey('golden-button-primary-normal'),
        label: 'Continue',
        leadingIcon: Icons.play_arrow,
        trailingIcon: Icons.arrow_forward,
        fullWidth: true,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      MxSecondaryButton(
        key: ValueKey('golden-button-secondary-outlined'),
        label: 'Cancel',
        leadingIcon: Icons.close,
        fullWidth: true,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      MxSecondaryButton(
        key: ValueKey('golden-button-secondary-tonal'),
        label: 'Review later',
        variant: MxSecondaryVariant.tonal,
        trailingIcon: Icons.schedule,
        fullWidth: true,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      MxSecondaryButton(
        key: ValueKey('golden-button-secondary-text'),
        label: 'Skip',
        variant: MxSecondaryVariant.text,
        fullWidth: true,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      Align(
        alignment: Alignment.centerLeft,
        child: MxIconButton(
          key: ValueKey('golden-button-icon-normal'),
          icon: Icons.search,
          tooltip: 'Search',
          onPressed: _noop,
        ),
      ),
    ],
  );
}

Widget _buildButtonStateGoldenContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      MxPrimaryButton(
        key: ValueKey('golden-button-primary-disabled'),
        label: 'Continue',
        fullWidth: true,
        onPressed: null,
      ),
      MxGap(AppSpacing.md),
      MxSecondaryButton(
        key: ValueKey('golden-button-secondary-disabled'),
        label: 'Cancel',
        fullWidth: true,
        onPressed: null,
      ),
      MxGap(AppSpacing.md),
      Align(
        alignment: Alignment.centerLeft,
        child: MxIconButton(
          key: ValueKey('golden-button-icon-disabled'),
          icon: Icons.search,
          tooltip: 'Search',
          onPressed: null,
        ),
      ),
      MxGap(AppSpacing.lg),
      MxPrimaryButton(
        key: ValueKey('golden-button-primary-loading'),
        label: 'Saving',
        fullWidth: true,
        isLoading: true,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      MxSecondaryButton(
        key: ValueKey('golden-button-secondary-loading'),
        label: 'Retry',
        fullWidth: true,
        isLoading: true,
        onPressed: _noop,
      ),
    ],
  );
}

Widget _buildStateGoldenContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      MxPrimaryButton(
        key: ValueKey('golden-state-disabled-button'),
        label: 'Review unavailable',
        fullWidth: true,
        onPressed: null,
      ),
      MxGap(AppSpacing.md),
      MxAnswerOptionCard(
        key: ValueKey('golden-state-disabled-answer'),
        label: 'Disabled answer option',
        enabled: false,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.lg),
      MxCard(
        key: ValueKey('golden-state-loading-card'),
        child: MxLoadingState(
          message: 'Loading next review',
          progressSize: MxProgressSize.medium,
        ),
      ),
      MxGap(AppSpacing.lg),
      MxErrorState(
        key: ValueKey('golden-state-error'),
        title: 'Sync failed',
        message: 'Use cached cards and retry when the connection is back.',
        retryLabel: 'Retry',
        onRetry: _noop,
      ),
    ],
  );
}

Widget _buildTextScaleGoldenContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      MxStudySetTile(
        key: ValueKey('golden-text-scale-study-set'),
        title: 'Long vocabulary deck name',
        icon: Icons.style_outlined,
        metaLine: '120 cards due today',
        ownerInitials: 'MX',
        ownerLabel: 'MemoX study group',
        onTap: _noop,
      ),
      MxGap(AppSpacing.md),
      MxAnswerOptionCard(
        key: ValueKey('golden-text-scale-answer'),
        label:
            'A longer answer option that should wrap cleanly at text scale 1.2.',
        selected: true,
        onPressed: _noop,
      ),
      MxGap(AppSpacing.md),
      MxPrimaryButton(
        key: ValueKey('golden-text-scale-primary-button'),
        label: 'Continue learning',
        leadingIcon: Icons.play_arrow,
        trailingIcon: Icons.arrow_forward,
        fullWidth: true,
        onPressed: _noop,
      ),
    ],
  );
}

Widget _buildCardGoldenContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      MxCard(
        key: ValueKey('golden-card-normal'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MxText('Normal card', role: MxTextRole.tileTitle),
            MxGap(AppSpacing.sm),
            MxText(
              'Token padding, radius, elevation, and themed background.',
              role: MxTextRole.tileMeta,
            ),
          ],
        ),
      ),
      MxGap(AppSpacing.md),
      MxCard(
        key: ValueKey('golden-card-clickable'),
        variant: MxCardVariant.outlined,
        onTap: _noop,
        child: Row(
          children: [
            Icon(Icons.touch_app_outlined),
            MxGap(AppSpacing.md),
            Expanded(
              child: MxText(
                'Clickable outlined card',
                role: MxTextRole.tileTitle,
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
      MxGap(AppSpacing.md),
      MxCard(
        key: ValueKey('golden-card-elevated'),
        variant: MxCardVariant.elevated,
        child: MxLinearProgress(
          value: 0.72,
          label: 'Card mastery',
          showPercentage: true,
        ),
      ),
    ],
  );
}

class _AppHarness extends StatelessWidget {
  const _AppHarness({
    required this.child,
    required this.host,
    required this.scrollableHost,
    required this.themeMode,
    required this.textScaleFactor,
    required this.surfaceSize,
  });

  final Widget child;
  final _WidgetHost host;
  final bool scrollableHost;
  final ThemeMode themeMode;
  final double textScaleFactor;
  final Size surfaceSize;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery(
      data: MediaQueryData(
        size: surfaceSize,
        textScaler: TextScaler.linear(textScaleFactor),
        platformBrightness: themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
      ),
      child: host == _WidgetHost.home
          ? child
          : _ScaffoldHost(scrollable: scrollableHost, child: child),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: mediaQuery,
    );
  }
}

class _ScaffoldHost extends StatelessWidget {
  const _ScaffoldHost({required this.child, required this.scrollable});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final hosted = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Align(alignment: Alignment.topLeft, child: child),
    );

    return Scaffold(
      body: SafeArea(
        child: scrollable ? SingleChildScrollView(child: hosted) : hosted,
      ),
    );
  }
}

final List<_SharedWidgetCase> _sharedWidgetCases = [
  _SharedWidgetCase(
    name: 'MxActionSheetList',
    minimal: (key) => MxActionSheetList<String>(key: key, items: const []),
    full: (key) => MxActionSheetList<String>(
      key: key,
      selectedValue: 'delete',
      popOnSelect: false,
      onSelected: (_) {},
      items: const [
        MxActionSheetItem(
          value: 'edit',
          label: 'Edit',
          subtitle: 'Change this item',
          icon: Icons.edit_outlined,
        ),
        MxActionSheetItem(
          value: 'delete',
          label: 'Delete',
          subtitle: 'Remove this item',
          icon: Icons.delete_outline,
          tone: MxActionSheetItemTone.destructive,
        ),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxBottomSheet',
    scrollableHost: false,
    minimal: (key) => MxBottomSheet(key: key, child: const SizedBox.shrink()),
    full: (key) => MxBottomSheet(
      key: key,
      title: 'Move cards',
      trailing: const Icon(Icons.close),
      child: const Text('Sheet body'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxDestinationPickerSheet',
    minimal: (key) => MxDestinationPickerSheet<String>(
      key: key,
      destinations: const [],
      showSearch: false,
      popOnSelect: false,
    ),
    full: (key) => MxDestinationPickerSheet<String>(
      key: key,
      selectedValue: 'deck-a',
      searchHintText: 'Search destinations',
      emptyLabel: 'No destinations',
      popOnSelect: false,
      onSelected: (_) {},
      destinations: const [
        MxDestinationOption(
          value: 'deck-a',
          title: 'Japanese',
          subtitle: 'Deck',
          icon: Icons.style_outlined,
          searchTerms: ['language'],
        ),
        MxDestinationOption(
          value: 'folder-b',
          title: 'Archive',
          subtitle: 'Folder',
          icon: Icons.folder_outlined,
        ),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxDialog',
    scrollableHost: false,
    minimal: (key) =>
        MxDialog(key: key, title: 'Confirm', child: const Text('Body')),
    full: (key) => MxDialog(
      key: key,
      title: 'Delete item',
      icon: Icons.warning_amber_outlined,
      actions: [TextButton(onPressed: () {}, child: const Text('Cancel'))],
      child: const Text('Longer dialog body'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxNameDialog',
    scrollableHost: false,
    minimal: (key) => MxNameDialog(
      key: key,
      title: 'Create',
      label: 'Name',
      hintText: 'Name',
      confirmLabel: 'Save',
    ),
    full: (key) => MxNameDialog(
      key: key,
      title: 'Rename',
      label: 'Name',
      hintText: 'New name',
      confirmLabel: 'Save',
      initialValue: 'Vocabulary',
    ),
  ),
  _SharedWidgetCase(
    name: 'MxBanner',
    minimal: (key) => MxBanner(key: key, message: 'Saved'),
    full: (key) => MxBanner(
      key: key,
      title: 'Offline',
      message: 'Changes will sync later.',
      tone: MxBannerTone.warning,
      primaryActionLabel: 'Retry',
      primaryAction: () {},
      onDismiss: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxAdaptiveScaffold',
    host: _WidgetHost.home,
    minimal: (key) => MxAdaptiveScaffold(
      key: key,
      destinations: const [
        MxAdaptiveDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        MxAdaptiveDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style),
          label: 'Decks',
        ),
      ],
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      body: const Text('Home'),
    ),
    full: (key) => MxAdaptiveScaffold(
      key: key,
      title: 'MemoX',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      destinations: const [
        MxAdaptiveDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        MxAdaptiveDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedIndex: 1,
      onDestinationSelected: (_) {},
      body: const Text('Profile'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxContentShell',
    minimal: (key) => MxContentShell(key: key, child: const Text('Content')),
    full: (key) => MxContentShell(
      key: key,
      width: MxContentWidth.reading,
      applyVerticalPadding: true,
      hasFab: true,
      child: const Text('Reading content'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxGap',
    minimal: (key) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Before'),
        MxGap(AppSpacing.xs, key: key),
      ],
    ),
    full: (key) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Before'),
        MxGap(AppSpacing.xxl, key: key),
        const Text('After'),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSliverGap',
    scrollableHost: false,
    minimal: (key) =>
        CustomScrollView(slivers: [MxSliverGap(AppSpacing.xs, key: key)]),
    full: (key) => CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: Text('Before')),
        MxSliverGap(AppSpacing.xl, key: key),
        const SliverToBoxAdapter(child: Text('After')),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxScaffold',
    host: _WidgetHost.home,
    minimal: (key) => MxScaffold(key: key, body: const Text('Body')),
    full: (key) => MxScaffold(
      key: key,
      title: 'Library',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      floatingActionButton: const MxFab(icon: Icons.add, onPressed: _noop),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: const Text('Library body'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSection',
    minimal: (key) =>
        MxSection(key: key, title: 'Section', child: const Text('Body')),
    full: (key) => MxSection(
      key: key,
      title: 'Section',
      subtitle: 'Helpful context',
      action: TextButton(onPressed: () {}, child: const Text('View')),
      child: const Text('Body'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxEmptyState',
    minimal: (key) => MxEmptyState(key: key, title: 'No cards'),
    full: (key) => MxEmptyState(
      key: key,
      title: 'No cards',
      message: 'Create your first card.',
      actionLabel: 'Create',
      actionLeadingIcon: Icons.add,
      onAction: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxErrorState',
    minimal: (key) => MxErrorState(key: key),
    full: (key) => MxErrorState(
      key: key,
      title: 'Could not load',
      message: 'Try again later.',
      details: 'Timeout',
      onRetry: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxLoadingState',
    minimal: (key) => MxLoadingState(key: key),
    full: (key) => MxLoadingState(
      key: key,
      message: 'Loading cards',
      progressSize: MxProgressSize.small,
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSkeleton',
    minimal: (key) => MxSkeleton(key: key),
    full: (key) => MxSkeleton(key: key, width: 180, height: 24),
  ),
  _SharedWidgetCase(
    name: 'MxOfflineState',
    minimal: (key) => MxOfflineState(key: key),
    full: (key) => MxOfflineState(
      key: key,
      title: 'Offline',
      message: 'Check your connection.',
      onRetry: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxRetainedAsyncState',
    minimal: (key) => MxRetainedAsyncState<String>(
      key: key,
      isLoading: true,
      dataBuilder: (_, data) => Text(data),
    ),
    full: (key) => MxRetainedAsyncState<String>(
      key: key,
      data: 'Loaded data',
      isLoading: true,
      skeletonBuilder: (_) => const MxSkeleton(width: 120),
      onRetry: () {},
      dataBuilder: (_, data) => Text(data),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxAnimatedSwitcher',
    minimal: (key) => MxAnimatedSwitcher(key: key, child: const Text('A')),
    full: (key) => MxAnimatedSwitcher(
      key: key,
      child: const Text('B', key: ValueKey('animated-child')),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxAnswerOptionCard',
    minimal: (key) => MxAnswerOptionCard(key: key, label: 'Answer'),
    full: (key) => MxAnswerOptionCard(
      key: key,
      label: 'Long answer that can wrap across lines without clipping.',
      selected: true,
      leadingIcon: Icons.check,
      semanticsLabel: 'Answer option',
      onPressed: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxAvatar',
    minimal: (key) => MxAvatar(key: key),
    full: (key) => MxAvatar(
      key: key,
      initials: 'mx',
      size: MxAvatarSize.xl,
      badgeLabel: 'Plus',
      onTap: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxBadge',
    minimal: (key) => MxBadge(key: key, label: 'New'),
    full: (key) => MxBadge(
      key: key,
      label: 'Synced',
      icon: Icons.check,
      tone: MxBadgeTone.success,
    ),
  ),
  _SharedWidgetCase(
    name: 'MxBreadcrumbBar',
    minimal: (key) => MxBreadcrumbBar(key: key, items: const []),
    full: (key) => MxBreadcrumbBar(
      key: key,
      items: [
        MxBreadcrumb(label: 'Library', icon: Icons.home, onTap: () {}),
        MxBreadcrumb(label: 'Folder', onTap: () {}),
        const MxBreadcrumb(label: 'Deck'),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxBulkActionBar',
    minimal: (key) => MxBulkActionBar(key: key, label: '1 selected'),
    full: (key) => MxBulkActionBar(
      key: key,
      label: '3 selected',
      subtitle: 'Move or archive selected cards.',
      leading: const Icon(Icons.checklist),
      actions: [
        MxSecondaryButton(label: 'Move', onPressed: () {}),
        MxPrimaryButton(label: 'Archive', onPressed: () {}),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxCard',
    minimal: (key) => MxCard(key: key, child: const Text('Card')),
    full: (key) => MxCard(
      key: key,
      variant: MxCardVariant.outlined,
      onTap: () {},
      onLongPress: () {},
      child: const Text('Interactive card'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxChip',
    minimal: (key) => MxChip(key: key, label: 'Chip'),
    full: (key) => MxChip(
      key: key,
      label: 'Filtered',
      icon: Icons.filter_alt,
      selected: true,
      tone: MxChipTone.info,
      onTap: () {},
      onDeleted: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxDivider',
    minimal: (key) => MxDivider(key: key),
    full: (key) => MxDivider(key: key, indent: 16, endIndent: 16),
  ),
  _SharedWidgetCase(
    name: 'MxFab',
    minimal: (key) => MxFab(key: key, icon: Icons.add, onPressed: null),
    full: (key) => MxFab(
      key: key,
      icon: Icons.add,
      onPressed: () {},
      tooltip: 'Create',
      variant: MxFabVariant.tonal,
      extendedLabel: 'Create',
    ),
  ),
  _SharedWidgetCase(
    name: 'MxFlashcard',
    minimal: (key) => MxFlashcard(key: key, content: 'Term'),
    full: (key) => MxFlashcard(
      key: key,
      content: 'Detailed answer that remains readable on the flashcard.',
      face: MxFlashcardFace.back,
      language: 'en',
      onTap: () {},
      onFullscreen: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxFolderTile',
    minimal: (key) =>
        MxFolderTile(key: key, name: 'Folder', icon: Icons.folder_outlined),
    full: (key) => MxFolderTile(
      key: key,
      name: 'Japanese vocabulary',
      icon: Icons.folder_outlined,
      caption: '5 decks',
      masteryPercent: 84,
      trailing: const Icon(Icons.more_vert),
      onTap: () {},
      onLongPress: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxIconButton',
    minimal: (key) =>
        MxIconButton(key: key, icon: Icons.search, onPressed: null),
    full: (key) => MxIconButton(
      key: key,
      icon: Icons.star_border,
      selectedIcon: Icons.star,
      isSelected: true,
      tooltip: 'Favorite',
      variant: MxIconButtonVariant.filledTonal,
      onPressed: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxInlineToggle',
    minimal: (key) => MxInlineToggle(
      key: key,
      label: 'Enabled',
      value: false,
      onChanged: (_) {},
    ),
    full: (key) => MxInlineToggle(
      key: key,
      label: 'Auto play',
      subtitle: 'Speak each card automatically.',
      leadingIcon: Icons.volume_up,
      value: true,
      onChanged: (_) {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxListTile',
    minimal: (key) => MxListTile(key: key, title: 'List item'),
    full: (key) => MxListTile(
      key: key,
      title: 'Deck title',
      subtitle: '55 cards',
      leadingIcon: Icons.style_outlined,
      trailing: const Icon(Icons.more_vert),
      selected: true,
      showChevron: true,
      onTap: () {},
      onLongPress: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxPageDots',
    minimal: (key) => MxPageDots(key: key, count: 0, activeIndex: 0),
    full: (key) =>
        MxPageDots(key: key, count: 3, activeIndex: 1, onDotTap: (_) {}),
  ),
  _SharedWidgetCase(
    name: 'MxPrimaryButton',
    minimal: (key) =>
        MxPrimaryButton(key: key, label: 'Continue', onPressed: null),
    full: (key) => MxPrimaryButton(
      key: key,
      label: 'Remembered',
      leadingIcon: Icons.check,
      trailingIcon: Icons.arrow_forward,
      tone: MxPrimaryButtonTone.success,
      size: MxButtonSize.large,
      fullWidth: true,
      onPressed: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxCircularProgress',
    minimal: (key) => MxCircularProgress(key: key),
    full: (key) =>
        MxCircularProgress(key: key, value: 0.4, size: MxProgressSize.large),
  ),
  _SharedWidgetCase(
    name: 'MxLinearProgress',
    minimal: (key) => MxLinearProgress(key: key, value: 0.4),
    full: (key) => MxLinearProgress(
      key: key,
      value: 0.72,
      label: 'Mastery',
      showPercentage: true,
      size: MxProgressSize.large,
    ),
  ),
  _SharedWidgetCase(
    name: 'MxProgressRing',
    minimal: (key) => MxProgressRing(key: key, value: 0.5),
    full: (key) =>
        MxProgressRing(key: key, value: 0.82, showLabel: false, strokeWidth: 4),
  ),
  _SharedWidgetCase(
    name: 'MxReorderableList',
    scrollableHost: false,
    minimal: (key) => SizedBox(
      height: 120,
      child: MxReorderableList.builder(
        key: key,
        itemCount: 1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) => ListTile(
          key: ValueKey('minimal-item-$index'),
          title: Text('Item $index'),
        ),
        onReorder: (_, _) {},
      ),
    ),
    full: (key) => SizedBox(
      height: 260,
      child: MxReorderableList.builder(
        key: key,
        itemCount: 3,
        header: const Text('Header'),
        footer: const Text('Footer'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) => ListTile(
          key: ValueKey('full-item-$index'),
          title: Text('Item $index'),
        ),
        onReorder: (_, _) {},
      ),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSearchField',
    minimal: (key) => MxSearchField(key: key),
    full: (key) => MxSearchField(
      key: key,
      hintText: 'Search cards',
      onChanged: (_) {},
      onSubmitted: (_) {},
      onClear: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSearchSortToolbar',
    minimal: (key) => MxSearchSortToolbar<String>(key: key),
    full: (key) => MxSearchSortToolbar<String>(
      key: key,
      searchHintText: 'Search cards',
      onSearchChanged: (_) {},
      sortLabel: 'Sort',
      selectedSort: 'recent',
      onSortSelected: (_) {},
      sortOptions: const [
        MxSortOption(value: 'recent', label: 'Recent', icon: Icons.schedule),
        MxSortOption(value: 'name', label: 'Name', icon: Icons.sort_by_alpha),
      ],
      trailing: [MxChip(label: 'Due', onTap: () {})],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSecondaryButton',
    minimal: (key) =>
        MxSecondaryButton(key: key, label: 'Cancel', onPressed: null),
    full: (key) => MxSecondaryButton(
      key: key,
      label: 'Forgot',
      leadingIcon: Icons.refresh,
      trailingIcon: Icons.arrow_forward,
      tone: MxSecondaryButtonTone.danger,
      variant: MxSecondaryVariant.tonal,
      size: MxButtonSize.large,
      fullWidth: true,
      onPressed: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSectionHeader',
    minimal: (key) => MxSectionHeader(key: key, title: 'Recent'),
    full: (key) => MxSectionHeader(
      key: key,
      title: 'Recent',
      subtitle: 'Updated today',
      actionLabel: 'View all',
      onAction: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSegmentedControl',
    minimal: (key) => MxSegmentedControl<String>(
      key: key,
      segments: const [MxSegment(value: 'all', label: 'All')],
      selected: const {'all'},
      onChanged: (_) {},
    ),
    full: (key) => SizedBox(
      width: 180,
      child: MxSegmentedControl<String>(
        key: key,
        adaptive: true,
        multiSelectionEnabled: true,
        emptySelectionAllowed: true,
        showSelectedIcon: true,
        segments: const [
          MxSegment(value: 'due', label: 'Due', icon: Icons.schedule),
          MxSegment(value: 'new', label: 'New', icon: Icons.fiber_new),
        ],
        selected: const {'due'},
        onChanged: (_) {},
      ),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSelectField',
    minimal: (key) => MxSelectField<String>(
      key: key,
      label: 'Mode',
      value: 'all',
      options: const [MxSelectOption(value: 'all', label: 'All')],
      onChanged: (_) {},
    ),
    full: (key) => MxSelectField<String>(
      key: key,
      label: 'Mode',
      value: 'due',
      helperText: 'Choose a filter',
      options: const [
        MxSelectOption(value: 'all', label: 'All'),
        MxSelectOption(value: 'due', label: 'Due'),
      ],
      onChanged: (_) {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxShakeTransition',
    minimal: (key) => MxShakeTransition(
      key: key,
      animation: const AlwaysStoppedAnimation(0),
      child: const Text('Stable'),
    ),
    full: (key) => MxShakeTransition(
      key: key,
      animation: const AlwaysStoppedAnimation(0.5),
      distance: 12,
      cycles: 4,
      child: const Text('Invalid answer'),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSlider',
    minimal: (key) => MxSlider(
      key: key,
      label: 'Speed',
      value: 1,
      min: 0,
      max: 2,
      onChanged: (_) {},
    ),
    full: (key) => MxSlider(
      key: key,
      label: 'Speed',
      value: 1.5,
      min: 0.5,
      max: 2,
      divisions: 3,
      valueLabel: '1.5x',
      onChanged: (_) {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSortMenuChip',
    minimal: (key) => MxSortMenuChip<String>(
      key: key,
      options: const [],
      selectedValue: null,
      fallbackLabel: 'Sort',
      onSelected: (_) {},
    ),
    full: (key) => MxSortMenuChip<String>(
      key: key,
      selectedValue: 'recent',
      fallbackLabel: 'Sort',
      onSelected: (_) {},
      options: const [
        MxSortOption(value: 'recent', label: 'Recent', icon: Icons.schedule),
        MxSortOption(value: 'name', label: 'Name', icon: Icons.sort_by_alpha),
      ],
    ),
  ),
  _SharedWidgetCase(
    name: 'MxSpeakButton',
    minimal: (key) =>
        MxSpeakButton(key: key, tooltip: 'Speak', onPressed: null),
    full: (key) => MxSpeakButton(
      key: key,
      tooltip: 'Stop',
      isSpeaking: true,
      onPressed: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxStreakCard',
    minimal: (key) => MxStreakCard(
      key: key,
      streakCount: 0,
      streakUnit: 'days',
      encouragement: 'Start a streak.',
      weekDays: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      weekDates: const [1, 2, 3, 4, 5, 6, 7],
      activeIndices: const {},
    ),
    full: (key) => MxStreakCard(
      key: key,
      streakCount: 11,
      streakUnit: 'days',
      encouragement: 'Keep your daily learning streak going.',
      weekDays: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      weekDates: const [8, 9, 10, 11, 12, 13, 14],
      activeIndices: const {0, 1, 3, 5},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxStudyProgressAction',
    minimal: (key) => MxStudyProgressAction(
      key: key,
      masteryPercent: null,
      cardCount: null,
      tooltip: 'Study',
      onPressed: _noop,
    ),
    full: (key) => MxStudyProgressAction(
      key: key,
      masteryPercent: 87,
      cardCount: 120,
      tooltip: 'Study due cards',
      onPressed: _noop,
    ),
  ),
  _SharedWidgetCase(
    name: 'MxStudySetTile',
    minimal: (key) =>
        MxStudySetTile(key: key, title: 'Deck', icon: Icons.style_outlined),
    full: (key) => MxStudySetTile(
      key: key,
      title: 'Japanese vocabulary',
      icon: Icons.style_outlined,
      metaLine: '55 cards',
      ownerInitials: 'MX',
      ownerLabel: 'MemoX',
      ownerBadge: 'Plus',
      trailing: const Icon(Icons.more_vert),
      onTap: () {},
      onLongPress: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxTappable',
    minimal: (key) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      child: const SizedBox(width: 48, height: 48),
    ),
    full: (key) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      semanticsLabel: 'Tap target',
      onTap: () {},
      onLongPress: () {},
      child: const SizedBox(width: 72, height: 48),
    ),
  ),
  _SharedWidgetCase(
    name: 'MxTermRow',
    minimal: (key) =>
        MxTermRow(key: key, term: 'Term', definition: 'Definition'),
    full: (key) => MxTermRow(
      key: key,
      term: 'Term',
      definition: 'Definition',
      caption: '2 examples',
      leading: const Icon(Icons.text_fields),
      trailing: const Icon(Icons.more_vert),
      selected: true,
      onTap: () {},
      onLongPress: () {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxText',
    minimal: (key) => MxText('Text', key: key, role: MxTextRole.contentBody),
    full: (key) => MxText(
      'Long text that can wrap without clipping.',
      key: key,
      role: MxTextRole.stateMessage,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  ),
  _SharedWidgetCase(
    name: 'MxTextField',
    minimal: (key) => MxTextField(key: key, label: 'Answer'),
    full: (key) => MxTextField(
      key: key,
      label: 'Answer',
      hintText: 'Type answer',
      helperText: 'Required',
      errorText: 'Try again',
      prefixIcon: Icons.edit,
      suffixIcon: const Icon(Icons.clear),
      maxLines: 2,
      textInputAction: TextInputAction.done,
      onChanged: (_) {},
      onSubmitted: (_) {},
    ),
  ),
  _SharedWidgetCase(
    name: 'MxToggle',
    minimal: (key) =>
        MxToggle(key: key, label: 'Enabled', value: false, onChanged: (_) {}),
    full: (key) => MxToggle(
      key: key,
      label: 'Daily reminder',
      subtitle: 'Send a reminder each day.',
      value: true,
      onChanged: (_) {},
    ),
  ),
];

final List<_LayoutCase> _touchTargetCases = [
  _LayoutCase(
    'MxTappable',
    (key) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      onTap: _noop,
      child: const SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
      ),
    ),
  ),
  _LayoutCase(
    'MxPageDots',
    (key) => MxPageDots(key: key, count: 3, activeIndex: 1, onDotTap: (_) {}),
  ),
  _LayoutCase(
    'MxIconButton',
    (key) => MxIconButton(
      key: key,
      icon: Icons.search,
      tooltip: 'Search',
      onPressed: _noop,
    ),
  ),
  _LayoutCase(
    'MxFab',
    (key) =>
        MxFab(key: key, icon: Icons.add, tooltip: 'Create', onPressed: _noop),
  ),
  _LayoutCase(
    'MxPrimaryButton',
    (key) => MxPrimaryButton(
      key: key,
      label: 'Continue',
      size: MxButtonSize.large,
      onPressed: _noop,
    ),
  ),
  _LayoutCase(
    'MxSecondaryButton',
    (key) => MxSecondaryButton(
      key: key,
      label: 'Cancel',
      size: MxButtonSize.large,
      onPressed: _noop,
    ),
  ),
  _LayoutCase(
    'MxFolderTile',
    (key) => MxFolderTile(
      key: key,
      name: 'Folder',
      icon: Icons.folder_outlined,
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxStudySetTile',
    (key) => MxStudySetTile(
      key: key,
      title: 'Deck',
      icon: Icons.style_outlined,
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxStudyProgressAction',
    (key) => MxStudyProgressAction(
      key: key,
      masteryPercent: 64,
      cardCount: 12,
      tooltip: 'Study',
      onPressed: _noop,
    ),
  ),
  _LayoutCase(
    'MxToggle',
    (key) =>
        MxToggle(key: key, label: 'Enabled', value: true, onChanged: (_) {}),
  ),
];

final List<_InteractionCase> _tapCallbackCases = [
  _InteractionCase(
    'MxPrimaryButton',
    (key, onAction) =>
        MxPrimaryButton(key: key, label: 'Continue', onPressed: onAction),
  ),
  _InteractionCase(
    'MxSecondaryButton',
    (key, onAction) =>
        MxSecondaryButton(key: key, label: 'Cancel', onPressed: onAction),
  ),
  _InteractionCase(
    'MxIconButton',
    (key, onAction) =>
        MxIconButton(key: key, icon: Icons.search, onPressed: onAction),
  ),
  _InteractionCase(
    'MxFab',
    (key, onAction) => MxFab(
      key: key,
      icon: Icons.add,
      tooltip: 'Create',
      onPressed: onAction,
    ),
  ),
  _InteractionCase(
    'MxTappable',
    (key, onAction) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      onTap: onAction,
      child: const SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
      ),
    ),
  ),
  _InteractionCase(
    'MxAnswerOptionCard',
    (key, onAction) =>
        MxAnswerOptionCard(key: key, label: 'Answer', onPressed: onAction),
  ),
  _InteractionCase(
    'MxCard',
    (key, onAction) => MxCard(
      key: key,
      onTap: onAction,
      child: const SizedBox(
        width: 96, // guard:raw-size-reviewed test fixture hit surface
        height: kMinInteractiveDimension,
        child: Center(child: Text('Card')),
      ),
    ),
  ),
  _InteractionCase(
    'MxChip',
    (key, onAction) =>
        MxChip(key: key, label: 'Due', selected: true, onTap: onAction),
  ),
  _InteractionCase(
    'MxFolderTile',
    (key, onAction) => MxFolderTile(
      key: key,
      name: 'Folder',
      icon: Icons.folder_outlined,
      onTap: onAction,
    ),
  ),
  _InteractionCase(
    'MxListTile',
    (key, onAction) => MxListTile(
      key: key,
      title: 'Deck',
      leadingIcon: Icons.style_outlined,
      onTap: onAction,
    ),
  ),
  _InteractionCase(
    'MxPageDots',
    (key, onAction) => MxPageDots(
      key: key,
      count: 3,
      activeIndex: 0,
      onDotTap: (_) => onAction(),
    ),
  ),
  _InteractionCase(
    'MxStudyProgressAction',
    (key, onAction) => MxStudyProgressAction(
      key: key,
      masteryPercent: 72,
      cardCount: 12,
      tooltip: 'Study',
      onPressed: onAction,
    ),
  ),
  _InteractionCase(
    'MxStudySetTile',
    (key, onAction) => MxStudySetTile(
      key: key,
      title: 'Deck',
      icon: Icons.style_outlined,
      onTap: onAction,
    ),
  ),
  _InteractionCase(
    'MxTermRow',
    (key, onAction) => MxTermRow(
      key: key,
      term: 'Term',
      definition: 'Definition',
      onTap: onAction,
    ),
  ),
  _InteractionCase(
    'MxToggle',
    (key, onAction) => MxToggle(
      key: key,
      label: 'Enabled',
      value: false,
      onChanged: (_) => onAction(),
    ),
  ),
];

final List<_InteractionCase> _disabledInteractionCases = [
  _InteractionCase(
    'MxPrimaryButton',
    (key, onAction) =>
        MxPrimaryButton(key: key, label: 'Continue', onPressed: null),
  ),
  _InteractionCase(
    'MxSecondaryButton',
    (key, onAction) =>
        MxSecondaryButton(key: key, label: 'Cancel', onPressed: null),
  ),
  _InteractionCase(
    'MxIconButton',
    (key, onAction) =>
        MxIconButton(key: key, icon: Icons.search, onPressed: null),
  ),
  _InteractionCase(
    'MxFab',
    (key, onAction) =>
        MxFab(key: key, icon: Icons.add, tooltip: 'Create', onPressed: null),
  ),
  _InteractionCase(
    'MxTappable',
    (key, onAction) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      enabled: false,
      onTap: onAction,
      child: const SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
      ),
    ),
  ),
  _InteractionCase(
    'MxAnswerOptionCard',
    (key, onAction) => MxAnswerOptionCard(
      key: key,
      label: 'Answer',
      enabled: false,
      onPressed: onAction,
    ),
  ),
  _InteractionCase(
    'MxSelectField',
    (key, onAction) => MxSelectField<String>(
      key: key,
      label: 'Mode',
      value: 'all',
      options: const [MxSelectOption(value: 'all', label: 'All')],
      enabled: false,
      onChanged: (_) => onAction(),
    ),
  ),
];

final List<_InteractionCase> _loadingInteractionCases = [
  _InteractionCase(
    'MxPrimaryButton',
    (key, onAction) => MxPrimaryButton(
      key: key,
      label: 'Continue',
      isLoading: true,
      onPressed: onAction,
    ),
  ),
  _InteractionCase(
    'MxSecondaryButton',
    (key, onAction) => MxSecondaryButton(
      key: key,
      label: 'Cancel',
      isLoading: true,
      onPressed: onAction,
    ),
  ),
];

final List<_LayoutCase> _pressedLayoutCases = [
  _LayoutCase(
    'MxPrimaryButton',
    (key) => MxPrimaryButton(key: key, label: 'Continue', onPressed: _noop),
  ),
  _LayoutCase(
    'MxAnswerOptionCard',
    (key) => MxAnswerOptionCard(key: key, label: 'Answer', onPressed: _noop),
  ),
  _LayoutCase(
    'MxTappable',
    (key) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      onTap: _noop,
      child: const SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
      ),
    ),
  ),
  _LayoutCase(
    'MxCard',
    (key) => MxCard(
      key: key,
      onTap: _noop,
      child: const SizedBox(
        width: 96, // guard:raw-size-reviewed test fixture hit surface
        height: kMinInteractiveDimension,
        child: Center(child: Text('Card')),
      ),
    ),
  ),
];

final List<_HitAreaCase> _hitAreaCases = [
  _HitAreaCase(
    'MxTappable',
    (key) => MxTappable(
      key: key,
      shape: const StadiumBorder(),
      onTap: _noop,
      child: const SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
      ),
    ),
  ),
  _HitAreaCase(
    'MxIconButton',
    (key) => MxIconButton(
      key: key,
      icon: Icons.search,
      tooltip: 'Search',
      onPressed: _noop,
    ),
  ),
  _HitAreaCase(
    'MxFab',
    (key) =>
        MxFab(key: key, icon: Icons.add, tooltip: 'Create', onPressed: _noop),
  ),
  _HitAreaCase(
    'MxPrimaryButton',
    (key) => MxPrimaryButton(
      key: key,
      label: 'Continue',
      size: MxButtonSize.large,
      onPressed: _noop,
    ),
  ),
  _HitAreaCase(
    'MxSecondaryButton',
    (key) => MxSecondaryButton(
      key: key,
      label: 'Cancel',
      size: MxButtonSize.large,
      onPressed: _noop,
    ),
  ),
  _HitAreaCase(
    'MxFolderTile',
    (key) => MxFolderTile(
      key: key,
      name: 'Folder',
      icon: Icons.folder_outlined,
      onTap: _noop,
    ),
  ),
  _HitAreaCase(
    'MxStudySetTile',
    (key) => MxStudySetTile(
      key: key,
      title: 'Deck',
      icon: Icons.style_outlined,
      onTap: _noop,
    ),
  ),
  _HitAreaCase(
    'MxStudyProgressAction',
    (key) => MxStudyProgressAction(
      key: key,
      masteryPercent: 64,
      cardCount: 12,
      tooltip: 'Study',
      onPressed: _noop,
    ),
    targetFinder: (key) => find
        .descendant(of: find.byKey(key), matching: find.byType(MxTappable))
        .first,
  ),
  _HitAreaCase(
    'MxPageDots',
    (key) => MxPageDots(key: key, count: 3, activeIndex: 1, onDotTap: (_) {}),
    targetFinder: (key) => find
        .descendant(of: find.byKey(key), matching: find.byType(MxTappable))
        .first,
  ),
  _HitAreaCase(
    'MxToggle',
    (key) =>
        MxToggle(key: key, label: 'Enabled', value: true, onChanged: (_) {}),
  ),
];

final List<_LayoutCase> _accessibilityTextScaleCases = [
  _LayoutCase(
    'MxPrimaryButton',
    (key) => MxPrimaryButton(
      key: key,
      label: 'Continue learning',
      leadingIcon: Icons.play_arrow,
      trailingIcon: Icons.arrow_forward,
      onPressed: _noop,
    ),
  ),
  _LayoutCase(
    'MxTextField',
    (key) => MxTextField(
      key: key,
      label: 'Answer',
      hintText: 'Type the answer',
      helperText: 'Use the term from the card.',
    ),
  ),
  _LayoutCase(
    'MxAnswerOptionCard',
    (key) => MxAnswerOptionCard(
      key: key,
      label:
          'A longer answer option that needs to wrap cleanly at larger text scales.',
      selected: true,
      onPressed: _noop,
    ),
  ),
  _LayoutCase(
    'MxStudySetTile',
    (key) => MxStudySetTile(
      key: key,
      title: 'Long vocabulary deck name',
      icon: Icons.style_outlined,
      metaLine: '120 cards due today',
      ownerInitials: 'MX',
      ownerLabel: 'MemoX study group',
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxErrorState',
    (key) => MxErrorState(
      key: key,
      title: 'Could not load cards',
      message: 'Check the connection and try again.',
      retryLabel: 'Retry',
      onRetry: _noop,
    ),
  ),
];

final List<_LayoutCase> _responsiveWidthCases = [
  _LayoutCase(
    'MxSearchField',
    (key) => MxSearchField(key: key, hintText: 'Search cards'),
  ),
  _LayoutCase(
    'MxSearchSortToolbar',
    (key) => MxSearchSortToolbar<String>(
      key: key,
      searchHintText: 'Search cards',
      sortLabel: 'Sort',
      selectedSort: 'recent',
      onSearchChanged: (_) {},
      onSortSelected: (_) {},
      sortOptions: const [
        MxSortOption(value: 'recent', label: 'Recent', icon: Icons.schedule),
        MxSortOption(value: 'name', label: 'Name', icon: Icons.sort_by_alpha),
      ],
    ),
  ),
  _LayoutCase(
    'MxBulkActionBar',
    (key) => MxBulkActionBar(
      key: key,
      label: '3 selected',
      subtitle: 'Ready to move',
      actions: [
        MxSecondaryButton(label: 'Cancel', onPressed: _noop),
        MxPrimaryButton(label: 'Move', onPressed: _noop),
      ],
    ),
  ),
  _LayoutCase(
    'MxStudySetTile',
    (key) => MxStudySetTile(
      key: key,
      title: 'Vocabulary deck',
      icon: Icons.style_outlined,
      metaLine: '120 cards',
      ownerInitials: 'MX',
      ownerLabel: 'MemoX',
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxFolderTile',
    (key) => MxFolderTile(
      key: key,
      name: 'Language folders',
      icon: Icons.folder_outlined,
      caption: '5 decks',
      masteryPercent: 84,
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxStreakCard',
    (key) => MxStreakCard(
      key: key,
      streakCount: 7,
      streakUnit: 'days',
      encouragement: 'Keep going.',
      weekDays: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      weekDates: const [1, 2, 3, 4, 5, 6, 7],
      activeIndices: const {0, 1, 3, 6},
    ),
  ),
  _LayoutCase(
    'MxTermRow',
    (key) => MxTermRow(
      key: key,
      term: 'Term',
      definition: 'Definition',
      caption: '2 examples',
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxErrorState',
    (key) => MxErrorState(
      key: key,
      title: 'Could not load cards',
      message: 'Try again later.',
      retryLabel: 'Retry',
      onRetry: _noop,
    ),
  ),
];

final List<_LayoutCase> _responsiveLongDataCases = [
  _LayoutCase(
    'MxSearchSortToolbar',
    (key) => MxSearchSortToolbar<String>(
      key: key,
      searchHintText: 'Search cards with a deliberately long placeholder label',
      sortLabel: 'Sort by recently studied cards',
      selectedSort: 'recent',
      onSearchChanged: (_) {},
      onSortSelected: (_) {},
      sortOptions: const [
        MxSortOption(
          value: 'recent',
          label: 'Recently studied cards',
          icon: Icons.schedule,
        ),
        MxSortOption(
          value: 'name',
          label: 'Alphabetical deck name',
          icon: Icons.sort_by_alpha,
        ),
      ],
      trailing: [MxChip(label: 'Due today and overdue', onTap: _noop)],
    ),
  ),
  _LayoutCase(
    'MxBulkActionBar',
    (key) => MxBulkActionBar(
      key: key,
      label: '12 selected flashcards with long names',
      subtitle:
          'These selected cards include several long prompts and definitions.',
      actions: [
        MxSecondaryButton(label: 'Move selected cards', onPressed: _noop),
        MxPrimaryButton(label: 'Archive selected cards', onPressed: _noop),
      ],
    ),
  ),
  _LayoutCase(
    'MxStudySetTile',
    (key) => MxStudySetTile(
      key: key,
      title:
          'A very long deck title that must keep the title and metadata readable',
      icon: Icons.style_outlined,
      metaLine:
          '120 cards due today from a long spaced repetition study session',
      ownerInitials: 'MX',
      ownerLabel: 'MemoX collaborative study group',
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxFolderTile',
    (key) => MxFolderTile(
      key: key,
      name: 'A very long folder name that should wrap without breaking the row',
      icon: Icons.folder_outlined,
      caption: '25 nested decks and 1200 cards',
      masteryPercent: 96,
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxTermRow',
    (key) => MxTermRow(
      key: key,
      term:
          'An unusually long vocabulary term that should ellipsize responsibly',
      definition:
          'A long definition that should preserve row structure on compact widths.',
      caption: 'Used in several example sentences',
      selected: true,
      onTap: _noop,
    ),
  ),
  _LayoutCase(
    'MxStreakCard',
    (key) => MxStreakCard(
      key: key,
      streakCount: 120,
      streakUnit: 'consecutive learning days',
      encouragement:
          'A longer encouragement message should wrap without overflow.',
      weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      weekDates: const [24, 25, 26, 27, 28, 29, 30],
      activeIndices: const {0, 1, 3, 6},
    ),
  ),
];

List<File> _sharedWidgetSourceFiles() {
  final files =
      Directory('lib/presentation/shared')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) {
            final source = file.readAsStringSync();
            return RegExp(
              r'class\s+Mx\w+(?:<[^>]+>)?\s+extends\s+(?:StatelessWidget|StatefulWidget)',
            ).hasMatch(source);
          })
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  expect(files, isNotEmpty);
  return files;
}

List<File> _sharedStateSourceFiles() {
  final files = <File>[
    File('lib/presentation/shared/states/mx_empty_state.dart'),
    File('lib/presentation/shared/states/mx_error_state.dart'),
    File('lib/presentation/shared/states/mx_loading_state.dart'),
  ];

  for (final file in files) {
    expect(file.existsSync(), isTrue, reason: file.path);
  }

  return files;
}

Set<String> _sharedWidgetCatalogNames() {
  return _sharedWidgetCases.map((entry) => entry.name).toSet();
}

Set<String> _sharedWidgetClassNames() {
  final names = <String>{};
  final classPattern = RegExp(
    r'class\s+(Mx\w+)(?:<[^>]+>)?\s+extends\s+(?:StatelessWidget|StatefulWidget)',
  );

  for (final file in _sharedWidgetSourceFiles()) {
    final source = file.readAsStringSync();
    for (final match in classPattern.allMatches(source)) {
      names.add(match.group(1)!);
    }
  }

  expect(names, isNotEmpty);
  return names;
}

Set<String> _interactionCoverageWidgetNames() {
  return {
    ..._interactionCaseNames(_tapCallbackCases),
    ..._dedicatedInteractionCoverageWidgetNames,
  };
}

Set<String> _stateCoverageWidgetNames() {
  return {
    ..._interactionCaseNames(_disabledInteractionCases),
    ..._interactionCaseNames(_loadingInteractionCases),
    ..._dedicatedStateCoverageWidgetNames,
  };
}

Set<String> _layoutCoverageWidgetNames() {
  return _sharedWidgetCatalogNames();
}

Set<String> _themeCoverageWidgetNames() {
  return _sharedWidgetCatalogNames();
}

Set<String> _accessibilityCoverageWidgetNames() {
  return {
    ..._layoutCaseNames(_accessibilityTextScaleCases),
    ..._dedicatedAccessibilityCoverageWidgetNames,
  };
}

Set<String> _interactionCaseNames(List<_InteractionCase> cases) {
  return cases.map((entry) => entry.name).toSet();
}

Set<String> _layoutCaseNames(List<_LayoutCase> cases) {
  return cases.map((entry) => entry.name).toSet();
}

List<String> _missingCoverage(Set<String> required, Set<String> actual) {
  return required.difference(actual).toList()..sort();
}

List<String> _findGoldenNondeterminism() {
  final source = _goldenSourceUnderTest();
  final violations = <String>[];
  final rules = <_SourceRule>[
    _SourceRule('DateTime.now', RegExp(r'\bDateTime\.now\b')),
    _SourceRule('random value', RegExp(r'\bRandom\s*\(')),
    _SourceRule(
      'network image',
      RegExp(r'\b(?:Image\.network|NetworkImage)\b'),
    ),
    _SourceRule('online URL', RegExp(r'https?://')),
    _SourceRule('HTTP client', RegExp(r'\b(?:HttpClient|Dio)\s*\(')),
    _SourceRule('package client', RegExp(r'\bClient\s*\(')),
    _SourceRule('delayed timer', RegExp(r'\bFuture\.delayed\s*\(')),
  ];

  for (final rule in rules) {
    if (rule.pattern.hasMatch(source)) {
      violations.add('golden source: ${rule.label}');
    }
  }

  return violations;
}

String _goldenSourceUnderTest() {
  final source = File(
    'test/presentation/shared/shared_widget_contract_test.dart',
  ).readAsStringSync();
  const startMarker = 'Future<void> _expectGoldenMatches';
  const endMarker = 'List<File> _sharedWidgetSourceFiles';
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker);

  expect(start, greaterThanOrEqualTo(0));
  expect(end, greaterThan(start));

  return source.substring(start, end);
}

String _stripComments(String source) {
  return source
      .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
      .replaceAll(RegExp(r'//.*$', multiLine: true), '');
}

List<String> _findRawEdgeInsets(File file, String source) {
  final violations = <String>[];
  final invocationPattern = RegExp(
    r'EdgeInsets\.(?:all|symmetric|only|fromLTRB)\s*\(',
  );
  final rawNumberPattern = RegExp(r'(?:^|[^A-Za-z_])\d+(?:\.\d+)?');

  for (final match in invocationPattern.allMatches(source)) {
    final invocation = _readInvocation(source, match.start);
    if (!rawNumberPattern.hasMatch(invocation)) {
      continue;
    }
    if (invocation.contains('AppSpacing') ||
        invocation.contains('MxSpace') ||
        invocation.contains('EdgeInsets.zero')) {
      continue;
    }
    violations.add('${_relativePath(file)}: raw EdgeInsets $invocation');
  }

  return violations;
}

List<String> _findRawGapUsage(File file, String source) {
  final violations = <String>[];
  final invocationPattern = RegExp(r'\bMx(?:Sliver)?Gap\s*\(');
  final rawNumberPattern = RegExp(r'(?:^|[^A-Za-z_])\d+(?:\.\d+)?');

  for (final match in invocationPattern.allMatches(source)) {
    final invocation = _readInvocation(source, match.start);
    if (!rawNumberPattern.hasMatch(invocation)) {
      continue;
    }
    if (invocation.contains('AppSpacing') || invocation.contains('MxSpace')) {
      continue;
    }
    violations.add('${_relativePath(file)}: raw gap $invocation');
  }

  return violations;
}

List<String> _findRawIconSizes(File file, String source) {
  final violations = <String>[];
  final invocationPattern = RegExp(r'\b(?:Icon|IconButton(?:\.\w+)?)\s*\(');
  final rawSizePattern = RegExp(r'\b(?:size|iconSize)\s*:\s*\d');

  for (final match in invocationPattern.allMatches(source)) {
    final invocation = _readInvocation(source, match.start);
    if (!rawSizePattern.hasMatch(invocation)) {
      continue;
    }
    if (invocation.contains('AppIconSizes')) {
      continue;
    }
    violations.add('${_relativePath(file)}: raw icon size $invocation');
  }

  return violations;
}

List<String> _findRawBorderThickness(File file, String source) {
  final violations = <String>[];
  final invocationPattern = RegExp(r'\b(?:BorderSide|Divider)\s*\(');
  final rawThicknessPattern = RegExp(r'\b(?:width|thickness)\s*:\s*\d');

  for (final match in invocationPattern.allMatches(source)) {
    final invocation = _readInvocation(source, match.start);
    if (!rawThicknessPattern.hasMatch(invocation)) {
      continue;
    }
    if (invocation.contains('AppFocus.ringWidth')) {
      continue;
    }
    violations.add('${_relativePath(file)}: raw border thickness $invocation');
  }

  return violations;
}

List<String> _findUnreviewedFixedAxisDimensions(
  File file,
  String source,
  String axis,
) {
  final violations = <String>[];
  final dimensionPattern = RegExp('\\b$axis\\s*:\\s*\\d');
  final lines = source.split('\n');

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    if (!dimensionPattern.hasMatch(line)) {
      continue;
    }
    if (line.contains('guard:raw-size-reviewed') ||
        line.contains('VerticalDivider(width: 1)')) {
      continue;
    }
    violations.add('${_relativePath(file)}:${index + 1}: fixed $axis');
  }

  return violations;
}

List<String> _findUnreviewedFixedDimensions(File file, String source) {
  final violations = <String>[];
  final dimensionPattern = RegExp(
    r'\b(?:width|height|minWidth|minHeight|maxWidth|maxHeight|dimension)\s*:\s*\d',
  );
  final lines = source.split('\n');

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    if (!dimensionPattern.hasMatch(line)) {
      continue;
    }
    if (line.contains('guard:raw-size-reviewed') ||
        line.contains('VerticalDivider(width: 1)')) {
      continue;
    }
    violations.add(
      '${_relativePath(file)}:${index + 1}: unreviewed fixed dimension',
    );
  }

  return violations;
}

List<String> _findArbitraryViewportScaling(File file, String source) {
  final violations = <String>[];
  final rules = <_SourceRule>[
    _SourceRule(
      'viewport-proportional layout scaling',
      RegExp(
        r'MediaQuery\.(?:of|sizeOf)\([^)]*\)\.(?:size\.)?(?:width|height)\s*[*\/]',
      ),
    ),
    _SourceRule(
      'constraint-proportional width scaling',
      RegExp(r'constraints\.maxWidth\s*[*\/]\s*(?:0?\.\d+|\d)'),
    ),
    _SourceRule(
      'font size derived from layout',
      RegExp(r'fontSize\s*:\s*(?:MediaQuery|constraints)'),
    ),
  ];

  for (final rule in rules) {
    if (rule.pattern.hasMatch(source)) {
      violations.add('${_relativePath(file)}: ${rule.label}');
    }
  }

  return violations;
}

String _readInvocation(String source, int start) {
  var depth = 0;
  for (var index = start; index < source.length; index++) {
    final char = source[index];
    if (char == '(') {
      depth++;
      continue;
    }
    if (char == ')') {
      depth--;
      if (depth == 0) {
        return source.substring(start, index + 1);
      }
    }
  }
  return source.substring(start);
}

const double _minimumNormalTextContrast = 4.5;
const double _minimumSupportingTextContrast = 3.0;

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}

String _relativePath(File file) => file.path.replaceAll('\\', '/');

class _SourceRule {
  const _SourceRule(this.label, this.pattern);

  final String label;
  final RegExp pattern;
}

void _noop() {}

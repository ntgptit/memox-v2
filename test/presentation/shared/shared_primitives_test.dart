import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/extensions/theme_extensions.dart';
import 'package:memox/core/theme/tokens/app_radius.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_action_sheet_list.dart';
import 'package:memox/presentation/shared/dialogs/mx_destination_picker_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_bulk_action_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_answer_option_card.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_reorderable_list.dart';
import 'package:memox/presentation/shared/widgets/mx_search_sort_toolbar.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_flashcard.dart';
import 'package:memox/presentation/shared/widgets/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_inline_toggle.dart';
import 'package:memox/presentation/shared/widgets/mx_segmented_control.dart';
import 'package:memox/presentation/shared/widgets/mx_speak_button.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/mx_text_field.dart';

void main() {
  testWidgets('DT1 onDisplay: MxActionSheetList renders semantic text roles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: MxActionSheetList<String>(
          items: [
            MxActionSheetItem<String>(
              value: 'new-deck',
              label: 'New deck',
              subtitle: 'Create cards in this folder',
              icon: Icons.style_outlined,
            ),
          ],
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'New deck' &&
            widget.role == MxTextRole.actionSheetItem,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'Create cards in this folder' &&
            widget.role == MxTextRole.actionSheetSubtitle,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'DT2 onDisplay: MxIconButton toolbar variant stays visually quiet',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: MxIconButton.toolbar(
            icon: Icons.arrow_back,
            tooltip: 'Back',
            onPressed: () {},
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final normalStates = <WidgetState>{};
      final background = iconButton.style?.backgroundColor?.resolve(
        normalStates,
      );
      final side = iconButton.style?.side?.resolve(normalStates);
      final fixedSize = iconButton.style?.fixedSize?.resolve(normalStates);
      final targetSize = tester.getSize(find.byType(IconButton));

      expect(find.byTooltip('Back'), findsOneWidget);
      expect(background?.a, 0);
      expect(side, BorderSide.none);
      expect(fixedSize, const Size.square(kMinInteractiveDimension));
      expect(targetSize.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(targetSize.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    },
  );

  testWidgets('DT1 onSelect: MxActionSheetList pops the selected value', (
    tester,
  ) async {
    String? selectedAction;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                selectedAction = await MxBottomSheet.show<String>(
                  context: context,
                  child: const MxActionSheetList<String>(
                    items: [
                      MxActionSheetItem<String>(
                        value: 'edit',
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                      ),
                      MxActionSheetItem<String>(
                        value: 'delete',
                        label: 'Delete',
                        icon: Icons.delete_outline,
                        tone: MxActionSheetItemTone.destructive,
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(selectedAction, 'delete');
  });

  testWidgets(
    'DT1 onSearchFilterSort: MxDestinationPickerSheet filters and returns a destination',
    (tester) async {
      String? selectedDestination;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selectedDestination =
                      await MxDestinationPickerSheet.show<String>(
                        context: context,
                        title: 'Move to',
                        searchHintText: 'Search destinations',
                        emptyLabel: 'No destinations',
                        destinations: const [
                          MxDestinationOption<String>(
                            value: 'folder-a',
                            title: 'Algebra',
                            subtitle: 'Folder',
                          ),
                          MxDestinationOption<String>(
                            value: 'folder-b',
                            title: 'Biology',
                            subtitle: 'Folder',
                          ),
                        ],
                      );
                },
                child: const Text('Pick destination'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Pick destination'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'alg');
      await tester.pumpAndSettle();

      expect(find.text('Algebra'), findsOneWidget);
      expect(find.text('Biology'), findsNothing);

      await tester.tap(find.text('Algebra'));
      await tester.pumpAndSettle();

      expect(selectedDestination, 'folder-a');
    },
  );

  testWidgets(
    'DT2 onSearchFilterSort: MxSearchSortToolbar reports search and sort changes',
    (tester) async {
      String? searchQuery;
      String? sortValue;

      await tester.pumpWidget(
        _TestApp(
          child: Theme(
            data: AppTheme.dark(),
            child: MxSearchSortToolbar<String>(
              searchHintText: 'Search cards',
              onSearchChanged: (value) => searchQuery = value,
              sortLabel: 'Sort',
              sortOptions: const [
                MxSortOption<String>(value: 'alpha', label: 'A-Z'),
                MxSortOption<String>(
                  value: 'recent',
                  label: 'Recently updated',
                ),
              ],
              onSortSelected: (value) => sortValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'kanji');
      await tester.pump();

      expect(searchQuery, 'kanji');
      expect(find.byType(MenuAnchor), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(OutlinedButton), findsOneWidget);
      final sortButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      final sortShape = sortButton.style?.shape?.resolve(<WidgetState>{});
      final sortMinimumSize = sortButton.style?.minimumSize?.resolve(
        <WidgetState>{},
      );
      expect(sortShape, isA<RoundedRectangleBorder>());
      expect(
        (sortShape! as RoundedRectangleBorder).borderRadius,
        AppRadius.button,
      );
      expect(sortMinimumSize, const Size(0, 36));
      expect(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton),
        findsNothing,
      );

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recently updated').last);
      await tester.pumpAndSettle();

      expect(sortValue, 'recent');
    },
  );

  testWidgets(
    'DT1 onUpdate: MxAnswerOptionCard wraps long text and respects states',
    (tester) async {
      var enabledTapCount = 0;
      var disabledTapCount = 0;
      const longAnswer =
          'This is a deliberately long matching answer that should wrap across '
          'multiple lines instead of truncating the option text.';

      await tester.pumpWidget(
        _TestApp(
          child: Column(
            children: [
              SizedBox(
                width: 220,
                child: MxAnswerOptionCard(
                  label: longAnswer,
                  selected: true,
                  onPressed: () => enabledTapCount += 1,
                ),
              ),
              const SizedBox(height: 12),
              MxAnswerOptionCard(
                label: 'Disabled answer',
                enabled: false,
                onPressed: () => disabledTapCount += 1,
              ),
            ],
          ),
        ),
      );

      final label = tester.widget<Text>(find.text(longAnswer));
      expect(label.softWrap, isTrue);
      expect(label.overflow, TextOverflow.visible);
      expect(label.maxLines, greaterThan(1));
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text(longAnswer));
      await tester.tap(find.text('Disabled answer'));
      await tester.pump();

      expect(enabledTapCount, 1);
      expect(disabledTapCount, 0);
    },
  );

  testWidgets('DT2 onUpdate: shared buttons expose semantic tones', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: Column(
          children: [
            MxPrimaryButton(
              label: 'Remembered',
              tone: MxPrimaryButtonTone.success,
              onPressed: () {},
            ),
            MxSecondaryButton(
              label: 'Forgot',
              tone: MxSecondaryButtonTone.danger,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final primary = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Remembered'),
    );
    final secondary = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Forgot'),
    );
    final primaryStates = <WidgetState>{};
    final secondaryStates = <WidgetState>{};

    expect(
      primary.style?.backgroundColor?.resolve(primaryStates),
      MxColorsExtension.light.success,
    );
    expect(
      primary.style?.foregroundColor?.resolve(primaryStates),
      MxColorsExtension.light.onSuccess,
    );
    expect(
      secondary.style?.foregroundColor?.resolve(secondaryStates),
      MxColorsExtension.light.ratingAgain,
    );
    expect(
      secondary.style?.side?.resolve(secondaryStates)?.color,
      MxColorsExtension.light.ratingAgain,
    );
  });

  testWidgets('DT3 onUpdate: borderless text field uses centered fill style', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 240,
          height: 120,
          child: MxTextField(
            label: 'Answer',
            variant: MxTextFieldVariant.borderless,
            textRole: MxTextRole.fillInput,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            expands: true,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    final decoration = textField.decoration!;
    final style = textField.style!;
    final theme = Theme.of(tester.element(find.byType(TextField)));

    expect(decoration.border, InputBorder.none);
    expect(decoration.enabledBorder, InputBorder.none);
    expect(decoration.focusedBorder, InputBorder.none);
    expect(decoration.labelText, isNull);
    expect(textField.textAlign, TextAlign.center);
    expect(textField.textAlignVertical, TextAlignVertical.center);
    expect(textField.expands, isTrue);
    expect(textField.maxLines, isNull);
    expect(textField.minLines, isNull);
    expect(style.fontSize, theme.textTheme.headlineMedium!.fontSize);
    expect(style.fontWeight, FontWeight.w500);
  });

  testWidgets('DT4 onUpdate: MxSpeakButton reflects idle and speaking states', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _TestApp(
        child: MxSpeakButton(tooltip: 'Speak', onPressed: () => tapCount += 1),
      ),
    );

    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Speak'));
    await tester.pump();

    expect(tapCount, 1);

    await tester.pumpWidget(
      _TestApp(
        child: MxSpeakButton(
          tooltip: 'Stop',
          isSpeaking: true,
          onPressed: () => tapCount += 1,
        ),
      ),
    );

    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
  });

  testWidgets(
    'DT5 onUpdate: MxInlineToggle keeps toggle content compact and interactive',
    (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        _TestApp(
          child: MxInlineToggle(
            label: 'Auto-play',
            subtitle: 'Speak after study transitions.',
            leadingIcon: Icons.volume_up_rounded,
            value: false,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      expect(find.text('Auto-play'), findsOneWidget);
      expect(find.text('Speak after study transitions.'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(changedValue, isTrue);
    },
  );

  testWidgets('DT1 onBehavior: MxFlashcard keeps long content scrollable', (
    tester,
  ) async {
    const longContent =
        'A very long flashcard face that needs to remain readable during study. '
        'It contains several clauses and repeated explanatory text so the card '
        'surface has to scroll instead of clipping the learner-visible answer.';

    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 240,
          child: MxFlashcard(content: longContent, aspectRatio: 0.7),
        ),
      ),
    );

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text(longContent), findsOneWidget);
  });

  testWidgets(
    'DT2 onSelect: MxSegmentedControl adaptive fallback updates selection',
    (tester) async {
      var selected = <int>{1};

      await tester.pumpWidget(
        _TestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 180,
                child: MxSegmentedControl<int>(
                  adaptive: true,
                  segments: const [
                    MxSegment(value: 1, label: 'One'),
                    MxSegment(value: 2, label: 'Two'),
                    MxSegment(value: 3, label: 'Three'),
                  ],
                  selected: selected,
                  onChanged: (value) => setState(() => selected = value),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(SegmentedButton<int>), findsNothing);
      expect(find.byType(RadioListTile<int>), findsNWidgets(3));

      await tester.tap(find.text('Three'));
      await tester.pump();

      expect(selected, {3});
    },
  );

  testWidgets(
    'DT6 onSelect: MxSegmentedControl compact density keeps three options inline',
    (tester) async {
      var selected = <int>{1};

      await tester.pumpWidget(
        _TestApp(
          child: Theme(
            data: AppTheme.light(),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 320,
                  child: MxSegmentedControl<int>(
                    adaptive: true,
                    density: MxSegmentedControlDensity.compact,
                    segments: const [
                      MxSegment(
                        value: 1,
                        label: 'CSV',
                        icon: Icons.table_chart,
                      ),
                      MxSegment(value: 2, label: 'Excel', icon: Icons.grid_on),
                      MxSegment(value: 3, label: 'Text', icon: Icons.notes),
                    ],
                    selected: selected,
                    onChanged: (value) => setState(() => selected = value),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(find.byType(RadioListTile<int>), findsNothing);
      expect(
        tester.getSize(find.byType(SegmentedButton<int>)).height,
        inInclusiveRange(40, 48),
      );

      await tester.tap(find.text('Text'));
      await tester.pump();

      expect(selected, {3});
      final control = tester.widget<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>),
      );
      final selectedColor = control.style?.backgroundColor?.resolve({
        WidgetState.selected,
      });
      expect(
        selectedColor,
        Theme.of(
          tester.element(find.byType(SegmentedButton<int>)),
        ).colorScheme.primary,
      );
    },
  );

  testWidgets(
    'DT3 onSelect: MxSearchSortToolbar renders selected sort button with icon',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: Theme(
            data: AppTheme.dark(),
            child: MxSearchSortToolbar<String>(
              sortLabel: 'Sort',
              selectedSort: 'recent',
              sortOptions: const [
                MxSortOption<String>(
                  value: 'recent',
                  label: 'Newest',
                  icon: Icons.schedule_rounded,
                ),
              ],
              onSortSelected: (_) {},
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final shape = button.style?.shape?.resolve(<WidgetState>{});
      final minimumSize = button.style?.minimumSize?.resolve(<WidgetState>{});

      expect(find.byType(FilterChip), findsNothing);
      expect(shape, isA<RoundedRectangleBorder>());
      expect((shape! as RoundedRectangleBorder).borderRadius, AppRadius.button);
      expect(minimumSize, const Size(0, 36));
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byIcon(Icons.schedule_rounded),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT4 onSelect: MxBulkActionBar renders labels and action buttons',
    (tester) async {
      var archiveTapped = false;
      var moveTapped = false;

      await tester.pumpWidget(
        _TestApp(
          child: MxBulkActionBar(
            label: '3 selected',
            subtitle: 'Move or archive the selected cards.',
            leading: const Icon(Icons.checklist_rounded),
            actions: [
              MxSecondaryButton(
                label: 'Move',
                onPressed: () => moveTapped = true,
              ),
              MxPrimaryButton(
                label: 'Archive',
                onPressed: () => archiveTapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('3 selected'), findsOneWidget);
      expect(find.text('Move or archive the selected cards.'), findsOneWidget);

      await tester.tap(find.text('Move'));
      await tester.pump();
      await tester.tap(find.text('Archive'));
      await tester.pump();

      expect(moveTapped, isTrue);
      expect(archiveTapped, isTrue);
    },
  );

  testWidgets('DT5 onSelect: MxTermRow renders content and selected state', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _TestApp(
        child: MxTermRow(
          term: 'Hello',
          definition: 'Xin chao',
          caption: '2 examples',
          selected: true,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Xin chao'), findsOneWidget);
    expect(find.text('2 examples'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.text('Hello'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('DT1 onMove: MxReorderableList renders keyed items', (
    tester,
  ) async {
    final items = ['One', 'Two', 'Three'];

    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          height: 320,
          child: MxReorderableList.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: ValueKey(items[index]),
                title: Text(items[index]),
              );
            },
            onReorder: (oldIndex, newIndex) {},
          ),
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );
  }
}

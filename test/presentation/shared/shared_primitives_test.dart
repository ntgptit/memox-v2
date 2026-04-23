import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_action_sheet_list.dart';
import 'package:memox/presentation/shared/dialogs/mx_destination_picker_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_bulk_action_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_reorderable_list.dart';
import 'package:memox/presentation/shared/widgets/mx_search_sort_toolbar.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';

void main() {
  testWidgets('MxActionSheetList pops the selected value', (tester) async {
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

  testWidgets('MxDestinationPickerSheet filters and returns a destination', (
    tester,
  ) async {
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
  });

  testWidgets('MxSearchSortToolbar reports search and sort changes', (
    tester,
  ) async {
    String? searchQuery;
    String? sortValue;

    await tester.pumpWidget(
      _TestApp(
        child: MxSearchSortToolbar<String>(
          searchHintText: 'Search cards',
          onSearchChanged: (value) => searchQuery = value,
          sortLabel: 'Sort',
          sortOptions: const [
            MxSortOption<String>(value: 'alpha', label: 'A-Z'),
            MxSortOption<String>(value: 'recent', label: 'Recently updated'),
          ],
          onSortSelected: (value) => sortValue = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'kanji');
    await tester.pump();

    expect(searchQuery, 'kanji');
    expect(find.byType(MenuAnchor), findsOneWidget);
    expect(find.byType(FilterChip), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
      findsNothing,
    );

    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recently updated').last);
    await tester.pumpAndSettle();

    expect(sortValue, 'recent');
  });

  testWidgets(
    'MxSearchSortToolbar keeps selected sort icon without checkmark',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
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
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));

      expect(chip.selected, isTrue);
      expect(chip.showCheckmark, isFalse);
      expect(chip.avatar, isA<Icon>());
    },
  );

  testWidgets('MxBulkActionBar renders labels and action buttons', (
    tester,
  ) async {
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
  });

  testWidgets('MxTermRow renders content and selected state', (tester) async {
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

  testWidgets('MxReorderableList renders keyed items', (tester) async {
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
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );
  }
}

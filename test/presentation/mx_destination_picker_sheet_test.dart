import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_destination_picker_sheet.dart';

void main() {
  testWidgets(
    'DT1 onSearchFilterSort: initial query matches subtitle and search terms',
    (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: MxDestinationPickerSheet<String>(
            initialQuery: 'grammar',
            destinations: [
              MxDestinationOption<String>(
                value: 'deck-1',
                title: 'Korean N5',
                subtitle: 'Folder / Grammar',
              ),
              MxDestinationOption<String>(
                value: 'deck-2',
                title: 'Reading',
                searchTerms: ['grammar drills'],
              ),
              MxDestinationOption<String>(value: 'deck-3', title: 'Listening'),
            ],
          ),
        ),
      );

      expect(find.text('Korean N5'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Listening'), findsNothing);
    },
  );

  testWidgets(
    'DT1 onSearchFilterSort: shows empty label when no destination matches',
    (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: MxDestinationPickerSheet<String>(
            initialQuery: 'missing',
            emptyLabel: 'No matching destinations',
            destinations: [
              MxDestinationOption<String>(value: 'deck-1', title: 'Korean N5'),
            ],
          ),
        ),
      );

      expect(find.text('Korean N5'), findsNothing);
      expect(find.text('No matching destinations'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onSelect: disabled destination does not call selection callback',
    (tester) async {
      String? selected;

      await tester.pumpWidget(
        _TestApp(
          child: MxDestinationPickerSheet<String>(
            popOnSelect: false,
            onSelected: (value) => selected = value,
            destinations: const [
              MxDestinationOption<String>(
                value: 'folder-locked',
                title: 'Locked folder',
                subtitle: 'This folder is locked to decks.',
                enabled: false,
              ),
              MxDestinationOption<String>(
                value: 'folder-open',
                title: 'Open folder',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Locked folder'));
      await tester.pumpAndSettle();

      expect(selected, isNull);

      await tester.tap(find.text('Open folder'));
      await tester.pumpAndSettle();

      expect(selected, 'folder-open');
    },
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: Scaffold(body: child));
}

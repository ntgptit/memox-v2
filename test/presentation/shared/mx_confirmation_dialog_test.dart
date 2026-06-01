import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/presentation/shared/dialogs/mx_confirmation_dialog.dart';

void main() {
  testWidgets('DT1 onCancel: destructive confirmation ignores barrier tap', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await MxConfirmationDialog.show(
                context: context,
                title: 'Delete flashcard?',
                message: 'This cannot be undone.',
                confirmLabel: 'Delete',
                tone: MxConfirmationTone.danger,
              );
            },
            child: const Text('Open dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Delete flashcard?'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets(
    'DT1 onCancel: explicit cancel returns false for destructive confirmation',
    (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await MxConfirmationDialog.show(
                  context: context,
                  title: 'Delete flashcard?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  tone: MxConfirmationTone.danger,
                );
              },
              child: const Text('Open dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete flashcard?'), findsNothing);
      expect(result, isFalse);
    },
  );

  testWidgets(
    'DT1 onConfirm: confirm returns true for destructive confirmation',
    (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await MxConfirmationDialog.show(
                  context: context,
                  title: 'Delete flashcard?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  tone: MxConfirmationTone.danger,
                );
              },
              child: const Text('Open dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete flashcard?'), findsNothing);
      expect(result, isTrue);
    },
  );

  testWidgets(
    'DT1 onCancel: standard confirmation keeps barrier-dismiss behavior',
    (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await MxConfirmationDialog.show(
                  context: context,
                  title: 'Upload local data?',
                  message: 'Upload this device to Drive.',
                  confirmLabel: 'Upload',
                );
              },
              child: const Text('Open dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Upload local data?'), findsNothing);
      expect(result, isFalse);
    },
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

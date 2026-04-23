import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';

void main() {
  testWidgets('confirm button stays disabled for blank input', (
    WidgetTester tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await MxNameDialog.show(
                  context: context,
                  title: 'Create folder',
                  label: 'Folder name',
                  hintText: 'e.g. Listening practice',
                  confirmLabel: 'Create',
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    final confirmButton = find.widgetWithText(ElevatedButton, 'Create');

    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField), 'Grammar');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNotNull);
    expect(result, isNull);
  });

  testWidgets('confirm returns trimmed value', (WidgetTester tester) async {
    String? result;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await MxNameDialog.show(
                  context: context,
                  title: 'Create folder',
                  label: 'Folder name',
                  hintText: 'e.g. Listening practice',
                  confirmLabel: 'Create',
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '  Grammar  ');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();

    expect(result, 'Grammar');
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('done action submits using the same logic as confirm', (
    WidgetTester tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await MxNameDialog.show(
                  context: context,
                  title: 'Rename deck',
                  label: 'Deck name',
                  hintText: 'e.g. Core vocabulary',
                  confirmLabel: 'Save',
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '  Biology  ');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(result, 'Biology');
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('rename dialog places the cursor at the end of initial value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                MxNameDialog.show(
                  context: context,
                  title: 'Rename folder',
                  label: 'Folder name',
                  hintText: 'e.g. Listening practice',
                  confirmLabel: 'Save',
                  initialValue: 'Existing folder',
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    final controller = field.controller!;

    expect(controller.text, 'Existing folder');
    expect(controller.selection.baseOffset, 'Existing folder'.length);
    expect(controller.selection.extentOffset, 'Existing folder'.length);
  });

  testWidgets('dialog does not dismiss when tapping outside', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                MxNameDialog.show(
                  context: context,
                  title: 'Create folder',
                  label: 'Folder name',
                  hintText: 'e.g. Listening practice',
                  confirmLabel: 'Create',
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Create folder'), findsOneWidget);
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

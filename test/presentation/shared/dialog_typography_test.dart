import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/app_typography.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';

void main() {
  testWidgets('MxDialog content inherits Plus Jakarta Sans typography', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Create folder',
                    child: const Text('Dialog body'),
                  );
                },
                child: const Text('Open dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'Dialog body',
      ),
    );

    expect(richText.text.style?.fontFamily, AppTypography.fontFamily);
    expect(find.text('Dialog body'), findsOneWidget);
  });

  testWidgets('MxDialog centers the title when an icon is provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Delete folder',
                    icon: Icons.delete_outline,
                    child: const Text('Dialog body'),
                  );
                },
                child: const Text('Open dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final title = tester.widget<Text>(find.text('Delete folder'));

    expect(title.textAlign, TextAlign.center);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}

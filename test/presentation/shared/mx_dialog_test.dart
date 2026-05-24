import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/responsive/app_layout.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';

void main() {
  testWidgets('DT1 onDisplay: compact dialog stays inside viewport', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(412, 915));

    late double expectedMaxWidth;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final inset =
                  Theme.of(context).dialogTheme.insetPadding ?? EdgeInsets.zero;
              expectedMaxWidth =
                  MediaQuery.sizeOf(context).width - inset.horizontal;

              return const MxDialog(
                title: 'Compact',
                child: SizedBox(width: 1000, child: Text('Dialog body')),
              );
            },
          ),
        ),
      ),
    );

    final dialogSize = tester.getSize(find.byType(Dialog));

    expect(dialogSize.width, lessThanOrEqualTo(expectedMaxWidth));
    expect(dialogSize.width, greaterThanOrEqualTo(expectedMaxWidth - 1));
  });

  testWidgets('DT2 onDisplay: wide dialog caps to AppLayout max width', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(1200, 800));

    late double expectedMaxWidth;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              expectedMaxWidth = context.dialogMaxWidth;
              return const MxDialog(
                title: 'Wide',
                child: SizedBox(width: 1000, child: Text('Dialog body')),
              );
            },
          ),
        ),
      ),
    );

    final dialogSize = tester.getSize(find.byType(Dialog));

    expect(dialogSize.width, lessThanOrEqualTo(expectedMaxWidth));
  });

  testWidgets('DT1 onBehavior: MxDialog.show opens a dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Create folder',
                    child: const Text('Dialog body'),
                  );
                },
                child: const Text('Open dialog'),
              ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Create folder'), findsOneWidget);
    expect(find.text('Dialog body'), findsOneWidget);
  });
}

void _setSurfaceSize(WidgetTester tester, Size size) {
  final view = tester.view;
  view.devicePixelRatio = 1;
  view.physicalSize = size;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
}

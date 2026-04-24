import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';

import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';

void main() {
  testWidgets('library add FAB uses the generic add icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) =>
                  buildLibraryOverviewFab(context, ref),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.create_new_folder_outlined), findsNothing);
  });

  testWidgets('dialog action using dialog context closes only the dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Create folder',
                    child: const Text('Dialog body'),
                    actions: [
                      Builder(
                        builder: (dialogContext) => TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
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

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Dialog body'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Open dialog'), findsOneWidget);
  });
}

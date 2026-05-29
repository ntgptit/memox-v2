import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';

/// P0-2: the V1 card-actions sheet must offer only Edit / Bury / Suspend.
/// Flashcard History is Future Proposal and must NOT appear.
void main() {
  /// Pumps a launcher that opens [MxCardActionsSheet.show] and records the
  /// resolved action in [result].
  Future<void> openSheet(
    WidgetTester tester,
    void Function(MxCardAction? action) onResolved,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async =>
                    onResolved(await MxCardActionsSheet.show(context: context)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders only the V1 actions (Edit / Bury / Suspend)', (
    tester,
  ) async {
    await openSheet(tester, (_) {});

    expect(find.text('Card actions'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Bury until tomorrow'), findsOneWidget);
    expect(find.text('Suspend card'), findsOneWidget);
  });

  testWidgets('does not expose a History action', (tester) async {
    await openSheet(tester, (_) {});

    expect(find.textContaining('History'), findsNothing);
    expect(find.textContaining('history'), findsNothing);
  });

  testWidgets('resolves to the selected action and dismisses', (tester) async {
    MxCardAction? resolved;
    var resolvedCalled = false;
    await openSheet(tester, (action) {
      resolved = action;
      resolvedCalled = true;
    });

    await tester.tap(find.text('Bury until tomorrow'));
    await tester.pumpAndSettle();

    expect(resolvedCalled, isTrue);
    expect(resolved, MxCardAction.bury);
    expect(find.text('Bury until tomorrow'), findsNothing);
  });
}

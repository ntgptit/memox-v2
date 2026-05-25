import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_form_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_list_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/mx_study_top_bar.dart';

void main() {
  testWidgets(
    'MxListScaffold renders list chrome and body without data state',
    (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: MxListScaffold(
            title: 'Decks',
            floatingActionButton: FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
            body: Text('Deck list section'),
          ),
        ),
      );

      expect(find.text('Decks'), findsOneWidget);
      expect(find.text('Deck list section'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets('MxFormScaffold keeps submit action separate from scroll body', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: MxFormScaffold(
          title: 'New card',
          body: Column(
            children: [
              TextField(key: ValueKey<String>('front_field')),
              SizedBox(height: 900),
              TextField(key: ValueKey<String>('back_field')),
            ],
          ),
          bottomAction: FilledButton(onPressed: null, child: Text('Save')),
        ),
      ),
    );

    expect(find.text('New card'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('front_field')), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('back_field')), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets(
    'MxStudyScaffold renders study chrome and optional bottom action',
    (tester) async {
      var closed = false;

      await tester.pumpWidget(
        _TestApp(
          child: MxStudyScaffold(
            modeLabel: 'Review',
            accent: MxStudyTopBarAccent.primary,
            progressValue: 0.5,
            counterLabel: '2 / 4',
            closeTooltip: 'Close study',
            onClose: () => closed = true,
            body: const Text('Study card'),
            bottomAction: const FilledButton(
              onPressed: null,
              child: Text('Answer'),
            ),
          ),
        ),
      );

      expect(find.text('REVIEW'), findsOneWidget);
      expect(find.text('2 / 4'), findsOneWidget);
      expect(find.text('Study card'), findsOneWidget);
      expect(find.text('Answer'), findsOneWidget);

      await tester.tap(find.byTooltip('Close study'));
      await tester.pump();

      expect(closed, isTrue);
    },
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

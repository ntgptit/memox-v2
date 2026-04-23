import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/presentation/shared/widgets/mx_term_row.dart';

void main() {
  testWidgets('root smoke widget test renders a term row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MxTermRow(
            term: 'Greeting',
            definition: 'Hello -> Xin chao',
            caption: 'Basic greeting',
          ),
        ),
      ),
    );

    expect(find.text('Greeting'), findsOneWidget);
    expect(find.text('Hello -> Xin chao'), findsOneWidget);
    expect(find.text('Basic greeting'), findsOneWidget);
  });
}

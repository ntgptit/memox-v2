// Smoke test for MemoX.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memox/app/app.dart';
import 'package:memox/presentation/shared/layouts/mx_adaptive_scaffold.dart';

void main() {
  testWidgets('MemoxApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MemoxApp()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MxAdaptiveScaffold), findsOneWidget);
  });

  testWidgets('Library folder tiles open the folder detail route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MemoxApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Japanese N5'));
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
  });
}

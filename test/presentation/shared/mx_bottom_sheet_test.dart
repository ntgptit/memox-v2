import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';

void main() {
  testWidgets(
    'DT1 onBehavior: MxBottomSheet applies bottom viewInsets outside content padding',
    (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          viewInsets: EdgeInsets.only(bottom: 160),
          child: MxBottomSheet(
            title: 'Import cards',
            child: SizedBox(height: 80, child: Text('Sheet content')),
          ),
        ),
      );

      final animatedPadding = tester.widget<AnimatedPadding>(
        find.descendant(
          of: find.byType(MxBottomSheet),
          matching: find.byType(AnimatedPadding),
        ),
      );
      final resolvedPadding = animatedPadding.padding.resolve(
        TextDirection.ltr,
      );

      expect(resolvedPadding.bottom, 160);
      expect(find.text('Sheet content'), findsOneWidget);
    },
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.viewInsets = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets viewInsets;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(viewInsets: viewInsets),
        child: Material(child: child),
      ),
    );
  }
}

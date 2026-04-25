import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';

void main() {
  testWidgets('MxGap adds horizontal spacing inside Row', (tester) async {
    const firstKey = ValueKey('first');
    const secondKey = ValueKey('second');

    await tester.pumpWidget(
      const _Host(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(key: firstKey, width: 10, height: 10),
            MxGap(20),
            SizedBox(key: secondKey, width: 10, height: 10),
          ],
        ),
      ),
    );

    final firstRight = tester.getTopRight(find.byKey(firstKey)).dx;
    final secondLeft = tester.getTopLeft(find.byKey(secondKey)).dx;

    expect(secondLeft - firstRight, 20);
  });

  testWidgets('MxGap adds vertical spacing inside Column', (tester) async {
    const firstKey = ValueKey('first');
    const secondKey = ValueKey('second');

    await tester.pumpWidget(
      const _Host(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(key: firstKey, width: 10, height: 10),
            MxGap(20),
            SizedBox(key: secondKey, width: 10, height: 10),
          ],
        ),
      ),
    );

    final firstBottom = tester.getBottomLeft(find.byKey(firstKey)).dy;
    final secondTop = tester.getTopLeft(find.byKey(secondKey)).dy;

    expect(secondTop - firstBottom, 20);
  });

  testWidgets('MxGap follows ListView scroll direction', (tester) async {
    const firstKey = ValueKey('first');
    const secondKey = ValueKey('second');

    await tester.pumpWidget(
      _Host(
        child: SizedBox(
          width: 120,
          height: 20,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(key: firstKey, width: 10, height: 10),
              MxGap(20),
              SizedBox(key: secondKey, width: 10, height: 10),
            ],
          ),
        ),
      ),
    );

    final firstRight = tester.getTopRight(find.byKey(firstKey)).dx;
    final secondLeft = tester.getTopLeft(find.byKey(secondKey)).dx;

    expect(secondLeft - firstRight, 20);
  });

  testWidgets('MxSliverGap renders spacing inside CustomScrollView', (
    tester,
  ) async {
    const firstKey = ValueKey('first');
    const secondKey = ValueKey('second');

    await tester.pumpWidget(
      const _Host(
        child: SizedBox(
          height: 120,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(key: firstKey, width: 10, height: 10),
              ),
              MxSliverGap(20),
              SliverToBoxAdapter(
                child: SizedBox(key: secondKey, width: 10, height: 10),
              ),
            ],
          ),
        ),
      ),
    );

    final firstBottom = tester.getBottomLeft(find.byKey(firstKey)).dy;
    final secondTop = tester.getTopLeft(find.byKey(secondKey)).dy;

    expect(secondTop - firstBottom, 20);
  });
}

class _Host extends StatelessWidget {
  const _Host({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    );
  }
}

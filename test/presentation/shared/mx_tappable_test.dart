import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/app_spacing.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/widgets/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/mx_folder_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_page_dots.dart';
import 'package:memox/presentation/shared/widgets/mx_study_set_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

void main() {
  testWidgets('DT1 onDisplay: MxTappable wires Material clipping and InkWell shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: MxTappable(
          shape: StadiumBorder(),
          onTap: _noop,
          child: SizedBox(width: 40, height: 24),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(MxTappable),
        matching: find.byType(Material),
      ),
    );
    final inkWell = tester.widget<InkWell>(
      find.descendant(
        of: find.byType(MxTappable),
        matching: find.byType(InkWell),
      ),
    );

    expect(material.shape, isA<StadiumBorder>());
    expect(material.clipBehavior, Clip.antiAlias);
    expect(inkWell.customBorder, isA<StadiumBorder>());
  });

  testWidgets('DT1 onNavigate: MxFolderTile routes tap handling through MxTappable', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _TestApp(
        child: MxFolderTile(
          name: 'Japanese',
          icon: Icons.folder_outlined,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.byType(MxTappable), findsOneWidget);

    await tester.tap(find.text('Japanese'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('DT2 onNavigate: MxStudySetTile keeps the widened gap between icon and content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: MxStudySetTile(
          title: 'Vitamin B1',
          metaLine: '1 cards · 0 due today',
          icon: Icons.style_outlined,
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(MxStudySetTile),
        matching: find.byWidgetPredicate(
          (widget) => widget is MxGap && widget.size == AppSpacing.lg,
        ),
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('DT1 onBehavior: MxAvatar keeps spacing between avatar and badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: MxAvatar(initials: 'MX', badgeLabel: 'Plus'),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(MxAvatar),
        matching: find.byWidgetPredicate(
          (widget) => widget is MxGap && widget.size == AppSpacing.sm,
        ),
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('DT3 onNavigate: MxPageDots uses shaped tap surfaces for dot taps', (
    tester,
  ) async {
    int? tappedIndex;

    await tester.pumpWidget(
      _TestApp(
        child: MxPageDots(
          count: 3,
          activeIndex: 1,
          onDotTap: (index) => tappedIndex = index,
        ),
      ),
    );

    expect(find.byType(MxTappable), findsNWidgets(3));
    expect(
      tester.getSize(find.byType(MxTappable).at(0)).width,
      greaterThanOrEqualTo(kMinInteractiveDimension),
    );
    expect(
      tester.getSize(find.byType(MxTappable).at(0)).height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
    );

    await tester.tap(find.byType(MxTappable).at(2));
    await tester.pump();

    expect(tappedIndex, 2);
  });

  testWidgets('DT1 onSelect: MxPageDots exposes page position and selected semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      late String selectedLabel;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) {
              selectedLabel = MaterialLocalizations.of(
                context,
              ).tabLabel(tabIndex: 2, tabCount: 3);
              return const MxPageDots(count: 3, activeIndex: 1);
            },
          ),
        ),
      );

      final selectedNode = tester.getSemantics(
        find.bySemanticsLabel(selectedLabel),
      );

      expect(selectedNode.flagsCollection.isSelected, Tristate.isTrue);
      expect(selectedNode.flagsCollection.isButton, isFalse);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('DT1 onUpdate: MxPageDots marks tappable dots as semantic buttons', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      late String selectedLabel;

      await tester.pumpWidget(
        _TestApp(
          child: Builder(
            builder: (context) {
              selectedLabel = MaterialLocalizations.of(
                context,
              ).tabLabel(tabIndex: 2, tabCount: 3);
              return MxPageDots(count: 3, activeIndex: 1, onDotTap: (_) {});
            },
          ),
        ),
      );

      final selectedNode = tester.getSemantics(
        find.bySemanticsLabel(selectedLabel),
      );

      expect(selectedNode.flagsCollection.isSelected, Tristate.isTrue);
      expect(selectedNode.flagsCollection.isButton, isTrue);
    } finally {
      semanticsHandle.dispose();
    }
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }
}

void _noop() {}

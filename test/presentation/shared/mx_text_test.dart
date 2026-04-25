import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/layouts/mx_section.dart';
import 'package:memox/presentation/shared/widgets/mx_study_set_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

void main() {
  testWidgets('DT1 onUpdate: MxText resolves pageTitle from the active theme', (
    tester,
  ) async {
    late TextStyle expectedStyle;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              expectedStyle = theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.onSurface,
              );
              return const MxText('Library', role: MxTextRole.pageTitle);
            },
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Library'));

    expect(text.style?.fontSize, expectedStyle.fontSize);
    expect(text.style?.fontWeight, expectedStyle.fontWeight);
    expect(text.style?.color, expectedStyle.color);
  });

  testWidgets('DT1 onDisplay: MxText applies semantic role color override', (tester) async {
    const overrideColor = Colors.deepOrange;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MxText(
            'Folders',
            role: MxTextRole.breadcrumb,
            color: overrideColor,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Folders'));

    expect(text.style?.color, overrideColor);
  });

  testWidgets('DT2 onDisplay: MxSection renders semantic title and subtitle roles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MxSection(
            title: 'Folders',
            subtitle: 'Manage your folder tree',
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'Folders' &&
            widget.role == MxTextRole.sectionTitle,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'Manage your folder tree' &&
            widget.role == MxTextRole.sectionSubtitle,
      ),
      findsOneWidget,
    );
  });

  testWidgets('DT1 onNavigate: MxStudySetTile renders title and meta with semantic roles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MxStudySetTile(
            title: 'Vitamin B1',
            icon: Icons.style_outlined,
            metaLine: '1 cards · 0 due today',
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'Vitamin B1' &&
            widget.role == MxTextRole.tileTitle,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == '1 cards · 0 due today' &&
            widget.role == MxTextRole.tileMeta,
      ),
      findsOneWidget,
    );
  });
}

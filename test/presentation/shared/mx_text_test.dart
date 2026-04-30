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

  testWidgets(
    'DT2 onUpdate: MxText resolves guessPrompt below display typography',
    (tester) async {
      late TextStyle expectedStyle;
      late double displayFontSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                expectedStyle = theme.textTheme.headlineMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                );
                displayFontSize = theme.textTheme.displayMedium!.fontSize!;
                return const MxText('상식', role: MxTextRole.guessPrompt);
              },
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('상식'));

      expect(text.style?.fontSize, expectedStyle.fontSize);
      expect(text.style?.fontSize, lessThan(displayFontSize));
      expect(text.style?.fontWeight, expectedStyle.fontWeight);
      expect(text.style?.color, expectedStyle.color);
    },
  );

  testWidgets(
    'DT3 onUpdate: MxText resolves recall roles with fixed hierarchy',
    (tester) async {
      late Color expectedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                expectedColor = Theme.of(context).colorScheme.onSurface;
                return const Column(
                  children: [
                    MxText('신고하다', role: MxTextRole.recallFront),
                    MxText('Report / Báo cáo', role: MxTextRole.recallBack),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final front = tester.widget<Text>(find.text('신고하다'));
      final back = tester.widget<Text>(find.text('Report / Báo cáo'));

      expect(front.style?.fontSize, greaterThan(back.style!.fontSize!));
      expect(front.style?.fontWeight, FontWeight.w500);
      expect(back.style?.fontWeight, FontWeight.w400);
      expect(front.style?.color, expectedColor);
      expect(back.style?.color, expectedColor);
    },
  );

  testWidgets(
    'DT4 onUpdate: MxText resolves fill roles with semantic hierarchy',
    (tester) async {
      late Color expectedOnSurface;
      late Color expectedError;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final scheme = Theme.of(context).colorScheme;
                expectedOnSurface = scheme.onSurface;
                expectedError = scheme.error;
                return const Column(
                  children: [
                    MxText('meaning', role: MxTextRole.fillPrompt),
                    MxText('term', role: MxTextRole.fillInput),
                    MxText('wrong', role: MxTextRole.fillIncorrectInput),
                    MxText('right', role: MxTextRole.fillCorrectAnswer),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final prompt = tester.widget<Text>(find.text('meaning'));
      final input = tester.widget<Text>(find.text('term'));
      final incorrect = tester.widget<Text>(find.text('wrong'));
      final correct = tester.widget<Text>(find.text('right'));

      expect(input.style?.fontSize, greaterThan(prompt.style!.fontSize!));
      expect(input.style?.fontWeight, FontWeight.w500);
      expect(incorrect.style?.color, expectedError);
      expect(correct.style?.color, expectedOnSurface);
      expect(correct.style?.fontWeight, FontWeight.w500);
    },
  );

  testWidgets('DT5 onUpdate: MxText resolves sheet roles below page title', (
    tester,
  ) async {
    late TextStyle expectedSheetTitle;
    late TextStyle expectedActionItem;
    late TextStyle expectedActionSubtitle;
    late double pageTitleFontSize;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              expectedSheetTitle = theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              );
              expectedActionItem = theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onSurface,
              );
              expectedActionSubtitle = theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              );
              pageTitleFontSize = theme.textTheme.titleLarge!.fontSize!;

              return const Column(
                children: [
                  MxText('Create', role: MxTextRole.sheetTitle),
                  MxText('New deck', role: MxTextRole.actionSheetItem),
                  MxText('Choose cards', role: MxTextRole.actionSheetSubtitle),
                ],
              );
            },
          ),
        ),
      ),
    );

    final sheetTitle = tester.widget<Text>(find.text('Create'));
    final actionItem = tester.widget<Text>(find.text('New deck'));
    final actionSubtitle = tester.widget<Text>(find.text('Choose cards'));

    expect(sheetTitle.style?.fontSize, expectedSheetTitle.fontSize);
    expect(sheetTitle.style?.fontSize, lessThan(pageTitleFontSize));
    expect(sheetTitle.style?.color, expectedSheetTitle.color);
    expect(actionItem.style?.fontSize, expectedActionItem.fontSize);
    expect(actionItem.style?.color, expectedActionItem.color);
    expect(actionSubtitle.style?.fontSize, expectedActionSubtitle.fontSize);
    expect(actionSubtitle.style?.color, expectedActionSubtitle.color);
  });

  testWidgets('DT1 onDisplay: MxText applies semantic role color override', (
    tester,
  ) async {
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

  testWidgets(
    'DT2 onDisplay: MxSection renders semantic title and subtitle roles',
    (tester) async {
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
    },
  );

  testWidgets(
    'DT1 onNavigate: MxStudySetTile renders title and meta with semantic roles',
    (tester) async {
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
    },
  );
}

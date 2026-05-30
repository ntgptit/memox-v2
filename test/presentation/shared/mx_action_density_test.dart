import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/widgets/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';

void _noop() {}

/// Pumps [child] under the app theme with an overridden logical [size] so
/// `context.isCompactMobile` can be exercised independent of the test surface.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 600),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(size: size),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
  await tester.pump();
}

double? _minHeight(ButtonStyle? style) =>
    style?.minimumSize?.resolve(<WidgetState>{})?.height;

void main() {
  group('MxActionButton intent density', () {
    testWidgets('cardPrimary uses compact, not large, visual height', (
      tester,
    ) async {
      const key = ValueKey('action-card-primary');
      await _pump(
        tester,
        const MxActionButton(
          key: key,
          intent: MxActionIntent.cardPrimary,
          label: 'Study',
          onPressed: _noop,
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.descendant(of: find.byKey(key), matching: find.byType(ElevatedButton)),
      );
      final height = _minHeight(button.style);
      expect(height, 40, reason: 'cardPrimary resolves to compact (40dp)');
      expect(height, lessThan(52), reason: 'cardPrimary must not be large');
    });

    testWidgets('cardSecondary is visually lighter than cardPrimary', (
      tester,
    ) async {
      const primaryKey = ValueKey('action-primary');
      const secondaryKey = ValueKey('action-secondary');
      await _pump(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxActionButton(
              key: primaryKey,
              intent: MxActionIntent.cardPrimary,
              label: 'Study',
              onPressed: _noop,
            ),
            MxActionButton(
              key: secondaryKey,
              intent: MxActionIntent.cardSecondary,
              label: 'Edit',
              onPressed: _noop,
            ),
          ],
        ),
      );

      // Primary renders the filled ElevatedButton; secondary renders the
      // lighter tonal FilledButton and never the elevated primitive.
      expect(
        find.descendant(
          of: find.byKey(primaryKey),
          matching: find.byType(ElevatedButton),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(secondaryKey),
          matching: find.byType(ElevatedButton),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(secondaryKey),
          matching: find.byType(FilledButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('inline is smaller than cardPrimary', (tester) async {
      const cardKey = ValueKey('action-inline-card');
      const inlineKey = ValueKey('action-inline');
      await _pump(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxActionButton(
              key: cardKey,
              intent: MxActionIntent.cardPrimary,
              label: 'Study',
              onPressed: _noop,
            ),
            MxActionButton(
              key: inlineKey,
              intent: MxActionIntent.inline,
              label: 'Undo',
              onPressed: _noop,
            ),
          ],
        ),
      );

      final cardHeight = _minHeight(
        tester
            .widget<ElevatedButton>(
              find.descendant(
                of: find.byKey(cardKey),
                matching: find.byType(ElevatedButton),
              ),
            )
            .style,
      );
      final inlineHeight = _minHeight(
        tester
            .widget<TextButton>(
              find.descendant(
                of: find.byKey(inlineKey),
                matching: find.byType(TextButton),
              ),
            )
            .style,
      );
      expect(inlineHeight, lessThan(cardHeight!));
    });

    testWidgets('cardPrimary is not full-width by default', (tester) async {
      const key = ValueKey('action-card-not-fullwidth');
      await _pump(
        tester,
        const SizedBox(
          width: 320, // guard:raw-size-reviewed test host width
          child: Align(
            alignment: Alignment.centerLeft,
            child: MxActionButton(
              key: key,
              intent: MxActionIntent.cardPrimary,
              label: 'Study',
              onPressed: _noop,
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(key)).width, lessThan(320));
    });

    testWidgets('bottomAction stretches full-width', (tester) async {
      const key = ValueKey('action-bottom');
      await _pump(
        tester,
        const SizedBox(
          width: 320, // guard:raw-size-reviewed test host width
          child: Align(
            alignment: Alignment.centerLeft,
            child: MxActionButton(
              key: key,
              intent: MxActionIntent.bottomAction,
              label: 'Start session',
              onPressed: _noop,
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(key)).width, 320);
    });

    testWidgets('semantic compact action keeps a 48dp touch target', (
      tester,
    ) async {
      const key = ValueKey('action-touch-target');
      await _pump(
        tester,
        const Align(
          child: MxActionButton(
            key: key,
            intent: MxActionIntent.cardPrimary,
            label: 'Study',
            onPressed: _noop,
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(key)).height,
        greaterThanOrEqualTo(kMinInteractiveDimension),
      );
    });
  });

  group('MxPrimaryButton stretch neutralization', () {
    testWidgets('large does not auto full-width on compact mobile width', (
      tester,
    ) async {
      const key = ValueKey('primary-large-compact');
      await _pump(
        tester,
        const SizedBox(
          width: 320, // guard:raw-size-reviewed test host width
          child: Align(
            alignment: Alignment.centerLeft,
            child: MxPrimaryButton(
              key: key,
              label: 'Continue',
              size: MxButtonSize.large,
              onPressed: _noop,
            ),
          ),
        ),
        size: const Size(360, 800),
      );

      expect(tester.getSize(find.byKey(key)).width, lessThan(320));
    });

    testWidgets('fullWidth: true still stretches explicitly', (tester) async {
      const key = ValueKey('primary-explicit-fullwidth');
      await _pump(
        tester,
        const SizedBox(
          width: 320, // guard:raw-size-reviewed test host width
          child: Align(
            alignment: Alignment.centerLeft,
            child: MxPrimaryButton(
              key: key,
              label: 'Continue',
              fullWidth: true,
              onPressed: _noop,
            ),
          ),
        ),
        size: const Size(360, 800),
      );

      expect(tester.getSize(find.byKey(key)).width, 320);
    });
  });

  group('MxCardActions layout', () {
    testWidgets('renders primary only', (tester) async {
      const key = ValueKey('card-actions-primary-only');
      await _pump(
        tester,
        const MxCardActions(
          key: key,
          primary: MxActionButton(
            intent: MxActionIntent.cardPrimary,
            label: 'Study',
            onPressed: _noop,
          ),
        ),
      );

      expect(find.text('Study'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('renders primary and secondary', (tester) async {
      const key = ValueKey('card-actions-both');
      await _pump(
        tester,
        const MxCardActions(
          key: key,
          primary: MxActionButton(
            intent: MxActionIntent.cardPrimary,
            label: 'Study',
            onPressed: _noop,
          ),
          secondary: MxActionButton(
            intent: MxActionIntent.cardSecondary,
            label: 'Edit',
            onPressed: _noop,
          ),
        ),
      );

      expect(find.text('Study'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('does not overflow or hero-stretch at 360dp', (tester) async {
      const key = ValueKey('card-actions-360');
      await _pump(
        tester,
        const SizedBox(
          width: 360, // guard:raw-size-reviewed compact phone width
          child: MxCardActions(
            key: key,
            primary: MxActionButton(
              intent: MxActionIntent.cardPrimary,
              label: 'Study',
              onPressed: _noop,
            ),
            secondary: MxActionButton(
              intent: MxActionIntent.cardSecondary,
              label: 'Edit',
              onPressed: _noop,
            ),
          ),
        ),
        size: const Size(360, 800),
      );

      expect(tester.takeException(), isNull);

      // Neither card action becomes a full-width hero button.
      final primaryWidth = tester
          .getSize(
            find.descendant(
              of: find.byKey(key),
              matching: find.byType(ElevatedButton),
            ),
          )
          .width;
      expect(primaryWidth, lessThan(360));
    });
  });
}

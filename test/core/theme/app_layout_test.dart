import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/responsive/app_breakpoints.dart';
import 'package:memox/core/theme/responsive/app_layout.dart';
import 'package:memox/core/theme/tokens/app_radius.dart';
import 'package:memox/core/theme/tokens/app_spacing.dart';

void main() {
  group('AppLayout page padding', () {
    test(
      'DT1 pagePadding: compact mobile keeps the standard 16 dp edge inset',
      () {
        final padding = AppLayout.pagePadding(
          WindowSize.compact,
          compactMobile: true,
        );

        expect(padding.left, AppSpacing.lg);
        expect(padding.right, AppSpacing.lg);
      },
    );

    test(
      'DT2 pagePadding: compact width keeps the standard 16 dp edge inset',
      () {
        final padding = AppLayout.pagePadding(
          WindowSize.compact,
          compactMobile: false,
        );

        expect(padding.left, AppSpacing.lg);
        expect(padding.right, AppSpacing.lg);
      },
    );

    test('DT3 pagePadding: medium width uses the 20 dp edge inset', () {
      final padding = AppLayout.pagePadding(WindowSize.medium);

      expect(padding.left, AppSpacing.xl);
      expect(padding.right, AppSpacing.xl);
    });

    test('DT4 pagePadding: expanded width uses the 24 dp edge inset', () {
      final padding = AppLayout.pagePadding(WindowSize.expanded);

      expect(padding.left, AppSpacing.xxl);
      expect(padding.right, AppSpacing.xxl);
    });
  });

  group('AppLayout final visual density', () {
    testWidgets('DT1 cardDensity: card padding and radius match mobile mock', (
      tester,
    ) async {
      await tester.pumpWidget(const _LayoutProbe(child: _CardDensityProbe()));

      final probe = tester.widget<_CardDensityProbeResult>(
        find.byType(_CardDensityProbeResult),
      );
      expect(probe.padding, AppSpacing.card);
      expect(probe.radius, AppRadius.card);
      expect(AppSpacing.card, const EdgeInsets.all(AppSpacing.md));
      expect(AppRadius.card, AppRadius.borderSemi);
    });

    testWidgets('DT2 chromeDensity: compact bottom navigation height is 64dp', (
      tester,
    ) async {
      await tester.pumpWidget(
        const _LayoutProbe(
          size: Size(360, 800),
          child: _NavigationDensityProbe(),
        ),
      );

      final probe = tester.widget<_NavigationDensityProbeResult>(
        find.byType(_NavigationDensityProbeResult),
      );
      expect(probe.height, 64);
    });
  });
}

class _LayoutProbe extends StatelessWidget {
  const _LayoutProbe({required this.child, this.size = const Size(360, 800)});

  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQueryData(size: size),
    child: child,
  );
}

class _CardDensityProbe extends StatelessWidget {
  const _CardDensityProbe();

  @override
  Widget build(BuildContext context) => _CardDensityProbeResult(
    padding: AppLayout.cardPadding(context),
    radius: AppLayout.cardRadius(context),
  );
}

class _CardDensityProbeResult extends StatelessWidget {
  const _CardDensityProbeResult({required this.padding, required this.radius});

  final EdgeInsets padding;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _NavigationDensityProbe extends StatelessWidget {
  const _NavigationDensityProbe();

  @override
  Widget build(BuildContext context) => _NavigationDensityProbeResult(
    height: AppLayout.navigationBarHeight(context),
  );
}

class _NavigationDensityProbeResult extends StatelessWidget {
  const _NavigationDensityProbeResult({required this.height});

  final double? height;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

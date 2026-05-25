import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/responsive/app_breakpoints.dart';
import 'package:memox/core/theme/responsive/app_layout.dart';
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
}

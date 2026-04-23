import 'package:flutter_test/flutter_test.dart';

import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/app_typography.dart';

void main() {
  group('AppTheme typography', () {
    test('light theme uses Plus Jakarta Sans across theme surfaces', () {
      final theme = AppTheme.light();

      expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);
      expect(theme.textTheme.titleLarge?.fontFamily, AppTypography.fontFamily);
      expect(
        theme.primaryTextTheme.bodyMedium?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.appBarTheme.titleTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.dialogTheme.titleTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.dialogTheme.contentTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.popupMenuTheme.textStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.tooltipTheme.textStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.inputDecorationTheme.labelStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.sliderTheme.valueIndicatorTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
    });

    test('dark theme uses Plus Jakarta Sans across theme surfaces', () {
      final theme = AppTheme.dark();

      expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);
      expect(theme.textTheme.titleLarge?.fontFamily, AppTypography.fontFamily);
      expect(
        theme.primaryTextTheme.bodyMedium?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.appBarTheme.titleTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.dialogTheme.titleTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.popupMenuTheme.textStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.tooltipTheme.textStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.inputDecorationTheme.labelStyle?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.sliderTheme.valueIndicatorTextStyle?.fontFamily,
        AppTypography.fontFamily,
      );
    });
  });
}

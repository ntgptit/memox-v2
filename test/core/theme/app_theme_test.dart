import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/app_radius.dart';
import 'package:memox/core/theme/tokens/app_typography.dart';

void main() {
  group('AppTheme Tokyo-adapted palette', () {
    test('DT1 onUpdate: light theme maps Tokyo Pure Light colors to Material roles', () {
      final theme = AppTheme.light();
      final scheme = theme.colorScheme;

      expect(scheme.surface, const Color(0xFFF2F5F9));
      expect(scheme.surfaceContainerLow, const Color(0xFFFFFFFF));
      expect(scheme.primary, const Color(0xFF5569FF));
      expect(scheme.onSurface, const Color(0xFF223354));
      expect(scheme.outlineVariant, const Color(0xFFD8DEEB));
      expect(theme.cardTheme.color, scheme.surfaceContainerLow);
      expect(theme.inputDecorationTheme.fillColor, scheme.surfaceContainerLow);
      expect(
        theme.navigationBarTheme.backgroundColor,
        scheme.surfaceContainerLow,
      );
      expect(theme.navigationBarTheme.indicatorColor, scheme.primary);
    });

    test('DT2 onUpdate: dark theme maps Tokyo Nebula colors to Material roles', () {
      final theme = AppTheme.dark();
      final scheme = theme.colorScheme;

      expect(scheme.surface, const Color(0xFF070C27));
      expect(scheme.surfaceContainerLow, const Color(0xFF111633));
      expect(scheme.primary, const Color(0xFF8C7CF0));
      expect(scheme.onSurfaceVariant, const Color(0xFF9EA4C1));
      expect(scheme.outlineVariant, const Color(0xFF272C48));
      expect(theme.cardTheme.color, scheme.surfaceContainerLow);
      expect(theme.inputDecorationTheme.fillColor, scheme.surfaceContainerLow);
      expect(
        theme.navigationBarTheme.backgroundColor,
        scheme.surfaceContainerLow,
      );
      expect(theme.navigationBarTheme.indicatorColor, scheme.primary);
    });

    test('DT1 onDisplay: component shapes use compact Tokyo radii', () {
      final theme = AppTheme.light();
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      final inputBorder = theme.inputDecorationTheme.enabledBorder;

      expect(cardShape.borderRadius, AppRadius.card);
      expect(inputBorder, isA<OutlineInputBorder>());
      expect((inputBorder as OutlineInputBorder).borderRadius, AppRadius.input);
      expect(
        theme.elevatedButtonTheme.style?.shape?.resolve(<WidgetState>{}),
        const RoundedRectangleBorder(borderRadius: AppRadius.button),
      );
    });
  });

  group('AppTheme typography', () {
    test('DT3 onUpdate: light theme uses Plus Jakarta Sans across theme surfaces', () {
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
        theme.menuButtonTheme.style?.textStyle
            ?.resolve(<WidgetState>{})
            ?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.menuButtonTheme.style?.shape?.resolve(<WidgetState>{}),
        isA<RoundedRectangleBorder>(),
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

    test('DT4 onUpdate: dark theme uses Plus Jakarta Sans across theme surfaces', () {
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
        theme.menuButtonTheme.style?.textStyle
            ?.resolve(<WidgetState>{})
            ?.fontFamily,
        AppTypography.fontFamily,
      );
      expect(
        theme.menuButtonTheme.style?.shape?.resolve(<WidgetState>{}),
        isA<RoundedRectangleBorder>(),
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

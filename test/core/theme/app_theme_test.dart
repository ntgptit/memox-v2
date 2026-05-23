import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/extensions/theme_extensions.dart';
import 'package:memox/core/theme/tokens/app_colors.dart';
import 'package:memox/core/theme/tokens/app_radius.dart';
import 'package:memox/core/theme/tokens/app_typography.dart';

void main() {
  group('AppTheme Tokyo-adapted palette', () {
    test(
      'DT1 onUpdate: light theme maps Tokyo Pure Light colors to Material roles',
      () {
        final theme = AppTheme.light();
        final scheme = theme.colorScheme;

        expect(scheme.surface, AppColors.lightSurface);
        expect(scheme.surfaceContainerLow, AppColors.lightSurfaceContainerLow);
        expect(scheme.primary, AppColors.lightPrimary40);
        expect(scheme.onSurface, AppColors.lightNeutral10);
        expect(scheme.onSurfaceVariant, AppColors.lightNeutral20);
        expect(scheme.outlineVariant, AppColors.lightNeutralVariant90);
        expect(theme.cardTheme.color, scheme.surfaceContainerLow);
        expect(
          theme.inputDecorationTheme.fillColor,
          scheme.surfaceContainerLow,
        );
        expect(
          theme.navigationBarTheme.backgroundColor,
          scheme.surfaceContainerLow,
        );
        expect(theme.navigationBarTheme.indicatorColor, scheme.primary);
      },
    );

    test(
      'DT2 onUpdate: dark theme maps Tokyo Nebula colors to Material roles',
      () {
        final theme = AppTheme.dark();
        final scheme = theme.colorScheme;

        expect(scheme.surface, AppColors.darkNavy5);
        expect(scheme.surfaceContainerLow, AppColors.darkNavy15);
        expect(scheme.primary, AppColors.darkPrimary80);
        expect(scheme.onSurfaceVariant, AppColors.darkNeutral70);
        expect(scheme.outlineVariant, AppColors.darkNavyOutlineVariant);
        expect(theme.cardTheme.color, scheme.surfaceContainerLow);
        expect(
          theme.inputDecorationTheme.fillColor,
          scheme.surfaceContainerLow,
        );
        expect(
          theme.navigationBarTheme.backgroundColor,
          scheme.surfaceContainerLow,
        );
        expect(theme.navigationBarTheme.indicatorColor, scheme.primary);
      },
    );

    test(
      'DT5 onUpdate: light theme foreground roles meet WCAG AA contrast',
      () {
        final theme = AppTheme.light();
        final scheme = theme.colorScheme;
        final customColors = theme.extension<MxColorsExtension>()!;

        _expectMinimumNormalTextContrast(
          label: 'onPrimary / primary',
          foreground: scheme.onPrimary,
          background: scheme.primary,
        );
        _expectMinimumNormalTextContrast(
          label: 'onSurface / surface',
          foreground: scheme.onSurface,
          background: scheme.surface,
        );
        _expectMinimumNormalTextContrast(
          label: 'onSurfaceVariant / surface',
          foreground: scheme.onSurfaceVariant,
          background: scheme.surface,
        );
        _expectMinimumNormalTextContrast(
          label: 'onError / error',
          foreground: scheme.onError,
          background: scheme.error,
        );
        _expectMinimumNormalTextContrast(
          label: 'onSuccess / success',
          foreground: customColors.onSuccess,
          background: customColors.success,
        );
        _expectMinimumNormalTextContrast(
          label: 'onWarning / warning',
          foreground: customColors.onWarning,
          background: customColors.warning,
        );
        _expectMinimumNormalTextContrast(
          label: 'onInfo / info',
          foreground: customColors.onInfo,
          background: customColors.info,
        );
      },
    );

    test('DT6 onUpdate: dark theme foreground roles meet WCAG AA contrast', () {
      final theme = AppTheme.dark();
      final scheme = theme.colorScheme;
      final customColors = theme.extension<MxColorsExtension>()!;

      _expectMinimumNormalTextContrast(
        label: 'onPrimary / primary',
        foreground: scheme.onPrimary,
        background: scheme.primary,
      );
      _expectMinimumNormalTextContrast(
        label: 'onSurface / surface',
        foreground: scheme.onSurface,
        background: scheme.surface,
      );
      _expectMinimumNormalTextContrast(
        label: 'onSurfaceVariant / surface',
        foreground: scheme.onSurfaceVariant,
        background: scheme.surface,
      );
      _expectMinimumNormalTextContrast(
        label: 'onError / error',
        foreground: scheme.onError,
        background: scheme.error,
      );
      _expectMinimumNormalTextContrast(
        label: 'onSuccess / success',
        foreground: customColors.onSuccess,
        background: customColors.success,
      );
      _expectMinimumNormalTextContrast(
        label: 'onWarning / warning',
        foreground: customColors.onWarning,
        background: customColors.warning,
      );
      _expectMinimumNormalTextContrast(
        label: 'onInfo / info',
        foreground: customColors.onInfo,
        background: customColors.info,
      );
    });

    test('DT1 onDisplay: component shapes use soft MemoX radii', () {
      final theme = AppTheme.light();
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      final dialogShape = theme.dialogTheme.shape as RoundedRectangleBorder;
      final sheetShape = theme.bottomSheetTheme.shape as RoundedRectangleBorder;
      final fabShape =
          theme.floatingActionButtonTheme.shape as RoundedRectangleBorder;
      final snackbarShape = theme.snackBarTheme.shape as RoundedRectangleBorder;
      final menuShape =
          theme.menuTheme.style?.shape?.resolve(<WidgetState>{})
              as RoundedRectangleBorder;
      final menuButtonShape =
          theme.menuButtonTheme.style?.shape?.resolve(<WidgetState>{})
              as RoundedRectangleBorder;
      final tooltipDecoration = theme.tooltipTheme.decoration as BoxDecoration;
      final inputBorder = theme.inputDecorationTheme.enabledBorder;

      expect(AppRadius.button, AppRadius.borderLg);
      expect(AppRadius.buttonSmall, AppRadius.borderLg);
      expect(AppRadius.card, AppRadius.borderXl);
      expect(AppRadius.cardLarge, AppRadius.borderXxl);
      expect(AppRadius.dialog, AppRadius.borderXxl);
      expect(
        AppRadius.bottomSheet,
        const BorderRadius.vertical(top: AppRadius.radiusXxl),
      );
      expect(AppRadius.input, AppRadius.borderLg);
      expect(AppRadius.banner, AppRadius.borderLg);
      expect(cardShape.borderRadius, AppRadius.card);
      expect(inputBorder, isA<OutlineInputBorder>());
      expect((inputBorder as OutlineInputBorder).borderRadius, AppRadius.input);
      expect(
        theme.elevatedButtonTheme.style?.shape?.resolve(<WidgetState>{}),
        const RoundedRectangleBorder(borderRadius: AppRadius.button),
      );
      expect(dialogShape.borderRadius, AppRadius.dialog);
      expect(sheetShape.borderRadius, AppRadius.bottomSheet);
      expect(fabShape.borderRadius, AppRadius.cardLarge);
      expect(snackbarShape.borderRadius, AppRadius.banner);
      expect(menuShape.borderRadius, AppRadius.card);
      expect(menuButtonShape.borderRadius, AppRadius.buttonSmall);
      expect(tooltipDecoration.borderRadius, AppRadius.borderMd);
    });
  });

  group('AppTheme typography', () {
    test(
      'DT3 onUpdate: light theme uses Plus Jakarta Sans across theme surfaces',
      () {
        final theme = AppTheme.light();

        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AppTypography.fontFamily,
        );
        expect(
          theme.textTheme.titleLarge?.fontFamily,
          AppTypography.fontFamily,
        );
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
      },
    );

    test(
      'DT4 onUpdate: dark theme uses Plus Jakarta Sans across theme surfaces',
      () {
        final theme = AppTheme.dark();

        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AppTypography.fontFamily,
        );
        expect(
          theme.textTheme.titleLarge?.fontFamily,
          AppTypography.fontFamily,
        );
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
      },
    );

    test('DT7 onUpdate: Material 3 type scale remains fixed', () {
      final theme = AppTypography.textTheme;

      _expectTextRole(theme.displayLarge, AppTypography.displayLarge);
      _expectTextRole(theme.displayMedium, AppTypography.displayMedium);
      _expectTextRole(theme.displaySmall, AppTypography.displaySmall);
      _expectTextRole(theme.headlineLarge, AppTypography.headlineLarge);
      _expectTextRole(theme.headlineMedium, AppTypography.headlineMedium);
      _expectTextRole(theme.headlineSmall, AppTypography.headlineSmall);
      _expectTextRole(theme.titleLarge, AppTypography.titleLarge);
      _expectTextRole(theme.titleMedium, AppTypography.titleMedium);
      _expectTextRole(theme.titleSmall, AppTypography.titleSmall);
      _expectTextRole(theme.bodyLarge, AppTypography.bodyLarge);
      _expectTextRole(theme.bodyMedium, AppTypography.bodyMedium);
      _expectTextRole(theme.bodySmall, AppTypography.bodySmall);
      _expectTextRole(theme.labelLarge, AppTypography.labelLarge);
      _expectTextRole(theme.labelMedium, AppTypography.labelMedium);
      _expectTextRole(theme.labelSmall, AppTypography.labelSmall);
    });
  });
}

const double _minimumNormalTextContrast = 4.5;

void _expectMinimumNormalTextContrast({
  required String label,
  required Color foreground,
  required Color background,
}) {
  final ratio = _contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(_minimumNormalTextContrast),
    reason: '$label contrast ratio ${ratio.toStringAsFixed(2)} is below AA',
  );
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}

void _expectTextRole(TextStyle? actual, TextStyle expected) {
  expect(actual?.fontFamily, AppTypography.fontFamily);
  expect(actual?.fontSize, expected.fontSize);
  expect(actual?.fontWeight, expected.fontWeight);
  expect(actual?.height, expected.height);
  expect(actual?.letterSpacing, expected.letterSpacing);
}

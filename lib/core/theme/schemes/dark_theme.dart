import 'package:flutter/material.dart';

import '../component_themes/app_bar_theme.dart';
import '../component_themes/button_theme.dart';
import '../component_themes/card_theme.dart';
import '../component_themes/chip_theme.dart';
import '../component_themes/dialog_theme.dart';
import '../component_themes/divider_theme.dart';
import '../component_themes/icon_theme.dart';
import '../component_themes/input_theme.dart';
import '../component_themes/list_tile_theme.dart';
import '../component_themes/navigation_bar_theme.dart';
import '../component_themes/popup_menu_theme.dart';
import '../component_themes/progress_indicator_theme.dart';
import '../component_themes/scrollbar_theme.dart';
import '../component_themes/segmented_button_theme.dart';
import '../component_themes/text_selection_theme.dart';
import '../component_themes/toggle_theme.dart';
import '../component_themes/tooltip_theme.dart';
import '../extensions/theme_extensions.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Dark [ColorScheme] derived from the MemoX brand palette.
///
/// This file is the Material 3 role layer. Keep role names here aligned with
/// M3 (`primary`, `onPrimary`, `surfaceContainerHigh`, `outlineVariant`, ...),
/// while `AppColors` remains the source palette/tonal-token layer.
const ColorScheme _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.darkPrimary80,
  onPrimary: AppColors.darkOnPrimary,
  primaryContainer: AppColors.darkPrimary30,
  onPrimaryContainer: AppColors.darkPrimary90,
  secondary: AppColors.darkSecondary80,
  onSecondary: AppColors.darkSecondary20,
  secondaryContainer: AppColors.darkSecondary30,
  onSecondaryContainer: AppColors.darkSecondary90,
  tertiary: AppColors.darkTertiary80,
  onTertiary: AppColors.darkTertiary20,
  tertiaryContainer: AppColors.darkTertiary30,
  onTertiaryContainer: AppColors.darkTertiary90,
  error: AppColors.darkError80,
  onError: AppColors.darkError20,
  errorContainer: AppColors.darkError30,
  onErrorContainer: AppColors.darkError90,
  surface: AppColors.darkNavy5,
  onSurface: AppColors.darkNeutral95,
  onSurfaceVariant: AppColors.darkNeutral70,
  surfaceContainerLowest: AppColors.darkNavy10,
  surfaceContainerLow: AppColors.darkNavy15,
  surfaceContainer: AppColors.darkNavy20,
  surfaceContainerHigh: AppColors.darkNavy25,
  surfaceContainerHighest: AppColors.darkNavy30,
  surfaceDim: AppColors.darkNavyDim,
  surfaceBright: AppColors.darkNavy40,
  inverseSurface: AppColors.darkNeutral90,
  onInverseSurface: AppColors.darkNavy20,
  inversePrimary: AppColors.darkPrimary40,
  outline: AppColors.darkNavyOutline,
  outlineVariant: AppColors.darkNavyOutlineVariant,
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  surfaceTint: AppColors.darkPrimary80,
);

ThemeData buildDarkTheme() {
  const scheme = _darkScheme;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    primaryTextTheme: AppTypography.textTheme.apply(
      bodyColor: scheme.onPrimary,
      displayColor: scheme.onPrimary,
    ),
    iconTheme: IconThemeBuilder.primary(scheme),
    primaryIconTheme: IconThemeBuilder.onPrimary(scheme),
    dividerTheme: DividerThemeBuilder.build(scheme),
    appBarTheme: AppBarThemeBuilder.build(scheme),
    cardTheme: CardThemeBuilder.build(scheme),
    chipTheme: ChipThemeBuilder.build(scheme),
    dialogTheme: DialogThemeBuilder.dialog(scheme),
    bottomSheetTheme: DialogThemeBuilder.bottomSheet(scheme),
    snackBarTheme: DialogThemeBuilder.snackbar(scheme),
    inputDecorationTheme: InputThemeBuilder.build(scheme),
    elevatedButtonTheme: ButtonThemeBuilder.filled(scheme),
    filledButtonTheme: ButtonThemeBuilder.tonal(scheme),
    outlinedButtonTheme: ButtonThemeBuilder.outlined(scheme),
    textButtonTheme: ButtonThemeBuilder.text(scheme),
    iconButtonTheme: ButtonThemeBuilder.icon(scheme),
    floatingActionButtonTheme: ButtonThemeBuilder.fab(scheme),
    navigationBarTheme: NavigationBarThemeBuilder.bar(scheme),
    navigationRailTheme: NavigationBarThemeBuilder.rail(scheme),
    progressIndicatorTheme: ProgressIndicatorThemeBuilder.build(scheme),
    segmentedButtonTheme: SegmentedButtonThemeBuilder.build(scheme),
    listTileTheme: ListTileThemeBuilder.build(scheme),
    tooltipTheme: TooltipThemeBuilder.build(scheme),
    scrollbarTheme: ScrollbarThemeBuilder.build(scheme),
    switchTheme: ToggleThemeBuilder.switchTheme(scheme),
    checkboxTheme: ToggleThemeBuilder.checkbox(scheme),
    radioTheme: ToggleThemeBuilder.radio(scheme),
    sliderTheme: ToggleThemeBuilder.slider(scheme),
    popupMenuTheme: PopupMenuThemeBuilder.build(scheme),
    menuTheme: PopupMenuThemeBuilder.menu(scheme),
    menuButtonTheme: PopupMenuThemeBuilder.menuButton(scheme),
    textSelectionTheme: TextSelectionThemeBuilder.build(scheme),
    extensions: const [MxColorsExtension.dark],
  );
}
